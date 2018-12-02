function insertCircles(dim, num_circles, radius,fname, blurring_intensity, noise_intensity)
    empty = zeros(dim,dim);
    centers = [dim/2 dim/2];

    radii = zeros(num_circles,1)+radius;
    shape = [centers radii];
    
    circles = insertShape(empty,'FilledCircle',shape,'Color','white','LineWidth',3);
    
    % Blur the image
%     circles = imgaussfilt(circles,blurring_intensity);
    
    % Add noise to the image
%     circles = imnoise(circles, 'gaussian', 0 ,noise_intensity);

    imshow(circles)
    imwrite(circles,fname)
end