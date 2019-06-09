
function features = feature_organization(Features_2D,Global_features_2D,Features_3D,Global_features_3D,type)

if type==0
    %% ALL
    features = [Features_2D,Features_3D,Global_features_2D,Global_features_3D];
elseif  type==1
    %% 2D features
    features = [Features_2D,Global_features_2D];  
elseif  type==2
    %% 3D features
    features = [Features_3D,Global_features_2D(:,3),Global_features_3D]; 
elseif  type==3
    %% CT features
    features = [Features_2D(:,1:59),Features_3D(:,1:59),...
       Global_features_2D(:,1:2),Global_features_2D(:,5:end),...
        Global_features_3D(:,1:2),Global_features_3D(:,4:end)];  
elseif  type==4
    %% PET features
    features = [Features_2D(:,60:end),Features_3D(:,60:end),...
        Global_features_2D(:,3:end),Global_features_3D(:,3:end)]; 
elseif  type==5
    %% clinical factors
    clinical_factors = xlsread('clinical factors.xlsx');
    if size(Features_2D,1)==45
        clinical_factors = [clinical_factors(1:45,1),clinical_factors(1:45,3)];
    elseif size(Features_2D,1)==66
        clinical_factors = [clinical_factors(1:66,6),clinical_factors(1:66,8)];
    else
        error('check the clinical factors')
    end
    features = [Global_features_2D(:,3),clinical_factors]; 
elseif  type==6
    %% combined features
    clinical_factors = xlsread('clinical factors.xlsx');
    if size(Features_2D,1)==45
        clinical_factors = [clinical_factors(1:45,1),clinical_factors(1:45,3)];
    elseif size(Features_2D,1)==66
        clinical_factors = [clinical_factors(1:66,6),clinical_factors(1:66,8)];
    else
        error('check the clinical factors')
    end
    features = [Features_2D,Features_3D,Global_features_2D,Global_features_3D,clinical_factors]; 
else
    error('feature type input wrong');
end





 

