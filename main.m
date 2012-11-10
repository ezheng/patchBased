function main()

global near; global far; global halfWindowSize; 
halfWindowSize = 4; 

isUseColor = true;
isUseMex = true;
depthFileSavePath = '.\fountain\';

 addpath('.\mexFile\');
workingPath = 'C:\Enliang\data\epfl\fountain'; 
fileName = fullfile(workingPath, 'fountain.txt'); 

% imageROI [top, left, bottom, right]
 imageROI = [1200, 300, 1800, 800];
% imageROI = [];
image = read_middleBurry(fileName, imageROI);
load(fullfile(workingPath, 'fountainRange.mat'));
% init random seeds
s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);


for i = 1:numel(image)
    fprintf(1, 'start processing image %d \n', i)
    near = near_depth(i) - 0.5;
    far = far_depth(i) + 0.5;
    
    depthFileSavePath = fullfile(depthFileSavePath, ['image', num2str(i)]);
    pathStereo(image(i), image([1:i-1, i+1:numel(image)]), imageROI, isUseColor, isUseMex, depthFileSavePath);
    fprintf(1, 'finish processing image %d \n', i)
end


