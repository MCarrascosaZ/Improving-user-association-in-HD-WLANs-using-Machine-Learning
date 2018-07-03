function [STA] = epsilon_greedy_sticky(STA,iter)
N_STAs=length(STA);

% ----- Update Association -----

for i=1:N_STAs
    %STA(i).APs_reward(STA(i).associated_AP) = STA(i).APs_reward(STA(i).associated_AP) + STA(i).satisfaction; 
    
    
        if(STA(i).sticky(1)>0)
            %Epsilon=STA(i).Epsilon(1,1);   % Eps 0 for exploitation
            STA(i).Epsilon(2,1)=STA(i).Epsilon(2,1)+1;
            Epsilon=-1;
        else
            Epsilon=STA(i).Epsilon(1,2);
            %Epsilon=1/sqrt(iter);
            STA(i).Epsilon(2,2)=STA(i).Epsilon(2,2)+1;
        end
    
    
    %%%%%%%%%%%%%%%%%Epsilon choice end
    
    
    if(rand() < Epsilon)
        %disp('Explore--------------');
        ap=STA(i).associated_AP;
        [val,ind]=max(STA(i).APs_reward);
        apnew=STA(i).APs_range(ceil(length(STA(i).APs_range)*rand));
        while(true)
           if(apnew~=ind || length(STA(i).APs_range)==1)    % AP chosen does not have max reward, nor is it our only option
               break;
           else
               apnew=STA(i).APs_range(ceil(length(STA(i).APs_range)*rand));
           end 
        end
        STA(i).associated_AP = apnew;
        
        if(STA(i).associated_AP>0)
            STA(i).ass(STA(i).associated_AP)=STA(i).ass(STA(i).associated_AP)+1;    % Times associated to the AP
        end
    else
        %disp('Exploit--------------');
        [x,index]=max(STA(i).APs_reward);
        if(Epsilon>=0)
            if(x~=0)
                STA(i).associated_AP = index;
                STA(i).expl(iter)=STA(i).expl(iter)+1;
            else
                STA(i).associated_AP = STA(i).APs_range(ceil(length(STA(i).APs_range)*rand));
                STA(i).expl(iter)=STA(i).expl(iter)+1;
            end
        else
            % Nothing
        end
                
        if(STA(i).associated_AP>0)
            STA(i).ass(STA(i).associated_AP)=STA(i).ass(STA(i).associated_AP)+1;
        end
        
    end

end

end
