function main()

% fileName = 'C:\Enliang\MATLAB\patchBased\fountain_yilin\origImage\fountain.txt'; 
fileName = 'C:\Enliang\data\middlebury\multiView\dinoRing\dinoR_par.txt';
% fileName = 'C:\Enliang\data\randObject\randObject.txt';
% fileName = 'C:\Enliang\data\brandenburgNight\pickedData.txt';
% imageROI [top, left, bottom, right]
% imageROI = [1200, 300, 1800, 800];
imageROI = [];
image = read_middleBurry(fileName, imageROI);



% do stereo

pathStereo(image(31), image([28:30, 32:34]), imageROI);


