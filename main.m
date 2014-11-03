function main()

% fileName = 'f:\Enliang\MATLAB\patchBased\fountain_yilin\origImage\fountain.txt'; 
%  imageROI = [1200, 300, 1800, 800];
fileName = 'C:\Enliang\data\fountain_subregion\fountain_original_sub.txt';
imageROI = [];
image = read_middleBurry(fileName, imageROI);

% do stereo
% pathStereo(image(31), image([28:30, 32:34]), imageROI);
% pathStereo(image(7), image([1:6, 8:end]), imageROI);
% pathStereo(image(2), image([1,3:end]), imageROI);

pathStereo(image(1), image(2:end), imageROI);