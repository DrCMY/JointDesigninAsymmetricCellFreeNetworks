function [OOAcc,OOAccUsers,OOAccAPs,rateSGL,SRAvL,SRAvK,CSum,Hxx,LamLog] = Results_v09(C,H,params,opt,SRAvL,SRAvK,CSum,SRL,SRK,LSelected,KSelected,XXor,PdBm,sigma2n) % Returns Hxx
    K = params.K; L = params.L; epsx = params.epsx;

    [params] = SubParameters_v03(C,params);

%     [X, LamLog] = splitrecongroupsparsegroup_AI_v03(100*eye(K), H, params);   % Slow search
    [X, LamLog] = splitrecongroupsparsegroup_AI_v05(100*eye(K), H, params); % Fast search
    
    % w/ AP selection
    Xc = vecnorm(X);
    [~, ind] = sort(Xc,'descend');
    totSilentUsers = floor(SRK * K); % Original
%     totSilentUsers = 16; % When SRL=SRK=0
    indx = sort(ind(1:totSilentUsers));
    X(:,indx) = 0;                     % For partially connected networks. Comment this for full zero-columns/vectors.
    
    indxSelected = 1 : K;
    indxSelected(indx) = [];
    cUsers = length(intersect(indxSelected, KSelected));

    Xr = vecnorm(X.');
    [~, ind] = sort(Xr,'ascend');
    totSilentAPs = floor(SRL * L);   
    indx = sort(ind(1:totSilentAPs));
    X(indx,:) = 0;                    % For partially connected networks. Comment this for full zero-columns/vectors.

    indxSelected = 1 : L;
    indxSelected(indx) = [];
    cAPs = length(intersect(indxSelected, LSelected));

    OOAcc = (cUsers + cAPs) / (length(KSelected)+length(LSelected)) * 100;

    OOAccUsers = cUsers / length(KSelected) * 100;

    OOAccAPs = cAPs / length(LSelected) * 100;
                 
    XX = abs(X)>epsx;

    Hxx = H';   
    XXr = find(sum(XX,2)==0);
    Hxx(XXr,:) = [];
    X(XXr,:) = [];
    XXc = find(sum(XX,1)==0);
    Hxx(:,XXc) = [];                        
    X(:,XXc) = []; 

    X = X ./ vecnorm(X); 

    [Ll,Kk] =size(Hxx);        
    rateSGL = RateF_v03(Hxx,X,Ll,Kk,PdBm,sigma2n);
    
    if opt == false    
    
        SRAvL = 0; SRAvK = 0; CSum = 0; LamLog = 0;
    
    else    

        SRx = (L-Ll) / L;
        SRAvL = SRAvL + SRx;    
    
        SRx = (K-Kk) / K;
        SRAvK = SRAvK + SRx;      
    
        CSumx = confusionmat(XXor(:),XX(:));
        CSum = CSum + CSumx;
    end
        