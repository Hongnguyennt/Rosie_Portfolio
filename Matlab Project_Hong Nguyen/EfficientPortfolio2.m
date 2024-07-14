function [EffWts, EffRet,EffRisk] = EfficientPortfolio2(R,S,target)

PortRisk = @(w,S) w'*S*w;  

N        = numel(R);

if nargin < 3
    
%Basic Mode    

    Aeq     = ones(1,N);
    Beq     = 1;
    
elseif nargin == 3 

%Impose an additional constraint

Aeq      = [ones(1,N); R];
Beq      = [1; target];

end


EffWts   = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,zeros(N,1),ones(N,1));

EffRet   = EffWts'*R';         % or R*EffWts 

EffRisk  = PortRisk(EffWts,S); %Portfolio Variance

