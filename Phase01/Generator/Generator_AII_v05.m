function Generator_AII_v05
rng('shuffle') 
tgGlobal=tic;

Mean=0;                        % Mean of the channel
SqrtVarpD=sqrt(.5);            % Variance of the channel per dimension

a=dir('*runme*');
fiditemp=fopen('code_0X.log','r');
sheetname=fscanf(fiditemp,'%s');     
fclose(fiditemp); delete('*.log');
C=xlsread(a.name,sheetname,'A1:A25');
CCell = num2cell(C);
[MonteCarlo, L, K, ~, SRL, SRK, ~, lnsMin, lnsMax, BW, PEMin, PEMax, PenetLMin, PenetLMax, NFig, dMin, dMax]=CCell{:};

dRange = ((dMax-dMin)*rand(L,K)+dMin)/1000;   % Uniform distribution between dMin and dMax (in km)
lnsRange = (lnsMax-lnsMin)*rand(L,K)+lnsMin;   % Uniform distribution between lnsMin and lnsMax
PERange = ((PEMax-PEMin)*rand(L,K)+PEMin)/100;   % Uniform distribution between PEMin and PEMax (%)
PenetLRange = (PenetLMax-PenetLMin)*rand(L,K)+PenetLMin;   % Uniform distribution between PLMin and PLMax
NFloor = -173.8+10*log10(BW) + NFig; % MmWave Noise power in dBm

Name=sprintf('L%dK%dSRL%dSRK%d',L,K,SRL,SRK); 
filename1=[Name '_H.log'];  % S-R channel file
filename2=[Name '_N.log']; % Noise file 
filename3=[Name '_Time.log'];  
filename4=[Name '_SUnits.log'];  % Selected units (users and APs)
fido3 = fopen(filename3,'w');

%dbstop at 101
% a = 0; b = 0; % To obtain full non-zero-columns/rows in the channel H matrix
a = 0.5; b = 0.8;
% a = 1; b = 1; % To obtain full zero-columns/rows in the channel H matrix
x = round(a + (b-a) * rand(MonteCarlo,1),1);
for mc=1:MonteCarlo         
    H = normrnd(Mean,SqrtVarpD,L,K)+1j*normrnd(Mean,SqrtVarpD,L,K);
    Gain = normrnd(Mean,SqrtVarpD,L,K);
    noise = normrnd(Mean,SqrtVarpD,L,K)+1i*normrnd(Mean,SqrtVarpD,L,K);   
    PathL = 10.^-( (128.1+37.6*log10(dRange) + lnsRange.*Gain + NFloor + PenetLRange)./20); 
    H= H.*(sqrt(PERange).*PathL);  
    H = HSparse(H,SRL,SRK,L,K,x(mc),filename4);       % Sparsity rate (X%). X out of 100 are zero
    noise=noise./vecnorm(noise);
    dlmwrite(filename1,H,'-append','delimiter','\t','precision','%3.6f');          
    dlmwrite(filename2,noise,'-append','delimiter','\t','precision','%3.6f');    
end

[totaltime,~]=secs2hms_v01(toc(tgGlobal));
fprintf('Total time to generate the input files is %s.\n',totaltime)
fprintf(fido3,'%s',totaltime);
fclose('all');
destination=['./Inputs/MC' num2str(MonteCarlo) '/L' num2str(L) '/K' num2str(K)];
zip(Name,{'*.mat', '*.log'});
delete('*.mat', '*.log')
movefile('*.zip', destination), 

    function Hsparse = HSparse(H,SRL,SRK,L,K,x,filename4)
        SRL = SRL / 100;
        SRK = SRK / 100;
        Hsparse = H;
        Lind = randperm(L,floor(L*SRL));
        Kind = randperm(K,floor(K*SRK)); 
        LSelected = 1:L;
        KSelected = 1:K;
        LSelected(Lind) = [];
        KSelected(Kind) = [];

        dlmwrite(filename4,sort(LSelected),'-append','delimiter','\t','precision','%d');   
        dlmwrite(filename4,sort(KSelected),'-append','delimiter','\t','precision','%d');   
    
        Lp = ceil(L * x); 
        Kp = ceil(K * x);
    
        for k = 1 : length(Kind)
            Lpind = randperm(L,Lp);
            Hsparse(Lpind,Kind(k)) = 0;
            Hsparse(1,Kind(k)) = 5 * H(1,Kind(k));  % Spike
            Hsparse(10,Kind(k)) = 5 * H(1,Kind(k)); % Spike
            Hsparse(20,Kind(k)) = 5 * H(1,Kind(k)); % Spike
            Hsparse(30,Kind(k)) = 5 * H(1,Kind(k)); % Spike
        end

        
        for l = 1 : length(Lind)
            Kpind = randperm(K,Kp);
            Hsparse(Lind(l),Kpind) = 0;   
%             Hsparse(Lind(l),1) = 5 * H(Lind(l),1);   % Spike
%             Hsparse(Lind(l),5) = 5 * H(Lind(l),5);   % Spike
%             Hsparse(Lind(l),10) = 5 * H(Lind(l),10); % Spike
%             Hsparse(Lind(l),15) = 5 * H(Lind(l),15); % Spike
        end 
    
        aL = 0.1;
        Lind = floor(aL*L);
        indxSelected = zeros(Lind,length(KSelected));
        for i = 1 : length(KSelected)
            indxSelected(:,i) = randperm(L,Lind);
        end        

        for i = 1 : length(KSelected)
            Hsparse(indxSelected(:,i),KSelected(i)) = 0;
        end

    end
end