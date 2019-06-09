%% evaluate the performance 
function [acc, Favg, sensitivity, specitivity,precision,NPV] = evaluate(pred, label)

num = 0;
for i = 1:length(label)
    if pred(i) == label(i)
        num = num+1;
    end
end
acc = num / length(label);
        
TP_num = 0;
for i = 1:length(label)
    if pred(i)==1 && label(i)==1
        TP_num = TP_num+1;
    end
end

FP_num = 0;
for i = 1:length(label)
    if pred(i)==1 && label(i)==0
        FP_num = FP_num+1;
    end
end

TN_num = 0;
for i = 1:length(label)
    if pred(i)==0 && label(i)==0
        TN_num = TN_num+1;
    end
end

FN_num = 0;
for i = 1:length(label)
    if pred(i)==0 && label(i)==1
        FN_num = FN_num+1;
    end
end

sensitivity = TP_num / (TP_num + FN_num);

specitivity = TN_num / (TN_num + FP_num);

precision = TP_num / (TP_num + FP_num);%PPV
NPV = TN_num / (TN_num + FN_num);

recall = TP_num / (TP_num + FN_num);

Favg = 2*precision*recall / (precision + recall);
