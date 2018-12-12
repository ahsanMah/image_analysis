load 'greyimages.mat' ;
colorbar;

TEST_CASE = 32;
I = reshape(greyimages(:,TEST_CASE),256, 256);
I = rescale(I,0,255);
I = imgaussfilt(I,0.5);
% [Gx,Gy] = imgradientxy(I);
dim = size(I,1);
pcolor(I)

I1 =I;
sz=30;
y_region = 150-sz:150+sz; x_region =128-2*sz:128+2*sz;
I1(y_region,x_region)=0;
pcolor(I1)

I1=I;
y_region = 180-sz/2:180+sz/2; x_region =128-1.5*sz:128+1.5*sz;
I1(y_region,x_region)=0;
pcolor(I1)


box=I(y_region,x_region);
wm = mean(box(:))
sd = std(box(:))


% Get pixels that are within 1 SD from WM_mean
wm=61;sd=13;

sdw = 1*sd
wm_low = wm-sdw; wm_high = wm+sdw;
I1=I;
I1(I<wm_low | I>wm_high)= 0;
pcolor(I1); colorbar; colormap('jet')


sorted=sort(I(:));
numpixels = size(sorted,1);
quantile = uint16(0.5*numpixels) % 90th percentile
skull = sorted(quantile)

q_low= uint16(0.78*numpixels);
q_low = sorted(q_low)

box = I(I > skull);
sm = mean(box(:))
sd = std(box(:))

sm_low = sm-1.5*sdw; sm_high = sm+sdw;
I1=I;
I1(I<sm_low | I > q_low)= 0;
pcolor(I1); colorbar; colormap('jet')


quantile = uint16(0.98*numpixels) % 90th percentile
skull = sorted(quantile)

box = I(I > skull);
sm = mean(box(:))
sd = std(box(:))

sm_low = sm-1*sd; sm_high = sm+sdw;
I1=I;
I1(I<sm_low)= 0;
pcolor(I1); colorbar; colormap('jet')