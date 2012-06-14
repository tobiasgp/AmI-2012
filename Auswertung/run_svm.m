features_file_no_cap = 'features_no_cap.arff';
features_file_with_cap = 'features_with_cap.arff';

%classes = [csvread('ae.csv'); csvread('am.csv')];
%recordings = [csvread('feugen.csv'); csvread('fmarko.csv')];
classes = ann_eugen;
recordings = eugen;

window_size = 100;
window_overlap = 50;
number_features = 8;

number_recordings = size(recordings);
number_recordings = number_recordings(1);
extracted_windows = 0; 
i = 1;

clear extracted_features;

while i < (number_recordings)
    % this determines the window's size
    current_class = classes(i);
    extract_features = true;
   
    % determine window size by acc
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

% do the partitioning for cross validation 
set_1 = [];
set_2 = [];
set_3 = [];
set_4 = [];

folds = 4;

% go through all classes
for i = 1:9
   % find the indices that belong to a class
   indices_for_one_class = find(extracted_features(:,9) == i);
   num_instances = size(indices_for_one_class);
   num_instances = num_instances(1);
   
   current = 1;
   
   while num_instances > 1
       if current > folds
            current = 1;
       end
       
       % randomly pick an element from this set
       index = ceil(rand(1,1) * num_instances);
       current_index = indices_for_one_class(index);
       
       % create 4 sets 
       % append the current index to a set
       if current == 1
           set_1 = [set_1 current_index];
       elseif current == 2
           set_2 = [set_2 current_index];
       elseif current == 3
           set_3 = [set_3 current_index];
       elseif current == 4
           set_4 = [set_4 current_index];
       end
       
       % remove this index from the list of indices
       indices_for_one_class(index) = [];
       
       num_instances = size(indices_for_one_class);
       num_instances = num_instances(1);
       current = current + 1;
   end
end

% build four training and test sets
trainingset_1 = extracted_features([set_1 set_2 set_3],:);
testset_1 = extracted_features(set_4,:);

trainingset_2 = extracted_features([set_1 set_2 set_4],:);
testset_2 = extracted_features(set_3,:);

trainingset_3 = extracted_features([set_1 set_3 set_4],:);
testset_3 = extracted_features(set_2,:);

trainingset_4 = extracted_features([set_2 set_3 set_4],:);
testset_4 = extracted_features(set_1,:);

% now, run the svm
nbclass = 9;
c = 1000;
lambda = 1e-5;
kerneloption= 2;
kernel='gaussian';
verbose = 1;

features = trainingset_1(:,1:8);
test = testset_1(:,1:8);
classes = trainingset_1(:,9);

% train the svm
[xsup,w,b,nbsv]=svmmulticlassoneagainstall(features,classes,nbclass,c,lambda,kernel,kerneloption,verbose);

% evaluate the svm
[ypred] = svmmultival(test,xsup,w,b,nbsv,kernel,kerneloption);

fprintf( '\nRate of correct class in training data : %2.2f \n',100*sum(ypred==testset_1(:,9))/length(classes)); 
