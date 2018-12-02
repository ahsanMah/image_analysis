% Using maxflow for skull stripping

load 'greyimages.mat' ;

% TEST_CASE = 32;
% I = reshape(greyimages(:,TEST_CASE),256, 256);
% [Gx,Gy] = imgradientxy(I);

figure(1);

% imagesc(I); colormap('gray');

fname = 'test.png'
dim=16; radius=5;
% insertCircles(dim,1,radius,fname,0,0);

I = imread(fname);

if ~ismatrix(I)
    I = rgb2gray(I) + 1;
end

[Gmag,Gdir] = imgradient(I);

% Building graph

G = imageGraph([dim,dim],4)

edges   = G.Edges.EndNodes;
weights = G.Edges.Weight; % All default to 1

gradients = Gmag(:);

% Separating source and sink nodes
s_nodes = edges(1:2:end);
t_nodes = edges(2:2:end);

% Want bidirectional edges
G = addedge(G,t_nodes, s_nodes, weights)

% Adding a super source with Pixel Index = Num Pixels + 1
num_pixels = dim*dim;
nodes = 1:num_pixels;

super_src = zeros(num_pixels,1) + num_pixels + 1;
intensities = I(:);


% Want high weights when connecting to background pixels 
% If background -> High weight else Low
s_weight = ones(num_pixels,1);
s_weight(intensities == 1) = 100;

G = addedge(G, super_src, nodes, s_weight)

% Adding a sink with Pixel Index = Num Pixels + 2
sink = zeros(num_pixels,1) + num_pixels + 2;

% Want high weights when connecting to target class pixels/ foreground
% If target -> High weight else Low
t_weight = ones(num_pixels,1);
t_weight(intensities > 1) = 100;

G = addedge(G, sink, nodes, t_weight);

% Run max flow 


















