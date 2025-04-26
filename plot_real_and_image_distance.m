clc;clear all; close all;

load("grasping_rosbag_sim.mat")

%%
%start_idx = 14401;
%end_idx = 34201;

%max_time = max(time_offset_distance);
% rosbag_pp.bag03_07_20_50_59_pp.Time = ...
%     datetime(rosbag_pp.bag03_07_20_50_59_pp.Time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
% 
% % 1行目の時間を基準にして差を取り、秒単位に変換
% time0 = rosbag_pp.bag03_07_20_50_59_pp.Time(1);
% elapsed_time = seconds(rosbag_pp.bag03_07_20_50_59_pp.Time - time0);


%%bag03_07_21_00_32_ppの場合
rosbag_sim.bag04_19_05_23_22.Time = ...
    datetime(rosbag_sim.bag04_19_05_23_22.Time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');

% 1行目の時間を基準にして差を取り、秒単位に変換
time0 = rosbag_sim.bag04_19_05_23_22.Time(1);
elapsed_time = seconds(rosbag_sim.bag04_19_05_23_22.Time - time0);

% 結果を新しい列に追加（オプション）
rosbag_sim.bag04_19_05_23_22.ElapsedTime = elapsed_time;

%% インデックス取得（xyz_ref_mode の  １列目が 1 になる最初の場所）
% rosbag_sim.bag04_19_05_23_22.vis_flag = ...
%     str2double(rosbag_sim.bag04_19_05_23_22.vis_flag);
% NaN のときに 0 にする
rosbag_sim.bag04_19_05_23_22.vis_flag(isnan(rosbag_sim.bag04_19_05_23_22.vis_flag)) = 0;
idx = find(rosbag_sim.bag04_19_05_23_22.vis_flag == -1, 1, 'first');

% 対応する時刻を取得
first_time = rosbag_sim.bag04_19_05_23_22.ElapsedTime(idx);



%%
%image processingの方のみ，0以上を表示
offset = 26.33;
valid_idx = rosbag_sim.bag04_19_05_23_22.ElapsedTime > offset;

%%
%連続して同じ値の時は，image_proseccingが更新されていないので，plotしない．
num_rows_image = height(rosbag_sim.bag04_19_05_23_22);
rosbag_sim.bag04_19_05_23_22.image_distance_filled = fillmissing(rosbag_sim.bag04_19_05_23_22.image_distance, 'linear');

for i = 1:num_rows_image-1
    if rosbag_sim.bag04_19_05_23_22.image_distance_filled(i+1) == rosbag_sim.bag04_19_05_23_22.image_distance_filled(i)
        rosbag_sim.bag04_19_05_23_22.image_distance_reprocess(i+1) = NaN;
    else
        rosbag_sim.bag04_19_05_23_22.image_distance_reprocess(i+1) = rosbag_sim.bag04_19_05_23_22.image_distance(i+1);
    end
end

%%
%一．連続して同じ値の時は，image_proseccingが更新されていないので，plotしない．
%二．Ground Truthの方は直線でつなぐ．Nanだとつないでくれないので，Nanを消去する．
%isnanは，NaNかどうかを判定，~は論理反転
num_rows_real = height(rosbag_sim.bag04_19_05_23_22);
rosbag_sim.bag04_19_05_23_22.real_distance_filled = fillmissing(rosbag_sim.bag04_19_05_23_22.real_distance, 'linear');

for i = 1:num_rows_real-1
    if rosbag_sim.bag04_19_05_23_22.real_distance_filled(i+1) == rosbag_sim.bag04_19_05_23_22.real_distance_filled(i)
        rosbag_sim.bag04_19_05_23_22.real_distance_reprocess(i+1) = NaN;
    else
        rosbag_sim.bag04_19_05_23_22.real_distance_reprocess(i+1) = rosbag_sim.bag04_19_05_23_22.real_distance(i+1);
    end
end
nnan_idx = ~isnan(rosbag_sim.bag04_19_05_23_22.real_distance_reprocess);

%%
figure(2)
hold on;

% %背景色を追加
% yLimits = [-20,40];
% fill([0 first_time first_time 0], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
%      [1 0.6 0.8] , 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % 半透明ピンク
% 
% 
% %背景色を追加
% yLimits = [-20,40];
% fill([first_time 100 100 first_time], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
%      [1 1 0], 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % 半透明ピンク

%背景色を追加
xLimits = [0.12 - 0.03, 0.12 + 0.03];
h4 = fill([-5.03 90 90 -5.03], [xLimits(1) xLimits(1) xLimits(2) xLimits(2)], ...
      [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % うす緑

plot(rosbag_sim.bag04_19_05_23_22.ElapsedTime(nnan_idx)-offset, rosbag_sim.bag04_19_05_23_22.real_distance_reprocess(nnan_idx), ".", 'LineWidth', 10,  'Color', [0.8500 0.3250 0.0980]);
hold on;
plot(rosbag_sim.bag04_19_05_23_22.ElapsedTime(valid_idx)-offset, rosbag_sim.bag04_19_05_23_22.image_distance_reprocess(valid_idx), ".", 'MarkerSize', 10, 'Color', [0 0.4470 0.7410]);
xline(0, "--", 'LineWidth', 2, 'Color',	[1 0 0]);
xline(first_time-offset, "--", 'LineWidth', 2, 'Color',	[1 0 0]);
h3 = yline(0.12, 'LineWidth', 2, 'Color','k');
grid on;

%見やすいlegendをつけるために，マーカーの大きいデータをNaNとしてプロット
nan_array1 = NaN(size(rosbag_sim.bag04_19_05_23_22.ElapsedTime(nnan_idx)));
nan_array2 = NaN(size(rosbag_sim.bag04_19_05_23_22.ElapsedTime(valid_idx)));
h1 = plot(rosbag_sim.bag04_19_05_23_22.ElapsedTime(nnan_idx)-offset, nan_array1, ".", 'MarkerSize', 30, 'Color', [0.8500 0.3250 0.0980]);
h2 = plot(rosbag_sim.bag04_19_05_23_22.ElapsedTime(valid_idx)-offset, nan_array2, ".", 'MarkerSize', 30, 'Color', [0 0.4470 0.7410]);

hold on;
xlabel('Time [s]', 'FontSize', 20);
ylabel('Distance [m]', 'FontSize', 20);
legend([h1 h2 h3 h4], {'Ground truth', 'Image processing', 'Target', 'Graspable area'}, 'FontSize', 20);
set(gca, 'FontSize', 20);
xlim([-2, 80]);
ylim([0, 6.5]);
xticks([0 10 20 30 40 50 60 70 80])
yticks([0 1 2 3 4 5 6])

% ===論文向けの枠線スタイル設定===
ax = gca;
ax.Box = 'on';
ax.BoxStyle = 'full';     % 上下左右すべて実線に
ax.XColor = 'k';          % X軸：黒
ax.YColor = 'k';          % Y軸：黒
ax.LineWidth = 1;       % 軸線の太さ
%ax.TickDir = 'out';       % 目盛りを外向き（論文向き）
