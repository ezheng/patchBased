function cost = addBinaryCost(uniaryCost, newDepth, neighborDepth)

weight = 0.1;
cost = uniaryCost - abs(newDepth - neighborDepth) * weight;








