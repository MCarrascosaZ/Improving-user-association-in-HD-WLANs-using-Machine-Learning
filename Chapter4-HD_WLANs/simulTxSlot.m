function [totTx,totUTx,sucTx,unsucTx]=simulTxSlot(wlan,STA,tx,hiddNod,contNod,NodeMatrix,maxIt)

N_WLANs=length(wlan);
N_STAs=length(STA);
N_nodes=N_WLANs+N_STAs;
totTx=zeros(1,1);   % Total successful transmissions
totUTx=zeros(1,1);  % Total unsuccessful transmissions
for i=1:maxIt
    
    isTransm=zeros(1,N_nodes); %Nodes in order of transmission
    usedNodes=zeros(1,N_nodes); %Nodes checked
    for j=1:N_nodes
        nextNode=ceil(rand*N_nodes);
        while(true)
            if(usedNodes(nextNode)==1)
                nextNode=ceil(rand*N_nodes);
            else
                usedNodes(nextNode)=usedNodes(nextNode)+1;
                break;
            end
        end

                
        interm=hiddNod(nextNode,:);
        conflict=0;
        if(sum(tx(nextNode,:))>0)   %Checks if it can transmit to someone
            if(sum(contNod(nextNode,:))>=1 || sum(interm<0)>=1) %Checks if it has contenders
                for k=1:N_nodes
                    if(contNod(nextNode,k)==1 || hiddNod(nextNode,k)==-1)  %Finds the contender
                        if(ismember(k,isTransm)==1) %If contender is already transmitting, then we can't transmit
                            conflict=1;
                            break;  %A single conflict is enough
                        end
                    end
                end
            end
            if(conflict==0) %If no contender is transmitting or we have no contenders, we transmit
                isTransm(j)=nextNode;
            end
        end
    end

    isTransm=isTransm(isTransm>0);

    
    %Now we check for successful tx
    unsucTx=zeros(1,length(isTransm));
    for l=1:length(isTransm)
        if(isTransm(l)~=0 && ismember(1,hiddNod(isTransm(l),:)))
            for j=1:N_nodes
                if( hiddNod(isTransm(l),j)==1 && ismember(j,isTransm))
                    unsucTx(l)=isTransm(l);
                    
                end
            end
        end
    end
    isTransm=isTransm-unsucTx;
    isTransm=isTransm(isTransm>0);
    unsucTx=unsucTx(unsucTx>0);
    if(length(totTx(1,:))>length(isTransm))
        isTransm(1,length(totTx(1,:)))=0;
    else if(length(isTransm)>length(totTx(1,:)))
            totTx(1,length(isTransm))=0;
        end
    end
    if(length(totUTx(1,:))>length(unsucTx))
        unsucTx(1,length(totUTx(1,:)))=0;
    else if(length(unsucTx)>length(totUTx(1,:)))
        totUTx(1,length(unsucTx))=0;
        end
    end
    totTx(i,:)=isTransm;
    totUTx(i,:)=unsucTx;
    
end 

sucTx=zeros(1,N_nodes);
unsucTx=zeros(1,N_nodes);
for i=1:N_nodes
    sucTx(i)=sum(totTx(:)==i);
    unsucTx(i)=sum(totUTx(:)==i);
end


end
