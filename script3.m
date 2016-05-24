%Script 3 - moving along contour
contour(x_vec,y_vec,new_z_mat)
axis square

%1) take current point
point = [28 0]
hold on;
 hPlot = plot(NaN,NaN,'ro');
 set(hPlot,'XData',point(1),'YData',point(2));
%interpolate to find z
point_z = interp2(x_vec,y_vec,new_z_mat,point(:,1),point(:,2)) 

point3 = [point point_z]


for i = 1:50
%2) find direction of contour

point_dx = interp2(x_vec,y_vec,Fx,point3(:,1),point3(:,2));
point_dy = interp2(x_vec,y_vec,Fy,point3(:,1),point3(:,2));
point_dz = (point_dx^2+point_dy^2);
sl_vec = [point_dx, point_dy, point_dz];
hold on;
%quiver3(point(:,1),point(:,2),point_z,point_dx,point_dy,point_dz,50)



%normal at that position

norm_x = interp2(x_mat,y_mat,Nx,point3(:,1),point3(:,2));
norm_y = interp2(x_mat,y_mat,Ny,point3(:,1),point3(:,2));
norm_z = interp2(x_mat,y_mat,Nz,point3(:,1),point3(:,2));
n_vec = [norm_x, norm_y, norm_z];
hold on;
set(gca,'DataAspectRatio',[1 1 1]);% set data aspect ratio
set(gca,'PlotBoxAspectRatio',[1 1 1]);% set plot box aspect ratio
%quiver3(point(:,1),point(:,2),point_z,norm_x,norm_y,norm_z,20)

%cross product
cx_vec = cross(n_vec,sl_vec);
if cx_vec(:,3) > 1e-8
    %cross vector is not flat along ground i.e. is not a contour
end

quiver3(point3(:,1),point3(:,2),point_z,cx_vec(:,1),cx_vec(:,2),0,20) %flat arrow for contour direction

% move in guessed directon
step = 30;
point3_next = point3 + step*[cx_vec(:,1) cx_vec(:,2) 0] %holding z
plot(point3_next(1),point3_next(2),'bo');

% 3) interpolate to origional contour required

% take origional contour
[origC, hc] = contour(x_vec,y_vec,new_z_mat,[point3(3) point3(3)],'b--');
S = contourcs(x_vec,y_vec,new_z_mat,[point3(3) point3(3)])
cline_vec = [S.X' S.Y'];
idx_nearest = dsearchn(cline_vec,[point3_next(1) point3_next(2)])
interp_point = [cline_vec(idx_nearest,1:2) S.Level]
%confirm that this is actually a point on the mesh - i.e. compare z values
%of interpolated z to the s level
point_z_Test = interp2(x_vec,y_vec,new_z_mat,interp_point(:,1),interp_point(:,2)) 

if S.Level ~= point_z_Test
    disp('we are on the mesh')
else
    disp('we are NOT on the mesh')
end


%confirm that S.Level is the same as origional level
if S.Level == point3(:,3)
    disp('we have remained on the same contour line')
    point3_next = interp_point;
end
plot(point3_next(1),point3_next(2),'ro');

point3 = point3_next;
drawnow
pause(0.1)
end