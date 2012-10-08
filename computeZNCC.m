function cost = computeZNCC(data1, data2, isUseColor)
% r,g,b
% global MATCH_METHOD;
% if(all(data2 == 0))
%     cost = -10;   
% else
    
%     if( strcmp(MATCH_METHOD, 'ZNCC'))
%         c(1) = computeZNCC_oneChannel(data1(1:dataSizePerChannel), data2(1:dataSizePerChannel));
%         c(2) = computeZNCC_oneChannel(data1(dataSizePerChannel+1: dataSizePerChannel*2), data2(dataSizePerChannel+1: dataSizePerChannel*2));
%         c(3) = computeZNCC_oneChannel(data1(dataSizePerChannel*2+1: dataSize), data2(dataSizePerChannel*2+1: dataSize));
%     elseif( strcmp(MATCH_METHOD, 'NCC'))
    if(isUseColor)
        dataSize = numel(data1); 
        dataSizePerChannel = dataSize/3;
        c = zeros(1,3);
        c(1) = computeNCC_oneChannel(data1(1:dataSizePerChannel), data2(1:dataSizePerChannel));
        c(2) = computeNCC_oneChannel(data1(dataSizePerChannel+1: dataSizePerChannel*2), data2(dataSizePerChannel+1: dataSizePerChannel*2));
        c(3) = computeNCC_oneChannel(data1(dataSizePerChannel*2+1: dataSize), data2(dataSizePerChannel*2+1: dataSize));        
        cost = mean(c);
    else
        cost = computeNCC_oneChannel(data1, data2, gaussianTable);
    end
    
%     else
%         fprintf(1, 'error in choosing normalization method');
%     end    
% end
end

function cost = computeZNCC_oneChannel(data1, data2)
    
meanData1 = mean(data1);
meanData2 = mean(data2);

fenzi = sum((data1 - meanData1).*(data2 - meanData2));
fenmu = sqrt(sum((data1 - meanData1).^2) .* sum((data2 - meanData2).^2));
cost = fenzi/(fenmu + eps);

end

function cost = computeNCC_oneChannel(data1, data2)

mask = find( isnan(data2) == 0);
data1 = data1(mask);
data2 = data2(mask);
if(isempty(data1) || isempty(data2))
   cost = -1; 
   return;
end
data1 = data1 - mean(data1);
data2 = data2 - mean(data2);

if(all(data1 == 0) || all(data2 == 0))
    cost = 0;
    return;
end
data1 = data1./norm(data1);
data2 = data2./norm(data2);

cost = dot(data1, data2);


end

