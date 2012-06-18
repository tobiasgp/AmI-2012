features_file_no_cap = 'features_no_cap.arff';
features_file_with_cap = 'features_with_cap.arff';

%classes = [csvread('ae.csv'); csvread('am.csv')];
%recordings = [csvread('feugen.csv'); csvread('fmarko.csv')];
classes = ann_marko;
recordings = marko;

window_size = 100;
window_overlap = window_size/2;
number_features = 8;

recordings(:, 3) = smooth(recordings(:, 3),10);
recordings(:, 4) = smooth(recordings(:, 4),10);
recordings(:, 5) = smooth(recordings(:, 5),10);
recordings(:, 6) = smooth(recordings(:, 6),10);

number_recordings = size(recordings);
number_recordings = number_recordings(1);
extracted_windows = 0; 
i = 1;

clear extracted_features;

while i < (number_recordings)
    % this determines the window's size
    current_class = classes(i);
    extract_features = true;
   
    % determine window size by counter
    end_of_window = i;
    sum_acc = 0;
    while sum_acc < window_size
        end_of_window = end_of_window + 1;
        
        if end_of_window > number_recordings
           break; 
        end
        
        sum_acc = sum_acc + recordings(end_of_window, 2);
    end
    
    % this is a fixed window size, alternative to acc
    % end_of_window = i + window_size - 1;
    
    % determine wether the window is valid
    for j = i:end_of_window
        % if j is out of bounds, stop it
        if j > number_recordings
            extract_features = false;
            break;
        end
        
        compare_class = classes(j);
        
        %if the class changes, do not extract features
        if current_class ~= compare_class
            extract_features = false;
            break;
        end
    end
    
    % if the window is ok, do the feature extraction
    if extract_features == true && current_class ~= 0
        accel_1 = recordings(i:end_of_window, 3);
        accel_2 = recordings(i:end_of_window, 4);
        accel_3 = recordings(i:end_of_window, 5);
        cap = recordings(i:end_of_window, 6);
        
        results = zeros(number_features,1);
        results(1) = mean(accel_1);
        results(2) = mean(accel_2);
        results(3) = mean(accel_3);
        results(4) = var(accel_1);
        results(5) = var(accel_2);
        results(6) = var(accel_3);
        results(7) = mean(cap);
        results(8) = var(cap);
        results(9) = current_class;
        
        extracted_windows = extracted_windows + 1;
        
        extracted_features(extracted_windows,:) = results;
    end
    
    % for fixed window sizes
    % i = i + window_overlap;
        
    % determine next overlap window size by acc
    start_of_window = i;
    sum_acc = 0;
    while sum_acc < window_overlap
        start_of_window = start_of_window + 1;
        
        if start_of_window > number_recordings
            break;
        end
        
        sum_acc = sum_acc + recordings(start_of_window, 2);
    end
    i = start_of_window;
    
end

% now, write the result into  the csv file for WEKA with NO CAP

fileID = fopen(features_file_no_cap,'w');

fprintf(fileID, '@RELATION capsense\r\n');

fprintf(fileID, '@ATTRIBUTE mean_accel_1 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE mean_accel_2 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE mean_accel_3 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_accel_1 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_accel_2 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_accel_3 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE class {class1,class2,class3,class4,class5,class6,class7,class8,class9}\r\n');
fprintf(fileID, '\r\n');

fprintf(fileID, '@DATA\r\n');

for i=1:extracted_windows
    fprintf(fileID,'%f,%f,%f,%f,%f,%f,',extracted_features(i,1:6));
    fprintf(fileID,'class%u\r\n',extracted_features(i,9));
end
fclose(fileID);


% now, write the result into  the csv file for WEKA

fileID = fopen(features_file_with_cap,'w');

fprintf(fileID, '@RELATION capsense\r\n');


fprintf(fileID, '@ATTRIBUTE mean_accel_1 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE mean_accel_2 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE mean_accel_3 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_accel_1 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_accel_2 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_accel_3 NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE mean_cap NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE var_cap NUMERIC\r\n');
fprintf(fileID, '@ATTRIBUTE class {class1,class2,class3,class4,class5,class6,class7,class8,class9}\r\n');
fprintf(fileID, '\r\n');

fprintf(fileID, '@DATA\r\n');

for i=1:extracted_windows
        fprintf(fileID,'%f,%f,%f,%f,%f,%f,',extracted_features(i,1:8));
    fprintf(fileID,'class%u\r\n',extracted_features(i,9));
end
fclose(fileID);

