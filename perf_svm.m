function [c_test, test_prob] = perf_svm(d_train, l_train, d_test,pres_nested, state,bestc,bestg)


if state==1
  cmd= ['-c ',num2str(bestc),' -g ',num2str(bestg),' -b 1']; %rbf svm
   model = lib_svmtrain(l_train, d_train,cmd);  
elseif state==0
    cmd= ['-t 0 ','-c ',num2str(bestc),' -b 1'];
   model = lib_svmtrain(l_train, d_train,cmd);
end
[c_test0, ~,test_prob0] = lib_svmpredict(l_train, d_train, model,' -b 1');
[c_test, z,test_prob] = lib_svmpredict(pres_nested, d_test, model,' -b 1');


