% �ҶȲ��ͼ
%����ͼ��Ҷȼ���Ϊ256
function C=gray_diff_pic(image,a,b)
I=image;   %��ȡͼ��
A=double(I);    %ת����double����
[m,n]=size(A);    %�õ�ͼ��ĸ߶ȺͿ��
B=A;
C=ones(m,n)*NaN;
for i=2:m-1              
    for j=2:n-1
        B(i,j)=A(i+a,j+b);
        C(i,j)=abs(round(A(i,j)-B(i,j)));    %����ҶȲ��ͼ��
    end
end

