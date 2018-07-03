function [wlan,STA,Associated]=SSFAssoc(wlan,STA,NodeMatrix)

N_WLANs=length(wlan);
N_STAs=length(STA);
Associated=zeros(N_STAs,N_WLANs);

for i=1:N_STAs
    highest_RP=STA(i).CCA;
    minx=0;
    miny=0;
    for j=1:N_WLANs
        if(NodeMatrix(i+N_WLANs,j)>highest_RP)
            highest_RP=NodeMatrix(i+N_WLANs,j);
            minx=i;
            miny=j;
        end
    end
    if(minx~=0 && miny~=0)
        Associated(minx,miny)=1;
        STA(i).anch=miny;
        
    end
end

for i=1:N_WLANs    
    wlan(i).stas=sum(Associated(:,i));
end

end