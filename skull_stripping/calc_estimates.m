function [skull_mean, skull_sd, wm_mean,wm_sd] = calc_estimates(I)
    sorted=sort(I(:));
    numpixels = size(sorted,1);
    
    
    quantile = uint16(0.6*numpixels) % Between 60th and 80th percentile
    q_low = sorted(quantile)

    q_high= uint16(0.8*numpixels);
    q_high = sorted(q_high)

    box = I(I > q_low & I < q_high);
    wm = mean(box(:))
    sd = std(box(:))

    wm_low = wm-1*sd; wm_high = wm+1*sd;
    I1=I;
    I1(I<wm_low | I > wm_high)= 0;
    pcolor(I1); colorbar; colormap('jet')
    
    wm_mean = wm;
    wm_sd = sd;
    
    % 
    quantile = uint16(0.98*numpixels) % 98th percentile
    skull = sorted(quantile)

    box = I(I > skull);
    skull_mean = mean(box(:))
    skull_sd = std(box(:))

    sm_low = skull_mean-1*skull_sd;
    I1=I;
    I1(I<sm_low)= 0;
    pcolor(I1); colorbar; colormap('jet') 
end

% load 'greyimages.mat' ;
% colorbar;
% 
% TEST_CASE = 31;
% I = reshape(greyimages(:,TEST_CASE),256, 256);
% I = rescale(I,0,255);
% I = imgaussfilt(I,0.5);
% % [Gx,Gy] = imgradientxy(I);
% dim = size(I,1);
% pcolor(I)
% 
% I1 =I;
% sz=30;
% y_region = 150-sz:150+sz; x_region =128-2*sz:128+2*sz;
% I1(y_region,x_region)=0;
% pcolor(I1)
% 
% I1=I;
% y_region = 180-sz/2:180+sz/2; x_region =128-1.5*sz:128+1.5*sz;
% I1(y_region,x_region)=0;
% pcolor(I1)
% 
% 
% box=I(y_region,x_region);
% wm = mean(box(:))
% sd = std(box(:))
% 
% 
% % Get pixels that are within 1 SD from WM_mean
% wm=61;sd=13;
% 
% sdw = 1*sd
% wm_low = wm-sdw; wm_high = wm+sdw;
% I1=I;
% I1(I<wm_low | I>wm_high)= 0;
% pcolor(I1); colorbar; colormap('jet')