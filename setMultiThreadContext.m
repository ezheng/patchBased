function setMultiThreadContext(isUseMultipleCore, numWorkers)

poolobj = gcp('nocreate'); % If no pool, do not create new one.

% if numWorers does not change, and the pool exist, do nothing
if (~isempty(poolobj)) && (poolobj.NumWorkers == numWorkers) && isUseMultipleCore
    return;
end

% if the pool exist, delete it
if(~isempty(poolobj))
    delete(poolobj);   
end

% if I need to use multiple cores, then create one. Otherwise just use one
% core
if(isUseMultipleCore)
    parpool(numWorkers);    
end