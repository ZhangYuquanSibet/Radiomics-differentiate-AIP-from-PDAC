
function [Features_2D,Global_features_2D,Features_3D,Global_features_3D] = dicom_preprocess(Data_path,type)

file_path = strcat(Data_path,type,'\data'); 
img_path_list = dir(file_path);  
folder_num = length(img_path_list); 
%
labels_path = strcat(Data_path,type,'\anno1');
labels_path_list = dir(labels_path);

%% output the processed dicom files and annotation files
dirout_data = strcat(Data_path,'new\',type,'\data'); 
dirout_anno = strcat(Data_path,'new\',type,'\anno');
if ~exist(dirout_data)
    mkdir(dirout_data);
    mkdir(dirout_anno);
else
    rmdir(dirout_data,'s');
    rmdir(dirout_anno,'s');
    mkdir(dirout_data);
    mkdir(dirout_anno);
end

rate = 1;
slice_num=0;
pat_num=0;
Features_2D = [];
Global_features_2D =[];
Features_3D = [];
Global_features_3D =[];
for x=3:folder_num
    pat_num=pat_num+1;
    PATIENT_name = img_path_list(x).name; 
    file_path1 = strcat(file_path,'\',PATIENT_name,'\Data1');
    img_path_list1 = dir(strcat(file_path1,'\*.DCM'));%获取该文件夹中所有dcm格式的图像 
    img_num1 = length(img_path_list1);%获取图像总数量  
    if isdir(strcat(file_path,'\',PATIENT_name,'\Data3'))
        file_path2 = strcat(file_path,'\',PATIENT_name,'\Data3'); 
        img_path_list2 = dir(strcat(file_path2,'\*.DCM'));%获取该文件夹中所有dcm格式的图像  
        img_num2 = length(img_path_list2);%获取图像总数量  
    else
        file_path2 = strcat(file_path,'\',PATIENT_name,'\Data2'); 
        img_path_list2 = dir(strcat(file_path2,'\*.DCM'));%获取该文件夹中所有dcm格式的图像  
        img_num2 = length(img_path_list2);%获取图像总数量
    end
    if img_num1~=img_num2
       message('PET/CT numbers do not match')
      return
    end
    M=double(nrrdread(strcat(labels_path,'\',labels_path_list(x).name,'\',strcat(labels_path_list(x).name,'3.nrrd'))));
    M=flip(M,3);
    if img_num1~=size(M,3)
      message('numbers do not match')
      return
    end
    MAX = [];
    IDX_CT = {};
    IDX_PET = {};
    
    O_CT3V = [];
    O_PET3V = [];
    MSK3V = [];%储存包含ROI的3维ROI图像
    
    %% create path for each patient dicom files
    datapath = strcat(dirout_data,'\',mat2str(x-2));
    if ~exist(datapath)
       mkdir(strcat(datapath,'\CT'));
       mkdir(strcat(datapath,'\PET'));
    else
       rmdir(datapath,'s');
       mkdir(strcat(datapath,'\CT'));
       mkdir(strcat(datapath,'\PET'));
    end
    annopath = strcat(dirout_anno,'\',mat2str(x-2));
    if ~exist(annopath)
       mkdir(annopath);
    else
       rmdir(annopath,'s');
       mkdir(annopath);
    end
    
    
    for i=1:img_num1
     mm=M(:,:,i);
     m1=max(max(mm));  % decide pancreas's  existance
     if m1
        slice_num=slice_num+1;
        file_name1=img_path_list1(i).name;
        info1 = dicominfo([file_path1 '\' file_name1]);
        % clear information
        info1.InstitutionName=[];
        info1.InstitutionAddress=[];
        info1.ReferringPhysicianName=[];
        info1.PatientName = mat2str(x-2);
        info1.PatientID = [];
        info1.PatientBirthDate = [];
        info1.OtherPatientID = [];
     
        img = dicomread(info1);
        dicomwrite(img,strcat(datapath,'\CT\',mat2str(i),'.dcm'), 'CreateMode','Copy',info1);
        
        
        file_name2=img_path_list2(i).name;
        info2 = dicominfo([file_path2 '\' file_name2]);
        if info1.SliceLocation ~= info2.SliceLocation
            file_name2=img_path_list2(img_num1+1-i).name;
            info2 = dicominfo([file_path2 '\' file_name2]);
        end
        % clear information
        info2.InstitutionName=[];
        info2.InstitutionAddress=[];
        info2.ReferringPhysicianName=[];
        info2.PatientName = mat2str(x-2);
        info2.PatientID = [];
        info2.PatientBirthDate = [];
        info2.OtherPatientID = [];
        img2 = dicomread(info2);
        dicomwrite(img2,strcat(datapath,'\PET\',mat2str(i),'.dcm'), 'CreateMode','Copy',info2);

        MSK3V = cat(3,MSK3V,mm);
      end
    end
    save(strcat(annopath,'\anno.mat'), 'MSK3V');
end



