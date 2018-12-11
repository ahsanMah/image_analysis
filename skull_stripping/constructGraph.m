function [G, super_src, sink] = constructGraph(dim, original_img, scheme)
    
    % Scheme 1 Weights:
    %   pixel-pixel  -> 1
    %   source-pixel -> 100 if intensities == background else 1
    %   pixel-sink   -> 100 if intensities == foreground else 1

    % Building graph

    G = imageGraph([dim,dim],4);
    
    G = digraph(G.Edges, G.Nodes)
    
    edges   = G.Edges.EndNodes;
    weights = G.Edges.Weight; % All default to 1
    
    % Want bidirectional edges
    s_nodes = edges(:,1);
    t_nodes = edges(:,2);
    G = addedge(G,t_nodes, s_nodes, weights);
    
    
    [Gmag,Gdir] = imgradient(original_img);

    intensities = double(original_img(:));
    gradients   = Gmag(:);
    edges = G.Edges.EndNodes;
    
    weights = inter_pixel_weight(edges, intensities, Gmag, Gdir);
    
    G.Edges.Weight = weights;
    
    
    num_pixels = dim*dim;
    nodes = 1:num_pixels;
    
    % Adding a super source with Pixel Index = Num Pixels + 1
    super_src = zeros(num_pixels,1) + num_pixels + 1;
    
    % Adding a sink with Pixel Index = Num Pixels + 2
    sink = zeros(num_pixels,1) + num_pixels + 2;

    
    %Assuming background and foreground intensities
    mean_background = 100
    
    % General heuristic as skull shows up lighter on MRI
    mean_target = 175

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
             
        otherwise
            s_weight = zeros(num_pixels,1) + 100;
            t_weight = ones(num_pixels,1);
       
    end
    
     

    G = addedge(G, super_src, nodes, s_weight);
    G = addedge(G, nodes, sink, t_weight);
    
    super_src = super_src(1);
    sink = sink(1);
    
end