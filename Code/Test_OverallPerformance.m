clc; clear all; close all;
% This script trains and assess the performance of the Wavelet-PCA-SVM
% classifier using different wavelets. Train and Test data is randomly
% split over all the patient data. 10 fold validation is used for testing
% classifer perforance.

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

p = 1; 
for i = 100:236
%     dataPath = strcat(pwd, '/ECG_data/Raw_Beat_CSV/', int2str(i), '_seg.mat'); %get path
    dataPath = strcat('C:/Users/19095/Documents/ECE251C/ECG_data/Raw_Beat_CSV/', int2str(i), '_seg.mat'); %get path

    if (exist(dataPath,  'file') == 2)
        % load File, Labels, Data
        dataStruct = load(dataPath); 
        labels_temp = dataStruct.type; 
        data_temp = dataStruct.beats; 
        
        %remove unwanted data points
        classToSave = {'L', 'R', 'V', 'A', 'N'}; 
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
    trainingIndex = fold.(key); 
    testingIndex = setdiff(allData, trainingIndex); 
    
    %define arrays for testing and training data
    trainData = [];
    trainLabels =[];
    testData = [];
    testLabels = [];
    AllData = [];
    AllLabels = [];
    
    for j = 1:numData %loop through all data, allocating to array as necessary
        key = strcat('key', string(j));
        labels_temp = labels.(key); %get relevant data peice
        data_temp = data.(key); %get corresponging labels
        AllData = [AllData; data_temp]; %add to training matrix
        AllLabels = [AllLabels; labels_temp];
    end
    
     rng(i);
     numTrain = 40000;
     keepIndex = randi(length(AllData), numTrain, 1);
     trainDataCut = AllData(keepIndex, :);
     trainLabelsCut = AllLabels(keepIndex, :);
     AllData(keepIndex, :) = [];
     AllLabels(keepIndex, :) = [];
     
    key = strcat('fold', string(i));
    trainDataStruct.(key) = trainDataCut;
    trainLabelStruct.(key) = trainLabelsCut;
    testDataStruct.(key) = AllData;
    testLabelStruct.(key) = AllLabels;

end

%% Train and test classifier

scores = [];
classes = ['A', 'L', 'N', 'R', 'V'];
confMat = zeros(10,length(classes), length(classes));
for i = 1:10
    % Grab the train and test data for fold i
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

    % Train SVM
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
        confMat(i, actIndex(1,1) , predIndex(1,1)) = confMat(i, actIndex(1,1) , predIndex(1,1)) + 1;
    end
    
end

OverallScore = mean(scores);

% visualize Confusion matrices for CV
for i  = 1:10
    C = squeeze(confMat(i,:,:));
    C = C./sum(C,2);
    figure(1), subplot(2,5,i),imagesc(C), title(i)
    xticks([1 2 3 4 5])
    xticklabels({'A','L','N','R','V'})
    xlabel('Actual Class')
    yticks([1 2 3 4 5])
    yticklabels({'A','L','N','R','V'})
    ylabel('Predicted Class')
end
sgtitle('10 fold Validation results')
