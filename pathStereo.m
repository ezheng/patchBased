function pathStereo(img1_struct, otherImage_struct)

global near; global far; global halfWindowSize; 
near = 0.5;
far = 12.0;
isUseColor = false;
% MATCH_METHOD = 'NCC';
halfWindowSize = 7; % window size is 7 by 7
depthFileSavePath = 'C:\Enliang\MATLAB\patchBased3\patchBased\saveDepthFile_ltrb_new_smallRange_idmap_NCC_brandenburg_1_2to10_binary_gray';
%--------------------------------------------- 

image1 = im2double(imread(img1_struct.imageName));
image1 = convertColor(image1, isUseColor);
img1_struct.imageData = image1; [h, w, d] = size(image1); img1_struct.h = h; img1_struct.w = w; img1_struct.d = d;

for i = 1:numel(otherImage_struct)
    image2 = im2double(imread(otherImage_struct(i).imageName));
    image2 = convertColor(image2, isUseColor);
    otherImage_struct(i).imageData = image2; 
    [hh, ww, dd] = size(image2); otherImage_struct(i).h = hh; otherImage_struct(i).w = ww; otherImage_struct(i).d = dd;
end
% ------------ verify camera poses
%   F = fundfromcameras(img1_struct.K * [img1_struct.R, img1_struct.T], otherImage_struct(1).K * [otherImage_struct(1).R, otherImage_struct(1).T]);
%   fig=vgg_gui_F(uint8(otherImage_struct(1).imageData), uint8(img1_struct.imageData),F);
% F = fundfromcameras(otherImage_struct(2).K * [otherImage_struct(2).R, otherImage_struct(2).T], img1_struct.K * [img1_struct.R, img1_struct.T]);
% fig=vgg_gui_F(uint8(img1_struct.imageData), uint8(otherImage_struct(2).imageData),F);

% ------------

s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

depthMap = rand(h,w) * (far - near) + near; % depthMap initialization
idMap = randi(numel(otherImage_struct), [h,w]);
numOfIteration = 1000;

tic;
if(matlabpool('size') ~=0)
    matlabpool close;    
end
matlabpool open;


if(~exist(depthFileSavePath, 'dir')) 
    mkdir(depthFileSavePath);
end
% saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(1), '_', '0.mat']));

for i = 1:numOfIteration    
     [depthMap, idMap] = proporgation(img1_struct, otherImage_struct, depthMap, idMap, 0,halfWindowSize);
     saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '0.mat']), idMap);
%     
%      A =  rand(h,w) * (far - near) + near; % depthMap initialization;
%      A =  rand(h,w) * (far - near) + near;
%      load loop1_1.mat;
     [depthMap, idMap] = proporgation(img1_struct, otherImage_struct, depthMap, idMap, 2,halfWindowSize);
     saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '1.mat']), idMap);
     
     [depthMap, idMap] = proporgation(img1_struct, otherImage_struct, depthMap, idMap, 1,halfWindowSize);
     saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '2.mat']), idMap);
%      
    [depthMap, idMap] = proporgation(img1_struct, otherImage_struct, depthMap, idMap, 3,halfWindowSize);
    saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '3.mat']), idMap);  
%     
    fprintf(1, 'Iteration %i is finished\n', i);
end
matlabpool close;
t = toc;
fprintf('use %f seconds', t);
save all.mat;


end


function saveImg(depthMap, fileName, idMap)
%     figure();
%     imagesc(depthMap); axis equal;
if nargin == 2    
    save(fileName, 'depthMap');
elseif nargin ==3
    save(fileName, 'depthMap', 'idMap');
end
end