% Using maxflow for skull stripping
addpath('Image Graphs')
load 'greyimages.mat' ;

TEST_CASE = 32;
I = reshape(greyimages(:,TEST_CASE),256, 256);
I = rescale(I,0,255);
I = imgaussfilt(I,0.15);
% [Gx,Gy] = imgradientxy(I);
dim = size(I,1);

% % Build Test Image
% fname = 'test.png';
% dim=16; radius=4;
% insertCircles(dim,1,radius,fname,0,0);
% I = imread(fname);
% imagesc(I);

if ~ismatrix(I)
    I = rgb2gray(I);
end

cutoff = 15;
I(I < cutoff) = 0;

figure(1);
imagesc(I); colormap(gray); set(gca,'YDir','normal');


original_img = I;

INT_DIFF = 4;
HYBRID = 3;

% Building graph
[G, super_src, sink] = constructGraph(dim, original_img,INT_DIFF,1)

% Run max flow
[mf,GF,cs,ct] = maxflow(G, super_src, sink);

% Can only run Ford Fulkerson if non parallel edges
% [mf,GF,cs,ct] = maxflow(G, super_src, sink, 'augmentpath')

sink_nodes = ct(1:end-1);
src_nodes  = cs(1:end-1);

x_vals = G.Nodes.x(sink_nodes);
y_vals = G.Nodes.y(sink_nodes);

src_x = G.Nodes.x(src_nodes);
src_y = G.Nodes.y(src_nodes);


hold on;
% s = scatter(x_vals,y_vals,5,'Filled','MarkerFaceColor','r');
s = scatter(src_x,src_y,10,'Filled', 'MarkerFaceColor','r');

hold off;

[G, super_src, sink] = constructGraph(dim, original_img,HYBRID,1)

% Run max flow
[mf,GF,cs,ct] = maxflow(G, super_src, sink);
h_src_nodes = cs(1:end-1);

diff_skull = src_nodes;
hybrid_skull = h_src_nodes;

I1=I; I1(diff_skull) = 0; I1(hybrid_skull) = 0;
% I1 = imgaussfilt(I1,0.25);
imagesc(I1); colormap(gray); set(gca,'YDir','normal');

figure(2);
imagesc(original_img); colormap(gray); set(gca,'YDir','normal');