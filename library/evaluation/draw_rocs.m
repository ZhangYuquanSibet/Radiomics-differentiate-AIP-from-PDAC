function [auc_m,SPE,SEN,AUC,ACC,Spe,Sen,PPV,NPV] = draw_rocs(X,Y,color)
X(X>1) =1;
Y(Y>1) =1;
Y(isnan(Y))=0;
X = X*100;
Y = Y*100;
stack_x = mean(X);
stack_y = mean(Y);


plot(stack_x,stack_y,color,'LineWidth',1);

hold on
xlabel('1-SPE(%)','fontsize',14);
ylabel('SEN(%)','fontsize',14);
set(gca, 'XTick',0:10:100,'YTick',0:10:100,'FontSize',14);  


stack_x = stack_x/100;
stack_y = stack_y/100;
Jordon = stack_y+1-stack_x;
n = find(Jordon==max(Jordon));
plot(stack_x(n)*100,stack_y(n)*100,'.','Color','k','markersize',15);
SPE = 1-stack_x(n);
SEN = stack_y(n);

stack_x = stack_x' ;
stack_y = stack_y' ;
auc_m = sum((stack_x(2:length(stack_x),1)-stack_x(1:length(stack_x)-1,1)).*stack_y(2:length(stack_x),1));
X = X/100;
Y = Y/100;
AUC = [];
Spe = [];
Sen = [];
ACC = [];
PPV = [];
NPV = [];
for i =1:size(X,1)
     [auc,acc,spe,sen,ppv,npv] = get_auc(X(i,:),Y(i,:));
     AUC = [AUC,auc];
     Spe = [Spe,spe];
     Sen = [Sen,sen];
     ACC = [ACC,acc];
     PPV = [PPV,ppv];
     NPV = [NPV,npv];
end
     