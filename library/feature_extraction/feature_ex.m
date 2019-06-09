function feature=feature_ex(image)

label = get_label(image);
[row, col] = size(image);
vals=[];
for i=1:row
    for j=1:col
        if label(i,j)
            vals=[vals,image(i,j)];
        end
    end
end
GP=zeros(1,max(vals)+1);
for k=0:max(vals)
     GP(k+1)=length(find(vals==k))/length(vals); 
                                                 
end 

feature=grayfeature(GP,max(vals)); 
end








