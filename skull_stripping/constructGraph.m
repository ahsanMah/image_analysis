function [G, super_src, sink] = constructGraph(dim, original_img, scheme)
    
    % Scheme 1 Weights:
    %   pixel-pixel  -> 1
    %   source-pixel -> 100 if intensities == background else 1
    %   pixel-sink   -> 100 if intensities == foreground else 1
    
    intensities = double(original_img(:));
    
    % Building graph
    G = imageGraph([dim,dim],4);
    G = digraph(G.Edges, G.Nodes)
     
    % Remove edges involving pixels with very low intensities
    cutoff = 20
    edges = G.Edges.EndNodes;   
    rm_s = []; 
    rm_t = [];
    for edge = edges.' %Transpose the matrix to loop over rows
        s = edge(1);
        t = edge(2);
        
        if intensities(s) < cutoff && intensities(t) < cutoff
            rm_s = [rm_s s]; rm_t = [rm_t t];
        end
    end
    
    disp('After pruning...');
    G = rmedge(G,rm_s, rm_t)
    % Remove nodes that are not connected to anything
    G = rmnode()
    
    % Want bidirectional edges
    edges   = G.Edges.EndNodes;
    weights = G.Edges.Weight; % All default to 1
    
    s_nodes = edges(:,1);
    t_nodes = edges(:,2);
    G = addedge(G,t_nodes, s_nodes, weights);
    
    
    [Gmag,Gdir] = imgradient(original_img);

    
    gradients   = Gmag(:);
    edges = G.Edges.EndNodes;
    
    weights = inter_pixel_weight(edges, intensities, Gmag, Gdir);
    
    G.Edges.Weight = weights;
    
    
    num_pixels = dim*dim;
%     nodes = 1:num_pixels;
    
    % To ignore pixels outised the brain
    nonzero_pixels = (intensities > 0);
    
    
    background_pixels = intensities(nonzero_pixels);
    foreground_pixels = background_pixels;
    num_nonzero = size(background_pixels,1);
    
    % Adding a super source with Pixel Index = Num Pixels + 1
    super_src = zeros(num_nonzero,1) + num_pixels + 1;
    
    % Adding a sink with Pixel Index = Num Pixels + 2
    sink = zeros(num_nonzero,1) + num_pixels + 2;

    
    %Assuming background and foreground intensities
    mean_background = 75
    
    % General heuristic as skull shows up lighter on MRI
    mean_target = 200

    % Want high weights when connecting to background pixels 
    % If background -> High weight else Low
    s_weight = zeros(num_pixels,1) + 100;
    
    % Want high weights when connecting to target class pixels/ foreground
    % If target -> High weight else Low
    t_weight = ones(num_pixels,1);
    
    
    switch scheme
        
        case 1 % Linear Decay
            disp('Using Scheme 1')
            s_weight = 255 ./ (1 + abs(intensities - mean_background));
  
            t_weight = 255 ./ (1 + abs(intensities - mean_target));
        
        case 2
            s_weight = 255 ./ exp(abs(intensities - mean_background));
            t_weight = 255 ./ exp(abs(intensities - mean_target));
        
        case 3
            original_img(original_img < 30) = 0 ; % Gets rid of the noise outside
            s_weight = original_img;
            t_weight = original_img;
            
            s_weight(original_img > mean_target) = 0;
            t_weight(original_img < mean_target) = 0;
        
        case 4
            
            s_weight = background_pixels .* min(1, 1./(background_pixels - mean_background).^2);
            t_weight = foreground_pixels .* min(1, 1./(foreground_pixels - mean_target).^2);
        
        otherwise
            s_weight = zeros(num_pixels,1) + 100;
            t_weight = ones(num_pixels,1);
       
    end
    
    
    background_nodes = find(nonzero_pixels == 1);
    foreground_nodes = background_nodes;
    
    G = addedge(G, super_src, background_nodes, s_weight);
    G = addedge(G, foreground_nodes, sink, t_weight);
    
    super_src = super_src(1);
    sink = sink(1);
    
end