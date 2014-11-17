function [ im1_pts, im2_pts ] = click_correspondences( im1, im2 )

[im1_pts, im2_pts] = cpselect(im1, im2, 'Wait', true);

% ADD CORNERS so that every pixel is within a triangle
im1_pts(end+1, :) = [0 0];
im1_pts(end+1, :) = [size(im1,2) 0];
im1_pts(end+1, :) = [size(im1,2) size(im1,1)];
im1_pts(end+1, :) = [0 size(im1,1)];

im2_pts(end+1, :) = [0 0];
im2_pts(end+1, :) = [size(im2,2) 0];
im2_pts(end+1, :) = [size(im2,2) size(im2,1)];
im2_pts(end+1, :) = [0 size(im2,1)];

end

