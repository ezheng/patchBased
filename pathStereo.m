function pathStereo(img1_struct, otherImage_struct)

global near; global far; global halfWindowSize; 
near = 3;
far = 8.0;
isUseColor = true;
% MATCH_METHOD = 'NCC';
halfWindowSize = 4; % window size is 7 by 7
depthFileSavePath = 'C:\Enliang\MATLAB\patchBased\saveDepthFile_ltrb_multipleView_newProb_fountain_1_2to5_cleverDepthSel_onesample\';
%--------------------------------------------- 

image1 = im2double(imread(img1_struct.imageName));
image1 = getROI(image1);
image1 = convertColor(image1, isUseColor);
img1_struct.imageData = image1; [h, w, d] = size(image1); img1_struct.h = h; img1_struct.w = w; img1_struct.d = d;

for i = 1:numel(otherImage_struct)
    image2 = im2double(imread(otherImage_struct(i).imageName));
    image2 = getROI(image2);
    image2 = convertColor(image2, isUseColor);
    otherImage_struct(i).imageData = image2; 
    [hh, ww, dd] = size(image2); otherImage_struct(i).h = hh; otherImage_struct(i).w = ww; otherImage_struct(i).d = dd;
%     assign a random id map for each image   
end
% ------------ verify camera poses
%   F = fundfromcameras(img1_struct.K * [img1_struct.R, img1_struct.T], otherImage_struct(1).K * [otherImage_struct(1).R, otherImage_struct(1).T]);
%   fig=vgg_gui_F(uint8(otherImage_struct(1).imageData), uint8(img1_struct.imageData),F);
% F = fundfromcameras(otherImage_struct(2).K * [otherImage_struct(2).R, otherImage_struct(2).T], img1_struct.K * [img1_struct.R, img1_struct.T]);
% fig=vgg_gui_F(uint8(img1_struct.imageData), uint8(otherImage_struct(2).imageData),F);

% ------------l
s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

depthMap = rand(h,w) * (far - near) + near; % depthMap initialization
% mapDistribution = ones(hh, ww, numel(otherImage_struct)) * 0.5;
mapDistribution = rand(hh, ww, numel(otherImage_struct));


numOfIteration = 1000;

tic;
if(matlabpool('size') ~=0)
    matlabpool close;    
end
matlabpool open 7;

if(~exist(depthFileSavePath, 'dir')) 
    mkdir(depthFileSavePath);
end

for i = 1:numOfIteration    
     [depthMap, mapDistribution] = proporgation(img1_struct, otherImage_struct, depthMap,mapDistribution, 0, halfWindowSize);
     saveImg(depthMap,mapDistribution, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '0.mat']));
     
%      A =  rand(h,w) * (far - near) + near; % depthMap initialization;
%      A =  rand(h,w) * (far - near) + near;
%      load loop1_1.mat;
    [depthMap,mapDistribution] = proporgation(img1_struct, otherImage_struct, depthMap, mapDistribution, 2, halfWindowSize);
    saveImg(depthMap, mapDistribution, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '1.mat']));
     
    [depthMap, mapDistribution] = proporgation(img1_struct, otherImage_struct, depthMap, mapDistribution, 1, halfWindowSize);
    saveImg(depthMap, mapDistribution, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '2.mat']));
%      
    [depthMap, mapDistribution] = proporgation(img1_struct, otherImage_struct, depthMap, mapDistribution, 3, halfWindowSize);
    saveImg(depthMap, mapDistribution, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '3.mat']));  
%     
    fprintf(1, 'Iteration %i is finished\n', i);
end
matlabpool close;
t = toc;
fprintf('use %f seconds', t);
save all.mat;


end


function saveImg(depthMap, mapDistribution, fileName)
%     figure();
%     imagesc(depthMap); axis equal;
% if nargin == 2    
    save(fileName, 'depthMap', 'mapDistribution');
% elseif nargin ==3
%     save(fileName, 'depthMap', 'idMap');
% end
end