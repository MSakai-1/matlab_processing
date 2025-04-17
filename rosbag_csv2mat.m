%% Load Rosbag Csv
%foldername = "2025-03-07-20-50-59_pp";
%foldername = "2025-03-07-21-00-32_pp";
%foldername = "2025-03-07-21-09-19_pp";
%foldername = "2025-03-07-21-13-19_pp";
foldername = "2025-03-07-21-22-12_pp";
filename1="calculated_distance_pp_.csv";
filename2="calculated_angle_pp_.csv";
filename3="gripper_vis_flag_pp_.csv";

%%
tablename="bag03_07_21_22_12_pp";  %-は使えないので注意

%%
%オプションを設定
%csvの場合
opts=detectImportOptions(filename,'FileType','text','Delimiter',',');%カンマ区切りテキストファイルとして認識，csvの時に使う，ただし実はこのoptionは必要ないらしい．
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
temptable1.Properties.VariableNames={'Time','distance'};

master_table = temptable1;

%%
%複数読み込んでマージしたい時
%file2の読み込み
temptable2 = readtable(foldername + "/" + filename2,opts);
temptable2.Properties.VariableNames={'Time','angle'};

master_table = outerjoin(master_table, temptable2, 'Keys', 'Time', 'MergeKeys', true);

%%
%file3の読み込み
temptable3 = readtable(foldername + "/" + filename3,opts);
temptable3.Properties.VariableNames={'Time','vis_flag'};

master_table = outerjoin(master_table, temptable3, 'Keys', 'Time', 'MergeKeys', true);

%%
% 構造体に保存
rosbag_pp.(tablename) = master_table;

% .mat ファイルとして保存
%save('theta_values_210919.mat', 'tables');
%save('theta_values_7.mat', 'tables');
save('grasping_rosbag.mat', 'rosbag_pp');