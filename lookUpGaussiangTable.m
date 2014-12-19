function prob = lookUpGaussiangTable(value, table )
theStart = -2; theEnd = 2;
N = 400;
% ---------------------------------------------------

step = (theEnd - theStart)/N;
if(value < theStart)
    value = theStart;  
end
if(value > theEnd)
    value = theEnd;
end
ind = floor( (value - theStart) ./ step) + 1;

%  if(any(ind(:) > 400) || any(ind(:) <= 0))
%      ind
%  end
ind(ind == 401) = 400;

prob = table(ind);

error('this file should not be executed\n');
% probLog














