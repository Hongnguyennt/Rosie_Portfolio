function [EffWts, EffRet,EffRisk] = EfficientPortfolio4(R,S,target,NumPort,AssBnd)

PortRisk = @(w,S) w'*S*w;  

N        = numel(R);

if nargin < 5  || isempty(AssBnd)
    
LowBnd = zeros(1,N);
UppBnd = ones(1,N);

else  
    
LowBnd  = AssBnd(1,:);
UppBnd  = AssBnd(2,:);

end

if nargin < 3 || isempty(target) && isempty(NumPort)

%Basic Mode     
    
    Aeq     = ones(1,N);
    Beq     = 1;

EffWts      = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,LowBnd,UppBnd);    

EffRet      = EffWts'*R';  % or R*EffWts 

EffRisk     = PortRisk(EffWts,S); %Portfolio Variance


elseif isreal(target) && isempty(NumPort)
    
for j = 1:numel(target)    
    
% For each target return, impose the constraint, solve and collect results    
    
Aeq      = [ones(1,N); R];
Beq      = [1; target(j)];

EffWts(:,j) = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,LowBnd,UppBnd);

EffRet(j)   = EffWts(:,j)'*R'; 

EffRisk(j)  = PortRisk(EffWts(:,j),S); 

end

elseif isreal(NumPort) && isempty(target)
    
%%% Set automatically equally spaced target returns (from the MVP to highest possible return)%%%   

% Find the minimum variance portfolio (basic mode)

Aeq     = ones(1,N);
Beq     = 1;

MVPWts      = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,LowBnd,UppBnd);    

MVPRet      = MVPWts'*R';  

% Set the grid of equally spaced returns    
    
PtfRet      = @(w,Ret) w'*R';

MaxWts      = fmincon(@(w) -PtfRet(w,R),repmat((1/N),N,1),[],[],Aeq,Beq,LowBnd,UppBnd);    

MaxRet      = PtfRet(MaxWts,R);  

ptf_grid = linspace(MVPRet,MaxRet,NumPort);

% Then, proceed as with explicit target returns

for j = 1:NumPort    

Aeq      = [ones(1,N); R];
Beq      = [1; ptf_grid(j)];


EffWts(:,j) = fmincon(@(w) PortRisk(w,S),repmat((1/N),N,1),[],[],Aeq,Beq,LowBnd,UppBnd);

EffRet(j)   = EffWts(:,j)'*R'; 

EffRisk(j)  = PortRisk(EffWts(:,j),S); 

end

elseif isreal(NumPort) && isreal(target)
    
    error('Eheh: You cannot have the drunk wife and the full barrel');
    
    
end
