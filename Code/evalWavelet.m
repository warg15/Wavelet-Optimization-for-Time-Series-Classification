function errorFinal = evalWavelet(T,trainDataStruct,trainLabelStruct,testDataStruct, testLabelStruct)
% Function used to evaluate the accuracy of the wavelet corresponding to the input thetas.
% Essentially our optimizer's cost function.

    % make wavelets
    [HiD, LoD] = myWaveletGenerator(T);
    
    %define varibale to save score
    scoreTotal = 0;
    crossVal = 10;
    for i = 1:crossVal
        
        %fetch data for this round of cross validation
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
        
        %sum scores over the 10 cross-validations
        scoreTotal = scoreTotal + score;
    end
    
    scoreFinal = scoreTotal/crossVal;
    errorFinal = (1 - scoreFinal)*100;

    % save data for later
    s = [T ,scoreFinal];
    dlmwrite('optimization_record_500_BEATBASED_length8.csv',s,'-append','delimiter',',')
    
end