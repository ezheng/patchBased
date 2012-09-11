function cost = computeZNCC(data1, data2)
% r,g,b
if(all(data2 == 0))
    cost = -2;   
else
    c = zeros(1,3);
    c(1) = compteZNCC_oneChannel(data1(1:3:end), data2(1:3:end));
    c(2) = compteZNCC_oneChannel(data1(2:3:end), data2(2:3:end));
    c(3) = compteZNCC_oneChannel(data1(3:3:end), data2(3:3:end));
    cost = mean(c);
end
end

function cost = compteZNCC_oneChannel(data1, data2)
    
meanData1 = mean(data1);
meanData2 = mean(data2);

fenzi = sum((data1 - meanData1).*(data2 - meanData2));
fenmu = sqrt(sum((data1 - meanData1).^2) .* sum((data2 - meanData2).^2));
cost = fenzi/(fenmu + eps);

end

