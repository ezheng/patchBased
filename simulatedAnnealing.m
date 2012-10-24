function choice = simulatedAnnealing(newCost, bestCost, T)

%  true means to use the newCost
if(newCost > bestCost)
    choice = true;
else
    prob = exp((newCost - bestCost )/(T + eps));
    sample = rand(1);
    if(sample> prob)
        choice = false;
    else
        choice = true;
    end
end


