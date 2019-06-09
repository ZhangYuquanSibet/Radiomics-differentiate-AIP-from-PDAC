function FF =feature_select_compare(fea_ss, all_label,num,fs_type,state,i,j)
 
%% normalization
fea_ss = scaleForSVM(fea_ss,fea_ss,0,1);

if fs_type==0
    %% No fs
    FF = (1:size(fea_ss,2));
    
elseif fs_type==1
    %% Spearman's rank correlation
    %b = [246,249,120,121,247,245,151,95,91,202];
    [coef, pval] = corr(fea_ss,all_label,'type','Spearman');
    % BP = mafdr(pval,'BHFDR',true);
    P_coef = abs(coef);
    [~,b] = sort(P_coef,'descend');
    indices8 = b(1:num);
    FF =indices8;
elseif fs_type==2
    % MRMR-muinf
    if size(fea_ss,2)>num
       [indices9, score] = mRMR(fea_ss,all_label,num);
        fea_ss = fea_ss(:,indices9);
    else
        indices9 = (1:size(fea_ss,2));
    end
    FF =indices9;
elseif fs_type==3
    %% SVM-RFE
    Param = struct();
    if state==0
        Param.kerType = 0;  
        Param.rfeC = i;
        Param.useCBR = false;
        [ftRank1,ftScore1] = ftSel_SVMRFECBR_ori(fea_ss, all_label,Param);
        FF =ftRank1(1:num);
    elseif state==1
        Param.kerType = 2;  
        Param.rfeC = i;
        Param.rfeG = j;
        Param.useCBR = false;
        [ftRank1,ftScore1] = ftSel_SVMRFECBR(fea_ss, all_label,Param);
        FF =ftRank1(1:num);
    end
else
    error('feature selection type input wrong');
end


    










