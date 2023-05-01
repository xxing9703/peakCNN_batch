fn=uigetfile('*.mzXML',"MultiSelect","on");
fn_pklist='pklist.csv';
cols=[5,6];
model='net64';
ppm=5;
ave=5;
for i=1:length(fn)
   fn_mzXML=fn{i};
   ispeak(:,i)=peaksEVA(fn_mzXML,fn_pklist,cols,model,ppm,ave);
end