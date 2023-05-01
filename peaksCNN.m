% this script train a cnn model for peak classification using the training
% image data in subfolder '25095EICs', which can be downloaded from
% https://pubs.acs.org/doi/suppl/10.1021/acs.analchem.1c01309/suppl_file/ac1c01309_si_001.zip
digitDatasetPath = '25095EICs';
digitDatasetPath = 'C:\Users\xxing\Documents\Github\Deep learning\25095EICs'
size=64;  % origian images will be compressed to sizeXsize, also need to change the dim value in customReadDatastoreImage.m
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

imds.ReadFcn = @customReadDatastoreImage;

% figure;
% perm = randperm(25095,20);
% for i = 1:4
%     subplot(2,2,i);
%     imshow(imds.Files{perm(i)});
% end

labelCount = countEachLabel(imds);
numModelFiles = 0.8;
numTrainFiles = 0.7;
[imdsModel,imdsTest] = splitEachLabel(imds,numModelFiles,'randomize');
[imdsTrain,imdsValidation] = splitEachLabel(imdsModel,numTrainFiles,'randomize');


%%  CNN model architecture
layers = [
    imageInputLayer([size size 1])
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)

    fullyConnectedLayer(2)

    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',2, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

net = trainNetwork(imdsTrain,layers,options);

YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

% show training accuracy
accuracy = sum(YPred == YValidation)/numel(YValidation)