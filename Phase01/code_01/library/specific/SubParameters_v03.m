function [params] = SubParameters_v03(C,params)

params.numgroups = C(1); 
params.mu = C(2);
params.alph = C(3);    % sparsity
params.bta = C(4);     % group sparsity
params.epp = C(5);
params.epq = C(6);
params.p = C(7);
params.q = C(8);
