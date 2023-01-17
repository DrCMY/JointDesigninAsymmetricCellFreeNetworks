function rate = RateF_v03(H,V,L,K,PdBm,sigma2n)
rate = 0;
% PdBm = 20; % This needs to be read from NetworkList_v01.xlsx 
Plin = 10^((PdBm - 30)/10);
sPlin = sqrt(Plin);
for k=0:K-1
    num=0;
    den=0;
    for j=0:K-1
        denx=0;
        if j~=k
            for l=0:L-1                
                denx=denx+sPlin*V(l+1,j+1)'*H(l+1,k+1);
            end
            den=den+abs(denx)^2;
        else
            for l=0:L-1                
                num=num+sPlin*V(l+1,k+1)'*H(l+1,k+1);
            end
            num=abs(num)^2;
        end
    end
    rate = rate + log2(1+num/(den+sigma2n));
end