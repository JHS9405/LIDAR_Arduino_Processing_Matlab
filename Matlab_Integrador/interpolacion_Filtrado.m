clc,clear all, close all
%% Median Filter
Data = load('ventilador.xyz');
K=3; % Number of samples for the Median Filter
for (j=1:3)
    for (i=1:length(Data))
        if(mod(i,K)==0)
            for(q=1:K)
                A(q)=Data((i-(K-q)),j);
            end
            filt=median(A);
            for(r=1:K)
                if ((Data((i-(K-r)),j)>(filt))||(Data((i-(K-r)),j)<(filt)))
                    Data((i-(K-r)),j)=filt;
                end
            end
        end
    end
end
%% Point Cloud Rotation
ptCloud=pointCloud(Data);
Rotation_1= [1 0 0 0; ...
    0 cos(-pi/4) -sin(-pi/4) 0; ...
    0 sin(-pi/4) cos(-pi/4) 0; ...
    0 0 0 1];
tform_1 = affine3d(Rotation_1);
ptCloud_1 = pctransform(ptCloud,tform_1);
Rotation_2= [1 0 0 0; ...
    0 cos(pi) -sin(pi) 0; ...
    0 sin(pi) cos(pi) 0; ...
    0 0 0 1];
tform_2 = affine3d(Rotation_2);
ptCloud_2 = pctransform(ptCloud_1,tform_2);
pcshow(ptCloud_2);
colormap('jet');
xlabel('X');
ylabel('Y');
zlabel('Z');
%% Point Cloud Interpolation
x = ptCloud_2.Location(:,1);
y = ptCloud_2.Location(:,2);
z = ptCloud_2.Location(:,3);
F = TriScatteredInterp(x,y,z);
sx=min(x);
hx=max(x);
sy=min(y);
hy=max(y);
[qx,qy] = meshgrid(sx:0.1:hx,sy:0.1:hy);
qz = F(qx,qy);
figure;
surf(qx,qy,qz);
colormap('jet');
axis equal
shading interp
xlabel('X');
ylabel('Y');
zlabel('Z');