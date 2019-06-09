% 灰度差分图
%所用图像灰度级均为256
function C=gray_diff_pic(image,a,b)
I=image;   %读取图像
A=double(I);    %转换成double类型
[m,n]=size(A);    %得到图像的高度和宽度
B=A;
C=ones(m,n)*NaN;
for i=2:m-1              
    for j=2:n-1
        B(i,j)=A(i+a,j+b);
        C(i,j)=abs(round(A(i,j)-B(i,j)));    %计算灰度差分图像
    end
end

