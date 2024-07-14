function [EffWts, EffRet,EffRisk] = EfficientPortfolio3(R,S,target,NumPort)

PortRisk = @(w,S) w'*S*w;  

N        = numel(R);

if nargin < 3

%Basic Mode     
    
    Aeq     = ones(1,N);
    Beq     = 1;

EffWts      = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,zeros(N,1),ones(N,1));    

EffRet      = EffWts'*R';  % or R*EffWts 

EffRisk     = PortRisk(EffWts,S); %Portfolio Variance


elseif nargin == 3 
    
for j = 1:numel(target)    
    
% For each target return, impose the constraint, solve and collect results    
    
Aeq      = [ones(1,N); R];
Beq      = [1; target(j)];

EffWts(:,j) = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,zeros(N,1),ones(N,1));

EffRet(j)   = EffWts(:,j)'*R'; 

EffRisk(j)  = PortRisk(EffWts(:,j),S); 

end

elseif nargin == 4 && isempty(target)
    
%%% Set automatically equally spaced target returns (from the MVP to highest possible return)%%%   

% Find the minimum variance portfolio (basic mode)

Aeq     = ones(1,N);
Beq     = 1;

MVPWts      = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,zeros(N,1),ones(N,1));    

MVPRet      = MVPWts'*R';  

% Set the grid of equally spaced returns    
    
ptf_grid = linspace(MVPRet,max(R),NumPort);

% Then, proceed as with explicit target returns

for j = 1:NumPort    

Aeq      = [ones(1,N); R];
Beq      = [1; ptf_grid(j)];


EffWts(:,j) = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,zeros(N,1),ones(N,1));

EffRet(j)   = EffWts(:,j)'*R'; 

EffRisk(j)  = PortRisk(EffWts(:,j),S); 

end

elseif nargin == 4 && isreal(target)
    
    error('Eheh: You cannot have the drunk wife and the full barrel');

end