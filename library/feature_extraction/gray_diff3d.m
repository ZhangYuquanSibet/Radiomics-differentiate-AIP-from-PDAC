
function T=gray_diff3d(img1,Nbins)
I=img1;   
C1=gray_diff3d_pic(img1,1,1,0); 
C2=gray_diff3d_pic(img1,0,1,0); 
C3=gray_diff3d_pic(img1,-1,1,0); 
C4=gray_diff3d_pic(img1,-1,0,0); 
C5=gray_diff3d_pic(img1,1,1,1); 
C6=gray_diff3d_pic(img1,0,1,1); 
C7=gray_diff3d_pic(img1,-1,1,1); 
C8=gray_diff3d_pic(img1,-1,0,1); 
C9=gray_diff3d_pic(img1,1,1,-1); 
C10=gray_diff3d_pic(img1,0,1,-1); 
C11=gray_diff3d_pic(img1,-1,1,-1); 
C12=gray_diff3d_pic(img1,-1,0,-1); 
C13=gray_diff3d_pic(img1,0,0,1); 

C = (C1+C2+C3+C4+C5+C6+C7+C8+C9+C10+C11+C12+C13)/13;


ROIonly = C;
vectorValid = ROIonly(~isnan(I));
histo = hist(vectorValid,Nbins);
histo = histo./(sum(histo(:)));


h = histo;
  
MEAN=0;   
CON=0;   
ASM=0;  
ENT=0;    
for i=1:Nbins
    MEAN=MEAN+(i*h(i));  
    
    CON=CON+i*i*h(i);   
    ASM=ASM+h(i)*h(i);    
    if(h(i)>0)
    ENT=ENT-h(i)*log2(h(i));   
    end
end
T=[MEAN,CON,ASM,ENT]; 