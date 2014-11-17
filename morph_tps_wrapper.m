function img_morphed = morph_tps_wrapper(img_source, img_dest, p_source, p_dest, warp_frac, dissolve_frac)
% Calculate the size of the resulting image
sz = max(size(img_source),size(img_dest));
sz(3) = 3;

% Calculate the intermediate shape
int_pts = (1-warp_frac)*p_source + warp_frac*p_dest;

% Obtain TPS estimates for source image
[a1_x,ax_x,ay_x,w_x] = est_tps(int_pts, p_source(:,1));
[a1_y,ax_y,ay_y,w_y] = est_tps(int_pts, p_source(:,2));

% Warp source image
intermediate1 = morph_tps(img_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, int_pts, sz);

% Obtain TPS estimates for destination image
[a1_x,ax_x,ay_x,w_x] = est_tps(int_pts, p_dest(:,1));
[a1_y,ax_y,ay_y,w_y] = est_tps(int_pts, p_dest(:,2));

% Warp destination image
intermediate2 = morph_tps(img_dest, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, int_pts, sz);

% % Plot the warped images
% figure
% subplot(1,2,1)
% imshow(intermediate1)
% subplot(1,2,2)
% imshow(intermediate2)

% Cross dissolve to morph images
img_morphed = (1-dissolve_frac)*intermediate1 + dissolve_frac*intermediate2;

end