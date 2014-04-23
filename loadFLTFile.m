function data = loadFLTFile( fileName )

% fileName = 'fountain0004_DepthMap.flt';
fid = fopen(fileName);

line = fscanf(fid, '%d&%d&%d&',[1,3]);
width=line(1);
height=line(2);
channels=line(3); 
num=width*height*channels;
D = fread(fid,num,'float');
fclose(fid);


data=reshape(D,[width,height]);
data = data';
% imagesc(data1);
% axis equal
