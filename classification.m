function [p_test, test_prob] = classification(data_train, l_train, data_test,l_test,classifier_type,i,j)

if classifier_type==0 || classifier_type==1
    %% SVM classifiers
    [p_test, test_prob] = perf_svm(data_train, l_train, data_test,l_test,classifier_type,i,j);
    
elseif classifier_type==2
    %% random forest
    tree_rf = templateTree('MinLeafSize',j);
    Factor=fitcensemble(data_train, l_train,'Method','Bag','NumLearningCycles',i,...
                                      'Learners',tree_rf,'ScoreTransform','logit');
    [p_test,Scores] = predict(Factor, data_test);
    test_prob = Scores(:,2);
elseif classifier_type==3
    %% Adaboost
     t  = templateTree('MaxNumSplits',1);
     Factor = fitensemble(data_train, l_train,'AdaBoostM1',i,t,'Type','classification','LearnRate',j);
     [p_test,Scores] = predict(Factor, data_test);
     test_prob = Scores(:,2);
else
    error('classification type input wrong');
end
