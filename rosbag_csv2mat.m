%% Load Rosbag Csv
%foldername = "2025-03-07-20-50-59_pp";
%foldername = "2025-03-07-21-00-32_pp";
%foldername = "2025-03-07-21-09-19_pp";
%foldername = "2025-03-07-21-13-19_pp";
%foldername = "2025-03-07-21-22-12_pp";
foldername = "rosbag_csv/2025-04-19-05-23-22";
filename1="calculated_distance_.csv";
filename2="calculated_angle_.csv";
filename3="calculated_relative_distance_to_xy_.csv";
filename4="calculated_relative_angle_to_xy_.csv";
filename5="gripper_vis_flag_.csv";
filename6="control_command_auv_.csv";

%%
tablename="bag04_19_05_23_22";  %-は使えないので注意

%%
%オプションを設定
%csvの場合
opts=detectImportOptions(foldername + "/" + filename1,'FileType','text','Delimiter',',');%カンマ区切りテキストファイルとして認識，csvの時に使う，ただし実はこのoptionは必要ないらしい．
%今回は，filename1の設定で全て読み込む
%データ構造がかわらなければこのままでＯＫ
opts.DataLines=[2 Inf];%指定した行からデータとして読み込む

%xlsxの場合
%opts=detectImportOptions(filename);
%opts.DataRange = 'A7';

opts.VariableNamingRule = 'preserve'; % 変数名を自動変更しない
opts.SelectedVariableNames = opts.VariableNames(1:2);  % 1列目と2列目だけ読み込む. rosbagを扱う場合のみ，これがないとなぜか７列だと認識された

%%
%file1の読み込み
%テーブルとして読み込む。受かってないマーカーのデータはNaNに。
temptable1=readtable(foldername + "/" + filename1,opts);
temptable1.Properties.VariableNames={'Time','image_distance'};
temptable1 = unique(temptable1, 'rows');

master_table = temptable1;

%%
%複数読み込んでマージしたい時
%file2の読み込み
temptable2 = readtable(foldername + "/" + filename2,opts);
temptable2.Properties.VariableNames={'Time','image_angle'};
temptable2 = unique(temptable2, 'rows');


master_table = outerjoin(master_table, temptable2, 'Keys', 'Time', 'MergeKeys', true);

%%
%file3の読み込み
temptable3 = readtable(foldername + "/" + filename3,opts);
temptable3.Properties.VariableNames={'Time','real_distance'};
temptable3 = unique(temptable3, 'rows');

master_table = outerjoin(master_table, temptable3, 'Keys', 'Time', 'MergeKeys', true);

%%
%file4の読み込み
temptable4 = readtable(foldername + "/" + filename4,opts);
temptable4.Properties.VariableNames={'Time','real_angle'};
temptable4 = unique(temptable4, 'rows');

master_table = outerjoin(master_table, temptable4, 'Keys', 'Time', 'MergeKeys', true);

%%
%file6の読み込み
temptable5 = readtable(foldername + "/" + filename5,opts);
temptable5.Properties.VariableNames={'Time','vis_flag'};
temptable5 = unique(temptable5, 'rows');

master_table = outerjoin(master_table, temptable5, 'Keys', 'Time', 'MergeKeys', true);

%%
%file6の読み込み
%読み込む列変更
opts=detectImportOptions(foldername + "/" + filename6,'FileType','text','Delimiter',',');
opts.DataLines=[2 Inf];%指定した行からデータとして読み込む
opts.VariableNamingRule = 'preserve'; % 変数名を自動変更しない
opts.SelectedVariableNames = opts.VariableNames(1:9);  % 1列目と2列目だけ読み込む. rosbagを扱う場合のみ，これがないとなぜか７列だと認識された
temptable6 = readtable(foldername + "/" + filename6,opts);
temptable6.Properties.VariableNames={'Time', 'header_seq', 'header_stamp_seq', 'header_stamp_nseq', 'header_frame_id', 'xyz_ref_mode', 'xyz_ref_value', 'rpy_ref_mode', 'rpy_ref_value'};
% 必要な列だけにする
temptable6 = temptable6(:, {'Time', 'xyz_ref_mode'});
temptable6 = unique(temptable6, 'rows');

master_table = outerjoin(master_table, temptable6, 'Keys', 'Time', 'MergeKeys', true);

%%
% 構造体に保存
rosbag_sim.(tablename) = master_table;

% .mat ファイルとして保存
%save('theta_values_210919.mat', 'tables');
%save('theta_values_7.mat', 'tables');
save('grasping_rosbag_sim.mat', 'rosbag_sim');