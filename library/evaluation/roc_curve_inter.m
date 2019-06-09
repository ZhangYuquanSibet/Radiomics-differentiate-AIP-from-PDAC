function [x1,y1] = roc_curve_inter(stack_x,stack_y) %%deci=wx+b, label_y, true label

    for i=2:length(stack_x)
       if stack_x(i)<=stack_x(i-1)
         stack_x(i)=stack_x(i-1)+0.00000000000001;
       end
       if stack_y(i)<=stack_y(i-1)
         stack_y(i)=stack_y(i-1)+0.00000000000001;
       end
    end
    x1=linspace(0,1,111); 
    y1=interp1(stack_x,stack_y,x1,'linear');  
    y1(y1>1)=1;
    
end
