% In this file we generate a network of links (between the AP and a node).

function [AP,STA,NodeMatrix,shadowingmatrix]=CreateNetwork(N_APs,N_STAs,L,CWmin,SLOT)

MaxChannels = 8;
Bmax=10E06;
EB=(CWmin-1)*SLOT/2;

MaxX=50;
MaxY=50;

disp('Density of APs');
disp(N_APs/(MaxX*MaxY));


for j=1:N_APs
    
    AP(j).channel=ceil(MaxChannels*rand());    
    AP(j).x = MaxX*rand();
    AP(j).y = MaxY*rand();    
    AP(j).stas = 0;
    AP(j).EB=EB;
    AP(j).L=L;
    AP(j).CCA=-82;
    AP(j).CW=CWmin;
    AP(j).airtime = 0;
    
end

switch N_APs
    case 2
        AP(1).x=MaxX/3;
        AP(1).y=MaxY/2;
        AP(2).x=(MaxX/3)*2;
        AP(2).y=MaxY/2;
    case 3
        AP(1).x=MaxX/4;
        AP(1).y=MaxY/2;
        AP(2).x=(MaxX*2/4);
        AP(2).y=(MaxX/2);
        AP(3).x=MaxX*3/4;
        AP(3).y=(MaxY/2);
    case 4
        AP(1).x=MaxX/3;
        AP(1).y=MaxY/3;
        AP(2).x=(MaxX/3)*2;
        AP(2).y=(MaxX/3)*2;
        AP(3).x=MaxX/3;
        AP(3).y=(MaxY/3)*2;
        AP(4).x=(MaxX/3)*2;
        AP(4).y=MaxY/3;
end



for i=1:N_STAs
    
    STA(i).x = rand()*33.343+8.327;   % uniform distribution for the STAs when using 3 APs
    STA(i).y = rand()*10+20;
    STA(i).L=L;
    STA(i).CCA=-82;
    STA(i).CW=CWmin;

%%% Boris
    STA(i).B = 7.5E06;  %ceil(Bmax*rand());
    STA(i).APs = -inf.*ones(1,N_APs);
    STA(i).d_APs = -inf.*ones(1,N_APs);
    STA(i).nAPs = 0;
    STA(i).Be = 0;
    STA(i).satisfaction = 0;
    STA(i).associated_AP = 0;
    STA(i).ass=zeros(1,N_APs);
    STA(i).APs_range = 0;
    STA(i).APs_reward = zeros(1,N_APs);
    STA(i).Epsilon = [0 , 0.75 , 1; 0 , 0 , 0]; % First row is Eps values, second is how many times they are used
    STA(i).sticky = [0 , 4 , 0];    % First one is the sticky counter, second is the limit for some experiments, third is the global sticky counter
    


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Not uniform
if (N_STAs==10)
STA(1).x=MaxX/3;
STA(1).y=MaxY/2;
STA(2).x=MaxX/3;
STA(2).y=(MaxY/2)+5;
STA(3).x=MaxX/3;
STA(3).y=(MaxY/2)-5;
STA(4).x=(MaxX/3)+5;
STA(4).y=(MaxY/2)+5;
STA(5).x=(MaxX/3)+5;
STA(5).y=(MaxY/2)-5;
STA(6).x=(MaxX/3)-4.17*2;
STA(6).y=(MaxY/2);
STA(7).x=(MaxX/3)-4.17*2;
STA(7).y=(MaxY/2)+5;
STA(8).x=(MaxX/3)-4.17*2;
STA(8).y=(MaxY/2)-5;
STA(9).x=(MaxX/3)*2-5;
STA(9).y=(MaxY/2)+5;
STA(10).x=(MaxX/3)*2-5;
STA(10).y=(MaxY/2)-5;
end
% Interference at every destination

PTdBm = 20;
Pn=10^(-90/10);
PLd1=40.05;
shawdowing = 5;

shadowingmatrix = shawdowing*randn(N_APs+N_STAs);
shadowingmatrix = triu(shadowingmatrix)+triu(shadowingmatrix)';


fc=5; %Working in 5 Ghz
d_walls=10;%distance between walls
NodeMatrix=zeros(N_APs+N_STAs);
for i=1:N_APs+N_STAs
    for j=1:N_APs+N_STAs
        if(i<=N_APs && j<=N_APs)
            d=sqrt((AP(i).x-AP(j).x)^2+(AP(i).y-AP(j).y)^2);            
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i<=N_APs && j>N_APs)
            d=sqrt((AP(i).x-STA(j-N_APs).x)^2+(AP(i).y-STA(j-N_APs).y)^2);
            STA(j-N_APs).d_APs(i)=d;            
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;            
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i>N_APs && j<=N_APs)
            d=sqrt((STA(i-N_APs).x-AP(j).x)^2+(STA(i-N_APs).y-AP(j).y)^2);           
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i>N_APs && j>N_APs)
            d=sqrt((STA(i-N_APs).x-STA(j-N_APs).x)^2+(STA(i-N_APs).y-STA(j-N_APs).y)^2);           
            PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
            NodeMatrix(i,j)=PTdBm-PL;
        end
    end
end

 NodeMatrix(NodeMatrix==inf)=0;
 NodeMatrix(isnan(NodeMatrix))=0;

end
