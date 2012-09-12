function pathStereo(img1_struct, img2_struct)

global near; global far; global halfWindowSize;
near = 3.5;
far = 13.5;
halfWindowSize = 3; % window size is 7 by 7
%--------------------------------------------- 

image1 = double(imread(img1_struct.imageName));
image2 = double(imread(img2_struct.imageName));
img1_struct.imageData = image1; [h, w, d] = size(image1); img1_struct.h = h; img1_struct.w = w; img1_struct.d = d;
img2_struct.imageData = image2; [h, w, d] = size(image2); img2_struct.h = h; img2_struct.w = w; img2_struct.d = d;
% ------------ verify camera poses
% F = fundfromcameras(img1_struct.K * [img1_struct.R, img1_struct.T], img2_struct.K * [img2_struct.R, img2_struct.T]);
% fig=vgg_gui_F(uint8(img2_struct.imageData), uint8(img1_struct.imageData),F);

% ------------

s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

depthMap = rand(h,w) * (far - near) + near; % depthMap initialization
numOfIteration = 5;
for i = 1:numOfIteration
    depthMap = proporgation(img1_struct, img2_struct, depthMap, 0);
    depthMap = proporgation(img1_struct, img2_struct, depthMap, 1);
    depthMap = proporgation(img1_struct, img2_struct, depthMap, 2);
    depthMap = proporgation(img1_struct, img2_struct, depthMap, 3);
end