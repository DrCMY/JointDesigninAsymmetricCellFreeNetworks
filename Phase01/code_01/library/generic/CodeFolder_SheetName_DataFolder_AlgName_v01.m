function [CodeFolder,SheetName,DataFolder,AlgNameA]=CodeFolder_SheetName_DataFolder_AlgName_v01(cversion)
CodeFolder=[pwd '\'];
cd '..\Generator\'   
DataFolder=[pwd '\'];
SheetName=textscan(CodeFolder,'%s','delimiter','\');
SheetName=cellfun(@(v) v(end),SheetName);
SheetName=char(SheetName);
AlgNameA=0;
if nargin==1
    fname=dir('*NetworkList*.xlsx');
    [~,FileName,~]=xlsread(fname.name,'AlgorithmsList_v01','A1:A10');
    [~,AlgNames,~]=xlsread(fname.name,'AlgorithmsList_v01','B1:B10');
    AlgNameAx=AlgNames(strcmp(cversion,FileName));
    if isempty(AlgNameAx)
        sprintf('Please add the algorithm name in %s',fname.name)
        return
    else
        AlgNameA=AlgNameAx{1};
    end
end
