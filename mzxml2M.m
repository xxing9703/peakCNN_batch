%parse .mzXML into matlab structure M. Support multiple files.
% dependency: mzxmlread_xi.m
function M = mzxml2M(varargin)
if nargin>0
    fname=varargin{1};
    if iscell(fname) %multifile selected
    else
      f{1}=fname;  % convert to cell format
      fname=f;
    end
else
    [filename, pathname] = ...
       uigetfile('*.mzXML','File Selector','MultiSelect','on');
    fname=fullfile(pathname,filename);
    if iscell(fname)  %multifile selected
    elseif fname==0    % no file selected
        warndlg('No files selected'); 
        M=[];
        return    
    else   % one file selected
        f{1}=fname;  % convert to cell format
        fname=f;
    end    
end
%---------parsing
for i=1:length(fname)
    fprintf(['parsing file #',num2str(i),'/',num2str(length(fname)),'\n']);
    A(i)=mzxmlread_xi(fname{i});
end
fprintf('converting to M structure\n');

for f=1:size(A,2)
    mat=[];
   for i=1:length(A(f).scan)
    rt_str=A(f).scan(i).retentionTime; %rt time
    mat{i,1}=str2num(rt_str(3:end-1))/60;
    pair=A(f).scan(i).peaks.mz;%mass-inten pair
    mz=pair(1:2:length(pair)-1);
    inten=pair(2:2:length(pair));
    mat{i,2}=mz;
    mat{i,3}=inten;
   end
    M(f).filename=fname{f};
    M(f).data=mat;
end
for i=1:length(M)
     M(i).rt=cell2mat(M(i).data(:,1));
end

