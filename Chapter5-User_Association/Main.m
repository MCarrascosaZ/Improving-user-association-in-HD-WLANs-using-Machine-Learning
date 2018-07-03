%%%%%%%%CENTRAL PROCESSING%%%%%%%%%%%%%%%
rng('default');
seed=12+99;

MaxSim=100; %Number of seeds to use
CCA=-82;    %Clear Channel Assessment
N_APs=4;  %Number of APs
N_STAs=10;   %Number of STAs
L=12000;    %Packet size
CWmin=16;   %Minimum contention window, for every node
SLOT=9E-6;  %OFDM time slot
MaxIter=100; %Number of e-greedy iterations
greedy=1;   % Use greedy alg or leave it at SSF

AggrSatisf=zeros(MaxSim*N_STAs,MaxIter+1);  % Holds all satisfaction 
AggrSticky=zeros(MaxSim,N_STAs);    % Holds all sticky counters
AggrEpsilon=zeros(MaxSim*N_STAs,3); % Holds all epsilon usage
AggrBe=zeros(MaxSim,N_STAs*2);  % Holds Bw obtained/ Bw desired
AggrBes=zeros(MaxSim,N_STAs);   % Holds Bw obtained with SSF
AggrBs=zeros(MaxSim,N_STAs);    % Holds Bw obtained with epsilon

countS=0;   % Counts the amount of times every possible STA is satisfied
iterFound=zeros(3,MaxSim);  % First row is first iteration convergence was found, second is last
AggrNA_STAS=zeros(MaxSim,1);    
for y=1:MaxSim
    
    rng(seed+y);  %Sets seed for all number generators
    
    [AP,STA,NodeMatrix,shadowingmatrix]=CreateNetwork(N_APs,N_STAs,L,CWmin,SLOT);
    for i=1:N_STAs
        for j=1:N_APs
            if(NodeMatrix(i+N_APs,j)>=CCA)
                STA(i).nAPs=STA(i).nAPs+1;  % Number of APs in range
                STA(i).APs_range(STA(i).nAPs) = j;  % Ids of APs in range
                STA(i).APs(j)=NodeMatrix(i+N_APs,j);    % RSSI of APs in range
            end
        end
    end
    [AP,STA,Associated]=SSFAssoc(AP,STA,NodeMatrix);
    
    NA_STAs=0;  % Not Associated STAs due to bad signal
    for i=1:N_STAs
        if(STA(i).associated_AP==0)
            NA_STAs=NA_STAs+1;
        end
    end
    AggrNA_STAS(y)=NA_STAs;
    
    %Redraw(CCA,AP,STA,NodeMatrix,2);
   
    Bmax=10E6;
    
    %[AP,STA]=nodeLoad(AP,STA, Bmax,NodeMatrix,1);  % For random demands
    
    
    
    if(greedy==1)
        balance=[0 0 0];
        gen_Be=zeros(N_STAs*2,2); % First value Be, second B
        for j=1:N_STAs
            STA(j).satisf=zeros(1,MaxIter+1);   % Satisfaction
            STA(j).expl=zeros(1,MaxIter);   % Exploitation            
        end
        
        for i=1:MaxIter
            satisfied=0;
            
            [AP,STA]=nodeLoad(AP,STA, Bmax,NodeMatrix,i);
            
            if(i==1)    %   SSF values
               for j=1:N_STAs
                   gen_Be(j,1)=STA(j).Be;
                   gen_Be(j,2)=STA(j).B;
               end
            end
            
            for j=1:N_STAs
                if(i>1)
                    if(STA(j).satisf(i)>STA(j).satisf(i-1))
                        satisfied=satisfied+1;
                    end
                else
                    if(STA(j).satisf(i)==1)
                        satisfied=satisfied+1;
                    end
                end
            end
            if(satisfied==(N_STAs-NA_STAs))
                str=num2str(i);
                str2='ALL STAs SATISFIED IN ITERATION: ';
                str3=strcat(str2,str);
                disp(str3);
                countS=countS+1;
                if(balance(1,1)==0) % Stores first iteration of convergence
                    balance(1,1)=i;
                else
                    balance(1,2)=i; % Stores last iteration of convergence
                end
            end
           
            %[STA]=epsilon_greedy(STA,i,1);%1/sqrt(i)1-(i/MaxIter)
            [STA]=epsilon_greedy_sticky(STA,i);
            
        end
        %%%% Checks satisfaction for iteration 101 after last decision %%%%
        
        [AP,STA]=nodeLoad(AP,STA, Bmax,NodeMatrix,MaxIter+1); 
        satisfied=0;
        for j=1:N_STAs            
            if(STA(j).satisf(MaxIter+1)>STA(j).satisf(MaxIter))
                satisfied=satisfied+1;
            end            
        end        
        
        if(satisfied==(N_STAs-NA_STAs))               
                countS=countS+1;
                if(balance(1,1)==0)
                    balance(1,1)=101;
                else
                    balance(1,3)=101;
                end
                
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
         gen_satisf=zeros(N_STAs,length(STA(1).satisf)); % Stores satisfaction of entire round in a matrix
         gen_sticky=zeros(N_STAs,1);
         gen_epsilon=zeros(N_STAs,3); 
         for j=1:N_STAs              
            gen_satisf(j,:)=STA(j).satisf;         
            gen_sticky(j,:)=STA(j).sticky(1);
            gen_Be(j+N_STAs,1)=STA(j).Be;
            gen_Be(j+N_STAs,2)=STA(j).B;
            gen_epsilon(j,:)=STA(j).Epsilon(2,:);
         end
        %Redraw(CCA,AP,STA,NodeMatrix,3);   % Draws last association
        
        
        AggrSatisf((1:N_STAs)+(N_STAs*(y-1)),:)=gen_satisf;
        AggrSticky(y,:)=gen_sticky;
        AggrEpsilon((1:N_STAs)+(N_STAs*(y-1)),:)=gen_epsilon;
        AggrBe(y,:)=gen_Be(:,1)./gen_Be(:,2);
        AggrBes(y,:)=gen_Be(1:N_STAs,1)'; %% SSF
        AggrBs(y,:)=gen_Be(N_STAs+1:N_STAs*2,1)'; %% e
    end
    
    iterFound(1:3,y)=balance';
    
    
end


%%%%% Figures
figure(1);
bar([mean(mean(AggrBe(:,1:N_STAs)))',mean(mean(AggrBe(:,N_STAs+1:N_STAs*2)))']);
x=char(949);
set(gca,'fontsize',14);
str=strcat(x,'-greedy');
set(gca,'xticklabels',{'SSF',str});
ylabel('BW obtained/BW desired')


figure(2);
boxplot([mean(AggrBe(:,1:N_STAs))',mean(AggrBe(:,N_STAs+1:N_STAs*2))']);
x=char(949);
set(gca,'fontsize',14);
str=strcat(x,'-greedy');
set(gca,'xticklabels',{'SSF',str});
ylabel('BW obtained/BW desired')

figure(3);
plot(mean(AggrSatisf))
set(gca,'fontsize',14)
xlabel('Iteration')
ylabel('Mean satisfaction')


[vals,probs]=calcProb(iterFound);
% disp('Iterations where convergence was maintained');
% disp(vals);
disp('Iterations where algorithm converged');
disp(probs(1));
disp('Iterations where convergence was found with SSF');
disp(probs(2));
