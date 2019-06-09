function gray=grayfeature(GPeq,maxvalue)


gray_entropy=0;
for i=1:maxvalue+1
    if GPeq(i)>0
        gray_entropy=gray_entropy-GPeq(i)*log2(GPeq(i));
    end
end

gray_mean=0;
for i=0:maxvalue
    gray_mean=gray_mean+i*GPeq(i+1);
end
gray_std=0;
for i=0:maxvalue
    gray_std=gray_std+(i-gray_mean)^2*GPeq(i+1);
end

gray_Skewness=0;
for i=0:maxvalue
    gray_Skewness=gray_Skewness+(i-gray_mean)^3*GPeq(i+1);
end
gray_Skewness = gray_Skewness / ((sqrt(gray_std))^3);

gray_kur=0;
for i=0:maxvalue
    gray_kur=gray_kur+(i-gray_mean)^4*GPeq(i+1);
end
gray_kur = (gray_kur / (gray_std^2) - 3);

gray=[gray_std,gray_entropy,gray_Skewness, gray_kur];

end


            

