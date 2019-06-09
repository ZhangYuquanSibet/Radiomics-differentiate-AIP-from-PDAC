
function shape_feature = get_shape(image)

label = get_label(image);
P = regionprops(label,'Area','Perimeter','Centroid','Eccentricity', 'MajorAxisLength','BoundingBox','Solidity');
E = P.Eccentricity; 
S = P.Solidity;
shape_feature = [S,P.Area,P.MajorAxisLength,E];
