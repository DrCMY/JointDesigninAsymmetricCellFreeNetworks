function Outputs_v15(MonteCarlo,L,K,PdBTxRx,SRLOr,SRKOr,SRAvL,SRAvK,SumRateSGL,rateFilters,OOAcc,OOAccUsers,OOAccAPs,OOAccRand,OOAccUsersRand,OOAccAPsRand,CSum,missedCases,fido1,AlgName,Name,cverSubFile_a,cverSubFile_b,tgGlobal,InputFolder,params,CSelParamsx)
[t1,t2]=secs2hms_v01(toc(tgGlobal));
fprintf(fido1,'Total Run Time= %s',t1);fprintf(fido1,'\n');
[~,computername] = system('hostname');     % Computer name
computername=strtrim(computername);
fprintf(fido1,'Computer name is %s\n',computername);

Outputfilename=[Name '.zip'];
Outputfolder=['\Results\MC' num2str(MonteCarlo) '\' cverSubFile_a '\' cverSubFile_b];
Currentfolder=pwd;
Outputfile=[Currentfolder Outputfolder '\' Outputfilename];
fclose('all');
versionx=dir('*Runners*.m');
version=textscan(versionx.name, '%s %s %d', 'delimiter','__');
version=version{3};

%%%%
% Writing the header row in the excel file
[excelfile1,excelfile2]=OutputExcelFiles_v01;
Sheet=['MC' num2str(MonteCarlo)];
Row1={'L','K', 'Network','KSelected', 'Tx dBm','Alg. Name',['Sparsity-Rate-L' newline 'Original %'],['Sparsity-Rate-K' newline 'Original %'],['Sparsity-Rate-L' newline 'Average %'],['Sparsity-Rate-K' newline 'Average %'],['Sum-Rate' newline 'JSGL'], ... 
    ['Sum-Rate' newline 'ZF_R'],['Sum-Rate' newline 'MMSE_R'],['Sum-Rate' newline 'MRC_R'], ... 
    ['Sum-Rate' newline 'ZF_E'],['Sum-Rate' newline 'MMSE_E'],['Sum-Rate' newline 'MRC_E'], ... 
    ['Selection' newline 'Accuracy Total %'],['Selection' newline 'Accuracy Users %'],['Selection' newline 'Accuracy APs %'], ...
    ['Selection' newline 'Accuracy Total Rand %'],['Selection' newline 'Accuracy Users Rand %'],['Selection' newline 'Accuracy APs Rand %'], ...
    'TP','FN','FP','TN',['Missed' newline 'Cases %'] ...
    ['Tested' newline 'Params'], ['Selected' newline 'Params'], ...
    'Total Time-1','Total Time-2',['Data Input' newline 'Location'],['Data Output' newline 'Location'],'Date'};
%%% Write the first row if the first row is empty
[~,B] = xlsfinfo(excelfile1); % Comment 2020/04/14 11:50
if isempty(find(ismember(B, Sheet),1))    
    xlswrite(excelfile1,Row1,Sheet,'A1');
end

% SumRateFilters1 = sum(rateFilters(:,:,1),2)';
% SumRateFilters2 = sum(rateFilters(:,:,2),2)';
% SumRateFilters3 = sum(rateFilters(:,:,3),2)';
% SumRateFilters4 = sum(rateFilters(:,:,4),2)';

SumRateFilters1 = rateFilters(:,1)';
SumRateFilters2 = rateFilters(:,2)';


[lenC,~] = size(CSelParamsx);
CSelParams = '';
for i = 1 : lenC
    CSelParams = [num2str(CSelParamsx(i,:)) '; ' CSelParams];
end
KSelected = K-floor(K*SRKOr/100);
%%%%
% Writing the output data in the excel file
data=xlsread(excelfile1,Sheet,'A2:A200');  
lcolumn=length(data)+1; 
Network=['L' num2str(L) '-K' num2str(K)];
testedParams = ['RangeGr= ' num2str(2.^params.RangeGr) '; RangeP0= ' num2str(params.RangeP0) '; RangeP1a= ' num2str(params.RangeP1a) '; RangeP1b= ' num2str(params.RangeP1b) '; RangeP2a= ' num2str(params.RangeP2a) '; RangeP2b= ' num2str(params.RangeP2b) ... 
    '; p= ' num2str(params.p) '; q= ' num2str(params.q) '; outiter= ' num2str(params.outiter) '; initer= ' num2str(params.initer) ...
    '; epsx= ' num2str(params.epsx) '; epsSVM= ' num2str(params.epsSVM) '; itersp= ' num2str(params.itersp) '; randPoints= ' num2str(params.randPoints) '; randPointsUnique= ' num2str(params.randPointsUnique)];
xlswrite(excelfile1,{L,K,Network,KSelected,PdBTxRx,AlgName,SRLOr,SRKOr,SRAvL,SRAvK,SumRateSGL,SumRateFilters1(1),SumRateFilters1(2),SumRateFilters1(3),... 
    SumRateFilters2(1),SumRateFilters2(2),SumRateFilters2(3),...
    OOAcc,OOAccUsers,OOAccAPs,OOAccRand,OOAccUsersRand,OOAccAPsRand,...
    CSum(1,1),CSum(1,2),CSum(2,1),CSum(2,2),missedCases...
    testedParams, CSelParams,....
    t1,t2,InputFolder,Outputfile,datestr(datetime)},Sheet,['A' num2str(lcolumn+1)]),

mkdir('.\Results\ExcelFiles')
copyfile(excelfile1,['.\Results\ExcelFiles\' excelfile2])
copyfile('../Generator/*.m',Currentfolder)  % Needs to be modified for GitLab upload
copyfile('../Generator/*.xlsx',Currentfolder) % Needs to be modified for GitLab upload
zip(Outputfilename,{'*.mat','*.log',[cverSubFile_a '*.m'],'Runners*.m','Main*.m','Generator*.m','*.xlsx','./library/*.*'});
if version~=1
    zipfile=dir('*.zip');
    zipfile=zipfile.name;
    OutputfolderExtra=[Currentfolder Outputfolder '\'];
    OutputfolderExtra=strrep(OutputfolderExtra, ['code_0' num2str(version)], 'code_01');   
    mkdir(OutputfolderExtra)
    copyfile(zipfile,OutputfolderExtra);   
end
movefile('*.zip',['.' Outputfolder])
delete('*.mat','*.log','*.tex','*.bak')
delete('Gene*.m','Netw*.xlsx','Runme*.xlsx')
close all
fprintf('Total simulation time is %s\n',t1);
fprintf('\n');