function main()

fileName = 'C:\Enliang\MATLAB\patchBased\fountain_yilin\origImage\fountain.txt'; 
% fileName = 'C:\Enliang\data\middlebury\multiView\dinoRing\dinoR_par.txt';
% fileName = 'C:\Enliang\data\randObject\randObject.txt';
% fileName = 'C:\Enliang\data\brandenburgNight\pickedData.txt';
% fileName = 'C:\Enliang\data\epfl\herzjesu_dense_large_resized\herzjesu_dense_large-resized.txt';
% imageROI [top, left, bottom, right]
 imageROI = [1200, 300, 1800, 800];
% imageROI = [];
image = read_middleBurry(fileName, imageROI);



% do stereo

% pathStereo(image(31), image([28:30, 32:34]), imageROI);
% pathStereo(image(7), image([1:6, 8:end]), imageROI);
pathStereo(image(1), image([2:end]), imageROI);
