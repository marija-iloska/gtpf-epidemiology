clear all
close all
clc

%------------------------------
%           GENERATE DATA
%------------------------------


% Settings
T = 300;     % Time series length

% Transition functions
fs = @(S, I, N, b) S - b*S.*I./N;
fe = @(S, E, I, N, a, b) (1-a)*E + b*S.*I./N;
fi = @(E, I, a, ga) (1 - ga)*I + a*E;
fr = @(I, R, ga) R + ga*I;
f = @(I, E, a, ga) -ga + a*(E./I); 


% True constants
beta = 0.2;
alpha = 1.5;
gamma = 0.03;
var_g = 0.01;
var_y = 0.02;

% Initial conditions
R(1) = 0;
I(1) = 1;
E(1) = 0;
N0 = 5e8;
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



%----------------------------------------
%           PARTICLE FILTER  
%----------------------------------------


% Number of particles
M = 100;

% Initialize
lambda = 1;
Ix = poissrnd(lambda, 1, M);
Ix(Ix==0) = 1;
Sx = N0 - Ix;
S_est = mean(Sx);
Ex = zeros(1,M);
Rx = zeros(1,M);

% True constants
beta_x = beta;
alpha_x = alpha;
gamma_x = gamma;
var_gx = var_g;
var_yx = var_y;



% TIME
for t = 2:T

%     beta_x = abs(normrnd(beta, 0.02));
%     gamma_x = abs(normrnd(gamma, 0.02));
%     alpha_x = abs(normrnd(1, 0.2));
%     var_gx = var_g;


    % PROPOSE PARTICLES
    mean_g(t, :) = f(Ix(t-1, :), Ex(t-1, :), alpha_x, gamma_x);
    x_p = mvnrnd(mean_g(t,:), var_gx*eye(M));


    % Deterministic Update
    Sx(t,:) = fs(Sx(t-1,:), Ix(t-1,:), N0, beta_x);
    Ex(t,:) = fe(Sx(t-1,:), Ex(t-1,:), Ix(t-1,:), N0, alpha_x, beta_x);   
    Rx(t,:) = fr(Ix(t-1,:), Rx(t-1,:), gamma_x);
    Ix(t,:) = (1 + x_p).*Ix(t-1,:);

    % COMPUTE WEIGHTS
    log_w = -0.5*log(2*pi*var_y) - 0.5*((y(t) - x_p).^2)/var_y;

    % NORMALIZE
    w = exp(log_w - max(log_w));
    w = w./sum(w);

    % RESAMPLE
    idx = datasample(1:M, M, 'Weights', w);

    % Propagate new samples
    x_p = x_p(idx);
    Sx(t,:) = Sx(t, idx);
    Ix(t,:) = Ix(t, idx);
    Rx(t,:) = Rx(t, idx);
    Ex(t,:) = Ex(t, idx);


    % Obtain estimates
    x_est(t) = mean(x_p);
    S_est(t) = round(mean(Sx(t,:),2));
    I_est(t) = round(mean(Ix(t,:),2));
    R_est(t) = round(mean(Rx(t,:),2));
    E_est(t) = round(mean(Ex(t,:),2));
end



%------------------------------
%           PLOTS
%------------------------------

lwd = 1.5;
lw = 1;
fsz = 20;
figure(1)
plot(1:T,g, 'k', 'linewidth', lwd)
hold on
plot(1:T, x_est, 'b')
hold on
scatter(1:T,y, 15, 'filled')
set(gca, 'FontSize', fsz)
ylabel('g', 'FontSize', fsz)
xlabel('Time', 'FontSize', fsz)
legend('Truth', 'Estimated', 'Observations', 'FontSize', fsz)

figure(2)
plot(1:T,S,  'k', 'linewidth', lwd)
hold on
plot(1:T, S_est,  'b', 'Linewidth', lw)
set(gca, 'FontSize', fsz)
ylabel('Susceptible', 'FontSize', fsz)
xlabel('Time', 'FontSize', fsz)
legend('Truth', 'Estimated', 'FontSize', fsz)
title('S', 'FontSize', fsz)


figure(3)
plot(1:T, E,  'k', 'linewidth', lwd)
hold on
plot(1:T, E_est,  'b', 'Linewidth', lw)
set(gca, 'FontSize', fsz)
ylabel('Exposed', 'FontSize', fsz)
xlabel('Time', 'FontSize', fsz)
legend('Truth', 'Estimated', 'FontSize', fsz)
title('E', 'FontSize', fsz)

figure(4)
plot(1:T, I,  'k', 'linewidth', lwd)
hold on
plot(1:T, I_est,  'r', 'Linewidth', lw)
set(gca, 'FontSize', fsz)
ylabel('Infectious', 'FontSize', fsz)
xlabel('Time', 'FontSize', fsz)
legend('Truth', 'Estimated', 'FontSize', fsz)
title('I', 'FontSize', fsz)

figure(5)
plot(1:T, R,  'k', 'linewidth', lwd)
hold on
plot(1:T, R_est,  'b', 'Linewidth', lw)
set(gca, 'FontSize', fsz)
ylabel('Recovery', 'FontSize', fsz)
xlabel('Time', 'FontSize', fsz)
legend('Truth', 'Estimated', 'FontSize', fsz)
title('R', 'FontSize', fsz)


% figure(6)
% plot(1:T,S,'linewidth', lwd)
% hold on
% plot(E,'linewidth', lwd)
% hold on
% plot(I,'linewidth', lwd)
% hold on
% plot(R,'linewidth', lwd)
% hold on
% plot(1:T,S_est,'LineStyle', "--",'linewidth', lwd)
% hold on
% plot(E_est,'LineStyle', "--",'linewidth', lwd)
% hold on
% plot(I_est,'LineStyle', "--",'linewidth', lwd)
% hold on
% plot(R_est,'LineStyle', "--",'linewidth', lwd)
% legend('S', 'E', 'I', 'R')

sum( abs(I - I_est))