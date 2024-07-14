function [EffWts, EffRet,EffRisk] = EfficientPortfolio(R,S)

PortRisk = @(w,S) w'*S*w;  

N        = numel(R);

EffWts   = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],ones(1,N),1,zeros(N,1),ones(N,1));

EffRet   = EffWts'*R';  % or R*EffWts 

EffRisk  = PortRisk(EffWts,S); %Portfolio Variance

