function output_img = buildFan(input_img, angle)
    original = input_img;
    [dimx dimy] = size(original);
    
%     Building the gaussian fan by convolving with the tehtas calculated
    k = 4;
    for x = 1:dimx
        for y=1:dimy
            %angle b/w (x,y)-(64.5,64.5)and (1,0)
            X = x-64.5-1;
            Y = y-64.5;
            theta = atan2(Y,X);
            original(x,y) = (1/(1+abs(theta+angle))^2)*cos(2*pi*k*(theta+angle)); 
        end
    end
    output_img = original;
end