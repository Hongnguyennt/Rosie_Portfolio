[data, names] = xlsread('Data2022','Stocks');
save('Data2022');
load('Data2022');
prices  = data(:,2:end-4);
stocks  = names(1:end-4);
dates   = x2mdate(data(:,1));
returns = diff(prices)./prices(1:end-1,:); % dailyreturn = tick2ret (data(:, 2:end-4))
ExpRet  = mean(returns); %compute expected return
CovMat  = cov(returns); %compute covariance matrix
CorMat  = corr(returns); % compute correlation matrix

%Compute 5 optimal portfolios corresponding to 5 target portfolio expected returns. 
NumberPorts = 5; %compute 5 portfolios from 5 targets
[FROWts, FROReturn, FRORisk] = EfficientPortfolio3(ExpRet, CovMat, [],NumberPorts);
FROWts = FROWts';
subplot(3,1,1);
plot(FRORisk,FROReturn)         % The Efficient Frontier
title('The Efficient Frontier - The Power of Diversification')
xlabel('Risk - Measured by the standard deviation of return')
ylabel('Return - Average of returns')

Group    = [0 0 0 1 0 0 0 0 1 0 0 0 1 1];          % My Group Stocks 
GrpBnd   = [0.3];                             % Max 30% 

%Following constraints, compute 10 optimal portfolios, starting with the minimum variance portfolio
Numports = 10;
[GrpWts, GrpReturn, GrpRisk] = EfficientPortfolio5(ExpRet, CovMat, [],Numports,[], Group,GrpBnd);
GrpWts = GrpWts';
subplot(3,1,2);
area(GrpWts)
legend(stocks)   % Area chart (how weights change across portfolios)
title('Menu of Asset Allocation')
xlabel('Portfolio')
ylabel('weights of stock')

% market model
markets  = data(:,end-3:end-1); % = data(:,16:18); 
ret_mkt  = diff(markets)./markets(1:end-1,:);  %compute market returns

% Estimate Market Model for all stocks 

for i = 1:14
    
    if i <= 4   %stock in US market
        
    index = ret_mkt(:,3); 
    
    elseif i > 4 && i <= 7 %stock in Uk market
        
    index = ret_mkt(:,1);    
    
    elseif i >= 8 && i <= 10 %stock in Germany market
        
    index = ret_mkt(:,2);
    
    elseif i > 10 % (or, else) %stock in US market
        
    index = ret_mkt(:,3);    
        
    end
    
    coeff = regress(returns(:,i),[ones(size(index,1),1) index]);
    
    a(i) = coeff(1);
    b(i) = coeff(2);
    
    % Implied Stock Returns
    ols_Ret(:,i) = a(i) + b(i)*index;
    
end
E_R = mean(ols_Ret); % compute mean of ols_Ret

%-	Compute the minimum variance portfolio using data up to 2020 
count = 0;
for i = 1:size(dates,1)
    if(dates(i) <= datenum("31-Dec-2020")) %find the row end of year 2020
                count = count + 1;
               
    else
      
    end
end

%compute the data up to 2020
 prices_2020 = data(1:count,2:end-4);
 returns_2020 = diff(prices_2020)./prices_2020(1:end-1,:);
 ExpRet_2020  = mean(returns_2020);
CovMat_2020  = cov(returns_2020);

% Compute 1 minimum variance portfolio
[PortRisk2020, PortReturn2020, PortWts2020] = portopt(ExpRet_2020, CovMat_2020, 1);
PortWts2020 = PortWts2020';
subplot(3,1,3);
pie(PortWts2020)         % Asset Allocation Menu
title('Asset Allocation Menu')
legend(stocks)

%Compute the portfolio 2020 and measure its performance by actual data in 2021
prices_2021 = data(count+1:end,2:end-4);
returns_2021 = diff(prices_2021)./prices_2021(1:end-1,:);
ExpRet_2021  = mean(returns_2021);
CovMat_2021  = cov(returns_2021);

%Compute risk and return of 2020 portfolio
[PortRisk2021, PortReturn2021] = portstats(ExpRet_2021, CovMat_2021,PortWts2020');

% Set the equally weight portfolio in 2020
N = size(stocks, 2);
Wts_equal = (1/N) * ones(1, N);
[PortRisk_equal, PortReturn_equal] = portstats(ExpRet_2020, CovMat_2020,Wts_equal);

