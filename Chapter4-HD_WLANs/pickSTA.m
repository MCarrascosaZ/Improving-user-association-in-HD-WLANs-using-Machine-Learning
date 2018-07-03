function picks = pickSTA(Associated)
% Picks a random STA from the ones associated to each AP % 
    totals=zeros(2,size(Associated,2));
    picks=zeros(1,size(Associated,2));
    totals(1,:)=sum(Associated);    % Total amount of STAs in each AP
    totals(2,:)=ceil(rand(1,size(Associated,2)).*totals(1,:));  % Picks a random number based on the total STAs in each AP
    for i=1:size(Associated,2)
        counter=1;
        for j=1:size(Associated,1)
            if(Associated(j,i)==1)
                if(counter==totals(2,i))    % Converts the number to the actual STA ID
                    picks(i)=j;
                    break;
                else
                    counter=counter+1;
                end
            end
        end
    end
            
    