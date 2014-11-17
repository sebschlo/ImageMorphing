function [ morphed_im ] = morph_tps( im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz )
% Output image
morphed_im = zeros(sz(1), sz(2), 3);

%% Prepare x and y arrays for multiplying for all of fx and fy at once
% I created an array called index, holding all the indeces to the pixels in
% the images. Each row corresponds to a pixel. The first column holds the
% row index for that pixel and the second column it's column index.
xIndeces = (1:sz(2))';
yIndeces = (1:sz(1))';
INDEX = zeros(sz(1)*sz(2),2);
INDEX(:,2) = repmat(xIndeces, sz(1), 1);
INDEX(:,1) = kron(yIndeces,ones(sz(2),1));

%% Calculate the summations for both fx and fy
% xdiff will hold the difference of each ctr_pt and each x index. each row
% has a copy of the control points and corresponds to an x index.
xdiff = repmat(ctr_pts(:,1)',sz(2),1);
xdiff = xdiff - repmat(xIndeces,1,size(ctr_pts,1));
% y diff is the same for the y indeces
ydiff = repmat(ctr_pts(:,2)',sz(1),1);
ydiff = ydiff - repmat(yIndeces,1,size(ctr_pts,1));
% each element in these matrices is now squared, this is equivalent to the
% formula for distance 
xdiff = xdiff.*xdiff;
ydiff = ydiff.*ydiff;
% now the matrices are repeated and interspersed so that each row
% corresponds to a specific row,column index pair from INDEX array
xdiff = repmat(xdiff,sz(1),1);
ydiff = kron(ydiff,ones(sz(2),1));
% u is created with the addition of the x and y values and U is performed
% on every element, NaNs are removed as well. 
u = xdiff+ydiff;
u = u.*log(u);
u(isnan(u)) = 0;
% matrix multiplication between u and the w row vectors will yield the sum
% of the multiplications of each corresponding element and will place this
% value in a column vector, where every row corresponds to a specific i,j
sumX = u*w_x;
sumY = u*w_y;

%% Perform calculations for all indeces of the image
fx = a1_x + ax_x*INDEX(:,2) + ay_x*INDEX(:,1) + sumX;
fy = a1_y + ax_y*INDEX(:,2) + ay_y*INDEX(:,1) + sumY;

% Take care of pixels outside of the image
fx(fx<1) = 1;
fx(fx > sz(2)) = sz(2);
fy(fy<1) = 1;
fy(fy > sz(1)) = sz(1);

%Interpolate
fx = round(fx);
fy = round(fy);

%% Perform the pixel value placements
for i = 1:size(INDEX,1)
    % f contains [x y] so you must flip here to [row=y col=x]
    try
        morphed_im(INDEX(i,1),INDEX(i,2),:) = im_source(fy(i), fx(i),:);
    catch
        continue;
    end
end

morphed_im = uint8(morphed_im);
end

