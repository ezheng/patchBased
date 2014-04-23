function main()

% fileName = 'F:\Enliang\data\fountain_subregion\fountain_original_sub.txt'; 
fileName = 'F:\Enliang\data\fountain_quartresolution\fountain_quadresolution.txt';
image = read_middleBurry(fileName);

% do stereo

pathStereo(image(1), image(2));


