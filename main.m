clc
clear 
close all
close all;clear;clc;
%% adding data path and toolboxes
warning off;
functiondir=which('main.m');functiondir=functiondir(1:end-length('main.m'));
addpath(genpath([functiondir '/library']));
Data_path='F:\zhangyuquan\DATA\validation\train0\new\';

%% parameters setting
feature_type = 0;  % feature type  0:all quantified features,1:2D,2:3D,3:CT,4:PET, 5:clinical factors, 6: combine features
fs_type = 2; % feature_selection type  0: None, 1:Spearman, 2:MRMR, 3:SVM-RFE
classifier_type = 0; % classifier type  0: Linear SVM, 1: RBF SVM, 2:RF, 3:Adaboost
num = 10; % number of features selected
if classifier_type==0 
    % linear svm parameters
    ICC = [0.01,0.1,1,10];  % C
    IGG = 0.0001; % g  no useful
elseif classifier_type==1
     % rbf svm parameters
    ICC = [0.01,0.1,1,10];  % C
    IGG = [0.0001,0.001,0.01,0.1,1]; % g
elseif classifier_type==2
    % RF parameters
    ICC = (50:50:300);  %number of trees
    IGG = 1;   %minleaf
elseif classifier_type==3
    % Adaboost parameters
    ICC = (50:50:300);  %number of trees
    IGG = 0.1;   %learnrate
else
    error('classification type input wrong');
end

%% extract features
%[aip_Features_2D,aip_Global_features_2D,aip_Features_3D,aip_Global_features_3D] = get_features(Data_path,'aip');
%[pda_Features_2D,pda_Global_features_2D,pda_Features_3D,pda_Global_features_3D] = get_features(Data_path,'pda');
% or load following mat files 
load('aip_Features_2D.mat')
load('aip_Features_3D.mat')
load('aip_Global_features_2D.mat')
load('aip_Global_features_3D.mat')
load('pda_Features_2D.mat')
load('pda_Features_3D.mat')
load('pda_Global_features_2D.mat')
load('pda_Global_features_3D.mat')

%% feature organization
aip_features = feature_organization(aip_Features_2D,aip_Global_features_2D,...
    aip_Features_3D,aip_Global_features_3D,feature_type);
pda_features = feature_organization(pda_Features_2D,pda_Global_features_2D,...
    pda_Features_3D,pda_Global_features_3D,feature_type);

all_data = [pda_features;aip_features]; 
all_label = [ones(size(pda_features,1),1);zeros(size(aip_features,1),1)];

%% nested cross-validation experiments including feature selection and classification
nv=10;  % outer loop numbers
fold_num=10; % fold numbers of each outer loop 
cv_num = 5; % fold numbers of inner loop 
FF = {};
L_T = [];  % true label
P_T = [];  % prediction
PB   = []; % predictive probabilities
FFF = {};  % statistics of the results of the feature selection
for ni = 1:nv
   L_test = [];
   P_test = [];
   prob   = [];
  [data, labels, cat_vec, fold_sizes, ~] = ...
      get_cv_data_new(all_data, all_label,fold_num, [0;1],ni);
  for k = 1:fold_num
    [d_train, l_train, d_test, l_test] = ...
        get_fold_vectors(data, labels, [0;1], cat_vec, fold_sizes, k);
       %% inner loop
        best_auc=0;
        CC = 0;
        GG = 0;
        [t_data, t_labels, t_cat_vec, t_fold_sizes, ~] = ...
            get_cv_data(d_train, l_train, cv_num, [0;1]);
        for icc = 1:length(ICC)
            for ijj = 1:length(IGG)
                i = ICC(icc);
                j = IGG(ijj);
                presented = [];
                predictions = [];
                Prob = [];
                for z = 1:cv_num
                    [dd_train, dl_train, dd_test, dl_test] = ...
                        get_fold_vectors(t_data, t_labels, [0;1],  ...
                          t_cat_vec, t_fold_sizes,z);
                    indices = feature_select_compare(dd_train, dl_train,num,fs_type,classifier_type,i,j);
                    dd_train = dd_train(:,indices);
                    dd_test = dd_test(:,indices);
                    [dd_train_sc,dd_test_sc] = scaleForSVM(dd_train,dd_test,0,1);
                    [ptest_label, tb] = classification(dd_train_sc, dl_train, dd_test_sc,dl_test,classifier_type,i,j);
                    presented = [presented;dl_test];
                    predictions = [predictions;ptest_label];
                    Prob = [Prob;tb];
                end
                auc = roc_curve_s(Prob(:,1),presented);
                if auc>best_auc
                    best_auc = auc;
                    CC = i;
                    GG = j;
                end
            end
        end
        data_train = d_train;
        data_test = d_test;
        FF1 = feature_select_compare(data_train, l_train,num,fs_type,classifier_type,CC,GG);%0 liner  2 rbf
        data_train = data_train(:,FF1);
        data_test = data_test(:,FF1);
        FFF = [FFF;FF1];
        [data_train,data_test] = scaleForSVM(data_train,data_test,0,1);
        [p_test, test_prob] = classification(data_train, l_train, data_test,l_test,classifier_type,CC,GG);
        L_test = [L_test; l_test(:)];
        P_test   = [P_test;   p_test(:)];
        prob   = [prob;  test_prob(:,1)];
        FF= [FF;[CC,GG]];
  end
   L_T(:, ni) = L_test;
   P_T(:, ni) = P_test;
   PB(:, ni) = prob;
end
%% performance evaluation with default threshold (i.e. 0.5)
ACC_h=[];
F_h=[];
SPE_h=[];
SEN_h=[];
for cvi = 1:nv
      [acc, Favg, sensitivity, specitivity,precision,NPV] = evaluate(P_T(:,cvi),L_T(:,cvi));
      ACC_h = [ACC_h,acc];
      F_h=[F_h,Favg];
      SPE_h = [SPE_h,specitivity]; 
      SEN_h = [SEN_h,sensitivity];
end
%% calculate AUC values and draw average ROC curve
X=[];
Y=[];
AUC=[];
for cvi = 1:nv
      [auc,x1,y1] = roc_curve(PB(:,cvi),2*L_T(:,cvi)-1);
      X = [X;x1];
      Y = [Y;y1];
      AUC = [AUC,auc];
end
auc_m= draw_rocs(X,Y,'b-');



