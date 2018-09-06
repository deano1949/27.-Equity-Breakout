%% Load data
addpath('C:\Users\gly19\Dropbox\GU\1.Investment\4. Alphas (new)\17.Extract_Rollyield\0.Research\VIX\dat');

dir='C:\Spectrion\Data\PriceData\Future_Generic\';
load(strcat(dir,'FUTROHLC.mat'));

futurelist=fieldnames(FUTROHLC);

%% Breakout upside
% setting
win=250; %number of days to define breakout
fwd_win=250; %forward looking windows to define trade pnl
thld=0.005; % threshold in %term above highest price to determine breakout
delay=5;

for i=1%:size(futurelist,2)
    dat=FUTROHLC.(futurelist{i});
    hi=dat.PX_HIGH;
    lo=dat.PX_LOW;
    cl=dat.PX_LAST;
    op=dat.PX_OPEN;

    peak_table=zeros(size(cl)); %define peaks
    trade_table=zeros(size(cl));%define a trade date
    max_max=zeros(size(cl));    %define maximum pnl%
    min_min=zeros(size(cl));    %define minimum pnl%
    median_minmax=zeros(size(cl)); %define median pnl%
    zscore=zeros(size(cl));
    for t=win+1+delay:size(cl,1)
        min_min(t)=min(lo(t-win-delay:t-delay));
        max_max(t)=max(hi(t-win-delay:t-delay));
        median_minmax(t)=(min_min(t)+max_max(t))/2;
        zscore(t)=(cl(t)-median_minmax(t))/(max_max(t)-min_min(t));
        if trade_table(t-1)==0 && zscore(t)>=0.5
            trade_table(t)=1;
        elseif trade_table(t-1)==1 && zscore(t)<0.25
            trade_table(t)=0;
        elseif trade_table(t-1)==0 && zscore(t)<=-0.5
            trade_table(t)=-1;
        elseif trade_table(t-1)==-1 && zscore(t)>-0.25
            trade_table(t)=0;
        else
            trade_table(t)=trade_table(t-1);
        end
    end
    zscore=smartMovingAvg(zscore,4);zscore(isnan(zscore))=0;
    quickpnl=backshift(1,zscore).*[0;tick2ret(cl)];
    quickpnl=quickpnl(2:end);
    quickpnlindex=ret2tick(quickpnl);
    
    plot(cl);hold on;
    plot(min_min);plot(max_max);plot(median_minmax);hold off
    yyaxis right
%     plot(zscore)
    plot(quickpnlindex)

end