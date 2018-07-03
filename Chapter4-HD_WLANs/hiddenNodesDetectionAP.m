function[totCont,totHidd,totExp,hiddNod,contNod]= hiddenNodesDetectionAP(wlan,STA,NodeMatrix,picks)

N_STAs=length(STA);
N_WLANs=length(wlan);
hiddNod=zeros((N_WLANs+N_STAs),(N_WLANs+N_STAs));
contNod=zeros(N_WLANs+N_STAs);
threshold=10;    
   for i=1:N_WLANs+N_STAs
       for j=1:N_WLANs+N_STAs
           if(i<=N_WLANs && j<=N_WLANs)
               if(NodeMatrix(i,j)<wlan(i).CCA && i~=j && wlan(i).stas~=0 && wlan(j).stas~=0 && wlan(i).channel==wlan(j).channel)
                   Pr1=NodeMatrix((picks(i)+N_WLANs),i);
                   Pr2=NodeMatrix((picks(i)+N_WLANs),j);
                   if(Pr1-Pr2<threshold)
                        string='AP';
                        string=strcat(string,num2str(j));
                        string=strcat(string,' is a hidden node of AP ');
                        string=strcat(string,num2str(i));
                        string=strcat(string,' IN STA ');
                        string=strcat(string,num2str(picks(i)));
                        %disp(string);  % To see in console all detections
                        hiddNod(i,j)=hiddNod(i,j)+1; %j is a hidden node of i in its receiver
                   end
               end
               if(NodeMatrix(i,j)>wlan(i).CCA && i~=j && wlan(i).stas~=0 && wlan(j).stas~=0 && wlan(i).channel==wlan(j).channel)
                   contNod(i,j)=contNod(i,j)+1; % j is a contending node of i
                   Pr1=NodeMatrix(picks(i)+N_WLANs,i);
                   Pr2=NodeMatrix(picks(i)+N_WLANs,j);
                   if( Pr1-Pr2>=threshold)
                       hiddNod(i,j)=hiddNod(i,j)-1; % j is an exposed node of i

                   end
               end
           end
           if(i<=N_WLANs && j>N_WLANs)
              if(NodeMatrix(i,j)<wlan(i).CCA && wlan(i).stas~=0 &&  STA(j-N_WLANs).anch~=0 && wlan(i).channel==wlan(STA(j-N_WLANs).anch).channel)
                   Pr1=NodeMatrix((picks(i)+N_WLANs),i);
                   Pr2=NodeMatrix((picks(i)+N_WLANs),j);
                   if(Pr1-Pr2<threshold)
                        string='STA';
                        string=strcat(string,num2str(j-N_WLANs));
                        string=strcat(string,' is a hidden node of AP ');
                        string=strcat(string,num2str(i));
                        string=strcat(string,' IN STA ');
                        string=strcat(string,num2str(picks(i)));
                        %disp(string);
                        hiddNod(i,j)=hiddNod(i,j)+1;
                   end
              end
              if(NodeMatrix(i,j)>wlan(i).CCA && wlan(i).stas~=0 &&  STA(j-N_WLANs).anch~=0 && STA(j-N_WLANs).anch~=i && wlan(i).channel==wlan(STA(j-N_WLANs).anch).channel)
                   Pr1=NodeMatrix(picks(i)+N_WLANs,i);
                   Pr2=NodeMatrix(picks(i)+N_WLANs,j);
                    contNod(i,j)=contNod(i,j)+1; % j is a contending node of i
                   if( Pr1-Pr2>=threshold)
                        hiddNod(i,j)=hiddNod(i,j)-1; % j is an exposed node of i

                    end
              else if (NodeMatrix(i,j)>wlan(i).CCA && wlan(i).stas~=0 &&  STA(j-N_WLANs).anch~=0 && STA(j-N_WLANs).anch==i)
                    contNod(i,j)=contNod(i,j)+1; % j is a contending  node of i
                  end
              end
           end
           if(i>N_WLANs && j<=N_WLANs)
               if(NodeMatrix(i,j)<STA(i-N_WLANs).CCA && wlan(j).stas~=0 && STA(i-N_WLANs).anch~=0 && wlan(STA(i-N_WLANs).anch).channel==wlan(j).channel)
                   Pr1=NodeMatrix(STA(i-N_WLANs).anch,i);
                   Pr2=NodeMatrix(STA(i-N_WLANs).anch,j);
                   if(Pr1-Pr2<threshold)
                        string='AP';
                        string=strcat(string,num2str(j));
                        string=strcat(string,' is a hidden node of STA ');
                        string=strcat(string,num2str(i-N_WLANs));
                        string=strcat(string,' IN AP ');
                        string=strcat(string,num2str(STA(i-N_WLANs).anch));
                        %disp(string);
                        hiddNod(i,j)=hiddNod(i,j)+1;
                   end
               end
               if(NodeMatrix(i,j)>STA(i-N_WLANs).CCA && wlan(j).stas~=0 && STA(i-N_WLANs).anch~=0 && STA(i-N_WLANs).anch~=j && wlan(STA(i-N_WLANs).anch).channel==wlan(j).channel)
                    contNod(i,j)=contNod(i,j)+1; % j is a contending node of i
                    Pr1=NodeMatrix(STA(i-N_WLANs).anch,i);
                    Pr2=NodeMatrix(STA(i-N_WLANs).anch,j);
                    if( Pr1-Pr2>=threshold)
                        hiddNod(i,j)=hiddNod(i,j)-1; % j is an exposed node of i
                    end
               else if(NodeMatrix(i,j)>STA(i-N_WLANs).CCA && wlan(j).stas~=0 && STA(i-N_WLANs).anch~=0 && STA(i-N_WLANs).anch==j)
                       contNod(i,j)=contNod(i,j)+1; %contending
                       
                   end
               end
           end
           
           if(i>N_WLANs && j>N_WLANs)
               if(NodeMatrix(i,j)<STA(i-N_WLANs).CCA && i~=j && STA(j-N_WLANs).anch~=0 && STA(i-N_WLANs).anch~=0 && wlan(STA(i-N_WLANs).anch).channel==wlan(STA(j-N_WLANs).anch).channel)
                   Pr1=NodeMatrix(STA(i-N_WLANs).anch,i);
                   Pr2=NodeMatrix(STA(i-N_WLANs).anch,j);
                   if(Pr1-Pr2<threshold)
                        string='STA';
                        string=strcat(string,num2str(j-N_WLANs));
                        string=strcat(string,' is a hidden node of STA ');
                        string=strcat(string,num2str(i-N_WLANs));
                        string=strcat(string,' IN AP ');
                        string=strcat(string,num2str(STA(i-N_WLANs).anch));
                        %disp(string);
                        hiddNod(i,j)=hiddNod(i,j)+1;
                   end
               end
               if(NodeMatrix(i,j)>STA(i-N_WLANs).CCA && i~=j && STA(j-N_WLANs).anch~=0 && STA(i-N_WLANs).anch~=0 && STA(i-N_WLANs).anch~=STA(j-N_WLANs).anch && wlan(STA(i-N_WLANs).anch).channel==wlan(STA(j-N_WLANs).anch).channel)
                   contNod(i,j)=contNod(i,j)+1; % j is a contending node of i                  
                   Pr1=NodeMatrix(STA(i-N_WLANs).anch,i);
                  Pr2=NodeMatrix(STA(i-N_WLANs).anch,j);
                   if( Pr1-Pr2>=threshold)
                    hiddNod(i,j)=hiddNod(i,j)-1; % j is an exposed node of i
                  end
               else if(NodeMatrix(i,j)>STA(i-N_WLANs).CCA && i~=j && STA(j-N_WLANs).anch~=0 && STA(i-N_WLANs).anch~=0 && STA(i-N_WLANs).anch==STA(j-N_WLANs).anch )
                   contNod(i,j)=contNod(i,j)+1; % j is a contending node of i
                   end
               end
           end
           
       end
   end
   
   totHidd=sum(sum(hiddNod(hiddNod>0)));    % Total hidden nodes
   totCont=sum(sum(contNod(contNod>0)));    % Total contending nodes
   totExp=sum(sum(hiddNod(hiddNod<0)));     % Total exposed nodes
  