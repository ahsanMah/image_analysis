% imngderx, imgdery = Matrices with derivative values in the x and y directions
% I_P = Intensity Polarity -> +1 looks for white circles on black backgrounds

function centers = hough_disk(fname, imgderx, imgdery, radius, I_P, num_centers, parzen_std)

    %Dimensions of Image
    dim = size(imgderx,1);

    %Magnitude of the gradient = L2-norm at each pixel
    grad_mag = sqrt(imgderx.^2+imgdery.^2); %or norm[x y]

    thresh = 0.05; %Used as mu for sigmoid function, with sd = 1
    vote_strength = normcdf(grad_mag,thresh,1);

    % Unit vectors for the gradient direction at each pixel
    derx_uv = I_P*imgderx./grad_mag;
    dery_uv = I_P*imgdery./grad_mag;

    smoothed_accum = fill_accumulator(derx_uv, dery_uv,vote_strength, dim, radius, parzen_std);

    fig=figure(1);
    
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 11 10];
    
    x = 1:dim; y = dim:-1:1;
    pcolor(x,y,smoothed_accum);
    c = colorbar;
    c.Label.String = 'Smoothed Votes';
    c.Label.FontSize = 16;
    xlabel('x');
    ylabel('y');set(get(gca,'YLabel'),'Rotation',0);
    title('\fontsize{18}Hough Map');
    

    fname = erase(fname,".png"); fname = erase(fname,".jpg");
    print("figures\"+fname+"_HoughMap.png",'-dpng');

    centers = getHighestVotes(smoothed_accum,num_centers)


end

%% Helper functions


% Gets votes from each pixel and fills them in the accumulator array
function smoothed_accum = fill_accumulator(derx_uv, dery_uv, vote_strength, dim, R, parzen_std)


    % Note that matrix columns = x coordinates and rows = y coordinates
    % So you would need to access the matrix as M(y,x) to get (x,y) pixel
    accum = zeros(dim,dim);

    % Check-function to get rid of indices outside of range
    validate =@(xy) (xy>0 & xy <= dim);

    % Maps coordinate points to valid matrix indices 
    discretize =@(x,y) round(x)+1;

        for x=0:dim-1
            for y=0:dim-1

                % To get mathematically accurate vector directions
                % with (x,y)=(0,0) pointing at bottom left pixel of image           
                i = dim-y; j = x+1;

                a = discretize(x + R * derx_uv(i,j));
                b = discretize(y + R * dery_uv(i,j));

                valid = validate([a,b]);

                if (valid)
                    accum(dim-b+1,a) = accum(dim-b+1,a) + vote_strength(j,i);
                end
            end
        end

    smoothed_accum = imgaussfilt(accum,parzen_std);
end

% Gets the top num_votes from the accumulator array
% Returns the list of x,y cenetr coordinates
function centers = getHighestVotes(accum,num_votes)
    dim = size(accum,1);
    pixel_radius = 0.07*dim;
    [xx,yy] = meshgrid(1:dim,dim:-1:1);
    centers = zeros(num_votes,2);
    
    for i=1:num_votes
        
         % Finding postion of current max
        [column_max row_nums] = max(accum);
        [max_value column_idx] = max(column_max);
        row_idx = row_nums(column_idx);
        
        
        % Recall that columns denote x values and rows y values
        % Index postions start from 1 and coordinates start from 0
        center_x = column_idx-1;
        center_y = dim - row_idx;

        % Removing votes from a scaled pixel radius by using a logical matrix       
        removed_pixels = (xx-center_x).^2 + (yy-center_y).^2 < pixel_radius^2;
        accum(removed_pixels) = 0;       
        
        centers(i,:) = [center_x, center_y];
        
    end
end
