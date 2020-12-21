clc; clear all; close all;
% This script trains and assess the performance of the Wavelet-PCA-SVM
% classifier using different wavelets. Training is done on the first
% nSamples of a time series. The remained of that time series is used for
% testing. Each time series is trained/tested independently and the average
% accuracy is reported at the end.

% Number of samples to train on for each individual
nSamples = 300;

% pick which wavelet to run test on. 
% (1) bior(6,8) 
% (2) Record Based Optimized Wavelet
% (3) Beat Based Optimized Wavelet
wavNum = 1;

if wavNum == 1
    % Standard wavelet for comparison:
    [LoD,HiD,~,~] = wfilters('bior6.8');
elseif wavNum == 2
    % Record Based Optimization
    T = [2.2459    1.2054    0.0504    4.2204    2.1728    4.3941    3.7735    4.7180];
    [HiD, LoD] = myWaveletGenerator(T);
elseif wavNum == 3
    % Beat Based Optimization
    T = [3.1813    2.0865    2.0696    4.7150    1.6286    3.8357    3.4543    4.9361];
    [HiD, LoD] = myWaveletGenerator(T);
end



%% import data

p = 1; %set file
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


%% Define testing and training data for each of the 10 folds

id = 1;
for j = 1:48 %loop through all data, allocating to array as necessary
    key = strcat('key', string(j));
    labels_temp = labels.(key); 
    data_temp = data.(key); 
    
    if size(data_temp,1)>nSamples
        train = data_temp(1:nSamples,:);
        train_lbl = labels_temp(1:nSamples,:);
        
        test = data_temp(nSamples:end,:);
        test_lbl = labels_temp(nSamples:end,:);
        
        % save data to structure
        key = strcat('fold', string(id));
        trainDataStruct.(key) = train;
        trainLabelStruct.(key) = train_lbl;
        testDataStruct.(key) = test;
        testLabelStruct.(key) = test_lbl;
        id = id+1;
    end
    
end

keyboard;
%% Train and test classifier

scores = [];
classes = ['A', 'L', 'N', 'R', 'V'];
confMat = zeros(length(classes), length(classes));

for i = 1:size(fieldnames(trainLabelStruct), 1)
    
    % Grab data
    key = strcat('fold', string(i));
    trainData = trainDataStruct.(key);
    trainLabels = trainLabelStruct.(key);
    testData = testDataStruct.(key);
    testLabels = testLabelStruct.(key);
    
    % wavelet transform
    wavTrainData = myWMRA(trainData', HiD, LoD);
    wavTestData = myWMRA(testData', HiD, LoD);

    % PCA dimension reduction
    numDims = 12;
    coeff = pca(wavTrainData); 
    coeff = coeff(:,1:numDims); 
    redTrainData = wavTrainData * coeff; %reduced train data
    redTestData = wavTestData * coeff; %reduce test data

    % train SVM
    t = templateSVM('KernelFunction','gaussian');
    model = fitcecoc(redTrainData,trainLabels,'Learners',t);
    % predict and get score
    pred = predict(model, redTestData);
    score = 0;
    for j = 1:length(pred)
        score = score + strcmp(pred(j), testLabels(j));
    end
    score = score/length(pred);
    scores = [scores, score];
    
    % Confusion Matrix
    for k = 1:length(pred)
        actIndex = find(classes == testLabels(k)); %index of actual label in classes
        predIndex = find(classes == pred(k)); %index of predicted label in classes
        confMat(predIndex(1,1) , actIndex(1,1)) = confMat(predIndex(1,1) , actIndex(1,1)) + 1;
    end

end
