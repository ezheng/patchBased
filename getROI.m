function subImage = getROI(image, imageROI)

% subImage = image(1200:1800, 300:800,:);
if ~isempty(imageROI)
    subImage = image( imageROI(1):imageROI(3), imageROI(2):imageROI(4), :);
else
    subImage = image;    
end

