function []=Main_Traj_Load(par_counter,batch_n, sim_type)
% input parameters
% screening level: screening level of the intervention. Set it to 0 always.
% pars_n: number of the parameter set to use (in the respective
% configuration file)
% batch_n: number of the batch for the current set of the parameters

% define handles
%Population = LargeData();

% Define the folder strings
folder_str_state = 'State';
folder_str_state_pers = ['State_pars_', num2str(par_counter), '_batch_', num2str(batch_n)];

% Construct the full folder path
fullFolderPath = fullfile(folder_str_state, folder_str_state_pers);

% load objects

% population 

% index to access entries in population table
pop_index.id=1;% number, unique
pop_index.birth=2; % number (0 being the start of the simulation, can be negative)
pop_index.death=3; % number
pop_index.age=4; % number, positive
pop_index.sp1_id=5; % number, id steady partner
pop_index.sp1_stdate=6; % start of the partnership
pop_index.nsteady=7; % number of current steady partners
pop_index.casual_prop=8; % propensity to acquire casual partners
pop_index.age_bin=9; % auxiliary entry, age bin, base - 10 year age-bands

% registry for the indices of present individuals
% File name for loading the object
filename = fullfile(fullFolderPath, 'alive_ind.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'alive_ind');
    alive_ind = loadedData.alive_ind;
    disp('alive_ind data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

% File name for loading the object
filename = fullfile(fullFolderPath, 'Population.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'Population');
    Population = loadedData.Population;
    disp('Population data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

% adjust the dates
% duration of calibration rounds in days
dur_calibr_days = floor(9.5*365);

Population.Data(pop_index.birth, alive_ind.Data) = - Population.Data(pop_index.age, alive_ind.Data);
Population.Data(pop_index.sp1_stdate, alive_ind.Data) = Population.Data(pop_index.sp1_stdate, alive_ind.Data) - dur_calibr_days;

% load pop_hiv: HIV table

% index to access entries in HIV table
hiv_index.id=1; % id, structure corresponding to the id in population table
hiv_index.status=2; % HIV status
hiv_index.date_inf=3; % date of infection
hiv_index.date_diagn=4; % date when diagnosis was received
hiv_index.date_art=5; % date when ART was started
hiv_index.date_sup=6; % date when viral suppression has been achieved
% date of expected cross to the new infection stage
hiv_index.date_new_stage=7;

% HIV status coding
HIV_st.susc=0;
HIV_st.A1=1;
HIV_st.A23=2;
HIV_st.A45=3;
HIV_st.C=4;
HIV_st.EA=5;
HIV_st.LA=6;

HIV_st.suscPrep=7;

HIV_st.A1D = 8;
HIV_st.A23D=9;
HIV_st.A45D=10;
HIV_st.CD=11;
HIV_st.EAD=12;
HIV_st.LAD=13;

HIV_st.A1T=14;
HIV_st.A23T=15;
HIV_st.A45T=16;
HIV_st.CT=17;
HIV_st.EAT=18;
HIV_st.LAT=19;

HIV_st.A1S=20;
HIV_st.A23S=21;
HIV_st.A45S=22;
HIV_st.CS=23;
HIV_st.EAS=24;
HIV_st.LAS=25;

% registry of indicides of infected individuals who are alive

% File name for loading the object
filename = fullfile(fullFolderPath, 'infect_alive.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'infect_alive');
    infect_alive = loadedData.infect_alive;
    disp('infect_alive data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

% File name for loading the object
filename = fullfile(fullFolderPath, 'Pop_hiv.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'Pop_hiv');
    Pop_hiv = loadedData.Pop_hiv;
    disp('Pop_hiv data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

% adjust the date of infection
Pop_hiv.Data(hiv_index.date_inf, infect_alive.Data) = Pop_hiv.Data(hiv_index.date_inf, infect_alive.Data) - dur_calibr_days+1;

% adjust the date of diagnosis
% find all who were diagnosed
inds_diagn = infect_alive.Data(Pop_hiv.Data(hiv_index.status, infect_alive.Data)>=HIV_st.A1D);
Pop_hiv.Data(hiv_index.date_diagn, inds_diagn) = Pop_hiv.Data(hiv_index.date_diagn, inds_diagn) - dur_calibr_days+1;

% adjust the date of art initiation
inds_art = inds_diagn(Pop_hiv.Data(hiv_index.status, inds_diagn)>=HIV_st.A1T);
Pop_hiv.Data(hiv_index.date_art, inds_art) = Pop_hiv.Data(hiv_index.date_art, inds_art) - dur_calibr_days+1;

% adjust the date of suppression
inds_suppr = inds_art(Pop_hiv.Data(hiv_index.status, inds_art) >= HIV_st.A1S);
Pop_hiv.Data(hiv_index.date_sup, inds_suppr) = Pop_hiv.Data(hiv_index.date_sup, inds_suppr) - dur_calibr_days+1;

% adjust the date of moving to the next phase
inds_HIV_trans = setdiff(infect_alive.Data, inds_suppr);
Pop_hiv.Data(hiv_index.date_new_stage, inds_HIV_trans) = Pop_hiv.Data(hiv_index.date_new_stage, inds_HIV_trans) - dur_calibr_days+1;

% assert that for non-suppressed people, no one has the next date sooner than t = 2

assert(sum(Pop_hiv.Data(hiv_index.date_new_stage, inds_HIV_trans)<2)==0);

% File name for loading the object
filename = fullfile(fullFolderPath, 'Rels_steady.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'Rels_steady');
    Rels_steady = loadedData.Rels_steady;
    disp('Rels_steady data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

Rels_steady.Data(:,3:4) = Rels_steady.Data(:,3:4) - dur_calibr_days + 1;

% check that no partnership ends sooner than the first day of the
% simulation
assert(sum(Rels_steady.Data(:,4)<2)==0);

% File name for loading the object
filename = fullfile(fullFolderPath, 'Rels_steady_hist.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'Rels_steady_hist');
    Rels_steady_hist = loadedData.Rels_steady_hist;
    disp('Rels_steady_hist data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

Rels_steady_hist.Data(:,3:4) = Rels_steady_hist.Data(:,3:4) - dur_calibr_days + 1;

% Rels_steady = LargeData();
% Rels_steady_hist = LargeData();

% File name for loading the object
filename = fullfile(fullFolderPath, 'total_infect_undiagn_ind.mat');

% Check if the file exists before loading
if exist(filename, 'file')
    loadedData = load(filename, 'total_infect_undiagn_ind');
    total_infect_undiagn_ind = loadedData.total_infect_undiagn_ind;
    disp('total_infect_undiagn_ind data loaded successfully.');
else
    error('File does not exist. Check the path and filename.');
end

% Load the all_casual_parts map
filename = fullfile(fullFolderPath, 'all_casual_parts.mat');
dataAll = load(filename, 'all_casual_parts');
all_casual_parts = dataAll.all_casual_parts;

filename = fullfile(fullFolderPath, 'rec_casual_parts.mat');
dataAll = load(filename, 'rec_casual_parts');
rec_casual_parts = dataAll.rec_casual_parts;

% adjust the dates of start and finish in the casual partnerships
keysList = keys(all_casual_parts);
    
for k = 1:length(keysList)
    currentKey = keysList{k};
    updated_partnerships = [];
    
    for p = all_casual_parts(currentKey)
        p.start_date = p.start_date - dur_calibr_days + 1;
        p.end_date = p.end_date - dur_calibr_days + 1;
        updated_partnerships = [updated_partnerships, p];
    end

    all_casual_parts(currentKey) = updated_partnerships;
end

keysList = keys(rec_casual_parts);

for k = 1:length(keysList)
    currentKey = keysList{k};

    updated_partnerships = [];
    
    for p = rec_casual_parts(currentKey)
        p.start_date = p.start_date - dur_calibr_days + 1;
        p.end_date = p.end_date - dur_calibr_days + 1;
        updated_partnerships = [updated_partnerships, p];
    end

    rec_casual_parts(currentKey) = updated_partnerships;
end

steady_dur = LargeData();
casual_dur = LargeData();

filename = fullfile(fullFolderPath,'total_diagn_ind.csv');
if exist(filename, 'file')
    total_diagn_ind = readmatrix(filename);
else
    error('File does not exist. Check the path and filename.'); 
end

filename = fullfile(fullFolderPath,'total_treat_ind.csv');
if exist(filename, 'file')
    total_treat_ind = readmatrix(filename);
else
    error('File does not exist. Check the path and filename.'); 
end

filename = fullfile(fullFolderPath,'total_sup_ind.csv');
if exist(filename, 'file')
    total_sup_ind = readmatrix(filename);
else
    error('File does not exist. Check the path and filename.'); 
end
    
% initialize variables
myname = mfilename; % get own name of this script file
error_tol = 1e-3; % set tolerance error

min_age=15;
max_age=75;
band_width=10;
age_edges=min_age:band_width:max_age; % define edges of age bands, 10 years long
num_age=numel(age_edges)-1; % number of age bins

year=365;% duration of a year in days
N_real = 200000;

% control seed
% Load the saved RNG state
% Define the file path for saving the RNG state
rngStateFilePath = fullfile(fullFolderPath, 'rng_state.mat');
loadedData = load(rngStateFilePath, 'rngState');

% Restore the RNG state
rng(loadedData.rngState);
 
%%
% reading of the distributions and parameters
% folder names 
DataFolderStr='Data';
% location of configuration files
ConfFolderStr='Config_calibr';
ConfFileStr=['config_pars_',num2str(par_counter),'.txt']; % most of the parameter definitions in this
% % file will be replaced by seperate distributions
% ConfInitInfectFileStr='HIV_spec.txt';
% configuration of additional screening
AddScreenConfig=['Screen_',num2str(par_counter),'.txt'];

% file names

% mean probability of dying in the 
% individual age band (needed for the simulation), exponential distribution
ProbFileStr='ProbDeathAge.csv';

out_folder_str='Output';
% destination of the outputs settings
OutFolderStr=[out_folder_str,'_par_num_',num2str(par_counter),'_batch_',num2str(batch_n),'_',sim_type];
if exist(OutFolderStr,'dir')~=7
    mkdir(OutFolderStr);
end

ACSDistrFolderStr='Distributions/ACS';

% read the distribution of propensity to acquire non-steady partners
for counter_age=1:num_age
    % load distributions for individuals in a steady partnership
    file_name=['Non_SteadyACSNonStYesStPartAge',num2str(age_edges(counter_age)),'_',num2str(age_edges(counter_age+1)),'.csv'];
    file_path = fullfile(ACSDistrFolderStr, file_name);
    % Read the CSV file into a table
    cas_prop_Yes_st{counter_age} = readmatrix(file_path);
    % load distributions for individuals in a steady partnership
    file_name=['Non_SteadyACSNonStNoStPartAge',num2str(age_edges(counter_age)),'_',num2str(age_edges(counter_age+1)),'.csv'];
    file_path = fullfile(ACSDistrFolderStr, file_name);
    cas_prop_No_st{counter_age} =readmatrix(file_path);
end


% read death probability of dying while within an age bracket (so per whole
% 10 year bracket)
DeathProb=readmatrix(fullfile(DataFolderStr,ProbFileStr)); % needed for simulation of death, exponential distribution is hardcoded

% loading configuration files
% read the configuration file for the overall processes
cfg = cfgRead(fullfile(ConfFolderStr,ConfFileStr));
% % read configuration file for initialization of infection stages
% cfg_infect = cfgRead(fullfile(ConfFolderStr,ConfInitInfectFileStr));
% read configuration file for additional screening
cfg_screen = create_config(sim_type); %cfgRead(fullfile(ConfFolderStr,AddScreenConfig));

c=1/cfg.AgeBr;% ageing rate, years^{-1}

T_burn_d = 0; %year*cfg.T_burn; % convert burn-in time of demographics and sexual networks from days to years

% create distribution of durations of partnerships
% steady
steady_dur_distr = create_st_dur_distr(cfg.rho/year);

% casual 
casual_dur_distr=create_cas_dur_distr(cfg.rho_cas/year);

% load age assortativity and serosorting matrices
FolderStrDistr='Distributions';

% age
% steady
file_name=fullfile(FolderStrDistr,'Steady_age.csv');
age_attr_steady=readmatrix(file_name);
% casual
file_name=fullfile(FolderStrDistr,'Casual_age.csv');
age_attr_casual=readmatrix(file_name);

% serosorting
% steady
file_name=fullfile(FolderStrDistr,'Steady_sero_mix.csv');
sero_attr_steady=readmatrix(file_name);
% casual
file_name=fullfile(FolderStrDistr,'Casual_sero_mix.csv');
sero_attr_casual=readmatrix(file_name);

% PrEP
file_name=fullfile(FolderStrDistr,'PrEP.csv');
% read PrEP uptake (in years^-1)
prep_uptake=readmatrix(file_name);
% convert to daily rates
prep_uptake=prep_uptake/year;

% condom use
file_name=fullfile(FolderStrDistr,'condom.csv');
% read condom use (in years^-1)
% first two rows - ego during steady partnership
% last two rows - ego casual partnership
% odd rows - no PrEP
% even rows with Prep
condom=readmatrix(file_name);


% load the data for the yearly number of immigrated and diagnosed
diagn_immigr_data = readmatrix('Data/diagn_immigr_annual.csv');

% compare the running time to the available data, whether we need to
% extrapolate extra data points
start_year = 2023;
final_year = start_year+ cfg.T; %(cfg.T-cfg.T_burn-0.5) + 2015+1; % we generate one extra year
if final_year>diagn_immigr_data(end,1)
    extra_years = (diagn_immigr_data(end,1)+1):1:final_year;

    % calculate the linear approximation to be used in the simulation
    diagn_immigr_LM = fitlm(diagn_immigr_data(:,1), diagn_immigr_data(:,2));
    
    % Visualize the fitted model
    temp = feval(diagn_immigr_LM, extra_years);
    diagn_immigr_FV = [diagn_immigr_data; [extra_years; temp]'];
else
    diagn_immigr_FV = diagn_immigr_data;
end

% rescale the data on diagn_immigr_FV

mult_fact = cfg.N/N_real;
diagn_immigr_FV(:,2) = mult_fact*diagn_immigr_FV(:,2);
%%



% allocate containers of the outputs
% time variable for the time series summary
% here T is the total running time in years, includes all the burning-in
% stages
% n_points: extrapolation points, ultimately, more is better, especially
% for 
tdistr=linspace(0,cfg.T*year,cfg.n_points);
% age distribution in the end of the run
Age_distr_ER=zeros(cfg.n_traj,num_age);
% total population size time series
PS_TS=zeros(cfg.n_traj,cfg.n_points);
% steady partnerships time series
% number of individuals without a steady partner
Steady0_TS=zeros(cfg.n_traj,cfg.n_points);
% number of individuals with one steady partner
Steady1_TS=zeros(cfg.n_traj,cfg.n_points); 
% duration of steady partnerships, used for calibration and de-bug
Steady_Rels_dur_Stats=zeros(cfg.n_traj,1);

% time series which tracks number of individuals with XX casual partners in
% the last 12 months, XX=0..maximum number of partners +10

% set maximum number of casual partners
max_num_casual = max(cellfun(@(x) find(x>0, 1, 'last'), [cas_prop_No_st, cas_prop_Yes_st]));

% padding with extra number of partners to account 
% Action: 1500 was done for the debug, i think we should ultimately have +10 not
% +1500, let us remember to circle back
max_num_casual=max_num_casual+1500;

% distribution of the number of steady partners within last 12 months taken
% at the end of the simulation run, used for calibration and debug, 11
% since this is the number of partners EMIS-2017 tabulated, with 11-th
% entry denoting >=10 partners
num_steady_distr_12mon=zeros(cfg.n_traj,11);
% number of casual partners within last 6 months, distribution at the end
% of each trajectory
num_casual_distr_6mon=zeros(cfg.n_traj,max_num_casual+1);

Casual_dur_Stats=zeros(cfg.n_traj,1);% means

% infection time series
S_TS=zeros(cfg.n_traj,cfg.n_points);
IA1_TS=zeros(cfg.n_traj,cfg.n_points);
IA23_TS=zeros(cfg.n_traj,cfg.n_points);
IA45_TS=zeros(cfg.n_traj,cfg.n_points);
IC_TS=zeros(cfg.n_traj,cfg.n_points);
IEA_TS=zeros(cfg.n_traj,cfg.n_points);
ILA_TS=zeros(cfg.n_traj,cfg.n_points);
SPrep_TS=zeros(cfg.n_traj,cfg.n_points);

IA1D_TS=zeros(cfg.n_traj,cfg.n_points);
IA23D_TS=zeros(cfg.n_traj,cfg.n_points);
IA45D_TS=zeros(cfg.n_traj,cfg.n_points);
ICD_TS=zeros(cfg.n_traj,cfg.n_points);
IEAD_TS=zeros(cfg.n_traj,cfg.n_points);
ILAD_TS=zeros(cfg.n_traj,cfg.n_points);

IA1T_TS=zeros(cfg.n_traj,cfg.n_points);
IA23T_TS=zeros(cfg.n_traj,cfg.n_points);
IA45T_TS=zeros(cfg.n_traj,cfg.n_points);
ICT_TS=zeros(cfg.n_traj,cfg.n_points);
IEAT_TS=zeros(cfg.n_traj,cfg.n_points);
ILAT_TS=zeros(cfg.n_traj,cfg.n_points);

IA1S_TS=zeros(cfg.n_traj,cfg.n_points);
IA23S_TS=zeros(cfg.n_traj,cfg.n_points);
IA45S_TS=zeros(cfg.n_traj,cfg.n_points);
ICS_TS=zeros(cfg.n_traj,cfg.n_points);
IEAS_TS=zeros(cfg.n_traj,cfg.n_points);
ILAS_TS=zeros(cfg.n_traj,cfg.n_points);

Dead_TS=zeros(cfg.n_traj,cfg.n_points);
HIVDead_TS=zeros(cfg.n_traj,cfg.n_points);

CSDead_TS=zeros(cfg.n_traj,cfg.n_points);
CSHIVDead_TS=zeros(cfg.n_traj,cfg.n_points);

% new infections (incidence) time series 
new_infect_TS=zeros(cfg.n_traj,cfg.n_points);
cs_new_infect_TS=zeros(cfg.n_traj,cfg.n_points);

% new diagnoses (incidence) time series 
new_diagn_TS=zeros(cfg.n_traj,cfg.n_points);
cs_new_diagn_TS=zeros(cfg.n_traj,cfg.n_points);

% proportion of diagnosed through the strategy out of the total diagnosed

prop_diagn_AHI=zeros(cfg.n_traj,1); 

% information about sources and targets of HIV infection
% the infector
inf_source_age_distr=zeros(cfg.n_traj,num_age);
inf_source_HIVSt_distr=zeros(cfg.n_traj,25); % 6 stages for undiagnosed, diagnosed, treated 
% propensity to enter casual partnerships
inf_source_casual_prop_distr=zeros(cfg.n_traj, 250); % 50 is padding

% the infectee
inf_target_age_distr=zeros(cfg.n_traj,num_age);
inf_target_HIVSt_distr=zeros(cfg.n_traj,25);
inf_target_casual_prop_distr=zeros(cfg.n_traj, 250);

% initialize arrays that describe the total number of newly diagnosed per
% trajectory (from the start of the infection dynamics
new_total_diagn_ensemble=zeros(cfg.n_traj,1);
new_AHI_diagn_ensemble=zeros(cfg.n_traj,1);

%%
% parameter calculation
% calculate birth rate (year) to achieve the supplied population size
% Action: ultimately remove the code between *****

% ***************************************************

DeathRates = -c*log(1 - DeathProb);

sum_prod=0;
for k=2:num_age
    prod_k=1;
    for j=2:k
        prod_k=prod_k/(DeathRates(j)+c);
    end
    prod_k=prod_k*(c^(k-1));
    sum_prod=sum_prod+prod_k;
end
% ATTENTION - THE TRAJECTORY TAKES TIME TO SETTLE 
%lambda=cfg.N*(DeathRates(1)+c)/(1+sum_prod); % correction to keep the population constant

% new code
% re-code AgeBirthProp into p
p = zeros(1,6) + 1/6;
c = zeros(1, 6) + 0.1;

mu = DeathRates;

[lambda, N_solutions] = solve_lambda(cfg.N, mu, c, p);

%N_prop = N_solutions./sum(N_solutions);


% convert rates from yearly to daily
% demographic
lambda_d=lambda/year;

% ***************************************************
% initally the probability was probability of dying between ages x and 
% x+n, we need this probability to be per day (so the duration of age 
% bracket in years times duration of the bracket in days;

DeathProbs_d=DeathProb/(cfg.AgeBr*year);

% details about the individuals ddiagnosed through AHI program

diagn_det_ahi=[];

% details about the people detected in a regular program
diagn_det = [];


% this is an internal array, where we collect thet data only when the
% twrite step is being reached, otherwise only the current state of the
% system is retained
time_step=10;
N_steps=ceil(1+(cfg.T*year-mod(cfg.T*year,time_step))/time_step);
twrite=0:time_step:((N_steps*time_step)-1);

% definition of write step to record HIV time series
write_step =10;

for traj_counter=1:1:cfg.n_traj
      % disp('The whole trajectory');
      % tic

    % Main simulation
    % Allocating the arrays and setting the population to its initial state
    % ids
    % the size of the population table is allocated to be twice of the size
    % predicted by the analog deterministic model
    
    % set ids of the initial population
    
    Id_counter= max(Population.Data(pop_index.id, alive_ind.Data))+1; % the id of the next person that will enter the population
      
    % allocate time series containers
    % size: number of time sampling points x age cathegories
    yAge=zeros(N_steps,num_age);
    % time series for the individuals with and without a steady partners
 
    ySteadyPars=zeros(N_steps,2);
    
    % time series for number of individuals in various HIV stages
    yHIV = zeros(ceil((cfg.T*year)/write_step),numel(fieldnames(HIV_st)));

    % time series for total dead individuals
    yDead=zeros(N_steps,1);
    % time series death due to HIV infection
    yHIVDead=zeros(N_steps,1);

    % record age-distribution of the population at the start of the
    % simulation
    for bin_counter=1:6
        yAge(1,bin_counter)=sum(Population.Data(pop_index.age_bin,:)==bin_counter);
    end

    % array keeping track of relationship duration 
    steady_dur.Data=[];

    % duration of casual partnerships
    casual_dur.Data=[];

    % non-dimensionalize the distribution of relationships durations
    steady_dur_distr=steady_dur_distr/sum(steady_dur_distr);

    % re-assign propensity to form casual partnerships to these who are in
    % the steady partnerhsip

    % record number of people who have 0 and 1 steady partners at the
    % start of the simulation

    ySteadyPars(1,1) = sum(Population.Data(pop_index.nsteady, alive_ind.Data)>0);
    ySteadyPars(1,2) = numel(alive_ind.Data) - ySteadyPars(1,1);

    % non-dimensionalize the distribution of relationships durations
    casual_dur_distr=casual_dur_distr/sum(casual_dur_distr);

    burn_fl=0;
    fl_collect=0;

    % arrays that will contain the data about who infected whom
    % source of infection schema: [id age casual_prop HIV_st_source]
    infect_source_data=[];
    % target of infection schema: [id age casual_prop HIV_st_source Susc_st_target]
    infect_target_data=[];

    % number of new infections
    % schema: [t num]
    num_new_infect=[];

    % number of new diagnoses
    % schema: [t num]
    num_new_diagn=[];

    twrite_counter=2;
    t_write_HIV_counter = 1;

    % arrays for the number of immigrated infected, diagnosed, suppressed
    num_immigr_inf = [];
    num_immigr_diagn = [];
    num_immigr_suppr = [];
    
    disp('Full trajectory run time is')
    tic
    
    for tcounter=2:1:(year*cfg.T)+1 % convert time from years to days
         % disp('Time step');
         % % tic   
         % disp('Ageing');   
         % tic

        % ageing module - shift the age
        if mod(tcounter+182,year)==0
            [Population, ind_new_bracket] = Age(Population,pop_index,alive_ind);
            if numel(ind_new_bracket)>0 % update the data for individuals who moved into the new bracket

                % Define bin_ages and nsteady
                bin_ages = Population.Data(pop_index.age_bin, ind_new_bracket);
                nsteady = Population.Data(pop_index.nsteady, ind_new_bracket);
                
                % Divide ind_new_bracket into groups by nsteady
                ind_new_brackets_0 = ind_new_bracket(nsteady==0);
                ind_new_brackets_1 = ind_new_bracket(nsteady==1);
                
                % bin_ages corresponding to each group
                bin_ages_0 = bin_ages(nsteady==0);
                bin_ages_1 = bin_ages(nsteady==1);
                
                % Generate arrays of random numbers for each group
                rands_0 = rand(1, numel(ind_new_brackets_0));
                rands_1 = rand(1, numel(ind_new_brackets_1));
                
                % Call set_casual_prop on each group with corresponding random numbers
                Population.Data(pop_index.casual_prop, ind_new_brackets_0) = arrayfun(@(bin_age, r) set_casual_prop(cas_prop_No_st{bin_age}, r), bin_ages_0, rands_0);
                Population.Data(pop_index.casual_prop, ind_new_brackets_1) = arrayfun(@(bin_age, r) set_casual_prop(cas_prop_Yes_st{bin_age}, r), bin_ages_1, rands_1);

            end
        end
      % toc

%        death module 
%        disp('Death');
%        tic 
        
        [Population, Pop_hiv, fl_collect,num_died,alive_ind,steady_dur,casual_dur,Rels_steady,dead_inds,infect_alive,reset_casual_prop,total_infect_undiagn_ind,total_diagn_ind,total_treat_ind,total_sup_ind] = Death_Load(Population,Pop_hiv,fl_collect,pop_index,hiv_index,DeathProbs_d,tcounter,alive_ind,steady_dur,casual_dur,Rels_steady,infect_alive,total_infect_undiagn_ind,total_diagn_ind,total_treat_ind,total_sup_ind,all_casual_parts); 
        if ~exist('reset_casual_prop')
            reset_casual_prop=[];
        end

        if numel(reset_casual_prop)>0
            % Define bin_ages
            bin_ages = Population.Data(pop_index.age_bin,reset_casual_prop);
            % Generate arrays of random numbers for each group
            rands = rand(1, numel(reset_casual_prop));
            Population.Data(pop_index.casual_prop,reset_casual_prop) = arrayfun(@(bin_age,r) set_casual_prop(cas_prop_No_st{bin_age},r), bin_ages, rands);
        end

        assert(numel(dead_inds)==num_died);
        yDead(tcounter)=num_died;

%       toc
% % % % 
%       disp('Birth');
%       tic
         % birth module 
        
        current_year = 2023 + floor(tcounter/365);

       % current_year
        lambda_diagn_d = diagn_immigr_FV(current_year-2013, 2)/year;

        [Population,Pop_hiv,Id_counter,alive_ind,ind_new_bracket, newly_infect3, new_diagn, new_suppr, infect_alive] = Birth_Immigr_Load(Population,Pop_hiv, pop_index,hiv_index,lambda_d,tcounter,Id_counter,alive_ind, cfg, lambda_diagn_d, infect_alive, HIV_st);
        if ~exist('ind_new_bracket')
            ind_new_bracket=[];
        end
        
        num_new_born = numel(ind_new_bracket);
        if num_new_born>0
             % Define age bins for people for whom the propensity to
             % acquire new partners needs to be seeded, in this case bin 1
            bin_ages = ones(1, num_new_born);
            % Generate arrays of random numbers for each group
            rands = rand(1, num_new_born);
            % note that below although the argument is bin_ages, the
            % function only really works with the first bracket - since it
            % is birth
            Population.Data(pop_index.casual_prop,ind_new_bracket) = arrayfun(@(bin_age,r) set_casual_prop(cas_prop_No_st{1},r), bin_ages,rands);

            % write up the immigration
            if numel(newly_infect3)>0
                num_immigr_inf = [num_immigr_inf; tcounter numel(newly_infect3)];
            end

            if numel(new_diagn)>0
                num_immigr_diagn = [num_immigr_diagn; tcounter numel(new_diagn)];
            end

            if numel(new_suppr)>0
                num_immigr_suppr = [num_immigr_suppr; tcounter numel(new_suppr)];
            end
    
         end

        
%        toc
%   
%        disp('Steady partnership creation');
%        tic
        num_pairs_old=size(Rels_steady.Data,1);
        % create steady partnerships
        [Population,Rels_steady]=create_steady(Population,pop_index,cfg.sigma,tcounter,Rels_steady,alive_ind,steady_dur_distr,age_attr_steady,sero_attr_steady,Pop_hiv,hiv_index,all_casual_parts); 
        
        num_pairs_new=size(Rels_steady.Data,1);
        if num_pairs_new>num_pairs_old % new pairs were created
            % append new pairs to the history catalogue
            Rels_steady_hist.Data=[Rels_steady_hist.Data; Rels_steady.Data((num_pairs_old+1):end,:)];

            % resample propensity to form casual partnerships
            ids_steady=(sort(unique([Rels_steady.Data((num_pairs_old+1):(num_pairs_new),1); Rels_steady.Data((num_pairs_old+1):(num_pairs_new),2)])))';
            
            if ~isempty(ids_steady)
                
                num_ids_steady = numel(ids_steady);
                inds_steady = find(ismember(Population.Data(pop_index.id,:),ids_steady'));
                % Define bin_ages
                bin_ages = Population.Data(pop_index.age_bin,inds_steady);
                % Generate arrays of random numbers for each group
                rands = rand(1, num_ids_steady);
                Population.Data(pop_index.casual_prop,inds_steady) = arrayfun(@(bin_age,r) set_casual_prop(cas_prop_Yes_st{bin_age},r), bin_ages,rands);        
        
            end

        end
        
        % toc
        % 
        % disp('Dissolution of steady partnership');
        % tic
        % 
        % break up steady pairs
        pairs_break=find(Rels_steady.Data(:,4)==tcounter);
        
        if numel(pairs_break)>0
            [Population, Rels_steady,steady_dur, ind_new_bracket]=break_up_steady(Population,pop_index,Rels_steady,pairs_break,steady_dur);
        end

%       resample propensity to form casual partnerships

        if numel(ind_new_bracket)>0
            bin_ages=Population.Data(pop_index.age_bin,ind_new_bracket);
            rands = rand(1, numel(ind_new_bracket));
            Population.Data(pop_index.casual_prop,ind_new_bracket) = arrayfun(@(bin_age,r) set_casual_prop(cas_prop_No_st{bin_age},r), bin_ages,rands);
        end

%       toc
% 
        % disp('Creation of casual partnerships');
        % tic

        % create casual partnerships
        % at the start of each partnership there is a sexual intercourse,
        % therefore, potentially an HIV transmission can take place
        % keep track of previously existing infections
        N_infect_old=numel(infect_alive.Data);
                
        [Pop_hiv,infect_alive,infect_source_data,infect_target_data, all_casual_parts, rec_casual_parts, new_rels_casual, newly_infect1]=create_casual(Population,Pop_hiv,pop_index,tcounter,alive_ind,casual_dur_distr,age_attr_casual,sero_attr_casual,condom, burn_fl,infect_source_data,infect_target_data,infect_alive,hiv_index,cfg,HIV_st, all_casual_parts, rec_casual_parts);
        % Note: new_rels_casual are the partnerships for whom infection
        % event was simulated
        % toc
% % 

        N_infect_new=numel(infect_alive.Data);
        % if N_infect_new>N_infect_old
        %     num_new_infect=[num_new_infect; tcounter N_infect_new-N_infect_old];
        % end

%  % 
        % disp('Dissolution of casual partnerships');
        % tic
        % dissolve casual partnerships
        % the wrapper arounf break_up_casual_v3 will need to be ultimately
        % removed
        [casual_dur, all_casual_parts] = break_up_casual(casual_dur, all_casual_parts, tcounter);
%         
%        toc  

        if mod(tcounter,30)==0 % & tcounter>182

            % disp('Clean up of history of casual partnerships');
            % tic

            keysList = keys(rec_casual_parts);
    
            for k = 1:length(keysList)
                currentKey = keysList{k};
                updated_partnerships = [];
                
                for p = rec_casual_parts(currentKey)
                    % Check if the partnership's start date is more than 182 days ago
                    if p.end_date > (tcounter - 182)
                        updated_partnerships = [updated_partnerships, p];
                    end
                end
                
                rec_casual_parts(currentKey) = updated_partnerships;
                
                %  If no partnerships remain for an individual, remove them from the map
                if isempty(updated_partnerships)
                    remove(rec_casual_parts, currentKey);
                end
            end

%            toc

        end
% 
       

        % HIV dynamics

        % initialization of HIV dynamics, executed once
        if ~burn_fl & tcounter>=T_burn_d+1
            burn_fl=1;
            % initialize the infection
            % seed infection
            % [Pop_hiv,inds_not_diagn,inds_not_treat,inds_not_sup,inds_sup]=seed_infection(Population,Pop_hiv,pop_index,hiv_index,alive_ind,cfg_infect, HIV_st, tcounter,cfg, rec_casual_parts);
            % infect_alive.Data=[infect_alive.Data, inds_not_diagn,inds_not_treat,inds_not_sup,inds_sup];


            %total_infect_undiagn_ind.Data=inds_not_diagn;% container for these who are infected but not diagnosed yet
            %total_diagn_ind=inds_not_treat;% container for these who are diagnosed but not on treatment
            %total_treat_ind=inds_not_sup;% container for these who are on treatment but not on treatment yet
            %total_sup_ind=inds_sup;% container for these who are suppressed

            % initialize containers for diagnosed during the main
            % simulation
            new_total_diagn_ind=[];
            new_AHI_diagn_ind=[];

            % write up as a time series the initialization point
            for HIV_St_counter=0:1:numel(fieldnames(HIV_st))-1
                yHIV(t_write_HIV_counter,HIV_St_counter+1)=sum(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_St_counter);
            end

            t_write_HIV_counter = t_write_HIV_counter + 1; 
        end

        if burn_fl % burn in is over, run the HIV dynamics
    
            % death due to AIDS
            % find these who are in the AIDS stage
            ind_AIDS1=alive_ind.Data(find(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_st.EA));
            ind_AIDS2=alive_ind.Data(find(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_st.LA));
            ind_AIDS3=alive_ind.Data(find(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_st.EAD));
            ind_AIDS4=alive_ind.Data(find(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_st.LAD));
            ind_AIDS5=alive_ind.Data(find(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_st.EAT));
            ind_AIDS6=alive_ind.Data(find(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_st.LAT));
    
            ind_AIDS=sort([ind_AIDS1,ind_AIDS2,ind_AIDS3,ind_AIDS4,ind_AIDS5,ind_AIDS6]);
    
            % disp('HIV death');
            % tic 

            ind_dead=[];
            if numel(ind_AIDS)>0
                [Population,fl_collect,Pop_hiv,Rels_steady,steady_dur,casual_dur,alive_ind,num_died_HIV,ind_dead,infect_alive,total_infect_undiagn_ind,total_diagn_ind,total_treat_ind,total_sup_ind,reset_casual_prop, all_casual_parts]=HIV_death(Population,fl_collect,Pop_hiv,Rels_steady,steady_dur,casual_dur,alive_ind,pop_index,hiv_index,cfg,tcounter,infect_alive,HIV_st,total_infect_undiagn_ind,total_diagn_ind,total_treat_ind,total_sup_ind, all_casual_parts);
                assert(numel(ind_dead)==num_died_HIV);
            
                if ~exist('reset_casual_prop')
                    reset_casual_prop=[];
                end
        
                if numel(reset_casual_prop)>0
                    % Define bin_ages
                    bin_ages = Population.Data(pop_index.age_bin,reset_casual_prop);
                    % Generate arrays of random numbers for each group
                    rands = rand(1, numel(reset_casual_prop));
                    Population.Data(pop_index.casual_prop,reset_casual_prop) = arrayfun(@(bin_age,r) set_casual_prop(cas_prop_No_st{bin_age},r), bin_ages, rands);
    
                end
                
    
                yHIVDead(tcounter)=num_died_HIV;
        
                if num_died_HIV>0
                    % update the ids for individuals at various stages of care
                    % cascade
                    total_infect_undiagn_ind.Data=setdiff(total_infect_undiagn_ind.Data,ind_dead);% container for these who are infected but not diagnosed yet
                    total_diagn_ind=setdiff(total_diagn_ind,ind_dead);% container for these who are diagnosed but not on treatment
                    total_treat_ind=setdiff(total_treat_ind,ind_dead);% container for these who are on treatment but not on treatment yet
                    total_sup_ind=setdiff(total_sup_ind,ind_dead);
                    newly_infect1 = setdiff(newly_infect1, ind_dead);
                    %newly_infect2 = setdiff(newly_infect2, ind_dead);
                    %newly_infect2 is not defined yet 
                    newly_infect3 = setdiff(newly_infect3, ind_dead);
                    new_diagn = setdiff(new_diagn, ind_dead);
                    new_suppr = setdiff(new_suppr, ind_dead);
                end
            end
%             toc 

%             disp('HIV advance');
%             tic 
            % advancement to the next stage of infection
            [Pop_hiv]=Infection_Advance(Pop_hiv,hiv_index,cfg,infect_alive,HIV_st,tcounter);
%             toc

%             disp('Infection');
%             tic 

            % infection
            infect_undiagn_old=total_infect_undiagn_ind.Data;

            N_infect_old=numel(infect_alive.Data);
            if numel(infect_alive.Data)>0
                [Pop_hiv,infect_alive,newly_infect2,infect_source_data,infect_target_data]=infection(Population,Pop_hiv,pop_index,hiv_index,cfg,infect_alive,tcounter,HIV_st,condom,new_rels_casual,infect_source_data,infect_target_data, all_casual_parts);
            end

            infect_alive.Data=[infect_alive.Data, newly_infect1, newly_infect2, newly_infect3];

            

            % NOTE newly infected are not added to the list of individuals
            % who can potentially be diagnosed in the same step

            N_infect_new=numel(infect_alive.Data);

            if (numel(newly_infect1) + numel(newly_infect2) + numel(newly_infect3))>0
                num_new_infect = [num_new_infect; tcounter (numel(newly_infect1) + numel(newly_infect2) + numel(newly_infect3))];
            end

            % if N_infect_new>N_infect_old
            %     if ~isempty(num_new_infect) & num_new_infect(end,1)==tcounter
            %         num_new_infect(end,2)=num_new_infect(end,2)+N_infect_new-N_infect_old;
            %     else
            %         num_new_infect=[num_new_infect; tcounter N_infect_new-N_infect_old];
            %     end
            % end
% 
%           toc
% 
%           % PrEP processes
%             
            % disp('PrEP uptake');
            % tic 
            if numel(alive_ind.Data)>numel(infect_alive.Data) % there are individuals who are not infected
                 [Pop_hiv]=PrEPUptake(Population,Pop_hiv,hiv_index,HIV_st,alive_ind,infect_alive,cfg,prep_uptake,pop_index,rec_casual_parts);
            end
    
%             toc
% % 
% %             % PrEP dropout
% %     
            % disp('PrEP drop');
            % tic 
            % 
            [Pop_hiv]=PrEPDrop(Pop_hiv,hiv_index,HIV_st,alive_ind,infect_alive,cfg);

  %       toc
            
            % cART dynamics
    
            % disp('diagnose');
            % tic 

            % diagnose
            num_AHI_diagn_ind_old=numel(new_AHI_diagn_ind);
            if numel(infect_undiagn_old)>0 % if number of infected and undiagnosed prior to this stage is above zero
                [Pop_hiv,newly_diagn,prop_diagn_AHI(traj_counter,1),new_total_diagn_ind,new_AHI_diagn_ind]=diagnose_Load(Pop_hiv,hiv_index,HIV_st,cfg,infect_undiagn_old,prop_diagn_AHI(traj_counter,1),tcounter,cfg_screen,new_total_diagn_ind,new_AHI_diagn_ind);
                if numel(newly_diagn)>0
                    num_new_diagn=[num_new_diagn; tcounter numel(newly_diagn)];
                    if num_AHI_diagn_ind_old<numel(new_AHI_diagn_ind) % record who are the individuals detected in AHI trajectory
                        % schema [date age, HIV_st before detection, recent
                        % number of casual partnerships tcounter]
                        for ind_counter=(num_AHI_diagn_ind_old+1):(numel(new_AHI_diagn_ind))
                            id=Population.Data(pop_index.id,new_AHI_diagn_ind(ind_counter));
                            age=Population.Data(pop_index.age,new_AHI_diagn_ind(ind_counter));
                            HIV_stat=Pop_hiv.Data(hiv_index.status,new_AHI_diagn_ind(ind_counter))-13;
                            
                            num_parts=numel(retrievePartners(rec_casual_parts,id));
                            
                            diagn_det_ahi=[diagn_det_ahi; id age HIV_stat num_parts tcounter];
                        end
                    end
                    for ind_counter=1:numel(newly_diagn)
                        ind = newly_diagn(ind_counter);
                        id=Population.Data(pop_index.id, ind);
                        age=Population.Data(pop_index.age,ind);
                        % the calculation of epidemiological status during diagnosis will
                        % depend on whether a person was detected as a part
                        % of AHI or regular screening
                        h_st = Pop_hiv.Data(hiv_index.status, ind);
                        if h_st>=HIV_st.A1T
                            HIV_stat=h_st-13;
                        else
                            HIV_stat=h_st-7;
                        end

                        num_parts=numel(retrievePartners(rec_casual_parts,id));
                        % collect the time between infection and diagnosis
                        % retrieve time of infection
                        time_infect = Pop_hiv.Data(hiv_index.date_inf,ind);
                        if time_infect==1 %cfg.T_burn*year+1 % initial infected
                            if HIV_stat==HIV_st.A1 % was initially infected when diagnosed, collect their
                                infect_age = 1; %tcounter-cfg.T_burn*year;
                            elseif HIV_stat==HIV_st.A23
                                infect_age = year*1/cfg.gamma_a1; %+tcounter-cfg.T_burn*year;
                            elseif HIV_stat==HIV_st.A45
                                infect_age = year*(1/cfg.gamma_a1+1/cfg.gamma_a23); %+tcounter-cfg.T_burn*year;
                            elseif HIV_stat==HIV_st.C
                                infect_age = year +1;
                            else  % AIDS
                                infect_age = year*(1/cfg.gamma_a1+1/cfg.gamma_a23+1/cfg.gamma_a45+1/cfg.gamma_c)+1;
                            end
                        else
                            infect_age = tcounter-time_infect;
                        end
                        diagn_det=[diagn_det; id age HIV_stat num_parts tcounter infect_age];                        
                        
                    end
                end
            else
                newly_diagn=[];
            end  

%             toc 
% % % % % 
%             disp('Start treatment');
%             tic 
            % update the indices for the infected individuals who were not
            % diagnosed yet by adding infected in this turn to the
            % difference of old undiagnosed uninfected with individuals who
            % are newly diagnosed
            total_infect_undiagn_ind.Data=[setdiff(total_infect_undiagn_ind.Data,newly_diagn), newly_infect1, newly_infect2, newly_infect3];
            
            % start treatment
            if numel(total_diagn_ind)>0
                [Pop_hiv,newly_treat,total_diagn_ind]=start_treatment(Pop_hiv,hiv_index,HIV_st,cfg,total_diagn_ind,tcounter);
            else
                newly_treat=[];
            end

            % all diagnosed (before and during simulation) who are alive
            % only add newly diagnosed after starting of the treatment - it
            % is impossible that most of them will get the treatment on the
            % same day
            if ~exist("new_AHI_diagn_ind")
                new_AHI_diagn_ind=[];
            end
            if numel(new_AHI_diagn_ind)>num_AHI_diagn_ind_old % we want to remove AHI individuals as upon diagnosis they will proceed to treatment immediately
                total_diagn_ind = [total_diagn_ind,setdiff(newly_diagn,new_AHI_diagn_ind((num_AHI_diagn_ind_old+1):(numel(new_AHI_diagn_ind))))];
            else
                total_diagn_ind = [total_diagn_ind,setdiff(newly_diagn,new_AHI_diagn_ind)];
            end  

            total_diagn_ind = [total_diagn_ind, new_diagn];
%            toc
% % 
% %             % get suppressed
% %             
%            disp('Get suppressed');
%            tic 

            if numel(total_treat_ind)>0
                [Pop_hiv,newly_sup,total_treat_ind ]=get_suppressed(Pop_hiv,hiv_index,HIV_st,cfg,total_treat_ind, tcounter);
            else
                newly_sup=[];
            end


            total_treat_ind=[total_treat_ind,newly_treat];
            % add individuals who were diagnosed in this step as a part of
            % AHI strategy to the treated compartment
            if numel(new_AHI_diagn_ind)>num_AHI_diagn_ind_old
                total_treat_ind=[total_treat_ind,new_AHI_diagn_ind((num_AHI_diagn_ind_old+1):(numel(new_AHI_diagn_ind)))];
            end
%             
%            toc 
 
%            disp('Drop CART');
%            tic 
            % drop out of cART
    
            if numel(total_sup_ind)>0
                [Pop_hiv,total_diagn_ind,total_sup_ind]=cART_drop(Pop_hiv,hiv_index,HIV_st,cfg,total_diagn_ind,total_sup_ind,tcounter);
            end

            total_sup_ind=[total_sup_ind, newly_sup, new_suppr];

            % add people who entered the population infected

            infect_alive.Data = [infect_alive.Data new_diagn, new_suppr];

%        toc
        end

%       disp('Upkeep at the end of the timestep');
%       tic 
%       tabulate the population, later rewrite to do it only at a handful of
%       points

        if mod(tcounter,write_step)==0

            for counter=1:1:num_age
                yAge(twrite_counter,counter)=sum(Population.Data(pop_index.age_bin,alive_ind.Data)==counter);
            end
    
            % tabulate relationship statistics
            % steady partnerships
            % record number of people who have 0 and 1steady partners
            for n_steady_counter=0:1
                % ySteadyPars(tcounter,n_steady_counter+1)=sum(Population.Data(pop_index.nsteady,alive_ind.Data)==n_steady_counter);
                ySteadyPars(twrite_counter,n_steady_counter+1)=sum(Population.Data(pop_index.nsteady,alive_ind.Data)==n_steady_counter);
            end
    
            if burn_fl
                % tabulate HIV dynamics
                for HIV_St_counter=0:1:numel(fieldnames(HIV_st))-1
                    % yHIV(tcounter,HIV_St_counter+1)=sum(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_St_counter);
                    yHIV(t_write_HIV_counter,HIV_St_counter+1)=sum(Pop_hiv.Data(hiv_index.status,alive_ind.Data)==HIV_St_counter);
                end

                t_write_HIV_counter = t_write_HIV_counter + 1; 
            end

            twrite_counter = twrite_counter + 1;
        end

       
        %elapsedTime(tcounter-1)=toc;
        %mean(elapsedTime)*numel(elapsedTime)
       % if mod(tcounter,365)==0
       %      toc;
       %      disp('year');
       %      tic;
       % end
    end

    toc


    % write summary of the run
    % age distribution at the end of the run
    Age_distr_ER(traj_counter,:)=yAge(end,:)./sum(yAge(end,:));
    % allocate the containers for the outputs collection
    % total population size
    %PS_TS(traj_counter,:)=interp1(0:1:(cfg.T*year),sum(yAge,2),tdistr);
    PS_TS(traj_counter,:)=interp1(twrite,sum(yAge,2),tdistr);
    % number of steady partnerships
    Steady0_TS(traj_counter,:)=interp1(twrite,ySteadyPars(:,1),tdistr);
    Steady1_TS(traj_counter,:)=interp1(twrite,ySteadyPars(:,2),tdistr);
    Steady_Rels_dur_Stats(traj_counter,1)=mean(steady_dur.Data);

    if traj_counter==1
        Steady_dur_Stats=histcounts(steady_dur.Data,'normalization','probability');
        Casual_dur_Stats=histcounts(casual_dur.Data,'normalization','probability');
    end

    % example of old code - first parameter of interp1
    
    % old code
    %t_HIV_write=linspace(cfg.T_burn*year,cfg.T*year, t_write_HIV_counter-1);
    % new code
    t_HIV_write = linspace(0,cfg.T*year, t_write_HIV_counter-1);
    
    S_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.susc+1),tdistr);
    IA1_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A1+1),tdistr);
    IA23_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A23+1),tdistr);
    IA45_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A45+1),tdistr);
    IC_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.C+1),tdistr);
    IEA_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.EA+1),tdistr);
    ILA_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.LA+1),tdistr);
    SPrep_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.suscPrep+1),tdistr);

    IA1D_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A1D+1),tdistr);
    IA23D_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A23D+1),tdistr);
    IA45D_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A45D+1),tdistr);
    ICD_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.CD+1),tdistr);
    IEAD_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.EAD+1),tdistr);
    ILAD_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.LAS+1),tdistr);

    IA1T_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A1T+1),tdistr);
    IA23T_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A23T+1),tdistr);
    IA45T_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A45T+1),tdistr);
    ICT_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.CT+1),tdistr);
    IEAT_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.EAT+1),tdistr);
    ILAT_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.LAT+1),tdistr);

    IA1S_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A1S+1),tdistr);
    IA23S_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A23S+1),tdistr);
    IA45S_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.A45S+1),tdistr);
    ICS_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.CS+1),tdistr);
    IEAS_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.EAS+1),tdistr);
    ILAS_TS(traj_counter,:)=interp1(t_HIV_write,yHIV(:,HIV_st.LAS+1),tdistr);

    Dead_TS(traj_counter,:)=interp1(0:1:cfg.T*year,yDead,tdistr);
    %HIVDead_TS(traj_counter,:)=interp1(0:1:cfg.T*year,yHIVDead,tdistr);
    CSDead_TS(traj_counter,:)=interp1(0:1:cfg.T*year,cumsum(yDead),tdistr);
    %CSHIVDead_TS(traj_counter,:)=interp1(0:1:cfg.T*year,cumsum(yHIVDead),tdistr);
    
    if ~isempty(num_new_infect)   
        if size(num_new_infect,1)>1
            new_infect_TS(traj_counter,:)=interp1(num_new_infect(:,1),num_new_infect(:,2),tdistr);
            cs_new_infect_TS(traj_counter,:)=interp1(num_new_infect(:,1),cumsum(num_new_infect(:,2)),tdistr);
        else
             ind = min(find(tdistr>num_new_infect(:,1),1),numel(tdistr));
             new_infect_TS(traj_counter, ind) = num_new_infect(1,2);
             cs_new_infect_TS(traj_counter,ind) = cumsum(num_new_infect(1,2));
        end

        
        inf_source_age_distr(traj_counter,:)=histcounts(infect_source_data(:,3),age_edges);
        inf_source_HIVSt_distr(traj_counter,:)=histcounts(infect_source_data(:,5),0.5:1:25.5); % 6 stages for undiagnosed, diagnosed, treated 
        inf_source_casual_prop_distr(traj_counter,:)=histcounts(infect_source_data(:,4),0:250);
    
        inf_target_age_distr(traj_counter,:)=histcounts(infect_target_data(:,3),age_edges);
        inf_target_HIVSt_distr(traj_counter,:)=histcounts(infect_target_data(:,6),0.5:1:25.5); % 6 stages for undiagnosed, diagnosed, treated 
        inf_target_casual_prop_distr(traj_counter,:)=histcounts(infect_target_data(:,4),0:250);
        
    else
       disp('No one was infected');
    end

    if size(num_new_diagn,1)>1
        new_diagn_TS(traj_counter,:)=interp1(num_new_diagn(:,1),num_new_diagn(:,2),tdistr);
        cs_new_diagn_TS(traj_counter,:)=interp1(num_new_diagn(:,1),cumsum(num_new_diagn(:,2)),tdistr);
    else
        disp('No one was diagnosed');
    end
    % record source and target of infection
    % analyze the data

    %  proportion AHI trajectory diagnosed out of the total
    new_total_diagn_ensemble(traj_counter,1)=numel(new_total_diagn_ind);
    new_AHI_diagn_ensemble(traj_counter,1)=numel(new_AHI_diagn_ind);

    prop_diagn_AHI(traj_counter,1)=prop_diagn_AHI(traj_counter,1)/cs_new_diagn_TS(traj_counter,end);

    if traj_counter<=cfg.n_traj_collect % output the distribution for steady and casual durations
        % tic for the whole trajectory
        %disp('Whole trajectory');
        
        % steady partners

       % steady partnerships
        ind_rels=find((tcounter-Rels_steady_hist.Data(:,4))>year);
        Rels_steady_hist.Data(ind_rels,:)=[];
    
        for ind=alive_ind.Data % we need to iterate through all individuals since there may be people without partnerships
            id=Population.Data(pop_index.id,ind);
            num_rels=sum(Rels_steady_hist.Data(:,1)==id)+sum(Rels_steady_hist.Data(:,2)==id);
            if num_rels<10
                num_steady_distr_12mon(traj_counter,num_rels+1)=num_steady_distr_12mon(traj_counter,num_rels+1)+1;
            else
                num_steady_distr_12mon(traj_counter,end)=num_steady_distr_12mon(traj_counter,end)+1;
            end
        end
        % non-dimensionalize
        num_steady_distr_12mon(traj_counter,:)=num_steady_distr_12mon(traj_counter,:)./sum(num_steady_distr_12mon(traj_counter,:));

        % summary of the rate of acquisition of casual partners
        % casual partnerships

        % clean up before the write up

        keysList = keys(rec_casual_parts);
    
        for k = 1:length(keysList)
            currentKey = keysList{k};
            updated_partnerships = [];
            
            for p = rec_casual_parts(currentKey)
                % Check if the partnership's start date is more than 182 days ago
                if p.start_date > (tcounter - 182)
                    updated_partnerships = [updated_partnerships, p];
                end
            end
            
            rec_casual_parts(currentKey) = updated_partnerships;
            
            %  If no partnerships remain for an individual, remove them from the map
            if isempty(updated_partnerships)
                remove(rec_casual_parts, currentKey);
            end
        end

        for ind=alive_ind.Data
            id=Population.Data(pop_index.id,ind);
            num_rels=numel(retrievePartners(rec_casual_parts,id));

            if num_rels+1<=size(num_casual_distr_6mon,2)
                num_casual_distr_6mon(traj_counter,num_rels+1)=num_casual_distr_6mon(traj_counter,num_rels+1)+1;
            else
                disp(['In simulation ',num2str(batch_n),' number of casual partners exceeds allocated size: ',  num2str(num_rels+1)]);
            end
        end
        % non-dimensionalize
        num_casual_distr_6mon(traj_counter,:)=num_casual_distr_6mon(traj_counter,:)./sum(num_casual_distr_6mon(traj_counter,:));

    end

end
%toc

% debugging figures
    Tot_pop = sum(yHIV,2);

    Tot_S = yHIV(:,1) + yHIV(:,8);
    Tot_PrEP = yHIV(:,8);
    
    Tot_Infect = Tot_pop - Tot_S;
    Tot_Prev = Tot_Infect./cfg.N;
    
    Tot_Infect_Undiag = sum(yHIV(:,2:7),2);
    Tot_Infect_A1 = yHIV(:,2) + yHIV(:,9) + yHIV(:,15) + yHIV(:,21);
    Tot_Infect_A23 = yHIV(:,3) + yHIV(:,10) + yHIV(:,16) + yHIV(:,22);
    Tot_Infect_A45 = yHIV(:,4) + yHIV(:,11) + yHIV(:,17) + yHIV(:,23);
    Tot_Infect_C = yHIV(:,5) + yHIV(:,12) + yHIV(:,18) + yHIV(:,24);
    Tot_Infect_EA = yHIV(:,6) + yHIV(:,13) + yHIV(:,19) + yHIV(:,25);
    Tot_Infect_LA = yHIV(:,7) + yHIV(:,14) + yHIV(:,20) + yHIV(:,26);

    % tabulate cascade of care
    Tot_Diagn = Tot_Infect - Tot_Infect_Undiag;
    Tot_Diagn_per = Tot_Diagn./Tot_Infect;
    Tot_Treat = Tot_Diagn - sum(yHIV(:, 9:14),2);
    Tot_Treat_per = Tot_Treat./Tot_Diagn;
    Tot_Sup = Tot_Treat - sum(yHIV(:, 15:20), 2);
    Tot_Sup_per = Tot_Sup./Tot_Treat;

%% Record outputs into CSV files
% population
% equilibrium distribution at the end of each run per each trajectory
writematrix(Age_distr_ER,[OutFolderStr,'/Age_distr_ER.csv']);
% population size time series, one per trajectory
writematrix(PS_TS,[OutFolderStr,'/PS_TS.csv']);
% steady partnerships
% time series for proportion of single individuals, one per trajectory
writematrix(Steady0_TS,[OutFolderStr,'/Steady0_TS.csv']);
% time series for proportion of individuals in a partnership, one per trajectory
writematrix(Steady1_TS,[OutFolderStr,'/Steady1_TS.csv']);
% average duration, one per trajectory
writematrix(Steady_Rels_dur_Stats,[OutFolderStr,'/Rels_dur_Stats.csv']);
% distribution of the number of steady partners within 12 months
writematrix(num_steady_distr_12mon,[OutFolderStr,'/num_steady_distr_6mon.csv']);

writematrix(Casual_dur_Stats,[OutFolderStr,'/Casual_dur_Stats.csv']);
% distribution of the number of steady partners within 6 months
writematrix(num_casual_distr_6mon,[OutFolderStr,'/num_casual_distr_6mon.csv']);


% epidemiological process
writematrix(S_TS,[OutFolderStr,'/S_TS.csv']);
writematrix(IA1_TS,[OutFolderStr,'/IA1_TS.csv']);
writematrix(IA23_TS,[OutFolderStr,'/IA23_TS.csv']);
writematrix(IA45_TS,[OutFolderStr,'/IA45_TS.csv']);
writematrix(IC_TS,[OutFolderStr,'/IC_TS.csv']);
writematrix(IEA_TS,[OutFolderStr,'/IEA_TS.csv']);
writematrix(ILA_TS,[OutFolderStr,'/ILA_TS.csv']);
writematrix(SPrep_TS,[OutFolderStr,'/SPrep_TS.csv']);

writematrix(IA1D_TS,[OutFolderStr,'/IA1D_TS.csv']);
writematrix(IA23D_TS,[OutFolderStr,'/IA23D_TS.csv']);
writematrix(IA45D_TS,[OutFolderStr,'/IA45D_TS.csv']);
writematrix(ICD_TS,[OutFolderStr,'/ICD_TS.csv']);
writematrix(IEAD_TS,[OutFolderStr,'/IEAD_TS.csv']);
writematrix(ILAD_TS,[OutFolderStr,'/ILAD_TS.csv']);

writematrix(IA1T_TS,[OutFolderStr,'/IA1T_TS.csv']);
writematrix(IA23T_TS,[OutFolderStr,'/IA23T_TS.csv']);
writematrix(IA45T_TS,[OutFolderStr,'/IA45T_TS.csv']);
writematrix(ICT_TS,[OutFolderStr,'/ICT_TS.csv']);
writematrix(IEAT_TS,[OutFolderStr,'/IEAT_TS.csv']);
writematrix(ILAT_TS,[OutFolderStr,'/ILAT_TS.csv']);

writematrix(IA1S_TS,[OutFolderStr,'/IA1S_TS.csv']);
writematrix(IA23S_TS,[OutFolderStr,'/IA23S_TS.csv']);
writematrix(IA45S_TS,[OutFolderStr,'/IA45S_TS.csv']);
writematrix(ICS_TS,[OutFolderStr,'/ICS_TS.csv']);
writematrix(IEAS_TS,[OutFolderStr,'/IEAS_TS.csv']);
writematrix(ILAS_TS,[OutFolderStr,'/ILAS_TS.csv']);

writematrix(Dead_TS,[OutFolderStr,'/Dead_TS.csv']);
%writematrix(HIVDead_TS,[OutFolderStr,'/HIVDead_TS.csv']);
writematrix(CSDead_TS,[OutFolderStr,'/CSDead_TS.csv']);
%writematrix(CSHIVDead_TS,[OutFolderStr,'/CSHIVDead_TS.csv']);

writematrix(new_infect_TS,[OutFolderStr,'/new_infect_TS.csv']);
writematrix(cs_new_infect_TS,[OutFolderStr,'/cs_new_infect_TS.csv']);

writematrix(new_diagn_TS,[OutFolderStr,'/new_diagn_TS.csv']);
writematrix(cs_new_diagn_TS,[OutFolderStr,'/cs_new_diagn_TS.csv']);

% who infects who

writematrix(inf_source_age_distr,[OutFolderStr,'/inf_source_age_distr.csv']);
writematrix(inf_source_HIVSt_distr,[OutFolderStr,'/inf_source_HIVSt_distr.csv']);
writematrix(inf_source_casual_prop_distr,[OutFolderStr,'/inf_source_casual_prop_distr.csv']);

writematrix(inf_target_age_distr,[OutFolderStr,'/inf_target_age_distr.csv']);
writematrix(inf_target_HIVSt_distr,[OutFolderStr,'/inf_target_HIVSt_distr.csv']);
writematrix(inf_target_casual_prop_distr,[OutFolderStr,'/inf_target_casual_prop_distr.csv']);

% write durations of steady and casual partnerships, from a single run
writematrix(Steady_dur_Stats,[OutFolderStr,'/Steady_dur_Stats.csv']);
writematrix(Casual_dur_Stats,[OutFolderStr,'/Casual_dur_Stats.csv']);

% number of new total diagnosed
writematrix(new_total_diagn_ensemble,[OutFolderStr,'/new_total_diagn_ensemble.csv']);
writematrix(new_AHI_diagn_ensemble,[OutFolderStr,'/new_AHI_diagn_ensemble.csv']);
    
% number of AHI within the trajectory

% proportion of AHI diagnosed out of all diagnosis
writematrix(prop_diagn_AHI,[OutFolderStr,'/prop_diagn_AHI.csv']);

if ~isempty(diagn_det_ahi)
    % details of individuals detected through AHI trajectory
    % schema [id age HIV at the time of detection recent number of casual parts]
    writematrix(diagn_det_ahi(:,2),[OutFolderStr,'/Det_diagn_AHI_Age.csv']);
    writematrix(diagn_det_ahi(:,3),[OutFolderStr,'/Det_diagn_AHI_HIV_st.csv']);
    writematrix(diagn_det_ahi(:,4),[OutFolderStr,'/Det_diagn_AHI_Num_Cas.csv']);
    writematrix(diagn_det_ahi(:,5),[OutFolderStr,'/Det_diagn_AHI_Time_det.csv']);
end

if ~isempty(diagn_det)
    % details of individuals detected through AHI trajectory
    % schema [id age HIV at the time of detection recent number of casual parts]
    writematrix(diagn_det(:,2),[OutFolderStr,'/Det_diagn_Age.csv']);
    writematrix(diagn_det(:,3),[OutFolderStr,'/Det_diagn_HIV_st.csv']);
    writematrix(diagn_det(:,4),[OutFolderStr,'/Det_diagn_Num_Cas.csv']);
    writematrix(diagn_det(:,5),[OutFolderStr,'/Det_diagn_Time_det.csv']);
    writematrix(diagn_det(:,6),[OutFolderStr,'/infect_age.csv']);
end
% record snapshot of the state of the system by the end of the run

% population
%writematrix(Population.Data,[OutFolderStr,'/Population_Snap.csv'])

%HIV dynamics
%writematrix(Pop_hiv.Data,[OutFolderStr,'/Pop_hiv_Snap.csv']);

% write HIV dynamics for calibration with the time series
% record outputs and time array corresponding to them (convenience)

% time array
writematrix(t_HIV_write, fullfile(OutFolderStr,'t_HIV_write.csv'));

% total population
writematrix(Tot_pop, fullfile(OutFolderStr,'Tot_pop.csv'));

% susceptible
writematrix(Tot_S, fullfile(OutFolderStr,'Tot_PrEP.csv'));
writematrix(Tot_PrEP, fullfile(OutFolderStr,'Tot_PrEP.csv'));

% infected
writematrix(Tot_Infect, fullfile(OutFolderStr,'Tot_Infect.csv'));
writematrix(Tot_Prev, fullfile(OutFolderStr,'Tot_Prev.csv'));
writematrix(Tot_Infect_Undiag, fullfile(OutFolderStr,'Tot_Infect_Undiag.csv'));

writematrix(Tot_Infect_A1, fullfile(OutFolderStr,'Tot_Infect_A1.csv'));
writematrix(Tot_Infect_A23, fullfile(OutFolderStr,'Tot_Infect_A23.csv'));
writematrix(Tot_Infect_A45, fullfile(OutFolderStr,'Tot_Infect_A45.csv'));    
writematrix(Tot_Infect_C, fullfile(OutFolderStr,'Tot_Infect_C.csv'));        
writematrix(Tot_Infect_EA, fullfile(OutFolderStr,'Tot_Infect_EA.csv'));            
writematrix(Tot_Infect_LA, fullfile(OutFolderStr,'Tot_Infect_LA.csv'));   

writematrix(Tot_Diagn, fullfile(OutFolderStr,'Tot_Diagn.csv'));
writematrix(Tot_Diagn_per, fullfile(OutFolderStr,'Tot_Diagn_per.csv'));
    
writematrix(Tot_Treat, fullfile(OutFolderStr,'Tot_Treat.csv'));
writematrix(Tot_Treat_per, fullfile(OutFolderStr,'Tot_Treat_per.csv'));

writematrix(Tot_Sup, fullfile(OutFolderStr,'Tot_Sup.csv'));
writematrix(Tot_Sup_per, fullfile(OutFolderStr,'Tot_Sup_per.csv'));

% write age of infection
if ~isempty(num_new_infect)
    writematrix(infect_source_data(:,1), fullfile(OutFolderStr,'infect_source_time.csv'));
    writematrix(infect_source_data(:,5), fullfile(OutFolderStr,'infect_source_source.csv'));
    writematrix(infect_source_data(:,6), fullfile(OutFolderStr,'infect_source_age_infect.csv'));
end

% write immigrated infected individuals
writematrix(num_immigr_inf, fullfile(OutFolderStr,'num_immigr_inf.csv'))
writematrix(num_immigr_diagn, fullfile(OutFolderStr,'num_immigr_diagn.csv'))
writematrix(num_immigr_suppr, fullfile(OutFolderStr,'num_immigr_suppr.csv'))

end