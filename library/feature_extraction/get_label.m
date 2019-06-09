
function label = get_label(image)
[row,col] = size(image);
label = zeros(size(image));
for i=1:row
    for j=1:col
        if ~isnan(image(i,j))
            label(i,j)=1;
        else
            label(i,j)=0;
         end
     end
end