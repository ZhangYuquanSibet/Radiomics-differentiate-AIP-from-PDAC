
function feature = extract_features (img1) 
   mask = get_label(img1);
   img1 =(1/(max(img1(:))-min(img1(:))))*(img1-min(img1(:)));
   img1 = round(img1*255);
   gray_feature1=feature_ex(img1); %4-d
   ho_feature1 = get_ho_feature(double(img1),64);
   feature = [gray_feature1,ho_feature1];
   
   