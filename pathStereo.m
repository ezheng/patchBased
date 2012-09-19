function pathStereo(img1_struct, img2_struct)

global near; global far; global halfWindowSize;
near = 3.5;
far = 13.5;
halfWindowSize = 5; % window size is 7 by 7
%--------------------------------------------- 

image1 = double(imread(img1_struct.imageName));
image2 = double(imread(img2_struct.imageName));
img1_struct.imageData = image1; [h, w, d] = size(image1); img1_struct.h = h; img1_struct.w = w; img1_struct.d = d;
img2_struct.imageData = image2; [h, w, d] = size(image2); img2_struct.h = h; img2_struct.w = w; img2_struct.d = d;
% ------------ verify camera poses
%  F = fundfromcameras(img1_struct.K * [img1_struct.R, img1_struct.T], img2_struct.K * [img2_struct.R, img2_struct.T]);
%  fig=vgg_gui_F(uint8(img2_struct.imageData), uint8(img1_struct.imageData),F);

% ------------

s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

depthMap = rand(h,w) * (far - near) + near; % depthMap initialization
numOfIteration = 5;

tic;
if(matlabpool('size') ~=0)
    matlabpool close;    
end
matlabpool open;
% close all;
depthFileSavePath = 'C:\Enliang\MATLAB\patchBased3\patchBased\saveDepthFile_ltrb_new_largeRange';
saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(1), '_', '0.mat']));

for i = 1:numOfIteration    
%      depthMap = proporgation(img1_struct, img2_struct, depthMap, 0,5);
%     saveImg(depthMap, 'Parallel.mat');
%     saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '0.mat']));
%     
     A =  rand(h,w) * (far - near) + near; % depthMap initialization;
     A =  rand(h,w) * (far - near) + near;
     load loop1_1.mat;
%      depthMap = proporgation(img1_struct, img2_struct, depthMap, 2,5);
%      saveImg(depthMap, 'Parallel.mat');
%      saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '1.mat']));
     
     depthMap = proporgation(img1_struct, img2_struct, depthMap, 1,5);
     saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '2.mat']));
%      
    depthMap = proporgation(img1_struct, img2_struct, depthMap, 3,5);
    saveImg(depthMap, fullfile(depthFileSavePath, ['loop', num2str(i), '_', '3.mat'] ));  
%     
    fprintf(1, 'Iteration %i is finished\n', i);
end
matlabpool close;
t = toc;
fprintf('use %f seconds', t);
save all.mat;


end


function saveImg(depthMap, fileName)
%     figure();
%     imagesc(depthMap); axis equal;
    save(fileName, 'depthMap');

end
