% Find the normals
function norms = normal(pdm)

num_points = 64
x_vals = pdm(1:2:end);
y_vals = pdm(2:2:end);


for i=1:64
    
    pos_r = i+1;
    if pos_r > num_points
        pos_r = 1
    end
    
    pos_l = i-1;
    if pos_l < 1
        pos_l = num_points;
    end

    
    a = x_vals(pos_r) - x_vals(i);
    b = y_vals(pos_r) - y_vals(i);
    norm_r = [-b,a] ./ sqrt(a^2 + b^2);
    
    a = x_vals(i) - x_vals(pos_l);
    b = y_vals(i) - y_vals(pos_l);
    norm_l = [-b,a] ./ sqrt(a^2 + b^2);
    
    norms(i,:) = (norm_r + norm_l) ./ 2;
    
end
% quiver(x_vals, y_vals, norms(:,1), norms(:,2))