clc;clear all; close all;

load("grasping_mocap.mat")
load("grasping_rosbag.mat")

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

data_triton.x_r = data_triton.x_cam - mocap.pole6.X5/1000;
data_triton.y_r = data_triton.y_cam - mocap.pole6.Y5/1000;
data_triton.z_r = data_triton.z_cam - mocap.pole6.Z5/1000;

%rosbagデータの整理
rosbag_pp.bag03_07_21_00_32_pp.Time = ...
    datetime(rosbag_pp.bag03_07_21_00_32_pp.Time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');

% 1行目の時間を基準にして差を取り、秒単位に変換
time0 = rosbag_pp.bag03_07_21_00_32_pp.Time(1);
elapsed_time = seconds(rosbag_pp.bag03_07_21_00_32_pp.Time - time0);
% 結果を新しい列に追加（オプション）
rosbag_pp.bag03_07_21_00_32_pp.ElapsedTime = elapsed_time;

%% インデックス取得（vis_flag が 1 になる最初の場所）
rosbag_pp.bag03_07_21_00_32_pp.vis_flag = ...
    str2double(rosbag_pp.bag03_07_21_00_32_pp.vis_flag);
idx = find(rosbag_pp.bag03_07_21_00_32_pp.vis_flag == -1, 1, 'first');
first_time = rosbag_pp.bag03_07_21_00_32_pp.ElapsedTime(idx);

%%
idx = (mocap.tra6_cam.Time >= 95) & ...
      (mocap.tra6_cam.Time <= first_time + 95);

%%2D描画したい場合
% figure(2)
% hold on;
% 
% h1 = plot(x_r(idx), y_r(idx), ".", 'LineWidth', 1,  'Color', [0.8500 0.3250 0.0980]);
% hold on;
% grid minor;
% hold on;
% xlabel('X [m]', 'FontSize', 20);
% ylabel('Y [m]', 'FontSize', 20);
% %legend([h1 h2 h3], {'Ground truth', 'Image processing', 'Target'}, 'FontSize', 20);
% set(gca, 'FontSize', 20);
% %xlim([-2, 70]);

%%3D描画したい場合
% figure(2)
% hold on;
% 
% h1 = plot3(x_r(idx), y_r(idx), z_r(idx), ".", 'LineWidth', 1,  'Color', [0.8500 0.3250 0.0980]);
% hold on;
% grid minor;
% hold on;
% xlabel('X [m]', 'FontSize', 20);
% ylabel('Y [m]', 'FontSize', 20);
% %legend([h1 h2 h3], {'Ground truth', 'Image processing', 'Target'}, 'FontSize', 20);
% set(gca, 'FontSize', 20);
% %xlim([-2, 70]);


%三角形描画したい場合
%三角形の基本形（尖った先端が上） ---
base_x = [0.0, -0.05, 0.05];
base_y = [0.01, -0.05, -0.05];


% --- 4. フレームごとに描画（500ごと） ---
num_frames = sum(idx);

figure(2)
hold on;
for i = 1:200:num_frames+3000
    % データ取得
    x_r = data_triton.x_r(i);
    y_r = data_triton.y_r(i);
    deltax = data_triton.deltax(i);
    deltay = data_triton.deltay(i);

    % 正規化（方向だけが必要なので）
    vec_norm = sqrt(deltax^2 + deltay^2);
    ux = deltax / vec_norm;
    uy = deltay / vec_norm;

    % 頂点（鋭角）→ (x_r, y_r)
    tip = [x_r, y_r];

    % 逆方向に少し移動 → 底辺の中点
    length_back = 0.1; % 三角形の高さ（調整可能）
    base_center = tip - length_back * [ux, uy];

    % 垂直方向の単位ベクトル（左側90度回転）
    perp = [-uy, ux];

    % 底辺の長さ（調整可能）
    half_width = 0.05;  % これが三角形の「幅」の半分

    % 底辺の左右の点
    base_left  = base_center + half_width * perp;
    base_right = base_center - half_width * perp;

    % 三角形の3頂点を並べる
    tri_x = [tip(1), base_left(1), base_right(1)];
    tri_y = [tip(2), base_left(2), base_right(2)];

    % 三角形を描く
    fill(tri_x, tri_y, 'g', 'FaceAlpha', 0.4);
end


% figure(2)
% hold on;
% 
% h1 = plot(x_r(idx), y_r(idx), ".", 'LineWidth', 1,  'Color', [0.8500 0.3250 0.0980]);
% hold on;
% grid minor;
hold on;
xlabel('X [m]', 'FontSize', 20);
ylabel('Y [m]', 'FontSize', 20);
%legend([h1 h2 h3], {'Ground truth', 'Image processing', 'Target'}, 'FontSize', 20);
set(gca, 'FontSize', 20);
%xlim([-2, 70]);









% % %%
% %rosbagデータの整理
% rosbag_pp.bag03_07_21_00_32_pp.Time = ...
%     datetime(rosbag_pp.bag03_07_21_00_32_pp.Time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
% 
% % 1行目の時間を基準にして差を取り、秒単位に変換
% time0 = rosbag_pp.bag03_07_21_00_32_pp.Time(1);
% elapsed_time = seconds(rosbag_pp.bag03_07_21_00_32_pp.Time - time0);
% 
% % 結果を新しい列に追加（オプション）
% rosbag_pp.bag03_07_21_00_32_pp.ElapsedTime = elapsed_time;
% 
% rosbag_pp.bag03_07_21_00_32_pp.angle = ...
%     str2double(rosbag_pp.bag03_07_21_00_32_pp.angle);
% 
% rosbag_pp.bag03_07_21_00_32_pp.angle = ...
%     rad2deg(rosbag_pp.bag03_07_21_00_32_pp.angle);
% 
% %% インデックス取得（vis_flag が 1 になる最初の場所）
% rosbag_pp.bag03_07_21_00_32_pp.vis_flag = ...
%     str2double(rosbag_pp.bag03_07_21_00_32_pp.vis_flag);
% idx = find(rosbag_pp.bag03_07_21_00_32_pp.vis_flag == -1, 1, 'first');
% 
% % 対応する時刻を取得
% first_time = rosbag_pp.bag03_07_21_00_32_pp.ElapsedTime(idx);
% 
% %%
% % %%205059の場合
% % %rosbagデータの整理
% % rosbag_pp.bag03_07_20_50_59_pp.Time = ...
% %     datetime(rosbag_pp.bag03_07_20_50_59_pp.Time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
% % 
% % % 1行目の時間を基準にして差を取り、秒単位に変換
% % time0 = rosbag_pp.bag03_07_20_50_59_pp.Time(1);
% % elapsed_time = seconds(rosbag_pp.bag03_07_20_50_59_pp.Time - time0);
% % 
% % % 結果を新しい列に追加（オプション）
% % rosbag_pp.bag03_07_20_50_59_pp.ElapsedTime = elapsed_time;
% % 
% % rosbag_pp.bag03_07_20_50_59_pp.angle = ...
% %     str2double(rosbag_pp.bag03_07_20_50_59_pp.angle);
% % 
% % rosbag_pp.bag03_07_20_50_59_pp.angle = ...
% %     rad2deg(rosbag_pp.bag03_07_20_50_59_pp.angle);
% %%
% %mocapデータの整理
% %poleの生データを使用する場合
% % mocap.tra6_cam.x_vector = mocap.pole6.X5/1000 - mocap.tra6_cam.x_cam;
% % mocap.tra6_cam.y_vector = mocap.pole6.Y5/1000 - mocap.tra6_cam.y_cam;
% %baseを使用する場合
% % mocap.tra6_cam.x_vector = mocap.poll6_base.x - mocap.tra6_cam.x_cam;
% % mocap.tra6_cam.y_vector = mocap.poll6_base.y - mocap.tra6_cam.y_cam;
% 
% %初期値から不変とする場合
% % mocap.tra6_cam.x_vector = -1.8970 - mocap.tra6_cam.x_cam;
% % mocap.tra6_cam.y_vector = -1.211 - mocap.tra6_cam.y_cam;
% 
% %高さ合わせをする場合
% x = (mocap.pole6.X5/1000 - mocap.poll6_base.x)./ (mocap.pole6.Z5/1000 - mocap.poll6_base.z) .* (mocap.tra6_cam.z_cam - mocap.poll6_base.z) + mocap.poll6_base.x;
% y = (mocap.pole6.Y5/1000 - mocap.poll6_base.y)./ (mocap.pole6.Z5/1000 - mocap.poll6_base.z) .* (mocap.tra6_cam.z_cam - mocap.poll6_base.z) + mocap.poll6_base.y;
% z = (mocap.pole6.Z5/1000 - mocap.poll6_base.z)./ (mocap.pole6.Z5/1000 - mocap.poll6_base.z) .* (mocap.tra6_cam.z_cam - mocap.poll6_base.z) + mocap.poll6_base.z;
% mocap.tra6_cam.x_vector = x - mocap.tra6_cam.x_cam;
% mocap.tra6_cam.y_vector = y - mocap.tra6_cam.y_cam;
% 
% deltax = mocap.tra6_cam.deltax;
% deltay = mocap.tra6_cam.deltay;
% 
% %cos = x_vector * mocap.tra6_cam.deltax + y_vector * mocap.tra6_cam.deltay / sqrt(x_vector^2 + y_vector^2) / sqrt(mocap.tra6_cam.deltax^2 + mocap.tra6_cam.deltay^2);
% 
% mocap.tra6_cam.bunsi = mocap.tra6_cam.x_vector .* deltax + mocap.tra6_cam.y_vector .* deltay;
% %mocap.tra6_cam.bunbo = sqrt(mocap.tra6_cam.x_vector.^2 + mocap.tra6_cam.y_vector.^2) .* sqrt(deltax.^2 + deltay.^2);
% mocap.tra6_cam.cross = deltax .* mocap.tra6_cam.y_vector - deltay .* mocap.tra6_cam.x_vector;
% %theta_deg = rad2deg(acos(mocap.tra6_cam.bunsi ./ mocap.tra6_cam.bunbo));
% theta_deg = rad2deg(atan2(mocap.tra6_cam.cross, mocap.tra6_cam.bunsi));
% 
% 
% 
% % 結果を新しい列に追加（オプション）
% mocap.tra6_cam.theta = theta_deg;
% 
% figure(2)
% hold on;
% 
% % %背景色を追加
% % yLimits = [-20,40];
% % fill([0 first_time first_time 0], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
% %      [1 0.6 0.8] , 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % 半透明ピンク
% % 
% % 
% % %背景色を追加
% % yLimits = [-20,40];
% % fill([first_time 100 100 first_time], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
% %      [1 1 0], 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % 半透明ピンク
% 
% h1 = plot(mocap.tra6_cam.Time-95, -mocap.tra6_cam.theta, ".", 'LineWidth', 1,  'Color', [0.8500 0.3250 0.0980]);
% hold on;
% 
% h2 = plot(rosbag_pp.bag03_07_21_00_32_pp.ElapsedTime+95-95, rosbag_pp.bag03_07_21_00_32_pp.angle, ".-", 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
% xline(0, "--", 'LineWidth', 2, 'Color',	[1 0 0]);
% xline(first_time, "--", 'LineWidth', 2, 'Color',	[1 0 0]);
% h3 = yline(0, 'LineWidth', 2, 'Color',[0.4660 0.6740 0.1880]);
% grid minor;
% % plot(data_pole_1_cropped.time, data_pole_1_cropped.y5);
% % plot(data_pole_1_cropped.time, data_pole_1_cropped.z5);
% hold on;
% xlabel('Time [s]', 'FontSize', 20);
% ylabel('Orientation [deg]', 'FontSize', 20);
% legend([h1 h2 h3], {'Ground truth', 'Image processing', 'Target'}, 'FontSize', 20);
% set(gca, 'FontSize', 20);
% xlim([-2, 70]);