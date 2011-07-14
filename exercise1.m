% EXERCSIE1: basic training and testing of a classifier

% add the required search paths
setup ;

% --------------------------------------------------------------------
% Stage A: Data Preparation
% --------------------------------------------------------------------

% Load training data
pos = load('data/aeroplane_train_hist.mat') ;
%pos = load('data/car_train_hist.mat') ;
%pos = load('data/person_train_hist.mat') ;
neg = load('data/background_train_hist.mat') ;
names = {pos.names{:}, neg.names{:}};
histograms = [pos.histograms, neg.histograms] ;
labels = [ones(1,numel(pos.names)), - ones(1,numel(neg.names))] ;
clear pos neg ;

% Load testing data
pos = load('data/aeroplane_val_hist.mat') ;
%pos = load('data/car_val_hist.mat') ;
%pos = load('data/person_val_hist.mat') ;
neg = load('data/background_val_hist.mat') ;
testNames = {pos.names{:}, neg.names{:}};
testHistograms = [pos.histograms, neg.histograms] ;
testLabels = [ones(1,numel(pos.names)), - ones(1,numel(neg.names))] ;
clear pos neg ;

% For stage F: thorw away part of the training data
% fraction = .1 ;
% fraction = .5 ;
fraction = +inf ;

sel = vl_colsubset(1:numel(labels), fraction, 'uniform') ;
names = names(sel) ;
histograms = histograms(:,sel) ;
labels = labels(:,sel) ;
clear sel ;

% count how many images are there
fprintf('number of training images: %d positive, %d negative\n', ...
        sum(labels > 0), sum(labels < 0)) ;
fprintf('number of testing images: %d positive, %d negative\n', ...
        sum(testLabels > 0), sum(testLabels < 0)) ;

% For Stage E: Vary the image representation
% histograms = removeSpatialInformation(histograms) ;

% For Stage F: Vary the classifier (Hellinger kernel)
% histograms = sqrt(histograms) ;
% testHistograms = sqrt(testHistograms) ;

% L2 normalize the histograms before running the linear SVM
histograms = bsxfun(@times, histograms, 1./sqrt(sum(histograms.^2,1))) ;
testHistograms = bsxfun(@times, testHistograms, 1./sqrt(sum(testHistograms.^2,1))) ;

% --------------------------------------------------------------------
% Stage B: Training a classifier
% --------------------------------------------------------------------

% Train the linear SVM
C = 100 ;
[w, bias] = trainLinearSVM(histograms, labels, C) ;

% Evaluate the scores on the training data
scores = w' * histograms + bias ;

% Visualize the precision-recall curve
figure(1) ; clf ; set(1,'name','Precision-recall on train data') ;
vl_pr(labels, scores) ;

% Visualize the ranked list of images
figure(2) ; clf ; set(2,'name','Ranked training images (subset)') ;
displayRankedImageList(names, scores)  ;

% --------------------------------------------------------------------
% Stage C: Classify the test images and assess the performance
% --------------------------------------------------------------------

% Test the linar SVM
testScores = w' * testHistograms + bias ;

% Visualize the precision-recall curve
figure(3) ; clf ; set(3,'name','Precision-recall on test data') ;
vl_pr(testLabels, testScores) ;

% Visualize the ranked list of images
figure(4) ; clf ; set(4,'name','Ranked test images (subset)') ;
displayRankedImageList(testNames, testScores)  ;

% Visualize visual words
% [drop,perm] = sort(w,'descend') ;
% displayVisualWordsFromImageList(names([1:10, end-10:end]) , perm) ;