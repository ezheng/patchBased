function pathStereo(img1_struct, otherImage_struct, imageROI)

global near; global far; global halfWindowSize; 
near = 3;
far = 12.0;
% near = 0.45;
% far = 0.70;
isUseColor = true;
isUseMex = false;
% MATCH_METHOD = 'NCC';
halfWindowSize = 4; 
% depthFileSavePath = 'C:\Enliang\MATLAB\patchBased3\patchBased\saveDepthFile_ltrb_multipleView_newProb_fountain_1_2to5_cleverDepthSel_3sample_NoAnneal_proporgateDist_smallsigma\';
% depthFileSavePath = 'C:\Enliang\MATLAB\patchBased3\patchBased\final\';
depthFileSavePath = 'C:\Enliang\MATLAB\patchBased3\patchBased\fountain_mex\';
%--------------------------------------------- 

image1 = im2double(imread(img1_struct.imageName));
image1 = getROI(image1, imageROI);
image1 = convertColor(image1, isUseColor);
img1_struct.imageData = image1; [h, w, d] = size(image1); img1_struct.h = h; img1_struct.w = w; img1_struct.d = d;

for i = 1:numel(otherImage_struct)
    image2 = im2double(imread(otherImage_struct(i).imageName));
    image2 = getROI(image2, imageROI);
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
% orientationMap = rand(h,w,3)*2 - 1;
orientationMap = zeros(h,w,3);
orientationMap(:,:,1:2) = 0; orientationMap(:,:,3) = 1.0;
orientationMap = orientationMap ./ repmat(sqrt(sum(orientationMap.^2,3)),[1,1, size(orientationMap,3)]);

% mapDistribution = ones(hh, ww, numel(otherImage_struct)) * 0.5;
% normalize mapDistribution
mapDistribution = rand(hh, ww, numel(otherImage_struct));
mapDistribution = mapDistribution./ repmat(sum(mapDistribution,3), [1,1,size(mapDistribution,3)]); % normalization


numOfIteration = 1000;

tic;
if(matlabpool('size') ~=0)
    matlabpool close;    
end
if(~isUseMex)
    matlabpool open 8;
end
if(~exist(depthFileSavePath, 'dir')) 
    mkdir(depthFileSavePath);
end



addpath('C:\Enliang\cpp\patchMatch_mex\build_64\Release\');
% addpath('C:\Enliang\cpp\patchMatch_mex\build_64\Debug\');
for i = 1:numOfIteration
     annealing = i;
     if(annealing <= 0) 
         annealing = 0;
     end
%      load(fullfile(depthFileSavePath, ['loop', num2str(1), '_', '3.mat']));
     
      [orientationMap, depthMap, mapDistribution] = proporgation(orientationMap, img1_struct, otherImage_struct, depthMap,mapDistribution, 0, halfWindowSize, annealing, isUseMex);
      saveImg(depthMap,mapDistribution, orientationMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '0.mat']));
     
%      A =  rand(h,w) * (far - near) + near; % depthMap initialization;
%      A =  rand(h,w) * (far - near) + near;
%      load loop1_1.mat;

    [orientationMap, depthMap,mapDistribution] = proporgation(orientationMap, img1_struct, otherImage_struct, depthMap, mapDistribution, 2, halfWindowSize, annealing, isUseMex);
    saveImg(depthMap, mapDistribution,orientationMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '1.mat']));
     
    [orientationMap, depthMap, mapDistribution] = proporgation(orientationMap, img1_struct, otherImage_struct, depthMap, mapDistribution, 1, halfWindowSize, annealing, isUseMex);
    saveImg(depthMap, mapDistribution,orientationMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '2.mat']));
%      
    [orientationMap, depthMap, mapDistribution] = proporgation(orientationMap, img1_struct, otherImage_struct, depthMap, mapDistribution, 3, halfWindowSize, annealing, isUseMex);
    saveImg(depthMap, mapDistribution,orientationMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '3.mat']));  
%     
    fprintf(1, 'Iteration %i is finished\n', i);
end
matlabpool close;
t = toc;
fprintf('use %f seconds', t);
save all.mat;


end


function saveImg(depthMap, mapDistribution, orientationMap, fileName)
%     figure();
%     imagesc(depthMap); axis equal;
% if nargin == 2    
    save(fileName, 'depthMap', 'mapDistribution', 'orientationMap');
% elseif nargin ==3
%     save(fileName, 'depthMap', 'idMap');
% end
end