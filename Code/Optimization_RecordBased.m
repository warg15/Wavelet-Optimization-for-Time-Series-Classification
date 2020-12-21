clc; clear all; close all;
% Optimize a wavelet using training and testing data sourced from distinct
% individuals ('Record based' scheme). Significant lower accuracy is 
% expected when using record based data. 10 fold cross validation is 
% used to assess the performance of the wavelet accross several data groups.


%% import data

p = 1; 
for i = 100:236
    dataPath = strcat(pwd, '/ECG_data/Raw_Beat_CSV/', int2str(i), '_seg.mat'); %get path
    
    if (exist(dataPath,  'file') == 2)
        % load File, Labels, Data
        dataStruct = load(dataPath); 
        labels_temp = dataStruct.type; 
        data_temp = dataStruct.beats; 
        
        %remove unwanted data points
        classToSave = {'L', 'R', 'V', 'A', 'N'}; 
        %classToSave = {'L', 'N', 'P'}; 
        classToRmv = setdiff(unique(labels_temp), classToSave); 
        for j = 1:size(classToRmv,1) 
            % get Char corresponding to class and remove from data/labels
            char = classToRmv{j,1}; 
            rmvIndex = find(labels_temp == char); 
            labels_temp(rmvIndex) = [];
            data_temp(rmvIndex,:) = [];
        end
        
        key = strcat('key', string(p));
        labels.(key) = labels_temp;
        data.(key) = data_temp;
        p = p + 1;
    end
end
clear classToRmv char key data_temp labels_temp dataStruct rmvIndex p


%% Define testing and training data for each of the 10 folds

%define testing datasets for each of the 10-fold cross val
fold.fold1 = [1, 2, 10, 18, 37];
fold.fold2 = [6, 7, 8, 11, 23];
fold.fold3 = [5, 12, 13, 14, 29];
fold.fold4 = [3, 16, 17, 33, 35, ];
fold.fold5 = [8, 10, 21, 22, 45];
fold.fold6 = [11, 26, 27, 37, 46];
fold.fold7 = [3, 18, 29, 31, 32];
fold.fold8 = [5, 23, 35, 36, 38];
fold.fold9 = [10, 29, 37, 41];
fold.fold10= [3, 11, 33, 47];

for i = 1:10
    numData = 48; 
    allData = 1:numData;
    key = strcat('fold', string(i));
    testingIndex = fold.(key); 
    trainingIndex = setdiff(allData, testingIndex); 

    %define arrays for testing and training data
    trainData = [];
    trainLabels =[];
    testData = [];
    testLabels = [];

    for j = 1:numData %loop through all data, allocating to array as necessary
        key = strcat('key', string(j));
        labels_temp = labels.(key); %get relevant data peice
        data_temp = data.(key); %get corresponging labels
        if ismember(j, trainingIndex) == 1 %if its training data
            trainData = [trainData; data_temp]; %add to training matrix
            trainLabels = [trainLabels; labels_temp];
        else
            testData = [testData; data_temp]; %else add to test matrix
            testLabels = [testLabels; labels_temp];
        end
    end
    
    %reduce training size to speed up training
    rng(1);
    numTrain = 500;
    keepIndex = randi(length(trainLabels), numTrain, 1);
    trainDataCut = trainData(keepIndex, :);
    trainLabelsCut = trainLabels(keepIndex, :);

    %store training and testing in respective structures
    key = strcat('fold', string(i));
    trainDataStruct.(key) = trainDataCut;
    trainLabelStruct.(key) = trainLabelsCut;
    testDataStruct.(key) = testData;
    testLabelStruct.(key) = testLabels;
end


%% wavelet optimization

% Define function to optomize
fun = @(T)evalWavelet(T,trainDataStruct,trainLabelStruct,testDataStruct, testLabelStruct);
% Solution space bounds
lb = [0,0,0,0,0,0,0,0];
ub = [2*pi,2*pi,2*pi,2*pi,2*pi,2*pi,2*pi,2*pi];
nvars = 8;
% Define optimizer
options = optimoptions('particleswarm');
options.Display = 'iter';
options.PlotFcn = 'pswplotbestf';
options.MaxStallIterations = 30;
options.SelfAdjustmentWeight= 1.3000;
options.SocialAdjustmentWeight= 1.3000;

% Run optimization
x = particleswarm(fun,nvars,lb,ub, options);




