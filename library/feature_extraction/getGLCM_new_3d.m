function [GLCM] = getGLCM_new_3d(ROIonly,levels,D)
% -------------------------------------------------------------------------
% function [GLCM] = getGLCM(ROIonly,levels)
% -------------------------------------------------------------------------
% DESCRIPTION: 
% This function computes the Gray-Level Co-occurence Matrix (GLCM) of the 
% region of interest (ROI) of an input volume. The input volume is assumed 
% to be isotropically resampled. Only one GLCM is computed per scan, 
% simultaneously recording (i.e. adding up) the neighboring properties of 
% the 26-connected neighbors of all voxels in the ROI. To account for 
% discretization length differences, neighbors at a distance of sqrt(3) 
% voxels around a center voxel increment the GLCM by a value of sqrt(3), 
% neighbors at a distance of sqrt(2) voxels around a center voxel increment
% the GLCM by a value of sqrt(2), and neighbors at a distance of 1 voxels 
% around a center voxel increment the GLCM by a value of 1.
%
% --> This function is compatible with 2D analysis (language not adapted in the text)
% -------------------------------------------------------------------------
% REFERENCE:
% [1] Haralick, R. M., Shanmugam, K., & Dinstein, I. (1973). Textural 
%     features for image classification. IEEE Transactions on Systems, 
%     Man and Cybernetics, smc 3(6), 610�?21.
% -------------------------------------------------------------------------
% INPUTS:
% - ROIonly: Smallest box containing the ROI, with the imaging data ready 
%            for texture analysis computations. Voxels outside the ROI are 
%            set to NaNs.
% - levels: Vector containing the quantized gray-levels in the tumor region
%           (or reconstruction levels of quantization).
%
% ** 'ROIonly' and 'levels' should be outputs from 'prepareVolume.m' **
% -------------------------------------------------------------------------
% OUTPUTS:
% - GLCM: Gray-Level Co-occurence Matrix of 'ROIOnly'.
% -------------------------------------------------------------------------
% AUTHOR(S): 
% - Issam El Naqa <ielnaqa@med.umich.edu>       
% - Martin Vallieres <mart.vallieres@gmail.com>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: 2009 (I. El Naqa)
% - Revision 1: January 2013 (M. Vallieres)
% - Revision 2: May 2015 (M. Vallieres)
% -------------------------------------------------------------------------
% STATEMENT:
% This file is part of <https://github.com/mvallieres/radiomics/>, 
% a package providing MATLAB programming tools for radiomics analysis.
% --> Copyright (C) 2015  Issam Elnaqa, Martin Vallieres
%
%    This package is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this package.  If not, see <http://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

% PRELIMINARY
nLevel = length(levels);
if nLevel > 100
    adjust = 10000;
else
    adjust = 1000;
end
levelTemp = max(levels)+1;
ROIonly(isnan(ROIonly)) = levelTemp;
levels = [levels,levelTemp];

dim = size(ROIonly);
if ndims(ROIonly) == 2
	dim(3) = 1;
end
q2 = reshape(ROIonly,1,prod(dim));


% QUANTIZATION EFFECTS CORRECTION (M. Vallieres)
% In case (for example) we initially wanted to have 64 levels, but due to
% quantization, only 60 resulted.
qs = round(levels*adjust)/adjust;
q2 = round(q2*adjust)/adjust;


% EL NAQA CODE
q3 = q2*0;
for k = 1:length(qs)
	q3(q2==qs(k)) = k;
end
q3 = reshape(q3,dim);
lqs = length(qs);
GLCM = double(zeros(lqs));
OFFSET = [D,D,0;0,D,0;-D,D,0;-D,0,0;...
    D,D,D;0,D,D;-D,D,D;-D,0,D;D,D,-D;...
    0,D,-D;-D,D,-D;-D,0,-D;0,0,D];


for i = D+1:dim(1)-D
	for j = D+1:dim(2)-D
		for k = D+1:dim(3)-D
            val_q3 = q3(i,j,k);  %���ĵ�
            for o = 1:size(OFFSET,1)
                pos = [i,j,k]+OFFSET(o,:);
                val_neighbor = q3(pos(1),pos(2),pos(3));
                GLCM(val_q3,val_neighbor) = GLCM(val_q3,val_neighbor) + 1;%sqrt(abs(I2-i)+abs(J2-j)+abs(K2-k)); % Discretization length correction (M. Vallieres)
					
			end
		end
	end
end

GLCM = GLCM(1:end-1,1:end-1);

end
