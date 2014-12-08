function pathStereo(img1_struct, otherImage_struct, imageROI)

near = 5.0;
far = 10.0;
% near = 0.45;
% far = 0.70;
isUseMultipleCore = true;
numWorkers = 6;
sigma = 0.45;
prob = 0.99999;
isUseColor = true;
numOfIteration = 3;
halfWindowSize = 3; 
depthFileSavePath = 'C:\Enliang\matlab\patchBased\';
% --------------------------------------------- 
if(~exist(depthFileSavePath, 'dir')) 
    mkdir(depthFileSavePath);
end

image1 = im2double(imread(img1_struct.imageName));
image1 = getROI(image1, imageROI);
image1 = convertColor(image1, isUseColor);
img1_struct.imageData = image1; [h, w, d] = size(image1); img1_struct.h = h; img1_struct.w = w; img1_struct.d = d;

for i = 1:numel(otherImage_struct)
    image2 = im2double(imread(otherImage_struct(i).imageName));
    image2 = getROI(image2, imageROI);
    image2 = convertColor(image2, isUseColor);
    otherImage_struct(i).imageData = image2; 
    [hh, ww, dd] = size(image2); otherImage_struct(i).h = hh; otherImage_struct(i).w = ww; otherImage_struct(i).d = dd;
end
% ------------ verify camera poses
%   F = fundfromcameras(img1_struct.K * [img1_struct.R, img1_struct.T], otherImage_struct(1).K * [otherImage_struct(1).R, otherImage_struct(1).T]);
%   fig=vgg_gui_F(uint8(otherImage_struct(1).imageData), uint8(img1_struct.imageData),F);
% F = fundfromcameras(otherImage_struct(2).K * [otherImage_struct(2).R, otherImage_struct(2).T], img1_struct.K * [img1_struct.R, img1_struct.T]);
% fig=vgg_gui_F(uint8(img1_struct.imageData), uint8(otherImage_struct(2).imageData),F);
% ------------l
% s = RandStream('mcg16807','Seed',0);
% RandStream.setDefaultStream(s);

rng(0);
setMultiThreadContext(isUseMultipleCore, numWorkers);

depthMap = rand(h,w) * (far - near) + near; % depthMap initialization

% orientation map is not used in this version of program
% orientationMap = zeros(h,w,3);
% orientationMap(:,:,1:2) = 0; orientationMap(:,:,3) = 1.0;
% orientationMap = orientationMap ./ repmat(sqrt(sum(orientationMap.^2,3)),[1,1, size(orientationMap,3)]);  % normalize orientation

tic;
if( ~exist('costMap.mat', 'file') )
    costMap = costMapComputation(depthMap, img1_struct, otherImage_struct, halfWindowSize);
%   costMap = rand( size(depthMap,1), size(depthMap,2), numel(otherImage_struct) );
%   distributionMap = distributionMapComputation(costMap);
    save costMap.mat costMap; % distributionMap; 
else
    load costMap.mat;
end

for i = 1:numOfIteration
    
    backwardMap = backwardMessage_row_left2rightProp(costMap, sigma, prob);
    [ depthMap, costMap] = proporgation( img1_struct, otherImage_struct, depthMap,backwardMap,costMap, 0, halfWindowSize, near, far,sigma,prob);
    fprintf(1, 'Iteration %i is finished. Left -> right \n', i);
    figure(); imagesc(depthMap); axis equal;
     
 
    backwardMap = backwardMessage_col_top2botProp(costMap, sigma, prob);
    [ depthMap,costMap] = proporgation( img1_struct, otherImage_struct, depthMap, backwardMap,costMap, 2, halfWindowSize, near, far,sigma,prob);
    fprintf(1, 'Iteration %i is finished. top -> bottom\n', i);
    figure(); imagesc(depthMap); axis equal;


    backwardMap = backwardMessage_row_right2leftProp(costMap, sigma, prob);
    [ depthMap, costMap] = proporgation( img1_struct, otherImage_struct, depthMap, backwardMap,costMap, 1, halfWindowSize, near, far,sigma,prob);
    fprintf(1, 'Iteration %i is finished. right -> left\n', i);
    figure(); imagesc(depthMap); axis equal;


    backwardMap = backwardMessage_col_bot2topProp(costMap, sigma, prob);
    [ depthMap, costMap] = proporgation( img1_struct, otherImage_struct, depthMap, backwardMap,costMap, 3, halfWindowSize, near, far,sigma,prob);
    fprintf(1, 'Iteration %i is finished. bottom -> top\n', i);
    figure(); imagesc(depthMap); axis equal;
    
end

t = toc;
fprintf('use %f seconds\n', t);
save all.mat;

end


function saveImg(depthMap, distributionMap, orientationMap, fileName)
%     figure();
%     imagesc(depthMap); axis equal;
% if nargin == 2    
    save(fileName, 'depthMap', 'distributionMap', 'orientationMap');
% elseif nargin ==3
%     save(fileName, 'depthMap', 'idMap');
% end
end