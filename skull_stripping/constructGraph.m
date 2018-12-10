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
    s_nodes = edges(:,1)
    t_nodes = edges(:,2)
    G = addedge(G,t_nodes, s_nodes, weights);
    
    
    [Gmag,Gdir] = imgradient(original_img);

    intensities = original_img(:);
    gradients   = Gmag(:);
    edges = G.Edges.EndNodes;
    
    weights = inter_pixel_weight(edges, intensities, Gmag, Gdir);
    
    G.Edges.Weight = weights;
    
    
    % Adding a super source with Pixel Index = Num Pixels + 1
    num_pixels = dim*dim;
    nodes = 1:num_pixels;

    super_src = zeros(num_pixels,1) + num_pixels + 1;

%     switch scheme
%         case 2
%             
%     end
    
    mean_background = 1
    mean_target = 154

    % Want high weights when connecting to background pixels 
    % If background -> High weight else Low
    s_weight = zeros(num_pixels,1) + 100;

%     s_weight = 100 ./ (intensities - mean_background + 1) % favors Background
    s_weight(intensities > 1) = 1;

    G = addedge(G, super_src, nodes, s_weight);

    % Adding a sink with Pixel Index = Num Pixels + 2
    sink = zeros(num_pixels,1) + num_pixels + 2;

    % Want high weights when connecting to target class pixels/ foreground
    % If target -> High weight else Low
    t_weight = ones(num_pixels,1);
    
%     t_weight = 100 ./ (intensities - mean_target + 1); % favors target

    t_weight = gradients;

    G = addedge(G, sink, nodes, t_weight);
    
    super_src = super_src(1);
    sink = sink(1);
    
end