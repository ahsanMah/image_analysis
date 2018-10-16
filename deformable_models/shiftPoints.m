function shifted_pdm = shiftPoints(pdm, normals, Gx, Gy)
    
    xvals = pdm(1:2:end);
    yvals = pdm(2:2:end);
    shifted_pdm = [];
    
    for pt = 1:64
        norm_points = zeros(11,2);
        normal = normals(pt,:);
        
        %Get the x and y values for a praticular point
        x = xvals(pt); y = yvals(pt);
        
        % Get 11 points around the normal
        for i=1:5
            norm_points(i,:) = [x y] + normal * i;          
            norm_points(12-i,:) = [x y] + normal * -i;
        end
        norm_points(6,:) = [x y];
        
        % Find directional derivative on this point
        % If greater than max derivative, update max and note the
        % points
        max = 0;
        x_max = x; y_max = y;
        for i=1:11
            x1 = norm_points(i,1);
            y1 = norm_points(i,2);

            grad_I = interpolateDD(x1,y1, Gx, Gy);
            if dot(-1*normal, grad_I) > max % Directional derivative
                max = dot(-1*normal, grad_I);
                x_max=x1; ymax=y1;
            end
        end
        
        shifted_pdm = [shifted_pdm, x_max, y_max];
        
    end
    shifted_pdm = shifted_pdm';
end

% Interpolate the directional derivative using four neighbouring points
function interpol = interpolateDD(x,y, Gx, Gy)
    [x,y]
    j = floor(x)+1; delta_x = x-j;
    k = floor(y)+1; delta_y = y-k;
    
    interpol = delta_y*(delta_x * [Gx(j+1,k+1), Gy(j+1,k+1)] + ...
           (1-delta_x) * [Gx(j,k+1), Gy(j,k+1)]) + ...
           (1-delta_y) * ( delta_x * [Gx(j+1,k), Gy(j+1,k)] + ...
           (1-delta_x) * [Gx(j,k), Gy(j,k)]);

end