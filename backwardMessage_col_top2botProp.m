function backwardMap = backwardMessage_col_top2botProp(costMap, sigma, prob)

backwardMap = zeros( size(costMap) );

% for row = 1: size(costMap,1)
% sigma = 0.45;
tic
parfor col = 1: size(costMap,2)
    backwardMap(:,col,:) = distributionMapComputation_route(costMap, col, sigma, prob);
end
fprintf(1, 'SPM computation time: %d seconds\n', toc);
end


function distributionMapACol = distributionMapComputation_route(costMap, col, sigma,prob)

    [height, ~, numOfSourceImages] = size(costMap);
    distributionMapACol = zeros(height, 1, numOfSourceImages);    
        
    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
     transitionProb = [prob,1-prob; 1-prob, prob];

    
    for imageIdx = 1:numOfSourceImages
%         compute emission
        emission = constant * exp( -( 1-costMap(:,col,imageIdx) ).^2/(2*sigma*sigma) );      % note the 1-NCC here. 
        emission_uniform = 0.5;
        
%       compute backward message
        beta = zeros(height, 2);
        beta(end, 1:2) = 0.5;    
        
        for i = height - 1: -1 : 1
           beta(i,1) = beta(i+1,1) * emission(i+1) * transitionProb(1,1) + beta(i+1,2)*emission_uniform * transitionProb(1,2); 
           beta(i,2) = beta(i+1,1) * emission(i+1) * transitionProb(2,1) + beta(i+1,2)*emission_uniform * transitionProb(2,2);
            Z = beta(i,1) + beta(i,2);
            beta(i,1) = beta(i,1)/Z;
            beta(i,2) = beta(i,2)/Z;
        end       
        
%       compute forward message
         alpha = zeros(height, 2 );
        alpha(1,1) = emission(1);
        alpha(1,2) = emission_uniform;
        for i = 2:height
            alpha(i,1) = emission(i) * ( alpha(i-1,1) * transitionProb(1,1) + alpha(i-1,2)*transitionProb(2,1) );
            alpha(i,2) = emission_uniform * ( alpha(i-1,1) * transitionProb(1,2) + alpha(i-1,2)*transitionProb(2,2) );
            Z = ( alpha(i,1) + alpha(i,2) );
            alpha(i,1) = alpha(i,1)/Z;
            alpha(i,2) = alpha(i,2)/Z;            
        end        
        alpha = alpha.*beta;        
        distributionMapACol(:,1,imageIdx) = alpha(:,1)./( alpha(:,1) + alpha(:,2) );

%         distributionMapACol(:, 1, imageIdx) = beta(:,1);
    end
    
end
