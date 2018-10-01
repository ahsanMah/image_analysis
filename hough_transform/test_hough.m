% Testing script for hough line

radius = 25;

fname = 'test.png';

rng(10); % Seed the random number generator
blurring_intensity = 0.5; noise_intensity = 0.01;
img_dim = 128; num_circles = 3;
insertRandomCircles(img_dim,num_circles,radius,fname, blurring_intensity,noise_intensity);

num_centers = 2;

original = imread(fname);

if ~ismatrix(original)
    original = rgb2gray(original);
end

scale = 0.5;
[imgderx, imgdery]=Derivative(original,scale);

%I_P = Intensity Polarity -> +1 looks for white circles on black backgrounds
I_P = -1;
parzen_std = 1;

centers = hough_disk(fname, imgderx, imgdery,radius,I_P,num_centers, parzen_std);

fig = figure(2);

subplot(1,2,1);
imshow(original);
axis on;
title('\fontsize{14}Original Image');
xlabel('x');
ylabel('y');set(get(gca,'YLabel'),'Rotation',0)

subplot(1,2,2);

% Note: viscircles and imshow plot y-axis top to bottom
dim = size(original,1);
centers(:,2) = dim - centers(:,2);

imshow(original);
radii = zeros(1,num_centers)+radius;
viscircles(centers,radii);
axis on;
title('\fontsize{14}Disks Discovered by Hough Transform');
xlabel('x');
ylabel('y');set(get(gca,'YLabel'),'Rotation',0)

% Save generated image to file
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 10 4];
fname = erase(fname,".png"); fname = erase(fname,".jpg");
print("figures\"+fname+"_detected.png",'-dpng','-r0');


function insertRandomCircles(dim, num_circles, radius,fname, blurring_intensity, noise_intensity)
    empty = zeros(dim,dim);
    centers = randi(dim, [num_circles 2])

    radii = zeros(num_circles,1)+radius;
    shape = [centers radii];
    
    circles = insertShape(empty,'circle',shape,'Color','white','LineWidth',3);
    
    % Blur the image
    circles = imgaussfilt(circles,blurring_intensity);
    
    % Add noise to the image
    circles = imnoise(circles, 'gaussian', 0 ,noise_intensity);

    imshow(circles)
    imwrite(circles,fname)
end