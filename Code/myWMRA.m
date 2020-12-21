function wave_beats = myWMRA(beats, HiD, LoD)
% Performs 8 level wavelet decomponsition on input 'beats'
% array. Operation is row wise, and iterates on the 
% Lowpass signal. Bins are concatenated and returned. 

    % Level 1
    cD1 = filter(HiD,1,beats,[],1);
    cD1 = downsample(cD1,2);
    LP1 = filter(LoD,1,beats,[],1);
    LP1 = downsample(LP1,2);
    % level 2
    cD2 = filter(HiD,1,LP1,[],1);
    cD2 = downsample(cD2,2);
    LP2 = filter(LoD,1,LP1,[],1);
    LP2 = downsample(LP2,2);
    % level 3
    cD3 = filter(HiD,1,LP2,[],1);
    cD3 = downsample(cD3,2);
    LP3 = filter(LoD,1,LP2,[],1);
    LP3 = downsample(LP3,2);
    % level 4
    cD4 = filter(HiD,1,LP3,[],1);
    cD4 = downsample(cD4,2);
    LP4 = filter(LoD,1,LP3,[],1);
    LP4 = downsample(LP4,2);
    % level 5
    cD5 = filter(HiD,1,LP4,[],1);
    cD5 = downsample(cD5,2);
    LP5 = filter(LoD,1,LP4,[],1);
    LP5 = downsample(LP5,2);
    % level 6
    cD6 = filter(HiD,1,LP5,[],1);
    cD6 = downsample(cD6,2);
    LP6 = filter(LoD,1,LP5,[],1);
    LP6 = downsample(LP6,2);
    % level 7
    cD7 = filter(HiD,1,LP6,[],1);
    cD7 = downsample(cD7,2);
    LP7 = filter(LoD,1,LP6,[],1);
    LP7 = downsample(LP7,2);
    % level 8
    cD8 = filter(HiD,1,LP7,[],1);
    cD8 = downsample(cD8,2);
    LP8 = filter(LoD,1,LP7,[],1);
    LP8 = downsample(LP8,2);

    wave_beats = [cD1;cD2;cD3;cD4;cD5;cD6;cD7;cD8]';

end