% Function that creates quantile functions for two images
% Returns the euclidean distanc between the two

function euclid_dist = quartile(target, ref_img)
    
    [dimx dimy] = size(target);
    
    % Normalize images first
    
    % Start range from zero
%     norm_target = target - min(target(:));
%     norm_ref = ref_img - min(ref_img);
%     
%     % Rescale range to be between 0 and 1
%     norm_target = norm_target ./ max(norm_target);
%     norm_ref = norm_ref ./ max(norm_ref);
%     
    norm_target=target;
    norm_ref=ref_img;
    
    
    [target_Gmag, target_Gdir] = imgradient(norm_target);
    [ref_Gmag, ref_Gdir] = imgradient(norm_ref);

    %%%Choosing gradient magnitudes in the top left corner as a feature%%%
    num_pixels = dimx/2 * dimy/2;
    
    % Number of elements in one quantile
    % Defaulting to 8 quantiles
    qsize = num_pixels/8;
    
    % Recall that the rows correspond to y values and columns to x values
    
    t_corner = target_Gmag(dimy/2+1:end, dimx/2+1:end);
    t_corner = sort(reshape(t_corner, 1, num_pixels));
    
    r_corner = ref_Gmag(dimy/2+1:end, dimx/2+1:end);
    r_corner = sort(reshape(r_corner, 1, num_pixels));

    target_qf = [t_corner(1) t_corner(qsize:qsize:end)];
    ref_qf = [r_corner(1) r_corner(qsize:qsize:end)];
    
    % Calculating Euclidean Distance
    
    SSD = sum( (target_qf - ref_qf).^2 );
    euclid_dist = sqrt(SSD);
%     euclid_dist = SSD;
    
end