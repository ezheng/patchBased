function [ depthMap, costMap] = RightToLeft( image1_struct, otherImage_struct, depthMap, mapDistribution, costMap, halfWindowSize, near, far,sigma,prob)

h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1,'starting right to left...\n');

parfor row = 1:h
    %fprintf(1, 'row: %d\n', row);
    mapDistributionOneRow = mapDistribution(row,:,:); 
    costMapOneRow = costMap(row,:,:);
    [emptyMap(row, :), costMap(row,:,:) ] = routine_RightLeft(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize,sigma,prob);
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end

%  using the old depth, to compute the forward message, and then use that
%  to update the depth, and then update the forward message. compute the
%  probability, 

function [oneRow,costMapOneRow] = routine_RightLeft(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize,sigma,prob)
    [h,w,~] = size(image1_struct.imageData);
    numOfSourceImgs = numel(otherImage_struct);
%     updatedCost = zeros(1, w, numOfSourceImgs);
%      updatedCost(1,w,:) = costMapOneRow(1,w,:);
     
    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
    transitionProb = [prob,1-prob; 1-prob, prob];
    emission = constant * exp( -( 1-costMapOneRow(1,w,:) ).^2/(2*sigma*sigma) ); %compute the cost of the last variable   
    emission_uniform = 0.5;
    alpha = [emission; repmat(emission_uniform,size(emission)) ]; alpha = alpha./repmat((alpha(1,:,:) + alpha(2,:,:)), 2, 1);
    
    for col = w-1 : -1 : 1        
%       compute alpha, and compute probability, and then update depth

        emission = constant * exp( -( 1-costMapOneRow(:,col,:) ).^2/(2*sigma*sigma) );       
        alpha_new = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha_new = alpha_new./ repmat((alpha_new(1,:,:) + alpha_new(2,:,:)), [2,1,1] );
        forward_backward_prob = [alpha_new .* [mapDistributionOneRow(1,col,:); 1-mapDistributionOneRow(1,col,:)] ];
        distribution = forward_backward_prob(1,:,:) ./ (forward_backward_prob(1,:,:) + forward_backward_prob(2,:,:));
        
%       --------------------------------------------------------------------------------
        colStart = min(w, col + halfWindowSize); colEnd = max(1, col - halfWindowSize);
        rowStart = max(1, row - halfWindowSize); rowEnd = min(h, row + halfWindowSize);
%       ----------------------------- Get the color of the reference image                
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart: -1 :colEnd,:); 
        data1 = data1(:);
%       ------------------------
        [meshX, meshY] = meshgrid(colStart:-1:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);

        numOfElem = (rowEnd - rowStart + 1) * (colStart - colEnd + 1);
        depthData = zeros( numOfElem, 3);   
        depthData(:, 1) = depthMap(row, col+1);       
        depthData(:, 2) = randMap(row, col);
        depthData(:, 3) = depthMap(row, col); % the 3rd column is current depth.    
% ----------------------------------------------------------------------------------------------------        
       [bestDepth,costWithBestDepth] = costCalculationGiveId(costMapOneRow(1,col,:), meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
             distribution );
       costMapOneRow(1,col,:) = reshape(costWithBestDepth, 1,1,numOfSourceImgs);
       depthMap(row, col) = bestDepth;
        
       %       update alpha
       emission = constant * exp( -( 1-costMapOneRow(:,col,:) ).^2/(2*sigma*sigma) );
       alpha = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
       alpha = alpha./ repmat((alpha(1,:,:) + alpha(2,:,:)), [2,1,1] );
       
    end
    oneRow = depthMap(row,:);

end