%% INTRO
% This script can showcase the work I did for this project and can also
% generate videos of transformations. In the next variables, indicate
% whether you want to use the triangulation method or not, and then whether
% you want a video to be created or not. If you write 0 on video, it will
% show you the middle image (0.5 for dissolve and warp fraction). It will
% also show the triangulation over the original images. If you want to use
% the same points I did, simply run this section to load the variables
% triangles and video and then load the included pickedPoints.mat file,
% which will replate the click correspondances routine. Then run the
% section with the video or the single image creation to see the results.

clear
clc

% Select morphing method
triangles = 0;
video = 0;

%% Loading Images to Memory

im1 = imread('seb.jpg');
im2 = imread('will.jpg');

%% Click Correspondences

% obtain user input for points
[im1_pts, im2_pts] = click_correspondences(im1, im2);

% triangulate
mean_pts = (im1_pts + im2_pts)/2;
triangulation = delaunay(mean_pts);

%% Plot
subplot(1,2,1);
imshow(im1);
hold on
triplot(triangulation, im1_pts(:,1), im1_pts(:,2));
triplot(triangulation, mean_pts(:,1), mean_pts(:,2),'r');
hold off

subplot(1,2,2);
imshow(im2);
hold on
triplot(triangulation, im2_pts(:,1), im2_pts(:,2));
triplot(triangulation, mean_pts(:,1), mean_pts(:,2),'r');
hold off

axis equal

if video
    %% Image Morph Via Triangulation Video Creation
    if triangles
        vname = 'Triangulation.avi';
    else
        vname = 'TPS.avi';
    end
    
    try
        % VideoWriter based video creation
        h_avi = VideoWriter(vname, 'Uncompressed AVI');
        h_avi.FrameRate = 10;
        h_avi.open();
    catch
        % Fallback deprecated avifile based video creation
        h_avi = avifile(vname,'fps',10);
    end

    fig = figure;
    fracs = linspace(0,1,60);
    for i = 1:60  
        if triangles
            morphed_image = morph(im1, im2, im1_pts, im2_pts, triangulation, fracs(i), fracs(i));
        else
            morphed_image = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, fracs(i), fracs(i));
        end
        imshow(morphed_image);
        axis image; axis off;drawnow;
        try
            % VideoWriter based video creation
            h_avi.writeVideo(getframe(fig));
        catch
            % Fallback deprecated avifile based video creation
            h_avi = addframe(h_avi, getframe(fig));
        end
    end

    try
        % VideoWriter based video creation
        h_avi.close();
    catch
        % Fallback deprecated avifile based video creation
        h_avi = close(h_avi);
    end
    clear h_avi;
else
    if triangles
        %% Only one frame
        morphed_pic = morph(im1, im2, im1_pts, im2_pts, triangulation, .5, .5);
        figure
        imshow(morphed_pic);
    else
        %% Image Morph Via THIN PLATE SPLINE Method 
        morphed_pic = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, 0.5, 0.5);
        figure
        imshow(morphed_pic);
    end
end