function[wlan,STA,NodeMatrix]=PTadjust(wlan,STA,shadowingmatrix,NodeMatrix)

N_WLANs=length(wlan);
N_STAs=length(STA);
PLd1=40.05;
alfa=4.4;
fc=5;
d_walls=10;
for i=1:N_STAs
    SSFAP=STA(i).anch;
        if(SSFAP~=0)
            %%%%%%%%%%%%%%%%%%%%%%%%%% Power Received at each node from an AP
        d=sqrt((STA(i).x-wlan(SSFAP).x)^2+(STA(i).y-wlan(SSFAP).y)^2);
        
        % Propagation model
        %PL = PLd1 + 10*alfa*log10(d) + shadowingmatrix(i+N_WLANs,SSFAP) ;
        PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i+N_WLANs,SSFAP) ;
        %%%%%%Choosing power output
        option=[20,10,5,0,-5,-10];
        
        for k=1:length(option)
            if(option(k)-PL>wlan(SSFAP).CCA)
                STA(i).Pt=option(k);
            end
        end
%         if(option(3)-PL>-82)
%             STA(i).Pt=option(3);
%         else if(option(2)-PL>-82)
%                 STA(i).Pt=option(2);
%             else
%                 STA(i).Pt=option(1);
%             end
%         end
        
        else
            STA(i).Pt=20;
        end
end
    
    %%%%%%%%REDO NRP
    
    for i=1:N_WLANs+N_STAs
        for j=1:N_WLANs+N_STAs
            
            if(i<=N_WLANs && j>N_WLANs)
                d=sqrt((wlan(i).x-STA(j-N_WLANs).x)^2+(wlan(i).y-STA(j-N_WLANs).y)^2);
                alfa=4.4;
                %PL = PLd1 + 10*alfa*log10(d) + shawdowing*randn(1) + (d/10).*obstacles.*rand(1);
                %PL = PLd1 + 10*alfa*log10(d) + shadowingmatrix(i,j) ;
                PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
                %RP(i,j)=PTdBm-PL;
                NodeMatrix(i,j)=STA(j-N_WLANs).Pt-PL;
            end
            
            if(i>N_WLANs && j>N_WLANs)
                d=sqrt((STA(i-N_WLANs).x-STA(j-N_WLANs).x)^2+(STA(i-N_WLANs).y-STA(j-N_WLANs).y)^2);
                alfa=4.4;
                %PL = PLd1 + 10*alfa*log10(d) + shawdowing*randn(1) + (d/10).*obstacles.*rand(1);
                %PL = PLd1 + 10*alfa*log10(d) + shadowingmatrix(i,j) ;
                PL = PLd1 + 20*log10(fc/2.4) +20*log10(min(d,10))+(d>=10)*35*log10(d/10) +7*(d/d_walls)+shadowingmatrix(i,j) ;
                %RP(i,j)=PTdBm-PL;
                NodeMatrix(i,j)=STA(j-N_WLANs).Pt-PL;
            end
        end
    end

 NodeMatrix(NodeMatrix==inf)=0;
    
    
    
    
    
    
    

end

        