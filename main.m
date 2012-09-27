function main()

% fileName = 'C:\Enliang\MATLAB\patchBased\fountain_yilin\origImage\fountain.txt'; 
% fileName = 'C:\Enliang\data\middlebury\multiView\dinoSparseRing\dinoSR_par.txt';
fileName = 'C:\Enliang\data\randObject\randObject.txt';
image = read_middleBurry(fileName);

% do stereo

pathStereo(image(10), image([1,3,5, 13,20,25]));


