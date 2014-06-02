function [orientationMap, depthMap, costMap] = LeftToRight(orientationMap, image1_struct, otherImage_struct, depthMap, mapDistribution, costMap, halfWindowSize)

global far; global near;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1, 'starting left to right...\n');
% parfor row = 1:h
for row = 1:h
    fprintf(1, 'row: %d\n', row);
    mapDistributionOneRow = mapDistribution(row,:,:);        
    costMapOneRow = costMap(row,:,:);    
    [emptyMap(row, :), updatedCost]=routine_LeftRight(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize);    
    costMap(row,:,:) = updatedCost;
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end

%         alpha = zeros( 2,width );
%         alpha(1,1) = emission(1);
%         alpha(2,1) = emission_uniform;
%         for i = 2:width
%             alpha(1,i) = emission(i) * ( alpha(1,i-1) * transitionProb(1,1) + alpha(2,i-1)*transitionProb(2,1) );
%             alpha(2,i) = emission_uniform * ( alpha(1,i-1) * transitionProb(1,2) + alpha(2,i-1)*transitionProb(2,2) );
%             Z = ( alpha(1,i) + alpha(2,i) );
%             alpha(1,i) = alpha(1,i)/Z;
%             alpha(2,i) = alpha(2,i)/Z;            
%         end
%         alpha = alpha.*beta;
%         distributionMapARow(1,:,imageIdx) = alpha(1,:)./( alpha(1,:) + alpha(2,:) );

%  using the old depth, to compute the forward message, and then use that
%  to update the depth, and then update the forward message. compute the
%  probability, 

function [oneRow,updatedCost] = routine_LeftRight(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize)
    [h,w,~] = size(image1_struct.imageData);   
    numOfSourceImgs = numel(otherImage_struct);
    updatedCost = zeros(1, w, numOfSourceImgs);
    updatedCost(1,1,:) = costMapOneRow(1,1,:);
    
    
     sigma = 0.45;
     constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
     transitionProb = [0.9999,0.0001; 0.0001, 0.9999];
     emission = constant * exp( -( 1-costMapOneRow(1,1,:) ).^2/(2*sigma*sigma) ); %compute the cost of 1st variable
     emission_uniform = 0.5;
     alpha = [emission; repmat(emission_uniform,size(emission)) ]; alpha = alpha./repmat((alpha(1,:,:) + alpha(2,:,:)), 2, 1);
%         alpha(1,1) = emission;
%          alpha(2,1) = emission_uniform;
     
    for col = 2:w    
%         compute alpha, and compute probability, and then update depth
%           alpha(1,i) = emission(i) * ( alpha(1,i-1) * transitionProb(1,1) + alpha(2,i-1)*transitionProb(2,1) );
%             alpha(2,i) = emission_uniform * ( alpha(1,i-1) * transitionProb(1,2) + alpha(2,i-1)*transitionProb(2,2) );
        emission = constant * exp( -( 1-costMapOneRow(:,col,:) ).^2/(2*sigma*sigma) );
        alpha_new = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha_new = alpha_new./ repmat((alpha_new(1,:,:) + alpha_new(2,:,:)), [2,1,1] );
        prob = [alpha_new .* [mapDistributionOneRow(1,col,:); 1-mapDistributionOneRow(1,col,:)] ];        
        mapDistributionOneRow(1,col,:) = prob(1,:,:) ./ (prob(1,:,:) + prob(2,:,:));
        
%         ------------------------------------------------------------------------------------------------
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
             mapDistributionOneRow(1,col,:) );
        updatedCost(1,col,:) = reshape(costWithBestDepth, 1,1,numOfSourceImgs);
        depthMap(row, col) = bestDepth;
        
    end
    oneRow = depthMap(row,:);   
    
end