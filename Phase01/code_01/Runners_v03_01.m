% NL: Stands for "network list". NL indicates that the value of the variable is obtained from the NetworkList.xlsx file. 
    % Therefore, to modify the value of a variable that has "NL" next to it, please modify the excel file NetworkList.xlsx
% Runners_vXX_YY.m: Rename YY depending on the folder, code_YY, you are in.
    % In addition, type YY in the Runners column of NetworkList_vZZ.xlsx
clc; close all; fclose('all'); dbstop if error; % dbclear if error;
addpath('.\library\generic');
addpath('.\library\specific');
closeoutputxlsxfile
%totaltime=tic;
folder=fileparts(which(mfilename));
cd(folder)                                      % Change Matlab directory to the "code" folder
%set(0,'DefaultFigureVisible','off');            % Comment here for the detailed figure outputs
%set(0,'DefaultFigureVisible','on');            % Uncomment here for the detailed figure outputs
%set(findobj(0,'type','figure'),'visible','on') % If the figures still do not open, run this line
%warnings
%pause(3)
[CodeFolder,SheetName,DataFolder,~]=CodeFolder_SheetName_DataFolder_AlgName_v01;  % Locations of the code and data folders. Sheet name of the runme.xlsx file
fname=dir('*NetworkList*.xlsx');
datar=xlsread([DataFolder fname.name],'A2:Z200'); % Read the NetworkList.xlsx file which contains the network parameters to be tested
Alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
MC=find(Alphabet=='A');                         % Number of Monte Carlo runs - NL
Lr=find(Alphabet=='B');                         % L: Number of access points - NL
Kr=find(Alphabet=='C');                         % K: Number of users - NL
TxdB=find(Alphabet=='D');                       % SNR between a transmitter and a receiver in dB - NL
SRLr=find(Alphabet=='E');                         % Sparsity rate (X%) of APs. X out of 100 are zero - NL
SRKr=find(Alphabet=='F');                         % Sparsity rate (X%) of users. X out of 100 are zero - NL
Runners=find(Alphabet=='G');
version=textscan(mfilename, '%s %s %d', 'delimiter','__');
selected=find(datar(:,Runners)==version{3});
parpoolMCLimit = 2; % Manual entry. Change in A_XX.m file too
if sum(datar(selected,1) > parpoolMCLimit) > 0 % parpool boolean
    p = gcp('nocreate');
    if isempty(p)
        parpool
    end
end
totaltime=tic;
lselected=length(selected);
if isempty(selected)
    display(version{2}, 'There is no Runner_X.m call in the NetworkList.xlsx file: X')
end    
for iter=1:lselected
    fprintf('Current date and time: %s\n',char(datetime('now')));
    fprintf('Testing set of networks: %d out of %d\n',iter,lselected);
    x=selected(iter);
    cd(DataFolder)
    fname=dir('*Runme*');  
    a = sheetnames(fname.name);
    sheetValid = any(strcmp(a, SheetName));    
    if ~sheetValid
        sprintf("Please duplicate a sheet in %s as %s" , fname.name, SheetName)
        return
    end    
    xlswrite(fname.name,[datar(x,MC),datar(x,Lr),datar(x,Kr),datar(x,TxdB),datar(x,SRLr),datar(x,SRKr)]',SheetName,'A1:A6'),    
    cd(CodeFolder)
    clearvars -except datar MC Lr Kr Mr TxdB SRLr SRKr Runners selected lselected iter totaltime tic; % Do not forget to delete the variable here when you introduce that new variable
    fname=dir('Main*.m');
    run(fname.name)
end
% fig = uifigure;
% uialert(fig,[mfilename ' is completed'],'Success','Icon','success');