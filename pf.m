clear all
close all
clc

% Read in data
dat = readtable('data/measles.xlsx');

% Reported cases
y = table2cell(dat(:,2));

pop = [757510, 820738, 921785, 931547, 895992, 832688, 831728, 880665];

cut = [0, 72, 120, 192, 240, 300, 361, 421];
d = length(cut);

N = zeros(1,length(y));

for i = 2:d
    N(cut(i-1)+1:cut(i)) = pop(i);
end

N(cut(end):end) = pop(end);

