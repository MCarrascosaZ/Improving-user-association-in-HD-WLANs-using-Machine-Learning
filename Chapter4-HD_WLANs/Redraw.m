function Redraw(CCA,wlan,STA,NodeMatrix,figN)

figure(figN);clf;
N_WLANs=length(wlan);
N_STAs=length(STA);

x=zeros(1,N_WLANs);
y=zeros(1,N_WLANs);

xn=zeros(1,N_STAs);
yn=zeros(1,N_STAs);

for i=1:length(wlan)
    x(i)=wlan(i).x;
    y(i)=wlan(i).y;
end

for i=1:length(STA)
    xn(i)=STA(i).x;
    yn(i)=STA(i).y;
end


axes;
set(gca,'fontsize',12);

h1=scatter(x,y,30,[0 0 0],'filled'); % x,y, size, color

labels = num2str((1:size(y' ))','%d');  % variable, not function or label, numbers of each WLAN
labels2 = num2str((1:size(yn' ))','%d');  % variable, not function or label, numbers of each sta
text(x, y, labels, 'horizontal','left', 'vertical','bottom') % gives the number to each dot, the dot is at the left and bottom of the text
text(xn, yn, labels2, 'horizontal','left', 'vertical','bottom') % gives the number to each dot, the dot is at the left and bottom of the text

xlabel('x [meters]','fontsize',12);
ylabel('y [meters]','fontsize',12);
axis([0-5 55 0-5 55]);
hold

h2=scatter(xn,yn,40,[0.5 0.5 0.5],'^','filled');
h3=0;
for i=1:length(STA)
    if(STA(i).anch~=0)
        h3=line([STA(i).x,wlan(STA(i).anch).x],[STA(i).y,wlan(STA(i).anch).y],'Color',[0.0,0.0,1.0]);

    end
end


for i=1:N_WLANs
    for j=1:N_WLANs
        if(NodeMatrix(i,j) >= CCA && wlan(i).channel==wlan(j).channel)
            h4=line([wlan(i).x,wlan(j).x],[wlan(i).y,wlan(j).y],'Color',[1.0,0.0,0.0]);
            
        end
    end
    
end

if(h3==0)
    legend([h1(1),h2(1),h4(1)],'APs','STAs','Share channel','Location','best')
else
    legend([h1(1),h2(1),h3(1),h4(1)],'APs','STAs','Association','Share channel','Location','best')
end

end
