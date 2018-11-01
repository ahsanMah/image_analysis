% Tries rotations defined by thetas and gets values by using three different metrics

function [metric_vals, local_max] = getMetrics(target, original_ref, thetas, A, B)
    % Iterating over rotations

    metric_vals = zeros(3,size(thetas,2));
    local_max = zeros(3);
    sd = 2;
    
    % Calculating global max
    idx = 0;
    for curr_angle = thetas
        idx = idx+1;
        
        ref_img = buildFan(original_ref, curr_angle);
        ref_img = imgaussfilt(ref_img, sd) * A + B;
        
        % Normalized cross correlation
        ncc = max(max(normxcorr2(target, ref_img)));
        mutual_inf = mi(target, ref_img);
        qf_dist = quartile(target, ref_img);

        metric_vals(1,idx) = ncc;
        metric_vals(2,idx) = mutual_inf;
        metric_vals(3,idx) =  qf_dist;
        
    end
    
    % Want the metric to be max when distance is the lowest
    % So we normalize from 0 to 1 and subtract the result from 1
    qf_dists = metric_vals(3,:);
    qf_dists = qf_dists - min(qf_dists);
    qf_dists = qf_dists ./ max(qf_dists);
    metric_vals(3,:) = 1 - qf_dists;
    
    
    % Assuming local max is at -0.75/4 = -0.1875 approx
    idx = find(thetas == -0.1875);
    local_max(1) = metric_vals(1,idx);
    local_max(2) = metric_vals(2,idx);
    local_max(3) = metric_vals(3,idx);
 
end