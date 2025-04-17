%% Load Rosbag Csv
%foldername = "2025-03-07-20-50-59_pp";
%foldername = "2025-03-07-21-00-32_pp";
%foldername = "2025-03-07-21-09-19_pp";
%foldername = "2025-03-07-21-13-19_pp";
%foldername = "2025-03-07-21-22-12_pp";
foldername = "rosbag_csv/2025-04-16-23-40-40";
filename1="calculated_distance_.csv";
filename2="calculated_angle_.csv";
filename3="calculated_relative_distance_to_xy_.csv";
filename4="calculated_relative_angle_to_xy_.csv";
filename5="control_command_auv_.csv";

%%
tablename="bag04_16_23_40_40";  %-は使えないので注意

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

%変数名をわかりやすくする。
temptable1.Properties.VariableNames={'Time','image_distance'};

master_table = temptable1;

%%
%複数読み込んでマージしたい時
%file2の読み込み
temptable2 = readtable(foldername + "/" + filename2,opts);
temptable2.Properties.VariableNames={'Time','image_angle'};

master_table = outerjoin(master_table, temptable2, 'Keys', 'Time', 'MergeKeys', true);

%%
%file3の読み込み
temptable3 = readtable(foldername + "/" + filename3,opts);
temptable3.Properties.VariableNames={'Time','real_distance'};

master_table = outerjoin(master_table, temptable3, 'Keys', 'Time', 'MergeKeys', true);

%%
%file4の読み込み
temptable4 = readtable(foldername + "/" + filename4,opts);
temptable4.Properties.VariableNames={'Time','real_angle'};

master_table = outerjoin(master_table, temptable4, 'Keys', 'Time', 'MergeKeys', true);

%%
%file5の読み込み
%読み込む列変更
opts=detectImportOptions(foldername + "/" + filename5,'FileType','text','Delimiter',',');
opts.DataLines=[2 Inf];%指定した行からデータとして読み込む
opts.VariableNamingRule = 'preserve'; % 変数名を自動変更しない
opts.SelectedVariableNames = opts.VariableNames(1:9);  % 1列目と2列目だけ読み込む. rosbagを扱う場合のみ，これがないとなぜか７列だと認識された
temptable5 = readtable(foldername + "/" + filename5,opts);
temptable5.Properties.VariableNames={'Time', 'header_seq', 'header_stamp_seq', 'header_stamp_nseq', 'header_frame_id', 'xyz_ref_mode', 'xyz_ref_value', 'rpy_ref_mode', 'rpy_ref_value'};
% 必要な列だけにする
temptable5 = temptable5(:, {'Time', 'xyz_ref_mode'});

master_table = outerjoin(master_table, temptable5, 'Keys', 'Time', 'MergeKeys', true);

%%
% 構造体に保存
rosbag_sim.(tablename) = master_table;

% .mat ファイルとして保存
%save('theta_values_210919.mat', 'tables');
%save('theta_values_7.mat', 'tables');
save('grasping_rosbag_sim.mat', 'rosbag_sim');