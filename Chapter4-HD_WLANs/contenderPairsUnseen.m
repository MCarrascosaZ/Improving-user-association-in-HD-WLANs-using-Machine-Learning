function [sensedNodes,pairs,net]=contenderPairsUnseen(wlan,STA,NodeMatrix,contNod)
N_WLANs=length(wlan);
N_STAs=length(STA);
sensedNodes=contNod;

pairs=zeros(2,N_WLANs+N_STAs); %first row they can see eachother, second row they can't
net=zeros(1,N_WLANs);
for i=1:(N_WLANs+N_STAs)
    for j=1:(N_WLANs+N_STAs)
        if(sensedNodes(i,j)==1) % If node j is a contender of node i
            for k=1:(N_WLANs+N_STAs)
                if(j~=k && k>j && sensedNodes(i,k)==1)  % If the node next to node j is also a contender of node i
                    n1=sensedNodes(j,k);
                    n2=sensedNodes(k,j);
                    if(n1==1)
                        pairs(1,i)=pairs(1,i)+1/2;    % node j senses node k
                    end
                    if(n2==1)
                        pairs(1,i)=pairs(1,i)+1/2;    % node k senses node j
                      
                    end
                    if(n1==0)
                        pairs(2,i)=pairs(2,i)-1/2;
                         if(i<=N_WLANs)
                            net(i)=net(i)+1/2;  % Stores the ones that come from WLANs
                        end
                    end
                    if(n2==0)
                        pairs(2,i)=pairs(2,i)-1/2;
                          if(i<=N_WLANs)
                            net(i)=net(i)+1/2;
                        end
                    end
                end
            end
        end
    end
end
end
