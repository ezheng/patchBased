function [cost, id] = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct, idSelected, data1)

allCost = zeros(1,3);

for i = 1:3
    data2 = fetchColor( meshX, meshY, depthData ,image1_struct, otherImage_struct(idSelected(i)) );
    allCost(i) = computeZNCC(data1, data2);
end


[maxCost, maxCostIdx ] = max(allCost);

cost = maxCost;
id = idSelected(maxCostIdx);