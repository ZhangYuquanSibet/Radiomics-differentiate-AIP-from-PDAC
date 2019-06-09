function features  = get3dshape(image)
Eccentricity = getEccentricity(image,1,3);
Size = getSize(image,1,3); 
Solidity = getSolidity(image,1,3);
Volume = getVolume(image,1,3);

features = [Eccentricity,Size,Solidity,Volume];

