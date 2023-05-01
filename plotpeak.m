function [imgL,imgS]=plotpeak(ax,fig,plt,x,y,m1,m2,dim)
%hold(ax,'off')
plt.XData=x; plt.YData=y;
title(ax,{['Extracted ion Chromatogram m/z ',num2str(m1,'%.6f'),' - ',num2str(m2,'%.6f')];''},'FontSize',10);
X=getframe(fig);
XX=rgb2gray(X.cdata);
imgL=X;
imgS=imresize(XX/max(max(XX))*255,[dim dim]);
