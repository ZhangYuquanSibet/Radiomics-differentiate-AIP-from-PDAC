
function T=gray_diff(image,mask)
I = image;
C1=gray_diff_pic(I,1,0);
C2=gray_diff_pic(I,1,1);
C3=gray_diff_pic(I,0,1);
C4=gray_diff_pic(I,-1,1);
C = (C1+C2+C3+C4)/4;
[m,n] = size(C);
vals=[];
for i=1:m
    for j=1:n
        if mask(i,j)
            vals=[vals,C(i,j)];
        end
    end
end
  
h=zeros(1,max(I(:))+1);
for k=0:max(I(:))
     h(k+1)=length(find(vals==k))/length(vals);  
end 
    
MEAN=0;  
CON=0;   
ASM=0;    
ENT=0;   
for i=1:max(I(:))+1
    MEAN=MEAN+(i*h(i))/(max(I(:))+1);    
    
    CON=CON+i*i*h(i);    
    ASM=ASM+h(i)*h(i);  
    if(h(i)>0)
    ENT=ENT-h(i)*log2(h(i));   
    end
end
T=[MEAN,CON,ASM,ENT]; 

