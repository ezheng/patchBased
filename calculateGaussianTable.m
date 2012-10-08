function gaussianTable = calculateGaussianTable()


sigma = 0.2;
theStart = -2; theEnd = 2;
N = 400;
% --------------------------------------------------------
step  = (theEnd - theStart)/ N;
halfStep = step / 2;
range = linspace(theStart + halfStep, theEnd - halfStep, N);
% range = [-2: 0.01: 2]
gaussianTable = exp(-0.5 .* (range./sigma).^2);
gaussianTable = gaussianTable / sum(gaussianTable);


% x = 1;
% ind = floor( (x - theStart) / step);
% gaussian(ind);





















