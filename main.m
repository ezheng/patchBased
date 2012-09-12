function main()

fileName = 'E:/matlab/patchBased/fountain/fountain - Copy.txt'; 
image = read_middleBurry(fileName);

% do stereo

pathStereo(image(1), image(2));


