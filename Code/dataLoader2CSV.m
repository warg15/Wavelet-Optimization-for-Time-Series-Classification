%{ 
INPUT DATA STRUCTURE:
ann = index of a beat
type = categorize that beat
signal = EEG signal
t = time variable for EEG signal
Fs = sampling rate
%}

fileList = dir('C:\Users\19095\Documents\ECE251C\ECG_data\*.atr');

% Save all beats into one big matrix for convenience
all_beats = [];
all_types = [];

for i = 1:length(fileList)
    
    recordName = fileList(i).name(1:end-4);
    
    % Read in Data
    [ann,type]=rdann( recordName , 'atr' ) ;
    [signal,Fs,t]=rdsamp( recordName , 1 ) ;
    
    % Preallocate space
    beats = zeros(length(ann), 252);
    
    % Segment out signals
    for j = 3:length(ann)-2
        ind = ann(j);
        s = signal(ind-89:ind+162);
        beats(j,:) = s;
    end
    
    % Ignore first and last 2 samples
    beats = beats(3:end-2,:);
    type = type(3:end-2,:);
    
    all_beats = [all_beats;beats];
    all_types = [all_types;type];
    
    % Save individual data
    filenameWMRA = 'C:\Users\19095\Documents\ECE251C\ECG_data\Raw_Beat_CSV\' + string(recordName) + '_seg.mat';
    save(filenameWMRA, 'beats', 'type');
end

% Save combined data
filenameWMRA = 'C:\Users\19095\Documents\ECE251C\ECG_data\Raw_Beat_CSV\ALL_BEATS.mat';
save(filenameWMRA, 'all_beats', 'all_types');
