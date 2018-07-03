% In this file we generate a network of links (between the AP and a node).

function [wlan,STA,NodeMatrix,shadowingmatrix]=CreateNetwork(N_WLANs,N_STAs,L,CWmin,SLOT)

MaxChannels = 8;
EB=(CWmin-1)*SLOT/2;

MaxX=50;
MaxY=50;

%%disp('Density of APs');
%%disp(N_WLANs/(MaxX*MaxY));



for j=1:N_WLANs
    
    wlan(j).channel=ceil(MaxChannels*rand());
    if(j>1)
        wlan(j).x = MaxX*rand();
        wlan(j).y = MaxY*rand();
    else
        wlan(j).x=MaxX/2;
        wlan(j).y=MaxY/2;
    end 
    wlan(j).stas = 0;
    wlan(j).EB=EB;
    wlan(j).L=L;
    wlan(j).CCA=-82;
    wlan(j).CW=CWmin;
    
end

%%%%%%%%%%% FOR FIXED AP POSITIONS %%%%%%%%%%%%%%
%%%%%%%%%%%% 2 APs %%%%%%%%%%%%

% wlan(1).x=MaxX/3;
% wlan(1).y=MaxY/2;
% wlan(2).x=(MaxX/3)*2;
% wlan(2).y=MaxY/2;

%%%%%%%%%%%% 3 APs %%%%%%%%%%%%

% wlan(1).x=MaxX/4;
% wlan(1).y=MaxY/2;
% wlan(2).x=(MaxX*2/4);
% wlan(2).y=(MaxX/2);
% wlan(3).x=MaxX*3/4;
% wlan(3).y=(MaxY/2);

%%%%%%%%%%%% 4 APs %%%%%%%%%%%%
% wlan(1).x=MaxX/3;
% wlan(1).y=MaxY/3;
% wlan(2).x=(MaxX/3)*2;
% wlan(2).y=(MaxX/3)*2;
% wlan(3).x=MaxX/3;
% wlan(3).y=(MaxY/3)*2;
% wlan(4).x=(MaxX/3)*2;
% wlan(4).y=MaxY/3;

%%%%%%%%%%% END FIXED AP POSITIONS %%%%%%%%%%%%%%



for i=1:N_STAs
    
    STA(i).x = MaxX*rand();
    STA(i).y = MaxY*rand();
    STA(i).anch=0;
    STA(i).EB=EB;
    STA(i).L=L;
    STA(i).CCA=-82;
    STA(i).CW=CWmin;

end


% Interference at every destination

PTdBm = 20;
PLd1=40.05;
shawdowing = 5;

shadowingmatrix = shawdowing*randn(N_WLANs+N_STAs);
shadowingmatrix = triu(shadowingmatrix)+triu(shadowingmatrix)';

fc=5;       %Working in 5 Ghz
d_walls=10; %distance between walls
NodeMatrix=zeros(N_WLANs+N_STAs);   % Received Power for every node

for i=1:N_WLANs+N_STAs
    for j=1:N_WLANs+N_STAs
        if(i<=N_WLANs && j<=N_WLANs)
            d=sqrt((wlan(i).x-wlan(j).x)^2+(wlan(i).y-wlan(j).y)^2);
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i<=N_WLANs && j>N_WLANs)
            d=sqrt((wlan(i).x-STA(j-N_WLANs).x)^2+(wlan(i).y-STA(j-N_WLANs).y)^2);
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;          
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i>N_WLANs && j<=N_WLANs)
            d=sqrt((STA(i-N_WLANs).x-wlan(j).x)^2+(STA(i-N_WLANs).y-wlan(j).y)^2);
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i>N_WLANs && j>N_WLANs)
            d=sqrt((STA(i-N_WLANs).x-STA(j-N_WLANs).x)^2+(STA(i-N_WLANs).y-STA(j-N_WLANs).y)^2);
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
            NodeMatrix(i,j)=PTdBm-PL;
        end
    end
end

 NodeMatrix(NodeMatrix==inf)=0;
 NodeMatrix(isnan(NodeMatrix))=0;
 
end
