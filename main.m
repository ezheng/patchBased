function main()

global near; global far; global halfWindowSize; 
halfWindowSize = 4; 

isUseColor = true;
isUseMex = true;
depthFileSavePath = '.\fountain\';

addpath('C:\Enliang\cpp\patchMatch_mex\build_64\Release\');

fileName = 'C:\Enliang\MATLAB\patchBased\fountain_yilin\origImage\fountain.txt'; 
% fileName = 'C:\Enliang\data\middlebury\multiView\dinoRing\dinoR_par.txt';
% fileName = 'C:\Enliang\data\randObject\randObject.txt';
% fileName = 'C:\Enliang\data\brandenburgNight\pickedData.txt';
% fileName = 'C:\Enliang\data\epfl\herzjesu_dense_large_resized\herzjesu_dense_large-resized.txt';
% imageROI [top, left, bottom, right]
%  imageROI = [1200, 300, 1800, 800];
imageROI = [];
image = read_middleBurry(fileName, imageROI);
load fountainRange.mat;
% do stereo

% pathStereo(image(31), image([28:30, 32:34]), imageROI);
% pathStereo(image(7), image([1:6, 8:end]), imageROI);
% pathStereo(image(2), image([1,3:end]), imageROI);

s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);


for i = 1:numel(image)
    fprintf(1, 'start processing image %d \n', i)
    near = near_depth(i);
    far = far_depth(i);
    
    depthFileSavePath = fullfile(depthFileSavePath, ['image', num2str(i)]);
    pathStereo(image(i), image([1:i-1, i+1:numel(image)]), imageROI, isUseColor, isUseMex, depthFileSavePath);
    fprintf(1, 'finish processing image %d \n', i)
end


