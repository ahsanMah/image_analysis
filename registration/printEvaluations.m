function max_angle_best = printEvaluations(thetas, metric_vals, local_max, A, B, correct_angle)
    
    evaluations = zeros(3,3);
    text = "metric, accuracy,rd,peakiness\n";
    
    ncc = metric_vals(1,:);
    mutual_inf = metric_vals(2,:);
    qf_dist = metric_vals(3,:);
    
    
    % Evaluating Normalized Cross Correlation
    [metric_max, max_idx] = max(ncc);
    max_angle = thetas(max_idx);
    
    accuracy = max_angle/correct_angle * 100;
    relative_diff = (metric_max - local_max(1)) / metric_max;
   
    % Peakiness = Negative 2nd derivative = -2 * first term of 2nd order polynomial
    smooth_fn = polyfit( thetas(max_idx-2:max_idx+2), metric_vals(max_idx-2:max_idx+2), 2);
    peakiness = -2*smooth_fn(1);

    evaluations(1,:) = [accuracy, relative_diff, peakiness];
     
    % Evaluating Mutual Information
    [metric_max max_idx] = max(mutual_inf);
    max_angle = thetas(max_idx);
    max_angle_best = max_angle;
    
    accuracy = max_angle/correct_angle * 100;
    relative_diff = (metric_max - local_max(2)) / metric_max;
    smooth_fn = polyfit( thetas(max_idx-1:max_idx+1), metric_vals(max_idx-1:max_idx+1), 2);
    peakiness = -2*smooth_fn(1);
    
    evaluations(2,:) = [accuracy, relative_diff, peakiness];
    
    % Evaluating Quartile Function
    [metric_max max_idx] = max(qf_dist);
    max_angle = thetas(max_idx);

    accuracy = max_angle/correct_angle * 100;
    relative_diff = (metric_max - local_max(3)) / metric_max;
    smooth_fn = polyfit( thetas(max_idx-2:max_idx+2), metric_vals(max_idx-2:max_idx+2), 2);
    peakiness = -2*smooth_fn(1);
    
    evaluations(3,:) = [accuracy, relative_diff, peakiness];
    
    
    text = text + sprintf("NCC, %d, %.4f, %.2f\n",evaluations(1,:));
    text = text + sprintf("MI, %d, %.4f, %.2f\n",evaluations(2,:));
    text = text + sprintf("QF, %d, %.4f, %.2f\n",evaluations(1,:));
    
    fname = "evals"+A+B+".csv";
    fileID = fopen(fname,'w');
    fprintf(fileID, text);
    
end