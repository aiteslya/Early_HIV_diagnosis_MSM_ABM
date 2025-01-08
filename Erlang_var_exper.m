% script outputing stds for Erlang distributions with the same mean but
% different shape parameters

% prepare state space

close all;
clear variables;
clc;
format long;

% set up arrays and initialize variables
k_arr=1:1:100;
mean_distr=9;

% calculate rates
lambda_arr=k_arr./mean_distr;
std_distr=sqrt(k_arr./((lambda_arr).^2));
var_distr=std_distr.^2;

% output

figure;plot(k_arr,std_distr,'LineWidth',4);hold on;
yl=yline(1,'r--','LineWidth',4,'Label','1 year');
set(yl,'FontSize',15)
xlabel('Shape parameter k');
ylabel('STD (year)');
title(['Mean=',num2str(mean_distr),' years']);
set(gca,'FontSize',25);

figure;plot(k_arr,var_distr,'LineWidth',4);hold on;
yl=yline(1,'r--','LineWidth',4,'Label','1 year');
set(yl,'FontSize',15)
xlabel('Shape parameter k');
ylabel('Variance (year^2)');
title(['Mean=',num2str(mean_distr),' years']);
set(gca,'FontSize',25);