function[wlan,STA,NodeMatrix]=CCAadjustALg(wlan,STA,shadowingmatrix,NodeMatrix)

N_WLANs=length(wlan);
N_STAs=length(STA);
CSMax=-42;
margin=-10;
for i=1:N_STAs
    checkAP=STA(i).anch;
    if(checkAP~=0)
        APSignal=NodeMatrix(i+N_WLANs,checkAP);
    else
        APSignal=0;
    end
        newCCA=floor(min(CSMax,APSignal+margin));
    
    STA(i).CCA=max(newCCA,-82);
end
