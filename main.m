function main()

fileName = 'C:\Enliang\MATLAB\patchBased\fountain_yilin\origImage\fountain.txt'; 
image = read_middleBurry(fileName);

% do stereo

pathStereo(image(1), image(2:11));


