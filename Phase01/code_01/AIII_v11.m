function AIII_v11(MonteCarlo,L,K,PdBTxRx,SRLOr,SRKOr,sigma2n,Name1,Name2,InputFolder)
tgGlobal=tic;
SRLOrR = SRLOr / 100;
SRKOrR = SRKOr / 100;
[cverSubFile_a,cverSubFile_b]=CodeVersion_v01(mfilename);             % Calling subfunction to detect the version of the current code

[CodeFolder,~,~,AlgName]=CodeFolder_SheetName_DataFolder_AlgName_v01(mfilename);  % Locations of the code and data folders. Sheet name of the runme.xlsx file
cd(CodeFolder)
disp(['Now ' AlgName ' is being executed'])

[fi1,~,fi3,fido1,Name]=IOFiles_v02(Name1,Name2,cverSubFile_b);

[params,C] = ParamInit_v04();


[lenC,lenparams] = size(C);
%%
mc=1;               % Monte Carlo counter
loader = 0;
loadermc = 0;
SRAvL = 0;           % Average sparsity rate for APs
SRAvK = 0;           % Average sparsity rate for users
OOAcc = 0;
OOAccUsers = 0;
OOAccAPs = 0;
OOAccRand = 0;
OOAccUsersRand = 0;
OOAccAPsRand = 0;
rateSGL = 0;
CSum = zeros(2,2);
filterOptions = 3; % ZF, MMSE, MRC
zeroOptions = 2;   % Correct locations, estimated locations
rateFilters = zeros(filterOptions,zeroOptions);
params.L = L;
params.K = K;
CM = zeros(MonteCarlo,lenparams);
missedCases = 0;
while mc<=MonteCarlo
    H=dlmread(fi1,'\t',[loader 0 loader+L-1 K-1]);
    H = H';    
    XXor = (abs(H)' ~= 0)'; 

    %%%
    % Replacing zeros with random small values
    Habs = abs(H);
    [ii,jj] = find(~Habs);
    a = -2; b = 2;
    for i = 1 : length(ii)
        H(ii(i),jj(i)) =  a + (b-a) * rand(1) + 1i*(a + (b-a) * rand(1));
    end
    %%%
    

    Ll = L - floor(L*SRLOr/100);
    Kk = K - floor(K*SRKOr/100);
    LSelected=dlmread(fi3,'\t',[loadermc 0 loadermc Ll-1]);
    KSelected=dlmread(fi3,'\t',[loadermc+1 0 loadermc+1 Kk-1]);

    loader=loader+L; 
    loadermc=loadermc+2; 
 
    parpoolMCLimit = 2; % Manual entry. Change in Runners_XX.m file too
%     if MonteCarlo > parpoolMCLimit
%         parfor i = 1 : lenC        
%             [OOAccM(i),rateSGLM(i)] = Results_v07(C(i,:),H,params,false,0,0,0,SRLOrR,SRKOrR,XXor,PdBTxRx,sigma2n);
%         end
%     else
%         for i = 1 : lenC
%            [OOAccM(i),rateSGLM(i)] = Results_v07(C(i,:),H,params,false,0,0,0,SRLOrR,SRKOrR,XXor,PdBTxRx,sigma2n);
%         end        
%     end
        parfor i = 1 : lenC        
            [OOAccM(i),rateSGLM(i)] = Results_v09(C(i,:),H,params,false,0,0,0,SRLOrR,SRKOrR,LSelected,KSelected,XXor,PdBTxRx,sigma2n);
        end
    
    % Options for selection: 1) OOAcc - On/off accuracy, 2) rateSGL - Data rate
%     [~,iMax]=max(OOAccM);
    [~,iMax]=max(rateSGLM);

    [OOAccx, OOAccUsersx, OOAccAPsx, rateSGLx, SRAvL, SRAvK, CSum, Hxx, ~] = Results_v09(C(iMax,:),H,params,true,SRAvL,SRAvK,CSum,SRLOrR,SRKOrR,LSelected,KSelected,XXor,PdBTxRx,sigma2n);
    CM(mc,:) = C(iMax,:);

    OOAcc =  OOAcc + OOAccx;
    OOAccUsers =  OOAccUsers + OOAccUsersx;
    OOAccAPs =  OOAccAPs + OOAccAPsx;
    rateSGL = rateSGL + rateSGLx;

    H = H'; 
    XXr = find(sum(H,2)==0);
    H(XXr,:) = []; %#ok<FNDSB> : To supress the message 
    XXc = find(sum(H,1)==0);
    H(:,XXc) = []; %#ok<FNDSB> : To supress the message 

    [rateFiltersx, OOAccRandx, OOAccUsersRandx, OOAccAPsRandx] = RateFilters_v08(H,Hxx,SRLOrR,SRKOrR,LSelected,KSelected,filterOptions,zeroOptions,PdBTxRx,sigma2n);


    OOAccRand = OOAccRand + OOAccRandx;
    OOAccUsersRand = OOAccUsersRand + OOAccUsersRandx;
    OOAccAPsRand = OOAccAPsRand + OOAccAPsRandx;

    rateFilters = rateFilters + rateFiltersx; 
    if rateSGLx < rateFiltersx(2,1)
        missedCases = missedCases + 1;
        sprintf("Smaller rate_SGL: rate_SGL, rate_MMSE, mc: %.4f %.4f %d",rateSGLx, rateFiltersx(2,1), mc) 
    end
    %%%
    mc=mc+1;
end
OOAcc = OOAcc / MonteCarlo;
OOAccUsers = OOAccUsers / MonteCarlo;
OOAccAPs = OOAccAPs / MonteCarlo;
OOAccRand = OOAccRand / MonteCarlo;
OOAccUsersRand = OOAccUsersRand / MonteCarlo;
OOAccAPsRand = OOAccAPsRand / MonteCarlo;
rateSGL = rateSGL / MonteCarlo;
rateFilters = rateFilters / MonteCarlo;
SRAvL = SRAvL / MonteCarlo * 100;
SRAvK = SRAvK / MonteCarlo * 100;
CSum = CSum / MonteCarlo;
missedCases = missedCases / MonteCarlo * 100;
sprintf("SGL, ZF, MMSE, MRC, SRAvL, SRAvK, OOAcc =")
for i = 1 : zeroOptions
    sprintf("%.2f  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f", rateSGL, rateFilters(:,i)', SRAvL, SRAvK, OOAcc)
end

Outputs_v15(MonteCarlo,L,K,PdBTxRx,SRLOr,SRKOr,SRAvL,SRAvK,rateSGL,rateFilters,OOAcc,OOAccUsers,OOAccAPs,OOAccRand,OOAccUsersRand,OOAccAPsRand,CSum,missedCases,fido1,AlgName,Name,cverSubFile_a,cverSubFile_b,tgGlobal,InputFolder,params,CM) 