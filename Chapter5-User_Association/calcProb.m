function[vals,probs]= calcProb(array)

ssfb=0;
hund=0;
bal=0;
fin=0;
vals=0;

for i=1:size(array,2)
    if(array(1,i)>0 && array(2,i)==100 && array(3,i)==101)
        vals(i)=array(1,i);
    end
    if(array(1,i)>0)
        bal=bal+1;
        if(array(1,i)==1)
            ssfb=ssfb+1;
        end
    end
    if(array(2,i)==100)
        hund=hund+1;
    end
    if(array(3,i)==101)
        fin=fin+1;
    end
    
end
vals=vals(vals>0);

probs=[bal,ssfb,hund,fin ];
end