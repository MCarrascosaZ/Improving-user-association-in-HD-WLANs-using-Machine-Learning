function [STA] = epsilon_greedy(STA,iter,Epsilon)
N_STAs=length(STA);

for i=1:N_STAs 
    
    if(rand() < Epsilon)
%         disp('Explore--------------');
        STA(i).associated_AP = STA(i).APs_range(ceil(length(STA(i).APs_range)*rand));
        
    else
%         disp('Exploit--------------');
        [x,index]=max(STA(i).APs_reward);
        if(x~=0)
            STA(i).associated_AP = index;
            STA(i).expl(iter)=STA(i).expl(iter)+1;
        end
    end

end

end
