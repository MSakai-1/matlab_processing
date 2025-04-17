% hello world
%カメラの位置及び，方向ベクトルを保存するコード
clc;clear all; close all;
load("grasping_mocap.mat")
tablename="tra6_cam";

%% 80 190s

data_triton.time = mocap.tra6.Time;
data_triton.x1 = mocap.tra6.X1;
data_triton.y1 = mocap.tra6.Y1;
data_triton.z1 = mocap.tra6.Z1;

data_triton.x2 = mocap.tra6.X2;
data_triton.y2 = mocap.tra6.Y2;
data_triton.z2 = mocap.tra6.Z2;

data_triton.x3 = mocap.tra6.X3;
data_triton.y3 = mocap.tra6.Y3;
data_triton.z3 = mocap.tra6.Z3;

data_triton.x4 = mocap.tra6.X4;
data_triton.y4 = mocap.tra6.Y4;
data_triton.z4 = mocap.tra6.Z4;

data_triton.x1 = fillmissing(data_triton.x1,"linear");
data_triton.x2 = fillmissing(data_triton.x2,"linear");
data_triton.x3 = fillmissing(data_triton.x3,"linear");
data_triton.x4 = fillmissing(data_triton.x4,"linear");

data_triton.y1 = fillmissing(data_triton.y1,"linear");
data_triton.y2 = fillmissing(data_triton.y2,"linear");
data_triton.y3 = fillmissing(data_triton.y3,"linear");
data_triton.y4 = fillmissing(data_triton.y4,"linear");

data_triton.z1 = fillmissing(data_triton.z1,"linear");
data_triton.z2 = fillmissing(data_triton.z2,"linear");
data_triton.z3 = fillmissing(data_triton.z3,"linear");
data_triton.z4 = fillmissing(data_triton.z4,"linear");

data_triton.x = (data_triton.x1 + data_triton.x2 + data_triton.x3 + data_triton.x4)/4 / 1000;
data_triton.y = (data_triton.y1 + data_triton.y2 + data_triton.y3 + data_triton.y4)/4 / 1000;
data_triton.z = (data_triton.z1 + data_triton.z2 + data_triton.z3 + data_triton.z4)/4 / 1000;

data_triton.deltax = ((data_triton.x2 - data_triton.x1) + (data_triton.x4 - data_triton.x3))/2 /1000 / 40 * 64.8594;
data_triton.deltay = ((data_triton.y2 - data_triton.y1) + (data_triton.y4 - data_triton.y3))/2 /1000 / 40 * 64.8594;

data_triton.x_cam = data_triton.x + data_triton.deltax;
data_triton.y_cam = data_triton.y + data_triton.deltay;
data_triton.z_cam = data_triton.z - 0.393;
data_triton.Time = data_triton.time;

% data_triton.deltax = data_triton.deltax/1000;
% data_triton.deltay = data_triton.deltay/1000;
% 
% data_triton.x_cam = data_triton.x_cam/1000;
% data_triton.y_cam = data_triton.y_cam/1000;

mocap.(tablename) = table(data_triton.Time, data_triton.x_cam, data_triton.y_cam, data_triton.z_cam, data_triton.deltax, data_triton.deltay,...
    'VariableNames', {'Time', 'x_cam', 'y_cam', 'z_cam', 'deltax', 'deltay'});

save('grasping_mocap.mat', 'mocap');





