% clc; clear variables; 
close all; fclose('all'); delete('*.log','*.bak'); % dbstop if error; dbclear if error;
warning('off','all'); %warning
%%%%%%%%%%%%%%
[CodeFolder,SheetName,DataFolder,~]=CodeFolder_SheetName_DataFolder_AlgName_v01;  % Locations of the code and data folders. Sheet name of the runme.xlsx file
fname=dir('*Runme*.xlsx');
x=xlsread(fname.name,SheetName,'A1:A200');
C=xlsread(fname.name,SheetName,['A1:A2' num2str(length(x))]);
CCell = num2cell(C);

[MonteCarlo, L, K, PdBTxRx, SRL, SRK, sigma2n]=CCell{:};

Name1=sprintf('L%dK%dSRL%dSRK%d',L,K,SRL,SRK); 
Name1x=sprintf('_MC%d',MonteCarlo);
Name1x=[Name1 Name1x];
Name2=['T' mat2str(PdBTxRx)]; 

% Checking the input files
InputFolder=InputFolder_v01(MonteCarlo,L,K,Name1,DataFolder);
[status,list]=system(InputFolder); 
if status==1
    disp('The input files are missing. They are now being generated. Please wait.')
    %pause(3);
    TempFolder=[DataFolder 'Temp\' Name1x '\' ]; 
    mkdir(TempFolder)
    copyfile(fname.name,TempFolder);
    [~,list]=system('dir G*.m /b');
    runner=textscan(list, '%s %s', 'delimiter','.');    
    copyfile([char(runner{1}) '.m'],TempFolder);
    cd(TempFolder)
    fidotemp = fopen('code_0X.log','w');
    fprintf(fidotemp,SheetName); fclose(fidotemp);
    run(char(runner{1}))  
    copyfile('Inputs',[DataFolder 'Inputs\'])
    cd ..
    rmdir(Name1x,'s')  
end
cd(CodeFolder)
%%
% The random channel and beamforming vector input files are copied to the current directory 
copyfile(InputFolder,pwd);
unzip(InputFolder);
delete('*.zip');
%%

AIII_v11(MonteCarlo,L,K,PdBTxRx,SRL,SRK,sigma2n,Name1,Name2,InputFolder)