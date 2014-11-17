function [ morphed_im ] = morph( im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac )

%% First compute the intermediate shape
% Determine the size of the intermediate image
sz = min(size(im1), size(im2)); 

% Create Variables
numTri = size(tri,1); %number of triangles
morphed_im = zeros(sz); %output image

% Create INDEX array with indeces to every pixel in the image. Every column
% corresponds to a pixel, row 1 is x and row 2 is y, row 3 is all 1s
INDEX = ones(3,sz(1)*sz(2));
INDEX(1,:) = kron(1:sz(2), ones(1,sz(1)));
INDEX(2,:) = repmat(1:sz(1), 1, sz(2));

% Obtain the intermediate shape and morph images towards it
int_pts = (1-warp_frac)*im1_pts+warp_frac*im2_pts;

%% Compute the transformation matrices for each image
trans1 = zeros(3,3,size(tri,1));
trans2 = zeros(size(trans1));

for i = 1:numTri
    baryMatrix = [int_pts(tri(i,1), 1) int_pts(tri(i,2), 1) int_pts(tri(i,3), 1);
                  int_pts(tri(i,1), 2) int_pts(tri(i,2), 2) int_pts(tri(i,3), 2);
                  1                    1                    1                   ];
              
    trans1(:,:,i) = [im1_pts(tri(i,1), 1) im1_pts(tri(i,2), 1) im1_pts(tri(i,3), 1);
                     im1_pts(tri(i,1), 2) im1_pts(tri(i,2), 2) im1_pts(tri(i,3), 2);
                     1                    1                    1                   ] / baryMatrix;
                 
                        
    trans2(:,:,i) = [im2_pts(tri(i,1), 1) im2_pts(tri(i,2), 1) im2_pts(tri(i,3), 1);
                     im2_pts(tri(i,1), 2) im2_pts(tri(i,2), 2) im2_pts(tri(i,3), 2);
                     1                    1                    1                   ] / baryMatrix;

end

%% Calculate triangle indeces
T = tsearchn(int_pts,tri, INDEX(1:2,:)');

%% Calculate the transformed coordinates
for t = 1:numTri
    % apply transformation matrix only to subset of indeces that belong to
    % triangle i.
    triINDEX = INDEX(:,T==t);
    COORDS1 = trans1(:,:,t) * triINDEX; 
    COORDS2 = trans2(:,:,t) * triINDEX;
    
    % divide by the z element at the bottom
    COORDS1(1,:) = COORDS1(1,:)./COORDS1(3,:);
    COORDS1(2,:) = COORDS1(2,:)./COORDS1(3,:);
    COORDS1(3,:) = [];
    
    % same for second image coords
    COORDS2(1,:) = COORDS2(1,:)./COORDS2(3,:);
    COORDS2(2,:) = COORDS2(2,:)./COORDS2(3,:);
    COORDS2(3,:) = [];
    
    % get rid of negatives
    COORDS1(COORDS1 < 1) = 1;
    COORDS2(COORDS2 < 1) = 1;
    
    % interpolate
    COORDS1 = round(COORDS1);
    COORDS2 = round(COORDS2);
   
    %% Cross dissolve pixel values from transformed coordinates
    for i = 1:length(COORDS1)
        try
            morphed_im(triINDEX(2,i),triINDEX(1,i),:) = ...
                (1-dissolve_frac)*im1(COORDS1(2,i),COORDS1(1,i),:)...
                + dissolve_frac*im2(COORDS2(2,i),COORDS2(1,i),:); 
        catch
            continue;
        end
    end     
end

morphed_im = uint8(morphed_im);
end