function cost = computeZNCC(data1, data2)
% r,g,b
% global MATCH_METHOD;

   
mask = find( isnan(data2) == 0);
data1 = data1(mask);
data2 = data2(mask);
if(isempty(data1) || isempty(data2))
    %    cost = -1;
    cost = 0;
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



