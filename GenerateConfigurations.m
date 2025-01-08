% this script generates configuration files for infection calibration
% it perturbs the following parameters: probability of transmission in the
% chronic stage and diagnosis rates in the first three primary stages and in three chronic stages
% as well as the rate of dropping from the cART
% the configurations generated will be written in the configuration
% registry file 

% prepare state space
close all
clear variables
clc

% initialize variables
% number of parameters
num_pars = 9;
% number of samples per parameter
num_sample_per_par=160;
n_sample=num_sample_per_par*num_pars;

% initialize the intervals from which the values will be sampled

% yearly rate of importation of undiagnosed infections
import_undiagn_rate_min = 10;
import_undiagn_rate_max = 170;
import_undiagn_rate_mean = (import_undiagn_rate_min+import_undiagn_rate_max)/2;

% probability of transmission
prob_trans_chr_min=0.005;
prob_trans_chr_max=0.012;
prob_trans_chr_mean=(prob_trans_chr_min+prob_trans_chr_max)/2;

% diagnosis rate for people in primary stage and first four months of
% chronic
upsilon_p_min = 0.75;
upsilon_p_max = 1.1;
upsilon_p_mean = (upsilon_p_min + upsilon_p_max)/2;

% diagnosis rate for people in chronic, with age of infection between 0 and 6 months
upsilon_c1_min = 0.65;
upsilon_c1_max = 1;
upsilon_c1_mean = (upsilon_c1_min + upsilon_c1_max)/2;

% diagnosis rate for people in chronic, with age of infection between 6 and 12 months
upsilon_c2_min = 0.65;
upsilon_c2_max = 0.9;
upsilon_c2_mean = (upsilon_c2_min + upsilon_c2_max)/2;

% diagnosis rate for people in chronic, with age of infection older than 12
% months
upsilon_c3_min = 0.4;
upsilon_c3_max = 0.5;
upsilon_c3_mean = (upsilon_c2_min + upsilon_c2_max)/2;

xi_min = 0.005;
xi_max = 0.12;
xi_mean = (xi_min+xi_max)/2;

eta_min = 5;
eta_max = 26;
eta_mean = (eta_max+eta_min)/2;

theta_min = 5;
theta_max = 26;
theta_mean = (theta_max+theta_min)/2;

import_undiagn_rate_LHS = exp(LHS_Call(log(import_undiagn_rate_min),log(import_undiagn_rate_mean),log(import_undiagn_rate_max),0,n_sample,'unif'));
prob_trans_chr_LHS = exp(LHS_Call(log(prob_trans_chr_min),log(prob_trans_chr_mean),log(prob_trans_chr_max),0,n_sample,'unif'));
upsilon_p_LHS = exp(LHS_Call(log(upsilon_p_min),log(upsilon_p_mean),log(upsilon_p_max),0,n_sample,'unif'));

%upsilon_c1_LHS = exp(LHS_Call(log(upsilon_c1_min),log(upsilon_c1_mean),log(upsilon_c1_max),0,n_sample,'unif'));

upsilon_c1_LHS = arrayfun(@(x) upsilon_c1_min + (x - upsilon_c1_min) * rand, upsilon_p_LHS);

%upsilon_c2_LHS = exp(LHS_Call(log(upsilon_c2_min),log(upsilon_c2_mean),log(upsilon_c2_max),0,n_sample,'unif'));

upsilon_c2_LHS = arrayfun(@(x) upsilon_c2_min + (x - upsilon_c2_min) * rand, upsilon_c1_LHS);

%upsilon_c3_LHS = exp(LHS_Call(log(upsilon_c3_min),log(upsilon_c3_mean),log(upsilon_c3_max),0,n_sample,'unif'));
upsilon_c3_LHS = arrayfun(@(x) upsilon_c3_min + (x - upsilon_c3_min) * rand, upsilon_c2_LHS);

xi_LHS =  exp(LHS_Call(log(xi_min),log(xi_mean),log(xi_max),0,n_sample,'unif'));
eta_LHS =  exp(LHS_Call(log(eta_min),log(eta_mean),log(eta_max),0,n_sample,'unif'));
theta_LHS =  exp(LHS_Call(log(theta_min),log(theta_mean),log(theta_max),0,n_sample,'unif'));

pars_LHS=[import_undiagn_rate_LHS'; prob_trans_chr_LHS'; upsilon_p_LHS'; upsilon_c1_LHS'; upsilon_c2_LHS'; upsilon_c3_LHS'; xi_LHS'; eta_LHS'; theta_LHS']';

% define locations
FolderStr='Configuration';

% source of the core template
config_core_file_str='ParsTemplate_Core.txt';
% core part of the names for produced configuration files
config_core_str='config_pars';

% define registry file
registry_str='Config_registry.txt';
% open registry file
f_reg=fopen(fullfile(FolderStr,registry_str),'w');
% open the template
f_core=fopen(fullfile(FolderStr,config_core_file_str));
temp=fread(f_core);

% main loop: create files
for pars_counter=1:n_sample
    pars=pars_LHS(pars_counter,:);
    % make a records in the registry
    str_registry=fprintf(f_reg,'%3d import_undiagn_rate =%6.5f prob_trans_chr=%6.5f  upsilon_p=%6.5f upsilon_c1=%6.5f upsilon_c2=%6.5f upsilon_c3=%6.5f xi = %6.5f eta = %6.5f theta = %6.5f \n',[pars_counter,pars(1,:)]);
    % create the file
    f_config=fopen(fullfile(FolderStr,[config_core_str,'_',num2str(pars_counter),'.txt']),'w');
    % write in the file
    fprintf(f_config,'[{\n');
    fprintf(f_config,'  "import_undiagn_rate": %6.5f,\n',pars(1,1));
    fprintf(f_config,'  "prob_trans_chr": %6.5f,\n',pars(1,2));

    fprintf(f_config,'  "upsilon_a1": %6.5f,\n',pars(1,3));
    fprintf(f_config,'  "upsilon_a23": %6.5f,\n',pars(1,3));
    fprintf(f_config,'  "upsilon_a45": %6.5f,\n',pars(1,3));
    fprintf(f_config,'  "upsilon_6mon": %6.5f,\n',pars(1,4));
    fprintf(f_config,'  "upsilon_12mon": %6.5f,\n',pars(1,5));
    fprintf(f_config,'  "upsilon_c": %6.5f,\n',pars(1,6));
    fprintf(f_config,'  "xi": %6.5f,\n',pars(1,7));

    fprintf(f_config,'  "theta_a1": %6.5f,\n',pars(1,8));
    fprintf(f_config,'  "theta_a23": %6.5f,\n',pars(1,8));
    fprintf(f_config,'  "theta_a45": %6.5f,\n',pars(1,8));
    fprintf(f_config,'  "theta_c": %6.5f,\n',pars(1,8));
    fprintf(f_config,'  "theta_ea": %6.5f,\n',pars(1,8));
    fprintf(f_config,'  "theta_la": %6.5f,\n',pars(1,8));

    fprintf(f_config,'  "eta_a1": %6.5f,\n',pars(1,9));
    fprintf(f_config,'  "eta_a23": %6.5f,\n',pars(1,9));
    fprintf(f_config,'  "eta_a45": %6.5f,\n',pars(1,9));
    fprintf(f_config,'  "eta_c": %6.5f,\n',pars(1,9));
    fprintf(f_config,'  "eta_ea": %6.5f,\n',pars(1,9));
    fprintf(f_config,'  "eta_la": %6.5f,\n',pars(1,9));
   
    % append core to header
    fwrite(f_config,temp);
    % close file
    fclose(f_config);
end

% close files
fclose(f_reg);
fclose(f_core);