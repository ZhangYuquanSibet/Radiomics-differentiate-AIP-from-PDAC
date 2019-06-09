
function ho_feature = get_ho_feature(image,N_level)

image =(1/(max(image(:))-min(image(:))))*(image-min(image(:)));
image = round(image*(N_level-1))+1;
mask = get_label(image);
gd=gray_diff(image,mask); 
GLCM_1 = getGLCM_new_2d(image,(1:1:N_level),1);
stats = GLCM_Features1(GLCM_1,0);
T(1) = stats.autoc; 
T(2) = stats.contr; 
T(3) = stats.corrm; 
T(4) = stats.cprom; 
T(5) = stats.cshad; 
T(6) = stats.dissi; 
T(7) = stats.energ; 
T(8) = stats.entro; 
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


[NGTDM,countValid] = getNGTDM(image,(1:1:N_level)); 
NGTDM_textures = getNGTDMtextures(NGTDM,countValid);
GLSZM = getGLSZM(image,(1:1:N_level));
GLSZM_textures = getGLSZMtextures(GLSZM);
GLRLM = getGLRLM(image,(1:1:N_level));  
GLRLM_textures = getGLRLMtextures(GLRLM);
ho_feature =[gd,T,cell2mat(struct2cell(NGTDM_textures))',cell2mat(struct2cell(GLSZM_textures))',cell2mat(struct2cell(GLRLM_textures))'];


