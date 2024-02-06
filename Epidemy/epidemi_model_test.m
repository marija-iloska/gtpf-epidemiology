clear all
close all
clc

% Settings
T = 200;     % Time series length

% Transition functions
fs = @(S, I, N, b) S - b*S.*I./N;
fe = @(S, E, I, N, a, b) (1-a)*E + b*S.*I./N;
fi = @(E, I, a, ga) (1 - ga)*I + a*E;
fr = @(I, R, ga) R + ga*I;
f = @(I, E, a, ga) -ga + a*(E./I); 


% True constants
beta = 0.2;
alpha = 1.2;
gamma = 0.03;
var_g = 0.02;
var_y = 0.02;

% Initial conditions
R(1) = 0;
I(1) = 1;
E(1) = 0;
N0 = 500000;
S(1) = N0 - I(1);
g(1) = f(I(1), E(1), alpha, gamma);
y(1) = normrnd(g(1), var_y);


% Generate data
for t = 2:T
    % Deterministic
    S(t) = fs(S(t-1), I(t-1), N0, beta);
    E(t) = fe(S(t-1), E(t-1), I(t-1), N0, alpha, beta);
    I(t) = fi(E(t-1), I(t-1), alpha, gamma);
    R(t) = fr(I(t-1), R(t-1), gamma);


    % Stochastic
    g(t) = f(I(t-1), E(t-1), alpha, gamma) + normrnd(0, var_g);
    y(t) = g(t) + normrnd(0, var_y);

end

% plot(g)
% hold on
% scatter(1:T,y, 10, 'filled')
% 
% figure(2)
% plot(1:T,S)
% hold on
% plot(E)
% hold on
% plot(I)
% hold on
% plot(R)
% legend('S', 'E', 'I', 'R')

