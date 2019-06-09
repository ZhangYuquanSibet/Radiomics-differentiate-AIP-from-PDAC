
function [Features_2D,Global_features_2D,Features_3D,Global_features_3D] = get_features(Data_path,type)

file_path = strcat(Data_path,type,'\data'); 
img_path_list = dir(file_path);  
img_path_list(1:2,:)=[];
folder_num = length(img_path_list); 
[~, ind] = sort([img_path_list(:).datenum], 'ascend');
img_path_list = img_path_list(ind);

%
labels_path = strcat(Data_path,type,'\anno');
labels_path_list = dir(labels_path);
labels_path_list(1:2,:)=[];
[~, ind] = sort([labels_path_list(:).datenum], 'ascend');
labels_path_list = labels_path_list(ind);


rate = 1;
slice_num=0;
pat_num=0;
Features_2D = [];
Global_features_2D =[];
Features_3D = [];
Global_features_3D =[];
for x=1:folder_num
        pat_num=pat_num+1;
        PATIENT_name = img_path_list(x).name; 
        file_path1 = strcat(file_path,'\',PATIENT_name,'\CT');
        img_path_list1 = dir(strcat(file_path1,'\*.DCM'));
        img_num1 = length(img_path_list1);
        if isdir(strcat(file_path,'\',PATIENT_name,'\Data3'))
            file_path2 = strcat(file_path,'\',PATIENT_name,'\Data3'); 
            img_path_list2 = dir(strcat(file_path2,'\*.DCM')); 
            img_num2 = length(img_path_list2); 
        else
            file_path2 = strcat(file_path,'\',PATIENT_name,'\PET'); 
            img_path_list2 = dir(strcat(file_path2,'\*.DCM')); 
            img_num2 = length(img_path_list2);
        end
        if img_num1~=img_num2
           message('PET/CT numbers do not match')
          return
        end
        %% load annotation
        load(strcat(labels_path,'\',labels_path_list(x).name,'\anno.mat'));
 
    
         %% get dicom files
         O_CT3V = [];
         O_PET3V = [];
         IDX_CT = {};
         IDX_PET = {};
        MAX=[];
          
        for i=1:img_num1
            slice_num=slice_num+1;
            file_name1=img_path_list1(i).name;
            info1 = dicominfo([file_path1 '/' file_name1]);
            XY_CT=info1.PixelSpacing;
            Ict = double(dicomread(info1));
            I=Ict*info1.RescaleSlope+info1.RescaleIntercept;% change pixel value to HU value
            I(I<-10)=-10;  
            I(I>100)=100;   
            Im = I;
            file_name2=img_path_list2(i).name;
            info2 = dicominfo([file_path2 '\' file_name2]);
            if info1.SliceLocation ~= info2.SliceLocation
                file_name2=img_path_list2(img_num1+1-i).name;
                info2 = dicominfo([file_path2 '\' file_name2]);
            end
            XY_PET=info2.PixelSpacing;
            Ipet = double(dicomread(info2));  
            f=XY_PET(1,1)/XY_CT(1,1);   
            Ipet=tongyi(f,Ipet);
            Ipet=Ipet*info2.RescaleSlope+info2.RescaleIntercept;% change pixel value to HU value

            %%suv
            Ipet =Ipet/(info2.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose/(1000*info2.PatientWeight));

            mm = MSK3V(:,:,i);
            [L,num]=bwlabel(mm,4); 
            for y=1:num
              [xx,yy]=find(L==y);
              mmm = ones(size(mm))*NaN;
              mmm(L==y) =1;
              Imm = Im.*mmm;
              Ipett = Ipet.*mmm;
              rectx = [min(yy),max(yy),max(yy),min(yy)]';
              recty = [min(xx),max(xx),max(xx),min(xx)]';
              center = [(min([rectx(1),rectx(3)])+0.5*abs(rectx(3)-rectx(1))),(min([recty(1),recty(3)])+ 0.5*abs(recty(3)-recty(1)))];
              new_rectx = (rectx-center(1))*rate+5*sign((rectx-center(1)))+center(1);
              new_recty = (recty-center(2))*rate+5*sign((recty-center(2)))+center(2);
              CT=Imm(min(new_recty):max(new_recty),min(new_rectx):max(new_rectx));
              PET=Ipett(min(new_recty):max(new_recty),min(new_rectx):max(new_rectx)); 
              MAX = [MAX, max(PET(:))];
              IDX_CT{end+1} = CT;
              IDX_PET{end+1} = PET;
            end
        
            O_CT3V = cat(3,O_CT3V,Im);
            O_PET3V = cat(3,O_PET3V,Ipet);
        end
    %% calculate 2D features
    [~,idx]=sort(MAX,'descend');
    CT = IDX_CT{idx(1)};
    PET = IDX_PET{idx(1)};
    [CT_max_value,CT_mean_value] = getSUVmetrics(CT);
    [SUVmax,SUVmean] = getSUVmetrics(sqrt(PET)); %3
    shape_feature = get_shape(CT); % 4
    ct_feature = extract_features (CT) ; %59
    pet_feature = extract_features (sqrt(PET)) ; %59
    global_features = [CT_max_value,CT_mean_value,SUVmax,SUVmean,shape_feature];
    features = [ct_feature,pet_feature];
    Features_2D  = [Features_2D;features];
    Global_features_2D  = [Global_features_2D;global_features];
    %% calculate 3D features
    [boxBound] = computeBoundingBox(MSK3V);
    maskBox = MSK3V(boxBound(1,1):boxBound(1,2),boxBound(2,1):boxBound(2,2),boxBound(3,1):boxBound(3,2));
    O_CT_box = O_CT3V(boxBound(1,1):boxBound(1,2),boxBound(2,1):boxBound(2,2),boxBound(3,1):boxBound(3,2));
    O_PET_box = O_PET3V(boxBound(1,1):boxBound(1,2),boxBound(2,1):boxBound(2,2),boxBound(3,1):boxBound(3,2));
    
    maskBox = imresize3D(maskBox,[],[round(double(size(maskBox,1))),round(double(size(maskBox,2))),round(double(size(maskBox,3))*3)],'nearest','fill');
    O_CT_box = imresize3D(O_CT_box,[],[round(double(size(O_CT_box,1))),round(double(size(O_CT_box,2))),round(double(size(O_CT_box,3))*3)],'cubic','fill');
    O_PET_box = imresize3D(O_PET_box,[],[round(double(size(O_PET_box,1))),round(double(size(O_PET_box,2))),round(double(size(O_PET_box,3))*3)],'cubic','fill');
 
    CT3V = O_CT_box; CT3V(~maskBox) = NaN;
    PET3V = O_PET_box; PET3V(~maskBox) = NaN;
    for z = 1:size(CT3V,3)
         s_n = 1; 
         slice_z= CT3V(:,:,s_n);
         if isnan(max(slice_z(:)))
             CT3V(:,:,s_n) = [];
             PET3V(:,:,s_n) = [];
         else
             s_n = s_n+1; 
         end
    end
    [ct_max_value,ct_mean_value] = getSUVmetrics(CT3V);
    [~,SUVmean] = getSUVmetrics(sqrt(PET3V));
    shapefeatures = get3dshape(CT3V);
    global_features = real([ct_max_value,ct_mean_value,SUVmean,shapefeatures]);
    Global_features_3D = [Global_features_3D;global_features];
    CTfeatures = get3dfeatures(CT3V,64); 
    PETfeatures = get3dfeatures(sqrt(PET3V),64); 
    features = real([CTfeatures,PETfeatures]);
    Features_3D  = [Features_3D;features];

end

NAME = strcat(type,'_Features_2D');
eval([NAME,'=Features_2D']);
save(strcat(NAME,'.mat'),NAME);
NAME = strcat(type,'_Global_features_2D');
eval([NAME,'=Global_features_2D']);
save(strcat(NAME,'.mat'),NAME);
NAME = strcat(type,'_Features_3D');
eval([NAME,'=Features_3D']);
save(strcat(NAME,'.mat'),NAME);
NAME = strcat(type,'_Global_features_3D');
eval([NAME,'=Global_features_3D']);
save(strcat(NAME,'.mat'),NAME);

