function [cost, id] = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct, idSelected, data1)

allCost = zeros(1,3);

if( size(image1_struct,3) == 1)
    isUseColor = false;
else
    isUseColor = true;
end

for i = 1:3
    data2 = fetchColor( meshX, meshY, depthData ,image1_struct, otherImage_struct(idSelected(i)) );
    allCost(i) = computeZNCC(data1, data2, isUseColor);
end


[maxCost, maxCostIdx ] = max(allCost);

cost = maxCost;
id = idSelected(maxCostIdx);