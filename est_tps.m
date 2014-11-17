function [ a1, ax, ay, w ] = est_tps( ctr_pts, target_value )

% DEFINE VARIABLES
lambda = 0.0000001;
p = size(ctr_pts,1);

% CREATE K
% NOTE: I actually vectorized this process and it consistently ran slower 
% than these nested for loops for a little bit so I left this loop. I
% suspect for huge p sizes, the vectorization might be more efficient.
K = zeros(p,p);
for i = 1:p
    for j = 1:p
        r = (ctr_pts(i,1)-ctr_pts(j,1))^2+(ctr_pts(i,2)-ctr_pts(j,2))^2; 
        if r < 0.000000001
            K(i,j) = 0;
        else
            K(i,j) = r*log(r);
        end
    end
end


% CREATE P
P = [ctr_pts ones(p,1)];

% OBTAIN SOLUTION 
sol = ([K P; P' zeros(3)] + lambda*eye(p+3))\[target_value(:,1); 0; 0; 0];

% EXTRACT DESIRED PARAMETERS
w  = sol(1:end-3);
ax = sol(end-2);
ay = sol(end-1);
a1 = sol(end);

end
