function test_parfor

%   matlabpool open;
tic;
M = 200; seed = 0; N = 2000;
eigValue = zeros(N, 1);
parfor i=1:N
    eigValue(i) = largestEigenvalue(M, seed);
end
t = toc;
fprintf(1, 'elapsed time is: %10f\n', t);
%   matlabpool close;


end


function y = largestEigenvalue(M, seed)
RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', seed));
y = max(eig(rand(M)));
end