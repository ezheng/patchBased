function cost = addBinaryCost(uniaryCost, newDepth, neighborDepth)

weight = 0.005;
cost = uniaryCost - abs(newDepth - neighborDepth) * weight;








