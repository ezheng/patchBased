function img = convertColor(img, isUseColor);

if(~isUseColor)
    img = rgb2gray(img);
end