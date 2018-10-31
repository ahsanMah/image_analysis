
original = zeros(128,128);

A=1; B=0; sd = 2; k = 4;
correct_angle = 0.25/k;

target = buildFan(original,correct_angle);
blurred = imgaussfilt(target,sd);
target = blurred*A + B;
figure(2);
imagesc(target); colormap('gray');

ref_img = buildFan(original,0);
ref_img = imgaussfilt(ref_img, sd) * A + B;
original_ref = ref_img;

figure(3);
imagesc(ref_img); colormap('gray');


