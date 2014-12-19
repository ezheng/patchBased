function [ depthMap, costMap,mapDistribution] = LeftToRight( image1_struct, otherImage_struct, depthMap, mapDistribution, costMap, halfWindowSize, near, far,sigma,prob,NCCDistribution)

h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1, 'starting left to right...\n');

parfor row = 1:h
%     fprintf(1, 'row: %d\n', row);
    mapDistributionOneRow = mapDistribution(row,:,:);        
    costMapOneRow = costMap(row,:,:);    
    [emptyMap(row, :), costMap(row,:,:), mapDistribution(row,:,:)]=routine_LeftRight(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize,sigma,prob,NCCDistribution);    
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end

%  using the old depth, to compute the forward message, and then use that
%  to update the depth, and then update the forward message. compute the
%  probability, 

function [oneRow,costMapOneRow, mapDistributionOneRow] = routine_LeftRight(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize,sigma,prob,NCCDistribution)
    [h,w,~] = size(image1_struct.imageData);   
    numOfSourceImgs = numel(otherImage_struct);
%     updatedCost = zeros(1, w, numOfSourceImgs);
%     updatedCost(1,1,:) = costMapOneRow(1,1,:);  % the cost of the first pixel does not change    
    
     constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
     transitionProb = [prob,1-prob; 1-prob, prob];
     emission = constant * exp( -( 1-costMapOneRow(1,1,:) ).^2/(2*sigma*sigma) ); %compute the cost of 1st variable
%      emission_uniform = 0.5;
     numOfBins = numel(NCCDistribution)-2;    
     emission_uniform = NCCDistribution(floor((1 - costMapOneRow(1,1,:))/ (2/numOfBins))+2);
     
     alpha = [emission; emission_uniform ]; alpha = alpha./repmat((alpha(1,:,:) + alpha(2,:,:)), 2, 1);
     
    for col = 2:w    
%       compute alpha, and compute probability, and then update depth

        emission = constant * exp( -( 1-costMapOneRow(:,col,:) ).^2/(2*sigma*sigma) );
        emission_uniform = NCCDistribution(floor((1 - costMapOneRow(1,col,:))/ (2/numOfBins))+2);
        alpha_new = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha_new = alpha_new./ repmat((alpha_new(1,:,:) + alpha_new(2,:,:)), [2,1,1] );
        forward_backward_prob = [alpha_new .* [mapDistributionOneRow(1,col,:); 1-mapDistributionOneRow(1,col,:)] ];        
        distribution = forward_backward_prob(1,:,:) ./ (forward_backward_prob(1,:,:) + forward_backward_prob(2,:,:));

%       ------------------------------------------------------------------------------------------------
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);         
        rowStart = max(1, row - halfWindowSize); rowEnd = min(h, row + halfWindowSize);
%       ----------------------------- Get the color of the reference image
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%       ------------------------ Generate the depth candidate
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);

        numOfElem = (rowEnd - rowStart + 1) * (colEnd - colStart + 1);        
        depthData = zeros( numOfElem, 3);   
        depthData(:,1) = depthMap(row, col-1); 
        depthData(:,2) = randMap(row, col);
        depthData(:,3) = depthMap(row, col);    % the 3rd column is current depth.       
%       ------------------------- compute the cost and generate the best depth given
        [bestDepth,costWithBestDepth] = costCalculationGiveId(costMapOneRow(1,col,:), meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
            distribution);
        costMapOneRow(1,col,:) = reshape(costWithBestDepth, 1,1,numOfSourceImgs);
        depthMap(row, col) = bestDepth;       
        
%       update alpha
        emission = constant * exp( -( 1-costMapOneRow(:,col,:) ).^2/(2*sigma*sigma) );
        emission_uniform = NCCDistribution(floor((1 - costMapOneRow(1,col,:))/ (2/numOfBins))+2);        
        alpha = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha = alpha./ repmat((alpha(1,:,:) + alpha(2,:,:)), [2,1,1] ); 
        %          compute and  save the new forward-backward message
        forward_backward_prob = [alpha .* [mapDistributionOneRow(1,col,:); 1-mapDistributionOneRow(1,col,:)] ];
        mapDistributionOneRow(1,col,:) = forward_backward_prob(1,:,:) ./ (forward_backward_prob(1,:,:) + forward_backward_prob(2,:,:));
        
    end
    oneRow = depthMap(row,:);   
    
end