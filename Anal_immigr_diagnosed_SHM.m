% this script outputs time series for the number of immigrants who arrived
% diagnosed to the Netherlands, the number of individuals who were
% suppressed, calculates the proportion of latter out of the former and
% saves the information into a file to be read during the main simulation
% data source: Ard van Sighem, SHM, personal communication

% prepare state space

close all
clear variables
clc
format long

% define variables

year = [2014 2015 2016 2017 2018 2019 2020 2021 2022]';
diagn_immigr = [58 67 86 144 179 199 166 182 197]';
diagn_suppr = [41 47 67 113 153 173 151 159 174]';

% figure related
figc = 1;
fs = 20;
lw = 4;
ms = 10;

% calculations
prop_suppr = diagn_suppr./diagn_immigr;

years_str = {};
for counter = 1:numel(year)
    years_str{counter} = num2str(year(counter));
end

data_table = table(year, diagn_immigr, diagn_suppr, prop_suppr);

% linear and logistic growth fits
data = [data_table.year'; data_table.prop_suppr']';

% logistic growth
years_extended = [year; (2023:1:2032)'];

% number of diagnosed people

% Define the logistic model
ft1 = fittype('K / (1 + exp(-r*(x-t0)))', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');

values = diagn_immigr;

% Provide some initial guesses for the parameters
opts.StartPoint = [max(values) 0.1 2015]; % K, r, t0 guesses

% Fit the model to the data
logisticModel1 = fit(year, values, ft1, opts);

% Visualize the fitted model
fittedValues1 = feval(logisticModel1, years_extended);


% number of suppressed people

% Define the logistic model
ft2 = fittype('K / (1 + exp(-r*(x-t0)))', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');

values = diagn_suppr;

% Provide some initial guesses for the parameters
opts.StartPoint = [max(values) 0.1 2015]; % K, r, t0 guesses

% Fit the model to the data
logisticModel2 = fit(year, values, ft2, opts);

% Visualize the fitted model
fittedValues2 = feval(logisticModel2, years_extended);

% proportion of suppressed
ft3 = fittype('K / (1 + exp(-r*(x-t0)))', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');

values = data(:, 2);

% Provide some initial guesses for the parameters
opts.StartPoint = [max(values) 0.1 2015]; % K, r, t0 guesses

% Fit the model to the data
logisticModel3 = fit(year, values, ft3, opts);

% Visualize the fitted model
fittedValues3 = feval(logisticModel3, years_extended);

% output
% save in the file
writetable(data_table,'Distributions/immigr_infect.csv');

% save in a figure
figure(figc);

subplot(1,3,1);
plot(data_table.year, data_table.diagn_immigr, '^-', years_extended, fittedValues1,'+-', "LineWidth",lw);
xlim([0.9999*min(year), 1.0001*max(year)]);
ylim([0.95*min(diagn_immigr), 1.05*max(diagn_immigr)]);
xticks(year);
xticklabels(years_str);

xlabel('Time (year)');
legend('Data', 'Logistic regression');
ylabel('Number of diagnosed');
set(gca, 'fontsize', fs);

subplot(1,3,2);
plot(data_table.year, data_table.diagn_suppr, '^-', years_extended, fittedValues2,'+-', "LineWidth",lw);
xlim([0.9999*min(year), 1.0001*max(year)]);
ylim([0.95*min(diagn_suppr), 1.05*max(diagn_immigr)]);
xticks(year);
xticklabels(years_str);

xlabel('Time');
legend('Data', 'Logistic regression');
ylabel('Number');
set(gca, 'fontsize', fs);

subplot(1,3,3);
plot(data_table.year, data_table.prop_suppr, '^-', years_extended, fittedValues3,'+-', "LineWidth",lw);
xlim([0.9999*min(year), 1.0001*max(year)]);
ylim([0.95*min(prop_suppr), 1.05*max(prop_suppr)]);
xticks(year);
xticklabels(years_str);
legend('Data','Logistic regression K=0.9331, r=0.2871, t0=2010')

xlabel('Time');
ylabel('Proportion suppressed out of diagnosed');
set(gca, 'fontsize', fs);

figc = figc + 1;

data = [diagn_immigr'; diagn_suppr']';

% Linear Regression
linearModel = fitlm(data(:,1), data(:,2));
x_arr = linspace(min(data(:,1)), max(data(:,1)),10);
diagn_suppr_linear = feval(linearModel, x_arr);

 figure(figc);
 plot(data(:,1), data(:,2), '^'); hold on;
 plot(x_arr, diagn_suppr_linear, '+-', 'LineWidth', lw );
 xlabel('Number of diagnosed');
 ylabel('Number of suppressed');
 legend('Data', 'Linear model');
 set(gca, 'FontSize', fs);
 figc = figc + 1;

 % the distribution which will ultimately be used in the model

% Define the logistic model

values = diagn_immigr;
year_trim = year(1:6);
values_trim = diagn_immigr(1:6);

% Fit the model to the data
linearModel2 = fitlm(year_trim, values_trim);

% Visualize the fitted model
fittedValues4 = feval(linearModel2, years_extended);

% Fit the model to the data
linearModel3 = fitlm(year, diagn_immigr);

% Visualize the fitted model
fittedValues5 = feval(linearModel3, years_extended);

 % save in a figure
figure(figc);

plot(year, diagn_immigr, '^-', years_extended, fittedValues4,'+-', "LineWidth",lw);hold on;
plot(years_extended, fittedValues5,'+-', "LineWidth",lw);hold on;
xlabel('Time (year)');
legend('Data', 'Linear regression, data trimmed', 'Linear regression, full data');
ylabel('Number of diagnosed');
set(gca, 'fontSize', fs);
figc = figc + 1;

% record the data for the annual immigrated diagnosed and subsequent linear
% extrapolation (with all the points)
full_data(:,1) = year;
% replace the first 9 values with the data 
full_data(1:9,2) = diagn_immigr;

% move into the matrix
writematrix(full_data, 'Data/diagn_immigr_annual.csv')
