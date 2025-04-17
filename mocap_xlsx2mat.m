%% Load Rosbag Csv
%filename="20250307sakai5-TriTon001.trc.xlsx";
filename="20250307sakai7-pole001.trc.xlsx";


%%
%tablename="tra7";
tablename="pole7";

%%
%オプションを設定
%csvの場合
%opts=detectImportOptions(filename,'FileType','text','Delimiter',',');%カンマ区切りテキストファイルとして認識，csvの時に使う，ただし実はこのoptionは必要ないらしい．
%opts.DataLines=[7 Inf];%指定した行からデータとして読み込む

%xlsxの場合
opts=detectImportOptions(filename);
opts.DataRange = 'A7';%データとして（カラム名は無視）読み込む最初のセルを指定

opts.VariableNamingRule = 'preserve'; % 変数名を自動変更しない

%テーブルとして読み込む。受かってないマーカーのデータはNaNに。
temptable=readtable(filename,opts);

%Var5とかの変数名をわかりやすくする。マーカーnの3座標はXn、Yn、Znという変数名に。RCalcはRCXn、RCYn、RCZnに。
%temptable.Properties.VariableNames={'Frame','Time','Timestamp','X1','Y1','Z1','X2','Y2','Z2','X3','Y3','Z3','X4','Y4','Z4','X5','Y5','Z5','X6','Y6','Z6','X7','Y7','Z7','X8','Y8','Z8'};
temptable.Properties.VariableNames={'Frame','Time','Timestamp','X1','Y1','Z1','X2','Y2','Z2','X3','Y3','Z3','X4','Y4','Z4','X5','Y5','Z5'};
%temptable.Properties.VariableNames={'Time','theta'};
%temptable.Properties.VariableNames={'Time','stamp1', 'stamp2','stamp3', 'id', 'angle', 'rate'};
%temptable.Properties.VariableNames={'Timestamp', 'XToParent1',	YToParent1	ZToParent1	QxToParent1	QyToParent1	QzToParent1	QwToParent1	XToGlobal1	YToGlobal1	ZToGlobal1	QxToGlobal1	QyToGlobal1	'QzToGlobal1','QwToGlobal1', 'Segmentlength1'};
%temptable.Properties.VariableNames={'Time','theta'};
%temptable.Properties.VariableNames={'Time','x', 'y', 'z', 'yaw', 'roll', 'pitch', 'd', 'theta'};


% 構造体に保存
mocap.(tablename) = temptable;

% .mat ファイルとして保存
%save('theta_values_210919.mat', 'tables');
%save('theta_values_7.mat', 'tables');
save('grasping_mocap.mat', 'mocap');