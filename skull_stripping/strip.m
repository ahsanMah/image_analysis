% Using maxflow for skull stripping

load 'greyimages.mat' ;

% TEST_CASE = 32;
% I = reshape(greyimages(:,TEST_CASE),256, 256);
% [Gx,Gy] = imgradientxy(I);

figure(1);

% imagesc(I); colormap('gray');

fname = 'test.png'
dim=64; radius=16;
insertCircles(dim,1,radius,fname,0,0);

I = imread(fname);
imagesc(I);

if ~ismatrix(I)
    I = rgb2gray(I) + 1;
end

[Gmag,Gdir] = imgradient(I);

intensities = I(:);
gradients   = Gmag(:)

% Building graph
G = constructGraph(dim, intensities, gradients, 1)

% Run max flow 

[mf,GF,cs,ct] = maxflow(G, super_src(1), sink(1));

sink_nodes = ct(1:end-1);

x_vals = G.Nodes.x(sink_nodes);
y_vals = G.Nodes.y(sink_nodes);

hold on;
s = scatter(x_vals,y_vals,15,'Filled');
s.MarkerEdgeColor = 'r';
hold off;













