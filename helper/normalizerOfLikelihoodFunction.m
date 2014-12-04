function test

sigma = 0.45;

% constant = 4/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
 constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
% constant = sqrt(2*pi)*sigma/2*erf(sqrt(2)/sigma);
% constant = 1/constant;

%  1 / sqrt(2 * 3.14159265358f)/sqrt(SPMAlphaSquare)  / ( 0.5 * erff( 2.0f /sqrt(SPMAlphaSquare)/1.414213562) );
% emission =  exp( -0.5 * emission * emission/SPMAlphaSquare) * constNorm;
range = 2;
% constant = sqrt(pi*2) * sigma/2 * erf(range/sqrt(2)/sigma);
% constant = 1/constant
% x = range;
% A =  (2^(1/2)*pi^(1/2)*erf((2^(1/2)*x*(1/sigma^2)^(1/2))/2))/(2*(1/sigma^2)^(1/2));
% constant = (sqrt(pi*2) * erf((sqrt(2) * x /sigma)/2))/(2 / sigma);
% constant = (2^(1/2)*pi^(1/2)*erf((2^(1/2)*x*(1/sigma^2)^(1/2))/2))/(2*(1/sigma^2)^(1/2));
% constant = 1/constant;

numOfseg = 20000;
v = linspace( 0,range, numOfseg+1);

emission = constant * exp( -(  v ).^2/(2 * sigma * sigma) );
figure(); plot(v, emission); axis equal;

sum((emission(1:end-1) + emission(2:end)) * range/numOfseg / 2)

%  sum(emission / numOfseg)



% %  --------------------------------------------------------------------
% sym t;

% f = @(t) exp(-t^2/2/sigma/sigma);

syms x t sigma
%  f = exp( -t^2/(2*sigma*sigma) );
f = exp( -t^2/(2*sigma^2) );
A = int(f, t, 0, x);

vpa( subs(A, [sigma,x], [0.45,2]) ) 

f = subs(f, sigma, 0.45);
A_val = vpa(int(f, t, 0, 2));


