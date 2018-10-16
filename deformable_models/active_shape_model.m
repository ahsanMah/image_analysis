load('pdms.mat');
load 'greyimages.mat' ;
load 'correctpdms';
load 'binaryimages'
rng(7);

original_pdms = correctpdms;
normalized_pdms = zeros(128,32);

for num_pdm = 1:32
    pdm = original_pdms(:,num_pdm);
    [norm_pdm, x_mean, y_mean, rotation_matrix] = normalizePDM(pdm);
    normalized_pdms(:,num_pdm) = norm_pdm;
end

normalized_pdms = original_pdms;

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

%Transform back into 2d
pdm_2d =zeros(128,24);

for subject=1:24
    for i=1:2:128
        pdm_2d(i,subject) = norm_train_set(1,floor(i/2+1),subject); % x coordinate
        pdm_2d(i+1,subject) = norm_train_set(2,floor(i/2+1),subject); % y - coordinate
    end
end

mean_pdm = reshape(mean_pdm, [128,1])

% Matlab expects columns to be features and rows to be observations
cov_matrix = cov(pdm_2d');
% [V,D] = eig(cov_matrix);

[U,S,V] = svd(cov_matrix);

eigen_vals = diag(S(:,1:5));

% Choose first k=5 eigen vectors to reduce the dimension
eigen_vectors = U(:,1:5);
reduced_pdms = zeros(5,24);

TEST_CASE = 32;
test_pdm = correctpdms(:,TEST_CASE);
new_pdm = test_pdm;

% Do five iterations
for i=1:50

    [norm_pdm, x_mean, y_mean, rotation_matrix] = normalizePDM(new_pdm);
    
    % Reduced PDMs will be k dimensional instead of 128

    % Project back into shape space -- multiply by Eigen-transverse which is
    % equal to the Eigen matrix since it is orthonormal
    proj_pdm = project_to_image(mean_pdm, eigen_vals, eigen_vectors, norm_pdm);


    I = reshape(greyimages(:,TEST_CASE),256, 256);
    [Gx,Gy] = imgradientxy(I);
    normals = normal(proj_pdm);

    % Shift the points along the grads normal
    shifted_bdry_pdm = shiftPoints(proj_pdm,normals,Gx, Gy);

    % NOW rotate back - then add the mean_pdm

    new_pdm = shiftCOM(shifted_bdry_pdm, x_mean, y_mean)
    
    figure(1), hold on;

    cpdm=correctpdms(:,TEST_CASE);
    greyimage =reshape(greyimages(:,TEST_CASE),256, 256);

    imagesc(greyimage), colormap('gray');

%     plot( mean_pdm(1:2:end), mean_pdm(2:2:end), 'r.');
    plot( cpdm(1:2:end), cpdm(2:2:end), 'b.');
    plot( shifted_bdry_pdm(1:2:end), shifted_bdry_pdm(2:2:end), 'g.');

    hold off;
    print('finalPos8','-dpng','-r256')
end

function [norm_pdm, x_mean, y_mean, rotation_matrix]  = normalizePDM(pdm)
    
    xvals = pdm(1:2:end);
    yvals = pdm(2:2:end);
    
    % Perform mean normalization
    x_mean = mean(xvals);
    y_mean = mean(yvals);
    
    % Subtract the means from x and y valeus each
    xvals = xvals - x_mean;
    yvals = yvals - y_mean;
 
    % Perform orientation normalization 
    moment_matrix=zeros(2,2);
    
    moment_matrix(1,1) = sum(xvals)
    moment_matrix(1,2) = sum(xvals .* yvals)
    moment_matrix(2,1) = sum(xvals .* yvals)
    moment_matrix(2,2) = sum(yvals)
    
    [U S V] = svd(moment_matrix);
    rotation_matrix = U';
    
    rotated = rotation_matrix * [xvals yvals]';
    norm_pdm = reshape(rotated, 128,1);
end

function new_pdm = shiftCOM(pdm, x_mean, y_mean)

    xvals = pdm(1:2:end);
    yvals = pdm(2:2:end);
    
    diff_x = mean(xvals) - x_mean
    diff_y = mean(yvals) - y_mean
    
    xvals = xvals - x_mean;
    yvals = yvals - y_mean;
    
    % Perform orientation normalization 
    moment_matrix=zeros(2,2);
    
    moment_matrix(1,1) = sum(xvals)
    moment_matrix(1,2) = sum(xvals .* yvals)
    moment_matrix(2,1) = sum(xvals .* yvals)
    moment_matrix(2,2) = sum(yvals)
    
    [U S V] = svd(moment_matrix);
    rotation_matrix = U';
    
    rotated = rotation_matrix * [xvals yvals]';
    new_pdm = reshape(rotated, 128,1);
end

function denorm_pdm = inverseNorm(pdm, mean_pdm, rotation_matrix)
    
    xvals = pdm(1:2:end);
    yvals = pdm(2:2:end);
    
    % Rotate back first
    rotated = rotation_matrix * [xvals yvals]';
    denorm_pdm = reshape(rotated, 128,1);
    
    % Add back the mean
    denorm_pdm = denorm_pdm + mean_pdm ;
end

function projected_pdm = project_to_image(mean_pdm, eigen_vals, eigen_vectors, test_pdm)

    reduced_test_pdm = eigen_vectors' * test_pdm;
    projected_pdm = zeros(128,1);

    for i = 1:5
        a_i = reduced_test_pdm(i) / sqrt(eigen_vals(i));

        if a_i < -2.5
            a_i = -2.5;
        end

        if a_i > 2.5
            a_i = 2.5;
        end

        projected_pdm = projected_pdm + a_i * eigen_vectors(:,i);
    end
    
    projected_pdm = mean_pdm + projected_pdm;

end