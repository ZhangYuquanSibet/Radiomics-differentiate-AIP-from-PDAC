function [auc,ACC,SPE,SEN,PPV,NPV] = get_auc(stack_x,stack_y)
auc = sum((stack_x(2:length(stack_x))-stack_x(1:length(stack_x)-1)).*stack_y(2:length(stack_x)));
Jordon = stack_y+1-stack_x;
n = find(Jordon==max(Jordon));
%plot(stack_x(n)*100,stack_y(n)*100,'.','Color','k','markersize',15);
SPE = 1-stack_x(n);
SEN = stack_y(n);
%stack_y(n): TPR   stack_x(n):FPR
TP = round(SEN*66);
FN = 66-TP;
FP = round(stack_x(n)*45);
TN = 45-FP;
PPV = TP / (TP + FP);%PPV
NPV = TN / (TN + FN);
ACC = (TP+TN)/111;
