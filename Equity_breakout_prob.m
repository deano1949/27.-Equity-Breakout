%% Description
% Identify the distribution of returns after break out 1y high in a forward
% 1y window
%% Load Data
clc;clear
location='Home';

if strcmp(location,'Home')
     addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));
    path='C:\Spectrion\Data\NewUniverse\';
    tradeuniversepath='C:\Users\gly19\Dropbox\GU\1.Investment\7. Operations\1. ScreenTradingUniverse\';
elseif strcmp(location,'Coutts')
     addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
     addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\Custom_Functions'));
     addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)');
    path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\NewUniverse\';
else
    error('Unrecognised location; Coutts or Home');
end

load(strcat(path, 'NUV.mat'));

%% Breakout upside
% setting
win=250; %number of days to define breakout
fwd_win=250; %forward looking windows to define trade pnl
x=cl;
thld=0.005; % threshold in %term above highest price to determine breakout

%main
peak_table=zeros(size(cl)); %define peaks
trade_table=zeros(size(cl));%define a trade date
max_pnl=zeros(size(cl));    %define maximum pnl%
min_pnl=zeros(size(cl));    %define minimum pnl%
median_pnl=zeros(size(cl)); %define median pnl%

for i=1:size(x,2)
    for t=win+1:size(x,1)-60
        if x(t,i)>max(x(t-win:t-1,i))*(1+thld) && sum(x(t-win:t-1,i))>0
            peak_table(t,i)=1; %mark peak
            if sum(peak_table(t-20:t-1,i))==0 %only trade when price break high but not keep breaking high in 20 working days
                trade_table(t,i)=1;
                if t+fwd_win<=size(x,1)
                    max_pnl(t,i)=max(x(t+1:t+fwd_win,i))/x(t,i)-1; %max pnl%
                    min_pnl(t,i)=min(x(t+1:t+fwd_win,i))/x(t,i)-1; %max pnl%
                    median_pnl(t,i)=nanmedian(x(t+1:t+fwd_win,i))/x(t,i)-1; %max pnl%
                else
                    max_pnl(t,i)=max(x(t+1:end,i))/x(t,i)-1; %max pnl%
                    min_pnl(t,i)=min(x(t+1:end,i))/x(t,i)-1; %max pnl%
                    median_pnl(t,i)=nanmedian(x(t+1:end,i))/x(t,i)-1; %max pnl%
                end
            end
        end
    end
end

%evaluation
k=1;
for i=1:size(cl,1)
    for j=1:size(cl,2)
        if trade_table(i,j)==1
            pnl_table(k,1)=max_pnl(i,j);
            pnl_table(k,2)=median_pnl(i,j);
            pnl_table(k,3)=min_pnl(i,j);
            stock_name{k}=name{j};
            timestamp{k}=time{i};
            k=k+1;
        end
    end
end
Tab=table(timestamp',stock_name',pnl_table);

writetable(Tab,'Output_spreadsheet.xlsx');
xlswrite('Output_spreadsheet.xlsx',thld,'Sheet1','G2');

%benchmark
max_pnl=zeros(size(cl));    %define maximum pnl%
min_pnl=zeros(size(cl));    %define minimum pnl%
median_pnl=zeros(size(cl)); %define median pnl%

for i=1:size(x,2)
    for t=win+1:size(x,1)-60
                if t+fwd_win<=size(x,1)
                    max_pnl(t,i)=max(x(t+1:t+fwd_win,i))/x(t,i)-1; %max pnl%
                    min_pnl(t,i)=min(x(t+1:t+fwd_win,i))/x(t,i)-1; %max pnl%
                    median_pnl(t,i)=nanmedian(x(t+1:t+fwd_win,i))/x(t,i)-1; %max pnl%
                else
                    max_pnl(t,i)=max(x(t+1:end,i))/x(t,i)-1; %max pnl%
                    min_pnl(t,i)=min(x(t+1:end,i))/x(t,i)-1; %max pnl%
                    median_pnl(t,i)=nanmedian(x(t+1:end,i))/x(t,i)-1; %max pnl%
                end
    end
end