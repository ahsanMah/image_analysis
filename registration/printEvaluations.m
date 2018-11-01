function printEvaluations(thetas, metric_vals, local_max, A, B, original_ref, correct_angle)
    
    evaluations = zeros(3,3);
    text = "metric, accuracy,rd,peakiness\n";
    
    ncc = metric_vals(1,:);
    mutual_inf = metric_vals(2,:);
    qf_dist = metric_vals(3,:);

    [metric_max, max_idx] = max(ncc);
    max_angle = thetas(max_idx)

    accuracy = max_angle/correct_angle * 100;
    relative_diff = (metric_max - local_max(1)) / metric_max;
    smooth_fn = polyfit( thetas(max_idx-2:max_idx+2), metric_vals(max_idx-2:max_idx+2), 2);

    % Peakiness = Negative 2nd derivative = -2 * first term of 2nd order polynomial
    peakiness = -2*smooth_fn(1)

    final_img = buildFan(original_ref, max_angle);
    figure()
    xlabel('x');
    ylabel('y');set(get(gca,'YLabel'),'Rotation',0);
    title("\fontsize{18} Final Angle = " + max_angle + " Radians");
    imagesc(final_img); colormap('gray');

    print("figures/ncc"+A+B+".png", '-dpng', '-r256');
    
    evaluations(1,:) = [accuracy, relative_diff, peakiness];
      
    [metric_max max_idx] = max(mutual_inf);
    max_angle = thetas(max_idx);

    accuracy = max_angle/correct_angle * 100;
    relative_diff = (metric_max - local_max(2)) / metric_max;
    smooth_fn = polyfit( thetas(max_idx-1:max_idx+1), metric_vals(max_idx-1:max_idx+1), 2);
    

    % Peakiness = Negative 2nd derivative = -2 * first term of 2nd order polynomial
    peakiness = -2*smooth_fn(1)

    final_img = buildFan(original_ref, max_angle);
    imagesc(final_img); colormap('gray');
    
    figure();
    xlabel('x');
    ylabel('y');set(get(gca,'YLabel'),'Rotation',0);
    title("\fontsize{18} Final Angle = " + max_angle + " Radians");
    imagesc(final_img); colormap('gray');

    print("figures/mi"+A+B+".png", '-dpng', '-r256');
    
    
    evaluations(2,:) = [accuracy, relative_diff, peakiness];
    
    [metric_max max_idx] = max(qf_dist);
    max_angle = thetas(max_idx);

    accuracy = max_angle/correct_angle * 100;
    relative_diff = (metric_max - local_max(3)) / metric_max;
    smooth_fn = polyfit( thetas(max_idx-2:max_idx+2), metric_vals(max_idx-2:max_idx+2), 2);

    % Peakiness = Negative 2nd derivative = -2 * first term of 2nd order polynomial
    peakiness = -2*smooth_fn(1);

    final_img = buildFan(original_ref, max_angle);
    imagesc(final_img); colormap('gray')
    figure();
    xlabel('x');
    ylabel('y');set(get(gca,'YLabel'),'Rotation',0);
    title("\fontsize{18} Final Angle = " + max_angle + " Radians");
    imagesc(final_img); colormap('gray');

    print("figures/qf"+A+B+".png", '-dpng', '-r256');
    
    evaluations(3,:) = [accuracy, relative_diff, peakiness];
    
    
    text = text + sprintf("NCC, %d, %.4f, %.2f\n",evaluations(1,:));
    text = text + sprintf("MI, %d, %.4f, %.2f\n",evaluations(2,:));
    text = text + sprintf("QF, %d, %.4f, %.2f\n",evaluations(1,:));
    
    fname = "evals"+A+B+".csv";
    fileID = fopen(fname,'w');
    fprintf(fileID, text);
    
end