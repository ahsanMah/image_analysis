load('pdms.mat');
load 'greyimages.mat' ;
load 'correctpdms';
rng(7);

% figure();
% greyimage =reshape(greyimages(:,2),256, 256); % *or binaryimage and binaryimages, respectively 
% imagesc(greyimage); colormap('gray');
% 
% figure()
% pdm=correctpdms(:,2);
% plot(pdm(1:2:end), pdm(2:2:end), 'b.')


normalized_pdms = pdms;

pdms_3d = zeros(2,64,32);
pdms_3d(1,:,:) = normalized_pdms(1:2:end,:);
pdms_3d(2,:,:) = normalized_pdms(2:2:end,:);

% Dividing into 3/4th training set and the rest as test cases
training_set = pdms_3d(:,:,1:24);
test_set = pdms_3d(:,:,25:32);

% Take the average value across each x and y point in a test case
mean_pdm = mean(training_set,3);
norm_train_set = training_set - mean_pdm;

%  Do PCA on the normalized training set

function normalizePDMs(pdms)
    normalized_pdms = zeros(128,32);

x_means = mean(pdms(1:2:end,:));
y_means = mean(pdms(2:2:end,:));

% Subtract the means from x and y valeus each
normalized_pdms(1:2:end,:) = pdms(1:2:end,:) - x_means;
normalized_pdms(2:2:end,:) = pdms(2:2:end,:) - y_means;

%%%%%%%% To be completed -- Need to perform orientation normalization

rotation_matrix=zeros(2,2,32);

matrix_3d = zeros(2,64,32);
rotated_matrix = zeros(2,64,32);

matrix_3d(1,:,:) = normalized_pdms(1:2:end,:);
matrix_3d(2,:,:) = normalized_pdms(2:2:end,:);

rotation_matrix(1,1,:) = sum(matrix_3d(1,:,:).^2, 2)
%%%%%%%%%%%%%%%%%%%%
end