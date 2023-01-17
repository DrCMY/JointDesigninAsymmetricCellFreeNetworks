function [params,C] = ParamInit_v04()

epsx = 1e-3;                    % Round-off threshold. 
epsSVM = 1e-2;                            % SVM border - to be done. 1e-2 w/o YN, 1e-3 w/o YN, 0.35 w/ YN at -10 dB
itersp = 10;

%%
% Algorithm parameters - Fixed variables
diagflag = 0;
inparms = double.empty;
exactflag = 1;

%% 
% Note that the maximum length of parameters to be tested is limited to params.randPoints = 128
m = [1e-2 1e-3];
n = [-2 0];
RangeP0 = 1;     % For mu
RangeP1a = m;  % For alpha 
RangeP1b = m;  % For beta
RangeP2a = m;  % For soft p 
RangeP2b = m;  % For soft q
RangeGr  = 1:2;      % Number of groups: 2.^range
p = n;  % Non-linearity parameters
q = n;  % Non-linearity parameters
outiter = 2e2;
initer = 2e1;

params.RangeP0 = RangeP0;
params.RangeP1a = RangeP1a;
params.RangeP1b = RangeP1b;
params.RangeP2a = RangeP2a;
params.RangeP2b = RangeP2b;
params.RangeGr = RangeGr;

params.epsx = epsx;
params.epsSVM = epsSVM;
params.itersp = itersp;
params.diagflag = diagflag;
params.inparms = inparms;
params.exactflag = exactflag;
params.p = p;
params.q = q;
params.outiter = outiter;
params.initer = initer;
params.randPoints = 128; % Selected random number of points. Should be <= length(Cx)   

Cx = Parameters_v03(RangeP0, RangeP1a, RangeP1b, RangeP2a, RangeP2b, RangeGr,p,q);
[nrows,~]=size(Cx);

if nrows <= params.randPoints 
    params.randPointsUnique = params.randPoints; 
    C = Cx;
else
    x = randi(nrows, params.randPoints, 1); 
    xu= unique(x);
    params.randPointsUnique = length(xu);
    C = Cx(xu,:);    
end




function C = Parameters_v03(RangeP0, RangeP1a, RangeP1b, RangeP2a, RangeP2b, RangeGr,p,q)
    numgroups = 2.^RangeGr;
    mu = RangeP0;        
    alph = RangeP1a; % Lasso    
    bta = RangeP1b;  % Group Lasso
    epp = RangeP2a;
    epq = RangeP2b;
    C = combvec(numgroups, mu, alph, bta, epp, epq, p, q).';