function backwardMap = backwardMessage_row_right2leftProp(costMap, sigma, prob)

backwardMap = zeros( size(costMap) );

tic
parfor row = 1: size(costMap,1)
    backwardMap(row,:,:) = distributionMapComputation_route(costMap, row, sigma, prob);
end
fprintf(1, 'SPM computation time: %d seconds\n', toc);
end


function distributionMapARow = distributionMapComputation_route(costMap, row, sigma, prob)

    [~, width, numOfSourceImages] = size(costMap);
    distributionMapARow = zeros(1, width, numOfSourceImages);    
        
    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
%     transitionProb = [0.9999,0.0001; 0.0001, 0.9999];
     transitionProb = [prob,1-prob; 1-prob, prob];
%   emission prob?, compute based on the cost function?
    
    for imageIdx = 1:numOfSourceImages
%         compute emission
        emission = constant * exp( -( 1-costMap(row,:,imageIdx) ).^2/(2*sigma*sigma) );      % note teh 1-NCC here. 
        emission_uniform = 0.5;
        
%       compute backward message
%         beta = zeros(2, width);
%         beta(1:2,end) = 0.5;        
%         for i = width-1:-1:1
%             beta(1, i) = beta(1,i+1) * emission(i+1) * transitionProb(1,1) + beta(2,i+1)* emission_uniform * transitionProb(1,2);
%             beta(2, i) = beta(1,i+1) * emission(i+1) * transitionProb(2,1) + beta(2,i+1)* emission_uniform * transitionProb(2,2);
%             Z = beta(1,i) + beta(2,i);
%             beta(1,i) = beta(1,i)/Z;
%             beta(2,i) = beta(2,i)/Z;            
%         end    
        
        beta = zeros(2,width);
        beta(1:2,1) = 0.5;
        for i = 2:1:width
            beta(1,i) = beta(1,i-1) * emission(i-1) * transitionProb(1,1) + beta(2,i-1)* emission_uniform * transitionProb(1,2);
            beta(2,i) = beta(1,i-1) * emission(i-1) * transitionProb(2,1) + beta(2,i-1)* emission_uniform * transitionProb(2,2);
            Z = beta(1,i) + beta(2,i);
            beta(1,i) = beta(1,i)/Z;
            beta(2,i) = beta(2,i)/Z;
        end

        distributionMapARow(1, :, imageIdx) = beta(1,:);
    end
    
end

