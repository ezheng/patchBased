function backwardMap = backwardMessage_row_left2rightProp(costMap, sigma, prob,NCCDistribution)

backwardMap = zeros( size(costMap) );

tic;
parfor row = 1: size(costMap,1)
    backwardMap(row,:,:) = distributionMapComputation_route(costMap, row, sigma, prob,NCCDistribution);
end
fprintf(1, 'SPM computation time: %d seconds\n', toc);
end


function distributionMapARow = distributionMapComputation_route(costMap, row, sigma, prob,NCCDistribution)

    [~, width, numOfSourceImages] = size(costMap);
    distributionMapARow = zeros(1, width, numOfSourceImages);    
%          constNorm = 1 / sqrt(2 * 3.14159265358f)/sqrt(SPMAlphaSquare)  / ( 0.5 * erff( 2.0f /sqrt(SPMAlphaSquare)/1.414213562) );
    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
    transitionProb = [prob,1-prob; 1-prob, prob];
%   emission prob?, compute based on the cost function?
    
    numOfBins = numel(NCCDistribution)-2;    

    for imageIdx = 1:numOfSourceImages
%         compute emission
        emission = constant * exp( -( 1-costMap(row,:,imageIdx) ).^2/(2*sigma*sigma) );      % note teh 1-NCC here. 
%         emission_uniform = 0.5;
        
%         if(any(costMap(row,:,imageIdx)>1) || any(costMap(row,:,imageIdx)<-1) )
%              costMap
%         end
        
        emission_uniform = NCCDistribution(floor((1 - costMap(row,:,imageIdx))/ (2/numOfBins))+2);
       
%       compute backward message
        beta = zeros(2, width);
        beta(1:2,end) = 0.5;        
        for i = width-1:-1:1
            beta(1, i) = beta(1,i+1) * emission(i+1) * transitionProb(1,1) + beta(2,i+1)* emission_uniform(i+1) * transitionProb(1,2);
            beta(2, i) = beta(1,i+1) * emission(i+1) * transitionProb(2,1) + beta(2,i+1)* emission_uniform(i+1) * transitionProb(2,2);
            Z = beta(1,i) + beta(2,i);
            beta(1,i) = beta(1,i)/Z;
            beta(2,i) = beta(2,i)/Z;  
        end     
        
%       compute forward message
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
        
        distributionMapARow(1, :, imageIdx) = beta(1,:);
        
    end    
end

