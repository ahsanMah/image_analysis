function weights = inter_pixel_weight(edges, intensities, Gmag, Gdir)

    % Separating source and sink pixels
    s_nodes = edges(:,1);
    t_nodes = edges(:,2);
    
    
    % Gradient direction difference
    % More orthogonal - less likely to belong to the same class
    
    directions = Gdir(:);
    
    dim  = size(s_nodes,1)
    weights = zeros(dim,1);
    
    % Calculating weights for s -> t
    for idx = 1:dim
        s = s_nodes(idx);
        t = t_nodes(idx);
        
        % How far away from being perpendicular
        angle_diff = abs(directions(s) - directions(t));
        weights(idx) = (1 + cos(angle_diff)) * 100;
    end

end