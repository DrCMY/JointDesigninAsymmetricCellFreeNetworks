function [rate, OOAcc, OOAccUsers, OOAccAPs] = RateFilters_v08(HR,HE,SRL,SRK,LSelected,KSelected,filterOptions,zeroOptions,PdBm,sigma2n)

%%%%
% Random filters
%%%
% Random selection: 
[L,K] = size(HR);
totSilentUsers = floor(SRK * K); % Original
% totSilentUsers = 16; % % When SRL=SRK=0
totSilentAPs = floor(SRL * L);
indUsers = randperm(K, totSilentUsers);
indAPs = randperm(L, totSilentAPs);
HR(:,indUsers) = [];
HR(indAPs,:) = [];

indUsersSelected = 1 : K;
indUsersSelected(indUsers) = [];
indAPsSelected = 1 : L;
indAPsSelected(indAPs) = [];

cUsers = length(intersect(sort(indUsersSelected), KSelected));
cAPs = length(intersect(sort(indAPsSelected), LSelected));
OOAcc = (cUsers + cAPs) / (length(KSelected)+length(LSelected)) * 100;
OOAccUsers = cUsers / length(KSelected) * 100;
OOAccAPs = cAPs / length(LSelected) * 100;
%%%




[L,K] = size(HR);
[Ll,Kk] = size(HE);
Plin = 10^((PdBm - 30)/10);
sPlin = sqrt(Plin);

HH = HR';
VZFR = HR/(HH*HR);
VMMSER = sPlin*(HR/(Plin*HH*HR+eye(K)));
VMRCR = HR;

VZFR = VZFR ./ vecnorm(VZFR);
VMMSER = VMMSER ./ vecnorm(VMMSER);
VMRCR = VMRCR ./ vecnorm(VMRCR);

%%%%
% Estimate filters
HH = HE';
VZFE = HE/(HH*HE);
VMMSEE = sPlin*(HE/(Plin*HH*HE+eye(Kk)));
VMRCE = HE;

VZFE = VZFE ./ vecnorm(VZFE);
VMMSEE = VMMSEE ./ vecnorm(VMMSEE); 
VMRCE = VMRCE ./ vecnorm(VMRCE);

rate = zeros(filterOptions,zeroOptions);
for k=0:K-1
    num=zeros(filterOptions,zeroOptions);
    den=zeros(filterOptions,zeroOptions);
    for j=0:K-1
        denx=zeros(filterOptions,zeroOptions);
        if j~=k
            for l=0:L-1                
                denx(1,1)=denx(1,1)+sPlin*VZFR(l+1,j+1)'*HR(l+1,k+1);
                denx(2,1)=denx(2,1)+sPlin*VMMSER(l+1,j+1)'*HR(l+1,k+1);
                denx(3,1)=denx(3,1)+sPlin*VMRCR(l+1,j+1)'*HR(l+1,k+1);
            end
            den(:,1)=den(:,1)+abs(denx(:,1)).^2; 
        else
            for l=0:L-1                
                num(1,1)=num(1,1)+sPlin*VZFR(l+1,k+1)'*HR(l+1,k+1);
                num(2,1)=num(2,1)+sPlin*VMMSER(l+1,k+1)'*HR(l+1,k+1);
                num(3,1)=num(3,1)+sPlin*VMRCR(l+1,k+1)'*HR(l+1,k+1);               
            end            
            num(:,1)=abs(num(:,1)).^2;
        end
    end
    rate(:,1) = rate(:,1) + log2(1 + num(:,1) ./ (den(:,1)+sigma2n));
end


for k=0:Kk-1
    num=zeros(filterOptions,zeroOptions);
    den=zeros(filterOptions,zeroOptions);
    for j=0:Kk-1
        denx=zeros(filterOptions,zeroOptions);
        if j~=k
            for l=0:Ll-1                
                denx(1,2)=denx(1,2)+sPlin*VZFE(l+1,j+1)'*HE(l+1,k+1); 
                denx(2,2)=denx(2,2)+sPlin*VMMSEE(l+1,j+1)'*HE(l+1,k+1);
                denx(3,2)=denx(3,2)+sPlin*VMRCE(l+1,j+1)'*HE(l+1,k+1);                          
            end
            den(:,2)=den(:,2)+abs(denx(:,2)).^2; 
        else
            for l=0:Ll-1                
                num(1,2)=num(1,2)+sPlin*VZFE(l+1,k+1)'*HE(l+1,k+1);
                num(2,2)=num(2,2)+sPlin*VMMSEE(l+1,k+1)'*HE(l+1,k+1);
                num(3,2)=num(3,2)+sPlin*VMRCE(l+1,k+1)'*HE(l+1,k+1);                
            end            
            num(:,2)=abs(num(:,2)).^2;
        end
    end
    rate(:,2) = rate(:,2) + log2(1 + num(:,2) ./ (den(:,2)+sigma2n));
end