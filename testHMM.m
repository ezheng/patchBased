function testHMM
% http://www.mathworks.com/help/stats/hidden-markov-models-hmm.html#f10328

tr = [0.95,0.05;
              0.10,0.90];
            
e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
              1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
seqLength = 10000;
          
[seq, states] = hmmgenerate(seqLength,tr,e);

% [pStates, LOGPSEQ ]= hmmdecode(seq,tr,e);
[pStates2, LOGPSEQ, FORWARD, BACKWARD, s] = hmmdecode(seq,tr,e);
% [PSTATES, LOGPSEQ, FORWARD, BACKWARD, S] = HMMDECODE(SEQ,TR,E)
a = tr(1); c = tr(2); b = tr(3); d = tr(4);
% newTr = [0, (d-c)/(a-c-b+d), (a-b)/(a-c-b+d);zeros(size(tr,1),1), tr ]; 
newTr = [0, 0.5, 0.5 ;zeros(size(tr,1),1), tr ]; 
newE = [ zeros(1,size(e,2)); e ];
tic
[pStates, LOGPSEQ, FORWARD, BACKWARD, s] = hmmdecode(seq,newTr,newE);
pStates = pStates(2:end,:); 
FORWARD = FORWARD(2:end,:); BACKWARD = BACKWARD(2:end,:);
% [pStates2, LOGPSEQ, FORWARD, BACKWARD, s] = hmmdecode(seq,tr,e);
toc
%  f = FORWARD.*repmat(cumprod(s),size(FORWARD,1),1);
%    bscale = fliplr(cumprod(fliplr(s)));
%  b = BACKWARD.*repmat([bscale(2:end), 1],size(BACKWARD,1),1);


% test hidden markov model. Do the coding myself.

% compute the forward message
tic
alpha = zeros( 2,seqLength );
 alpha(1,1) = e(1, seq(1) ) ;
 alpha(2,1) = e(2, seq(1) ) ;
% alpha(1,1) = e(1, seq(1)  ) * ( 1.0 * tr(1,1) + 0.0 * tr(2,1) );
% alpha(2,1) = e(2, seq(1)  ) * (1.0 * tr(1,2) + 0.0 * tr(2,2) );
Z = alpha(1,1) + alpha(2,1);
alpha(1,1) = alpha(1,1) / Z;
alpha(2,1) = alpha(2,1) / Z;
% compute the backward message
for i = 2:seqLength
    alpha(1,i) = e(1, seq(i) ) * ( alpha(1,i-1) * tr(1,1) + alpha(2,i-1)*tr(2,1) );
    alpha(2,i) = e(2, seq(i) ) * ( alpha(1,i-1) * tr(1,2) + alpha(2,i-1)*tr(2,2) );
    Z = ( alpha(1,i) + alpha(2,i) );
    alpha(1,i) = alpha(1,i)/Z;
    alpha(2,i) = alpha(2,i)/Z;
%     alpha(1:2,i) = alpha(1:2,i)/(alpha(1,i)+alpha(2,i));
end

beta = zeros(2, seqLength);
beta(1,end) = 0.5;
beta(2,end) = 0.5;
for i = seqLength-1:-1:1
    beta(1, i) = beta(1,i+1)*e(1, seq(i+1))*tr(1,1) + beta(2,i+1)*e(2, seq(i+1))*tr(1,2);
    beta(2, i) = beta(1,i+1)*e(1, seq(i+1))*tr(2,1) + beta(2,i+1)*e(2, seq(i+1))*tr(2,2);
    Z = beta(1,i) + beta(2,i);
    beta(1,i) = beta(1,i)/Z;
    beta(2,i) = beta(2,i)/Z;
%     beta(1:2,i) = beta(1:2,i)/(beta(1,i)+beta(2,i));
end
prob = alpha .* beta;
prob = prob ./ repmat(sum(prob), 2,1);
toc
BACKWARD = BACKWARD ./ repmat(sum(BACKWARD), 2, 1); BACKWARD = BACKWARD(:, 2:end);
figure(1); plot(abs(BACKWARD(:)-beta(:) ) );
FORWARD = FORWARD ./ repmat(sum(FORWARD), 2, 1); FORWARD = FORWARD(:,2:end);
figure(2); plot(abs(FORWARD(:)-alpha(:) ) );
figure(3); plot(abs(prob(:) - pStates(:) ))
