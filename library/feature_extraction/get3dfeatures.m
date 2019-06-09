function features = get3dfeatures(CT3V,N_level)

img1 =(1/(max(CT3V(:))-min(CT3V(:))))*(CT3V-min(CT3V(:)));
img1 = round(img1*255);

global_textures = getGlobalTextures(img1,256); 
% 
img1 =(1/(max(CT3V(:))-min(CT3V(:))))*(CT3V-min(CT3V(:)));
img1 = round(img1*(N_level-1))+1;

glds_features=gray_diff3d(img1,N_level); %4

GLCM_1 = getGLCM_new_3d(img1,(1:1:N_level),1);
stats = GLCM_Features1(GLCM_1,0);
T(1) = mean(stats.autoc); 
T(2) = mean(stats.contr); 
T(3) = mean(stats.corrm); 
T(4) = mean(stats.cprom); 
T(5) = mean(stats.cshad); 
T(6) = mean(stats.dissi); 
T(7) = mean(stats.energ); 
T(8) = mean(stats.entro); 
T(9) = mean(stats.homom); 
T(10) = mean(stats.maxpr); 
T(11) = mean(stats.sosvh); 
T(12) = mean(stats.savgh); 
T(13) = mean(stats.svarh); 
T(14) = mean(stats.senth); 
T(15) = mean(stats.dvarh); 
T(16) = mean(stats.denth); 
T(17) = mean(stats.inf1h); 
T(18) = mean(stats.inf2h); 
T(19) = mean(stats.indnc); 
T(20) = mean(stats.idmnc); 

[NGTDM,countValid] = getNGTDM(img1,(1:1:N_level));
NGTDM_textures = getNGTDMtextures(NGTDM,countValid); %5
GLSZM = getGLSZM(img1,(1:1:N_level));
GLSZM_textures = getGLSZMtextures(GLSZM); %13
GLRLM = getGLRLM(img1,(1:1:N_level));
GLRLM_textures = getGLRLMtextures(GLRLM); %13
ho_features = [cell2mat(struct2cell(NGTDM_textures))',cell2mat(struct2cell(GLSZM_textures))',cell2mat(struct2cell(GLRLM_textures))'];
features = [cell2mat(struct2cell(global_textures))',glds_features,T,ho_features];



