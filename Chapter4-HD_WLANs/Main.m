%%%%MAIN%%%%
clear;clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_WLANs=4;  %Number of APs
N_It=10;    %Number of iterations
CCAAdjust=0;    % CCA adjustment, 0 for deactivated, 1 for activated
TPAdjust=0;     % Transmission power adjustment, 0 for deactivated, 1 for activated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stasMax=[4, 10:10:100];
N_Slots=200;
seedHidd=zeros(N_It,length(stasMax)); % Stores the Hidden nodes for all iterations
seedCont=zeros(N_It,length(stasMax)); % Stores the Contending nodes for all iterations
seedExp=zeros(N_It,length(stasMax));  % Stores the Pairs unseen by networks for all iterations
PTs=zeros(N_It*length(stasMax),6); %  Stores the amount of STAs that used each TP
ccas=zeros(N_It*length(stasMax),stasMax(length(stasMax)));    % CCA used by each STA

seedCentralHidd=zeros(N_It,length(stasMax));    % Central nodes
seedCentralCont=zeros(N_It,length(stasMax));
seedCentralExp=zeros(N_It,length(stasMax));
totsucTx=zeros(N_It*length(stasMax),N_WLANs+stasMax(length(stasMax)));  % Successful transmissions
totunsucTx=zeros(N_It*length(stasMax),N_WLANs+stasMax(length(stasMax)));


for y=1:N_It
    disp(y)
    
    seed=y+82;
    rng(seed);  %Sets seed for all number generators
    kHidd=zeros(1,1);
    kCont=zeros(1,1);
    kExp=zeros(1,1);
    
    totscentral=zeros(1,length(stasMax));   % Stores each k iteration
    totscentralc=zeros(1,length(stasMax));
    totscentrale=zeros(1,length(stasMax));
    ksucTx=zeros(length(stasMax),N_WLANs+stasMax(length(stasMax)));
    kunsucTx=zeros(length(stasMax),N_WLANs+stasMax(length(stasMax)));
    ccask=zeros(length(stasMax),stasMax(length(stasMax)));    
    adjustedPTk=zeros(length(stasMax),6);    
    
    for k=1:length(stasMax)
        
        CCA=-82;    %Clear Channel Assessment
        N_WLANs=4;  %Number of APs
        N_STAs=stasMax(k);   %Number of STAs
        L=12000;    %Packet size
        CWmin=16;   %Minimum contention window, for every node
        SLOT=9E-6;  %OFDM time slot
        
        [wlan,STA,NodeMatrix,shadowingmatrix]=CreateNetwork(N_WLANs,N_STAs,L,CWmin,SLOT);
        [wlan,STA,Associated]=SSFAssoc(wlan,STA,NodeMatrix);
        picks=pickSTA(Associated);
        [tx]=SimulTx(wlan,STA,picks);
        %Redraw(-82,wlan,STA,NodeMatrix,7);
        
        if(CCAAdjust==1)
            [wlan,STA,NodeMatrix]=CCAadjustALg(wlan,STA,shadowingmatrix,NodeMatrix);   % Adjusts the CCA for the STAs
            for t=1:N_STAs
                ccask(k,t)=STA(t).CCA;
            end
        end
        if(TPAdjust==1)
            [wlan,STA,NodeMatrix]=PTadjust(wlan,STA,shadowingmatrix,NodeMatrix);    % Adjusts the Transmission Power for the STAs
            adjustedPTk(k,:)=counter(STA);    % Counts how many STAs use each TP
        end
        
        [totCont,totHidd,totExp,hiddNod,contNod]= hiddenNodesDetectionAP(wlan,STA,NodeMatrix,picks);        
        [totTx,totUTx,sucTx,unsucTx]=simulTxSlot(wlan,STA,tx,hiddNod,contNod,NodeMatrix,N_Slots);
        
        if(size(sucTx,2)<size(ksucTx,2))
            sucTx(size(ksucTx,2))=0;
            unsucTx(size(kunsucTx,2))=0;
        end
        ksucTx(k,:)=sucTx;
        kunsucTx(k,:)=unsucTx;        
        kHidd(k)=totHidd;
        kCont(k)=totCont;
        kExp(k)=totExp;
                
        %%%%%%%%%%%%%%% GETS THE CENTRAL NETWORK'S HN/EN
        rows=zeros(1,N_WLANs+N_STAs);
        rowsc=zeros(1,N_WLANs+N_STAs);
        rows(1,:)=hiddNod(1,:);
        rowsc(1,:)=contNod(1,:);
        centStas=zeros(1,N_STAs);
        
        for x=1:N_STAs
            if(STA(x).anch==1)
                centStas(x)=1;
            end
        end
        centralNodes=sum(centStas)+1;
        for z=1:N_STAs
            if(centStas(z)==1)
                rows(z+N_WLANs,:)=hiddNod(z+N_WLANs,:);
                rowsc(z+N_WLANs,:)=contNod(z+N_WLANs,:);
            end
        end
        
        hiddenCentral=sum(sum(rows>0))/centralNodes;
        contendingCentral=sum(sum(rowsc(rowsc>0)))/centralNodes;
        exposedCentral=sum(sum(rows(rows<0)))/centralNodes;
        
        totscentral(k)=hiddenCentral;
        totscentralc(k)=contendingCentral;
        totscentrale(k)=exposedCentral;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    ccas(((y-1)*(length(stasMax)))+1:(y*length(stasMax)),:)=ccask;    
    totsucTx(((y-1)*(length(stasMax)))+1:(y*length(stasMax)),:)=ksucTx;
    totunsucTx(((y-1)*(length(stasMax)))+1:(y*length(stasMax)),:)=kunsucTx;
    seedHidd(y,:)=kHidd;
    seedCont(y,:)=kCont;
    seedExp(y,:)=kExp;
    
    seedCentralHidd(y,:)=totscentral;
    seedCentralCont(y,:)=totscentralc;
    seedCentralExp(y,:)=totscentrale;
    
    
    PTs(((y-1)*(length(stasMax)))+1:(y*length(stasMax)),:)=adjustedPTk;
    
end

%%%%%%%% Figures
figure(1);clf
b=bar([mean(abs(seedHidd)./((stasMax+N_STAs).*ones(N_It,length(stasMax))))',mean(abs(seedCentralHidd))']);
legend('Hidden nodes','Hidden nodes in central network','Location','best')
set(gca,'fontsize',14);
xticklabels([stasMax])
xlabel('Number of STAs')
ylabel('Avg. per node')

figure(2);clf;
b=bar([mean(abs(seedExp)./((stasMax+N_STAs).*ones(N_It,length(stasMax))))',mean(abs(seedCentralExp))']);
legend('Exposed nodes','Exposed nodes in central network','Location','best')
set(gca,'fontsize',14);
xticklabels([stasMax])
xlabel('Number of STAs')
ylabel('Avg. per node')

allsucTx=zeros(1,length(stasMax));
allnsucTx=zeros(1,length(stasMax));
for j=1:length(stasMax)
    sucTxit=totsucTx(j:length(stasMax):end,1:stasMax(j)+N_WLANs);
    allsucTx(j)=mean(mean(sucTxit));
    nsucTxit=totunsucTx(j:length(stasMax):end,1:stasMax(j)+N_WLANs);
    allnsucTx(j)=mean(mean(nsucTxit));
end

figure(3);clf;
bar([(allsucTx./N_Slots)',(allnsucTx./N_Slots)']);
xticklabels([4, 10:10:100])
legend('Successful tranmission','Unsuccessful transmission','Location','best')
set(gca,'fontsize',14);
xlabel('Number of STAs','fontsize',14)
ylabel('Avg. transmissions per node per slot','fontsize',14)