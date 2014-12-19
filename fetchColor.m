function color = fetchColor(x, y, z, image1_struct, image2_struct)
% x,y,z is column with the same size. z is the depth in image 1
R1 = image1_struct.R; C1 = image1_struct.C; K1 = image1_struct.K; T1 = image1_struct.T;
R2 = image2_struct.R; C2 = image2_struct.C; K2 = image2_struct.K; T2 = image2_struct.T;
image2 = image2_struct.imageData;

x = x - 0.5;    % x = x + 0.5 - 1 (0.5 is the center of pixel. -1 is because matlab index starts from 1)
y = y - 0.5;

% do reverse: [X Y Z] = [R' -R'T] * matrixinverse(K) * (x,y,1) * depthvalue
points2d = K1\([x,y,ones(size(x))]' .* repmat(z', 3, 1));
recovered = [R1', C1] * [ points2d; ones(1, size(points2d,2))];

proj = K2 * [R2, T2] * [recovered; ones(1, size(recovered,2))];
proj = proj./ repmat(proj(3,:), 3,1);

[h,w,~] = size(image2);
% if( all(proj(1,:) + 1 > 0) && all(proj(1,:) + 1 < w) && all(proj(2,:) + 1 > 0) && all(proj(2,:) + 1 < h)) % image projection is within the 2nd image
color = vgg_interp2(image2, proj(1,:) + 1, proj(2,:) + 1, 'linear');    % +1 is because matlab index starts from 1
color = color(:);   % some pixels may have NaN value. We do not count it in
% else
%    color = zeros(3 * size(proj,2),1); 
% end
color(isnan(color)) = 0;


% n =  [0,0,1]';
% R = R2 * R1'; 
% T = R2 * (C2 - C1);
% H_ba = R - T*n'/z(2);
% p = K2 * H_ba / (K1) *  [x(2), y(2), 1.0]';
% p = p/p(3)
% proj(:,2)