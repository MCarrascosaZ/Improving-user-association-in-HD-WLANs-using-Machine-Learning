%%%%MAIN%%%%
clear;clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_WLANs=3;  %Number of APs
N_STAs=10;   %Number of STAs
N_It=10;    %Number of iterations
CCAAdjust=0;    % CCA adjustment, 0 for deactivated, 1 for activated
TPAdjust=0;     % Transmission power adjustment, 0 for deactivated, 1 for activated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

seedHidd=zeros(N_It,1); % Stores the Hidden nodes for all iterations
seedCont=zeros(N_It,1); % Stores the Contending nodes for all iterations
seedPairs1=zeros(N_It,1);   % Stores the Pairs seen for all iterations
seedPairs2=zeros(N_It,1);   % Stores the Pairs unseen for all iterations
seedPairsN=zeros(N_It,N_WLANs); % Stores the Pairs unseen by networks for all iterations
seedExp=zeros(N_It,1);  % Stores the Pairs unseen by networks for all iterations
PTs=zeros(1,6); %  Stores the amount of STAs that used each TP
suc=zeros(N_It,N_WLANs+N_STAs); % Successful transmissions
nsuc=zeros(N_It,N_WLANs+N_STAs);    % Unsuccessful transmissions
sucbywlantotal=zeros(N_It*N_WLANs,N_WLANs+N_STAs);  % Successful transmissions by WLAN
nsucbywlantotal=zeros(N_It*N_WLANs,N_WLANs+N_STAs); % Unsuccessful transmissions by WLAN
ccas=zeros(N_It,N_STAs);    % CCA used by each STA

for y=1:N_It
    disp(y) % Iteration    
    seed=y+82;
    rng(seed);  %Sets seed for all number generators
       
    CCA=-82;    %Clear Channel Assessment    
    L=12000;    %Packet size
    CWmin=16;   %Minimum contention window, for every node
    SLOT=9E-6;  %OFDM time slot
    
    [wlan,STA,NodeMatrix,shadowingmatrix]=CreateNetwork(N_WLANs,N_STAs,L,CWmin,SLOT);   % Creates STAs and WLANs
    [wlan,STA,Associated]=SSFAssoc(wlan,STA,NodeMatrix);    % Creates SSF association
    picks=pickSTA(Associated);  % Picks the receivers for the WLANs
    [tx]=SimulTx(wlan,STA,picks);
    
    %Redraw(-82,wlan,STA,NodeMatrix,1);   % Draws the network
    if(CCAAdjust==1)
    [wlan,STA,NodeMatrix]=CCAadjustALg(wlan,STA,shadowingmatrix,NodeMatrix);   % Adjusts the CCA for the STAs
     for t=1:N_STAs
        ccas(y,t)=STA(t).CCA;       % Gets the CCA for each STA
    end
    end
    if(TPAdjust==1)
    [wlan,STA,NodeMatrix]=PTadjust(wlan,STA,shadowingmatrix,NodeMatrix);    % Adjusts the Transmission Power for the STAs
    adjustedPT=counter(STA);    % Counts how many STAs use each TP    
    PTs(y,:)=adjustedPT;
    end
    [totCont,totHidd,totExp,hiddNod,contNod]= hiddenNodesDetectionAP(wlan,STA,NodeMatrix,picks);
    [totTx,totUTx,sucTx,unsucTx]=simulTxSlot(wlan,STA,tx,hiddNod,contNod,NodeMatrix,1000);
    suc(y,:)=suc(y,:)+sucTx;
    nsuc(y,:)=nsuc(y,:)+unsucTx;
    
    %%%%%%%% The next block adds up the transmissions according to the WLAN they belong to
    
    sucbywlan=zeros(N_WLANs,N_WLANs+N_STAs);
    nsucbywlan=zeros(N_WLANs,N_WLANs+N_STAs);
    for i=1:N_WLANs
        for j=1:N_STAs
            if(STA(j).anch==i)
                sucbywlan(i,j+N_WLANs)=sucbywlan(i,j+N_WLANs)+sum(suc(y,j+N_WLANs));
                nsucbywlan(i,j+N_WLANs)=nsucbywlan(i,j+N_WLANs)+sum(nsuc(y,j+N_WLANs));
            end
        end
        for l=1:N_WLANs
            if(i==l)
                sucbywlan(i,l)=(suc(y,l));
                nsucbywlan(i,l)=(nsuc(y,l));
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [sensedNodes,pairs,net]=contenderPairsUnseen(wlan,STA,NodeMatrix,contNod);  % Pairs of nodes that sense each other
    pairs1=sum(sum(pairs(1,:)));
    pairs2=sum(sum(pairs(2,:)));
    
    
    seedHidd(y,:)=totHidd;
    seedCont(y,:)=totCont;
    seedExp(y,:)=totExp;
    seedPairs1(y,:)=pairs1;
    seedPairs2(y,:)=pairs2;
    seedPairsN(y,:)=net;
    
    sucbywlantotal(y+((N_WLANs-1)*(y-1)):y*N_WLANs,:)=sucbywlan;
    nsucbywlantotal(y+((N_WLANs-1)*(y-1)):y*N_WLANs,:)=nsucbywlan;
    
end

%%%%%%%%% HN/EN
figure(112);clf
boxplot([seedHidd./(N_WLANs+N_STAs),abs(seedExp)./(N_WLANs+N_STAs)])
set(gca,'fontsize',14);
ylabel('Avg. per node')
xticklabels({'Hidden nodes','Exposed nodes'})
set(gca,'fontsize',16);
