% this script depicts in the bar chart form the number of infection averted
% in the shape of difference and ratio

% prepare state space
close all
clear variables
clc

% define parameters
year = 365;
num_rates = 4;
N_real = 200000;

% define locations
Output_folder_str = 'Output';
Main_folder_str = 'Baseline';
ConfFolderStr='Configuration';
ConfFileStr='config_pars_1.txt'; % most of the parameter definitions in this
% read the configuration file for the overall processes
cfg = cfgRead(fullfile(Main_folder_str,ConfFolderStr,ConfFileStr));
mult_fact = N_real/25000;

% discretized array from the start of the run (including network burn in)
tdistr=linspace(0,cfg.T*year,cfg.n_points);

% load files
% base_05 = readmatrix(fullfile(Output_folder_str,'cs_incid_05_Baseline.csv'));
base_05 = readmatrix(fullfile(Output_folder_str,'cs_incid_mean_Baseline.csv'));

%incid_05,_01,_09 [slow, medium, fast, max]

%incid_05(1,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_05_Slow.csv'));
incid_05(1,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_mean_Slow.csv'));
incid_01(1,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_01_Slow.csv'));
incid_09(1,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_09_Slow.csv'));

%incid_05(2,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_05_Medium.csv'));
incid_05(2,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_mean_Medium.csv'));
incid_01(2,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_01_Medium.csv'));
incid_09(2,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_09_Medium.csv'));

%incid_05(3,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_05_Fast.csv'));
incid_05(3,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_mean_Fast.csv'));
incid_01(3,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_01_Fast.csv'));
incid_09(3,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_09_Fast.csv'));

%incid_05(4,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_05_Max.csv'));
incid_05(4,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_mean_Max.csv'));
incid_01(4,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_01_Max.csv'));
incid_09(4,:) = readmatrix(fullfile(Output_folder_str,'cs_incid_09_Max.csv'));

ind_t1 = find(tdistr>12*year,1);
ind_t2 = numel(tdistr);

cs_incid_4_years_base = base_05(ind_t1);
cs_incid_8_years_base = base_05(ind_t2);

for counter = 1:num_rates
    incid_05_4(1,counter) = incid_05(counter,ind_t1);
    incid_05_8(1,counter) = incid_05(counter,ind_t2);

    incid_01_4(1,counter) = incid_01(counter,ind_t1);
    incid_01_8(1,counter) = incid_01(counter,ind_t2);

    incid_09_4(1,counter) = incid_09(counter,ind_t1);
    incid_09_8(1,counter) = incid_09(counter,ind_t2);
end

% infections averted difference
figc = 1;

figure(figc);
b1=bar(-mult_fact*[incid_05_4-cs_incid_4_years_base; incid_05_8-cs_incid_8_years_base]);hold on


xticks([1,2]);
xticklabels({'4 years';'8 years'});
ylabel('Infections averted');
set(gca,'FontSize',20);

figc = figc + 1;

figure(figc);
b1=bar([incid_05_4./cs_incid_4_years_base; incid_05_8./cs_incid_8_years_base]);hold on

xticks([1,2]);
xticklabels({'4 years';'8 years'});
ylabel({'Ratio of new infections';'relative to the baseline'});
set(gca,'FontSize',20);

set(gca,'FontSize',20);
figc = figc + 1;

% infections averted
% load data
cs_incid_4_years_base = readmatrix(fullfile(Output_folder_str, 'cs_incid_4_years_Baseline.csv'));
cs_incid_8_years_base = readmatrix(fullfile(Output_folder_str, 'cs_incid_8_years_Baseline.csv'));

cs_incid_4_years_slow = readmatrix(fullfile(Output_folder_str, 'cs_incid_4_years_Slow.csv'));
cs_incid_8_years_slow = readmatrix(fullfile(Output_folder_str, 'cs_incid_8_years_Slow.csv'));

cs_incid_4_years_medium = readmatrix(fullfile(Output_folder_str, 'cs_incid_4_years_Medium.csv'));
cs_incid_8_years_medium = readmatrix(fullfile(Output_folder_str, 'cs_incid_8_years_Medium.csv'));

cs_incid_4_years_fast = readmatrix(fullfile(Output_folder_str, 'cs_incid_4_years_Fast.csv'));
cs_incid_8_years_fast = readmatrix(fullfile(Output_folder_str, 'cs_incid_8_years_Fast.csv'));

cs_incid_4_years_max = readmatrix(fullfile(Output_folder_str, 'cs_incid_4_years_Max.csv'));
cs_incid_8_years_max = readmatrix(fullfile(Output_folder_str, 'cs_incid_8_years_Max.csv'));

num_traj = size(cs_incid_8_years_max,2);
% create string arrays with data label
for counter = 1:4*num_traj
    if counter<=num_traj
        str = 'x2.8 increase ';
    elseif counter<=2*num_traj
        str = 'x5.6 increase ';
    elseif counter<=3*num_traj
        str = 'x33.6 increase';
    else
        str = 'Maximum impact';
    end
    label(counter,:) = str;
end

% combine outputs
% box plots will not do - do vertical lines where we subtract quartiles
figure(figc);
median_base_4 = quantile(cs_incid_4_years_base, 0.5);
median_base_8 = quantile(cs_incid_8_years_base, 0.5);

% quantiles

cs_incid_4_years = [cs_incid_4_years_slow; cs_incid_4_years_medium; cs_incid_4_years_fast; cs_incid_4_years_max];
cs_incid_8_years = [cs_incid_8_years_slow; cs_incid_8_years_medium; cs_incid_8_years_fast; cs_incid_8_years_max];

num_rows = size(cs_incid_4_years,1);

for row_counter = 1:num_rows
    cs_incid_4_years_05(1,row_counter) = quantile(cs_incid_4_years(row_counter,:), 0.5);
    cs_incid_4_years_025(1,row_counter) = quantile(cs_incid_4_years(row_counter,:), 0.25);
    cs_incid_4_years_075(1,row_counter) = quantile(cs_incid_4_years(row_counter,:), 0.75);

    cs_incid_8_years_05(1,row_counter) = quantile(cs_incid_8_years(row_counter,:), 0.5);
    cs_incid_8_years_025(1,row_counter) = quantile(cs_incid_8_years(row_counter,:), 0.25);
    cs_incid_8_years_075(1,row_counter) = quantile(cs_incid_8_years(row_counter,:), 0.75);
end

% plot % on the figure

% define colors
c_first = [232,0,47]/255;
c_end = [0, 51, 142]/255;
color_arr = [linspace(c_first(1,1),c_end(1,1),num_rows); linspace(c_first(1,2),c_end(1,2),num_rows); linspace(c_first(1,3),c_end(1,3),num_rows)]';

delta_x = 1;

ax_arr = zeros(1,2*num_rows);
for row_counter = 1:num_rows
    ax_arr(1,row_counter) = 2 + (row_counter-1)*delta_x;
    ax_arr(1, num_rows+ row_counter) = 9 + (row_counter-1)*delta_x;
end

for row_counter = 1:num_rows
    figure(figc);
    % medians
    p1 = plot(ax_arr([row_counter row_counter+num_rows]), mult_fact*[cs_incid_4_years_05(row_counter)-cs_incid_4_years cs_incid_8_years_05(row_counter)-cs_incid_8_years],'o','Color',color_arr(row_counter,:),'MarkerSize', 10); hold on
    set(p1,'MarkerFaceColor', color_arr(row_counter,:));
    % % 0.25 quantiles
    % p1 = plot(ax_arr([row_counter row_counter+num_rows]), mult_fact*[cs_incid_4_years_025(row_counter) cs_incid_8_years_025(row_counter)],'o','Color',color_arr(row_counter,:),'MarkerSize', 6); hold on
    % set(p1,'MarkerFaceColor', color_arr(row_counter,:));
    % % 0.75 quantiles
    % p1 = plot(ax_arr([row_counter row_counter+num_rows]), mult_fact*[cs_incid_4_years_075(row_counter) cs_incid_8_years_075(row_counter)],'o','Color',color_arr(row_counter,:),'MarkerSize', 6); hold on
    % set(p1,'MarkerFaceColor', color_arr(row_counter,:));
    % 
    % x1 = line([ax_arr(row_counter) ax_arr(row_counter)],mult_fact*[cs_incid_4_years_025(row_counter) cs_incid_4_years_075(row_counter)],'LineWidth',2);
    % set(x1,'color',color_arr(row_counter,:));
    % set(x1, 'HandleVisibility','off');
    % 
    % x1 = line([ax_arr(row_counter+num_rows) ax_arr(row_counter+num_rows)], mult_fact*[cs_incid_8_years_025(row_counter) cs_incid_8_years_075(row_counter)],'LineWidth',2);
    % set(x1,'color',color_arr(row_counter,:));
    % set(x1, 'HandleVisibility','off');

end

set(gca, 'FontSize', 20);
xlim([1, 14]);
ylim([1500 3300]);
xticks(ax_arr);
xticklabels({'Baseline','x 2.8 Baseline','x 5.6 Baseline','x 33.6 Baseline','Maximum impact','Baseline','x 2.8 Baseline','x 5.6 Baseline','x 33.6 Baseline','Maximum impact'})
figc = figc + 1;

figure(figc);
plot([ax_arr(1,1)-delta_x ax_arr(1,1:4)], mult_fact*[ cs_incid_4_years_05(2:end)], 'o','MarkerSize',10); hold on;
plot([ax_arr(1,6)-delta_x ax_arr(1,6:end)], mult_fact*[median_base_8 cs_incid_8_years_05(2:end)], 'o','MarkerSize',10); hold on;

figc = figc + 1;

% from median of the baseline and then color them respectively
cs_incid_4_years = -mult_fact*[cs_incid_4_years_slow'-quantile(cs_incid_4_years_base,0.5); cs_incid_4_years_medium'-quantile(cs_incid_4_years_base,0.5); cs_incid_4_years_fast'-quantile(cs_incid_4_years_base,0.5);cs_incid_4_years_max'-quantile(cs_incid_4_years_base,0.5)];
boxplot(cs_incid_4_years,label);
% numbers
figure(figc);
cs_incid_8_years = -mult_fact*[cs_incid_8_years_slow'-quantile(cs_incid_8_years_base,0.5); cs_incid_8_years_medium'-quantile(cs_incid_8_years_base,0.5); cs_incid_8_years_fast'-quantile(cs_incid_8_years_base,0.5);cs_incid_8_years_max'-quantile(cs_incid_8_years_base,0.5)];
boxplot(cs_incid_8_years,label);


figc = figc + 1;

