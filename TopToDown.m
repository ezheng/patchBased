function [ depthMap, costMap, mapDistribution] = TopToDown( image1_struct, otherImage_struct, depthMap, mapDistribution, costMap, halfWindowSize, near, far,sigma,prob,NCCDistribution)

h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1, 'starting top to down...\n');

parfor col = 1:w    
   % fprintf(1, 'col: %d\n', col);
    mapDistributionOneCol = mapDistribution(:,col,:);
     costMapOneCol = costMap(:,col,:);  
    [emptyMap(:, col), costMap(:,col,:), mapDistribution(:,col,:)] = routine_TopDown(randMap, mapDistributionOneCol, costMapOneCol, image1_struct, otherImage_struct, depthMap, col, halfWindowSize,sigma,prob,NCCDistribution);
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end

%  using the old depth, to compute the forward message, and then use that
%  to update the depth, and then update the forward message. compute the
%  probability, 

function [oneCol, costMapOneCol, mapDistributionOneCol] = routine_TopDown(randMap, mapDistributionOneCol, costMapOneCol, image1_struct, otherImage_struct, depthMap, col, halfWindowSize,sigma,prob,NCCDistribution)
    [h,w,~] = size(image1_struct.imageData);
    numOfSourceImgs = numel(otherImage_struct);
%     updatedCost = zeros(h, 1, numOfSourceImgs);
%     updatedCost(1,1,:) = costMapOneCol(1,1,:);    

    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
    transitionProb = [prob,1-prob; 1-prob, prob];
    emission = constant * exp( -( 1-costMapOneCol(1,1,:) ).^2/(2*sigma*sigma) ); %compute the cost of 1st variable
%     emission_uniform = 0.5;
     numOfBins = numel(NCCDistribution)-2;    
     emission_uniform = NCCDistribution(floor((1 - costMapOneCol(1,1,:))/ (2/numOfBins))+2);
 
     alpha = [emission; emission_uniform]; alpha = alpha./repmat((alpha(1,:,:) + alpha(2,:,:)), 2, 1);

    for row = 2:h   
%       compute alpha, and compute probability, and then update depth
        
        emission = constant * exp( -( 1-costMapOneCol(row,1,:) ).^2/(2*sigma*sigma) );
        emission_uniform = NCCDistribution(floor((1 - costMapOneCol(row,1,:))/ (2/numOfBins))+2);
        alpha_new = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha_new = alpha_new./ repmat((alpha_new(1,:,:) + alpha_new(2,:,:)), [2,1,1] );
        forward_backward_prob = [alpha_new .* [mapDistributionOneCol(row,1,:); 1-mapDistributionOneCol(row,1,:)] ];        
        distribution = forward_backward_prob(1,:,:) ./ (forward_backward_prob(1,:,:) + forward_backward_prob(2,:,:));
        
%  -----------------------------------------------------------------------------------
        rowStart = max(1, row - halfWindowSize); rowEnd = min(h, row + halfWindowSize);
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);
%  ----------------------------- Get the color of the reference image
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%  -------------------------
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);

        numOfElem = (rowEnd - rowStart + 1) * (colEnd - colStart + 1);
        depthData = zeros( numOfElem, 3);   
        depthData(:,1) = depthMap(row-1, col);       
        depthData(:,2) = randMap(row,col);
        depthData(:,3) = depthMap(row, col);
% -------------------------------------------------------------------------        
        [bestDepth, costWithBestDepth] = costCalculationGiveId(costMapOneCol(row,1,:), meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
           distribution);
        costMapOneCol(row,1,:) = reshape(costWithBestDepth, 1, 1, numOfSourceImgs);
        depthMap(row, col) = bestDepth;
        
    %       update alpha
        emission = constant * exp( -( 1-costMapOneCol(row,:,:) ).^2/(2*sigma*sigma) );
        emission_uniform = NCCDistribution(floor((1 - costMapOneCol(row,1,:))/ (2/numOfBins))+2);
        alpha = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha = alpha./ repmat((alpha(1,:,:) + alpha(2,:,:)), [2,1,1] );        
        %       compute and  save the new forward-backward message
        forward_backward_prob = [alpha .* [mapDistributionOneCol(row,1,:); 1-mapDistributionOneCol(row,1,:)] ];
        mapDistributionOneCol(row,1,:) = forward_backward_prob(1,:,:) ./ (forward_backward_prob(1,:,:) + forward_backward_prob(2,:,:));

    end    
    oneCol = depthMap(:,col);
    
end