% Inputs:
% fn_mzXML:  file name of mzXML
% fn_pklist: file name of peak list
% cols: a two-number array that specifies the columns of m/z and rt in the peaklist.
% verbose: 0 without saving EICs in created folders. 1 saving EICs
% model: pre-trained CNN model name
% ppm (optional): ppm window used in reading EIC, default is 5
% ave (optional): EIC moving average, default is 5 

% Output:
% ispeak: an array of 1 or 0. This new column will be appended to peaklist
% img: an array that stores all the EIC curves as images. 
% In addition, all results will be saved in a temp folder ('tmp' followed by time stamp) containing: 
% -- a true folder: images of EICs classified as true peaks.
% -- a false folder: images of EICs classified as false peaks.
% -- updated peaklist, with an added column of 'ispeak'.

% example usage:
% peaksEVA('example_pos.mzXML','example_peaks_pos.csv',[5,6],'net64')

function ispeak=peaksEVA_batch(fn_mzXML,fn_pklist,cols,model,verbose,ppm,ave) 
% setup figure, axes, plot
fig=figure('Units','normalized');
fig.Position(1)=0.3;
fig.Position(2)=0.2;
ax=axes(fig);
plt=plot(ax,[0,1],[0,1],'k','LineWidth',1);
set(ax,'TickDir','out');
set(ax,'linewidth',1)
xlabel(ax,'Seconds','fontsize',10);
ylabel(ax,'Intensity','FontSize',10);
ytickangle(ax,90)

% settings
settings.ppm=5*1e-6;
settings.rtm=1;
settings.ave=5;
settings.prominence=1e3;
settings.peakwidth=0.02;
if nargin>5
  settings.ave=ave;
  settings.ppm=ppm*1e-6;
end

if ~iscell(fn_mzXML)
    fn{1}=fn_mzXML;  % single mzXML
else
    fn=fn_mzXML;  % multiple mzXML
end

% initialize
ispeak=[];
folder=['tmp',datestr(now,'yyyy-mm-dd-HH-MM')];
mkdir(folder);
if verbose==1  % write to folders
       mkdir(fullfile(folder,'true'));
       mkdir(fullfile(folder,'false'));
end
[~,fname_pklist]=fileparts(fn_pklist);
fn_out=[fname_pklist,'_CNN.csv'];

%------------------------------------------
for k=1:length(fn)  % K: loop over files
   [~,fname_mzXML]=fileparts(fn{k});
   M=mzxml2M(fn{k});
   T=readtable(fn_pklist);
   O=load([model,'.mat']);
   dim=O.dim;
   net=O.net;
   TRUE=0;FALSE=0;
   for i=1:size(T,1)    
    pk=[];
    pk.mz=T{i,cols(1)};
    pk.rt=T{i,cols(2)};
    spec=getEIC(M,pk,settings);
    spec=spec{1};
    m1=pk.mz-pk.mz*settings.ppm;
    m2=pk.mz+ pk.mz*settings.ppm;
    x=spec(:,1)*60; %EIC-X
    y=spec(:,3);  %EIC-Y(ave)
   
    [imgL,imgS]=plotpeak(ax,fig,plt,x,y,m1,m2,dim);    
    % img{i}=imgL;
    cc=classify(net,imgS); qq=predict(net,imgS);
    ispeak(i,k)=int8(strcmp(string(cc),'true'));
    quality(i,k)=qq(2);
    if verbose==1  % write to folders
       imwrite(imgL.cdata,fullfile(folder,string(cc),[fname_mzXML,'_pk',num2str(i,'%.5d'),'.png']));
       if strcmp(string(cc),'true')
         %T{i,'isPeak'}=1;
         TRUE=TRUE+1;
       else
         %T{i,'isPeak'}=0;      
         FALSE=FALSE+1;
       end
     end
     fprintf(['file-',num2str(k),' #',num2str(i),'/',num2str(size(T,1)),':',char(cc),'--',num2str(TRUE),':',num2str(FALSE),'\n'])
   end
fprintf('Done!\n')
end

T{:,'ispeak'}=sum(ispeak,2);
T{:,'Quality'}=mean(quality,2);
writetable(T,fullfile(folder,fn_out));