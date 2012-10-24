function probWithBestDepth = calculateProb(cost)

sigma = 0.2;
probWithBestDepth = exp(-0.5 .* (cost./sigma).^2);
















