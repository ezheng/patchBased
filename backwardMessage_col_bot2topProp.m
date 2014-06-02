function backwardMap = backwardMessage_col_bot2topProp(costMap)

backwardMap = zeros( size(costMap) );

% for row = 1: size(costMap,1)
sigma = 0.45;
tic
% parfor row = 1: size(costMap,1)
for col = 1: size(costMap,2)
%     fprintf(1, 'row: %d\n', row);
    backwardMap(:,col,:) = distributionMapComputation_route(costMap, col, sigma);
end
fprintf(1, 'SPM computation time: %d seconds\n', toc);
end


function distributionMapACol = distributionMapComputation_route(costMap, col, sigma)

    [height, ~, numOfSourceImages] = size(costMap);
    distributionMapACol = zeros(height, 1, numOfSourceImages);    
        
    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
    transitionProb = [0.9999,0.0001; 0.0001, 0.9999];
%   emission prob?, compute based on the cost function?
    
    for imageIdx = 1:numOfSourceImages
%         compute emission
        emission = constant * exp( -( 1-costMap(:,col,imageIdx) ).^2/(2*sigma*sigma) );      % note teh 1-NCC here. 
        emission_uniform = 0.5;
        
%       compute backward message
%         beta = zeros(height, 2);
%         beta(end, 1:2) = 0.5;            
%         for i = height - 1: -1 : 1
%            beta(i,1) = beta(i+1,1) * emission(i+1) * transitionProb(1,1) + beta(i+1,2)*emission_uniform * transitionProb(1,2); 
%            beta(i,2) = beta(i+1,1) * emission(i+1) * transitionProb(2,1) + beta(i+1,2)*emission_uniform * transitionProb(2,2);
%             Z = beta(i,1) + beta(i,2);
%             beta(i,1) = beta(i,1)/Z;
%             beta(i,2) = beta(i,2)/Z;
%         end       

        beta = zeros(height,2);
        beta(1,1:2) = 0.5;
        for i = 2:1:height
            beta(i,1) = beta(i-1,1)*emission(i-1) * transitionProb(1,1) + beta(i-1,2)*emission_uniform * transitionProb(1,2);
            beta(i,2) = beta(i-1,1)*emission(i-1) * transitionProb(2,1) + beta(i-1,2)*emission_uniform * transitionProb(2,2);
            Z = beta(i,1) + beta(i,2);
            beta(i,1) = beta(i,1)/Z;
            beta(i,2) = beta(i,2)/Z;
        end

        distributionMapACol(:, 1, imageIdx) = beta(:,1);
    end
    
end

