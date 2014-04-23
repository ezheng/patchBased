function cosDistribution


x = rand(100000000,1)*2 * pi;

y = cos(x);

figure(1); hist(y, [-1:0.001:1]);














