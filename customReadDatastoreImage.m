function data = customReadDatastoreImage(filename)
dim=64;
onState = warning('off', 'backtrace'); 
c = onCleanup(@() warning(onState)); 
data = imread(filename); % added lines: 
data = imresize(data/max(max(data))*255,[dim,dim]);
end