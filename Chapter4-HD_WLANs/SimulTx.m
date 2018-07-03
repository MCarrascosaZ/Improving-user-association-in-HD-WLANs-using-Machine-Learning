function [tx]=SimulTx(wlan,STA,picks)

N_STAs=length(STA);
N_WLANs=length(wlan);
tx=zeros(N_WLANs+N_STAs);   % Holds the receiver for each node

for i=1:N_WLANs+N_STAs


if(i<=N_WLANs && wlan(i).stas~=0)
    tx(i,picks(i)+N_WLANs)=tx(i,picks(i)+N_WLANs)+1;
else if(i>N_WLANs && STA(i-N_WLANs).anch~=0)
    tx(i,STA(i-N_WLANs).anch)=tx(i,STA(i-N_WLANs).anch)+1;
    end
end

end  

            
            
