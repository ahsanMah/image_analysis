function [G, super_src, sink] = constructGraph(dim, original_img, scheme)
    
    % Scheme 1 Weights:
    %   pixel-pixel  -> 1
    %   source-pixel -> 100 if intensities == background else 1
    %   pixel-sink   -> 100 if intensities == foreground else 1
    
    intensities = double(original_img(:));
    
    % Building graph
    G = imageGraph([dim,dim],4);
    G = digraph(G.Edges, G.Nodes)
    
    prune = 0;
    
    if prune == 1
    
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

        % Want bidirectional edges
        edges   = G.Edges.EndNodes;
        weights = G.Edges.Weight; % All default to 1

        s_nodes = edges(:,1);
        t_nodes = edges(:,2);
        G = addedge(G,t_nodes, s_nodes, weights);

    end
    
%   % Remove nodes that are not connected to anything
%     disp('Removing disconnected nodes...');
%     indeg = indegree(G)==0;
%     outdeg = outdegree(G)==0;
%     lonely_nodes = G.Nodes.PixelIndex(indeg & outdeg);
%     G = rmnode(G, lonely_nodes)
%     
    
    [Gmag,Gdir] = imgradient(original_img);

    gradients   = Gmag(:);
    edges = G.Edges.EndNodes;
    
    weights = inter_pixel_weight(edges, intensities, Gmag, Gdir);
    
    G.Edges.Weight = weights;
    
    
    num_pixels = dim*dim;
%     nodes = 1:num_pixels;
    
    % To ignore pixels outised the brain
    
    
    nodes = G.Nodes.PixelIndex;
    node_intensities = intensities(nodes);
      
%     nonzero_pixels = (intensities > 0);
%     background_pixels = intensities(nonzero_pixels);
%     background_nodes = find(nonzero_pixels == 1);
   
    
    foreground_pixels = node_intensities;
    num_nodes = size(node_intensities,1)
    
   
    %Assuming background and foreground intensities
    mean_background = 50
    
    % General heuristic as skull shows up lighter on MRI
    mean_target = 200
    
    WM_mean = 61;
    WM_sd = 14;
    mean_target = WM_mean; %white matter mean

    % Want high weights when connecting to background pixels 
    % If background -> High weight else Low
    s_weight = zeros(num_pixels,1) + 100;
    
    % Want high weights when connecting to target class pixels/ foreground
    % If target -> High weight else Low
    t_weight = ones(num_pixels,1);
    
    MAX = 255;
    
    switch scheme
        
        case 1 % Linear Decay
            disp('Using Scheme 1')
            s_weight = 255 ./ (1 + abs(node_intensities - mean_background));
  
            t_weight = 255 ./ (1 + abs(node_intensities - mean_target));
        
        case 2
            s_weight = 255 ./ exp(abs(intensities - mean_background));
            t_weight = 255 ./ exp(abs(intensities - mean_target));
        
        case 3

            % Target is brain
            % Background is 0 and skull
            
            sdw = 1*WM_sd;
            wm_low = WM_mean-sdw; wm_high = WM_mean+sdw;
            target_pixels = node_intensities > wm_low & node_intensities < wm_high;
            
            skull_mean = 180; skull_sd = 20;
            sm_low = skull_mean - skull_sd;
            bg_pixels = node_intensities > sm_low;
            
            s_weight = zeros(num_nodes,1);
            
%             s_weight(node_intensities < wm_low) = bg_low .* (bg_low - wm_low).^2;
            max_weight = max(max(s_weight(:)), MAX);
            s_weight(node_intensities == 0) = max_weight;
            s_weight(bg_pixels) = max_weight;
            
            t_weight = node_intensities';
%             t_weight = t_weight .* min(1, 1./(t_weight - mean_target).^2);
            t_weight = t_weight .* min(1, 1./abs(t_weight - mean_target));
            t_weight(node_intensities < 1) = 0; %Not conected to background
            t_weight(target_pixels) = MAX;
        
        case 4
            %Assuming background and foreground intensities
            mean_background = 50;
            mean_target = 200;
            
            s_weight = node_intensities .* min(1, 1./(node_intensities - mean_background).^2);
            t_weight = node_intensities .* min(1, 1./(node_intensities - mean_target).^2);
        
        otherwise
            disp('Strict cutoff')
            s_weight = node_intensities;
            t_weight = node_intensities;
            
            s_weight(s_weight > mean_target) = 0;
            t_weight(t_weight < mean_target) = 0;
       
    end
    
    % Adding a super source with Pixel Index = Num Pixels + 1
    super_src = zeros(num_nodes,1) + num_pixels + 1;
    
    % Adding a sink with Pixel Index = Num Pixels + 2
    sink = zeros(num_nodes,1) + num_pixels + 2;

    
    G = addedge(G, super_src, nodes, s_weight);
    G = addedge(G, nodes, sink, t_weight);
    
    super_src = super_src(1);
    sink = sink(1);
    
end