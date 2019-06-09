function C=gray_diff3d_pic(img1,a,b,c)
I=img1;   
A=double(I);    
[m,n,z]=size(A);    
B=A;
C=ones(m,n,z)*NaN;
for i=2:m-1              
    for j=2:n-1
        for k = 2:z-1
               B(i,j,k)=A(i+a,j+b,k+c);
               C(i,j,k)=abs(round(A(i,j,k)-B(i,j,k)));
        end
    end
end
