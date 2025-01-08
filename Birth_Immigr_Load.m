
function [Population,Pop_hiv,Id_counter,alive_ind,ind_new_bracket, new_infect3, new_diagn, new_suppr, infect_alive] = Birth_Immigr_Load(Population,Pop_hiv,pop_index,hiv_index,lambda_d,tcounter,Id_counter,alive_ind, cfg, lambda_diagn_d, infect_alive, HIV_st)
% insert new individuals which are born according to poisson process with
% average lambda_d per day
% set their age to 15 years, set their date of birth 

% updated birth function accounting for importation of new infections via
% importation

% additional parameters being passed: configuration cfg, yearly number
% of diagnosed individuals who have immigrated infected_distr, and registry
% of infected alive individuals in infect_alive.Data
% assumption about infected_distr: it is rescaled to the model population
% size in the main routine
    new_infect3 = [];
    new_diagn = [];
    new_suppr = [];
    num_born=poissrnd(lambda_d);

    N_real = 200000;
    mult_fact = cfg.N/N_real;

    year = 365; % duration of year in days

    if num_born>0
        % find the first available num_born slates (accounting for
        % possibility new individuals may take place of individuals who
        % already left the populaiton
        ind=find(Population.Data(pop_index.id,:)==0,num_born);
        Population.Data(pop_index.age,ind)=15;
        Population.Data(pop_index.birth,ind)=(tcounter-mod(tcounter,365))/365-15; % tcounter is in days, needs to converted to years
        Population.Data(pop_index.age_bin,ind)=1;
        new_ids=Id_counter:1:(Id_counter+num_born-1);
        Id_counter=Id_counter+num_born;
        Population.Data(pop_index.id,ind)=new_ids;
        Population.Data(pop_index.death,ind)=-1;
        Population.Data(pop_index.sp1_id,ind)=-1;
        Population.Data(pop_index.sp1_stdate,ind)=-40000;
        Population.Data(pop_index.nsteady,ind)=0;
        % list new individuals as having to sample propensity to acquire
        % casual partners
        ind_new_bracket=ind;
        
        alive_ind.Data=[alive_ind.Data, ind];

        %add hiv table record
        Pop_hiv.Data(hiv_index.id,ind)=new_ids;

        % set up an array of entrance rates
        lambda_inf = mult_fact*cfg.import_undiagn_rate/year;
        lambda_diagn = lambda_diagn_d;
        lambda_art = lambda_diagn*cfg.prop_immigr_suppr;
        lambda_sus = lambda_d - lambda_inf - lambda_diagn - lambda_art;
        Lambda_arr = [lambda_inf lambda_diagn-lambda_art lambda_art lambda_sus];
        Lambda_arr = Lambda_arr./sum(Lambda_arr);
        % determine the statuses
        HIV_st_new = randsample(1:4, num_born,true, Lambda_arr);
        n_infect = sum(HIV_st_new == 1);
        n_diagn = sum(HIV_st_new == 2);
        n_suppr = sum(HIV_st_new == 3);

        if (n_infect + n_diagn + n_suppr) == 0 % no individuals with pre-existing infection entered the population

            Pop_hiv.Data(hiv_index.status,ind)=0;
            Pop_hiv.Data(hiv_index.date_inf,ind)=-40000;
            Pop_hiv.Data(hiv_index.date_diagn,ind)=-40000;
            Pop_hiv.Data(hiv_index.date_art,ind)=-40000;
            Pop_hiv.Data(hiv_index.date_sup,ind)=-40000;
            Pop_hiv.Data(hiv_index.date_new_stage,ind)=-40000;
        else
            % decide who of new-entered people is in what stage
            % infected
            ind_select = ind;
            init_infect_seed_weight = [1/cfg.gamma_a1 1/cfg.gamma_a23 1/cfg.gamma_a45 1/cfg.gamma_c 1/cfg.gamma_ea 1/cfg.mu_la];
            % normalization of weights
            init_infect_seed_weight = init_infect_seed_weight./sum(init_infect_seed_weight);

            % define mean sojourn times
            gamma_a1D=cfg.gamma_a1/year;
            gamma_a23D=cfg.gamma_a23/year;
            gamma_a45D=cfg.gamma_a45/year;
            gamma_cD=cfg.gamma_c/year;
            gamma_eaD=cfg.gamma_ea/year;

            if n_infect>0
                ind_infect = datasample(ind_select,n_infect,'Replace',false);% ind_select(unidrnd(numel(ind_select),[1, n_infect]));
                ind_select = setdiff(ind_select, ind_infect);

                new_infect3 = ind_infect;

                % set HIV status
                Pop_hiv.Data(hiv_index.status, ind_infect) = randsample(1:6,n_infect,true,init_infect_seed_weight);

                Pop_hiv.Data(hiv_index.date_diagn,ind_infect)=-40000;
                Pop_hiv.Data(hiv_index.date_art,ind_infect)=-40000;
                Pop_hiv.Data(hiv_index.date_sup,ind_infect)=-40000;
                
                for ind=ind_infect
                    % retrieve HIV status
                    st = Pop_hiv.Data(hiv_index.status,ind);
                    if st==HIV_st.A1 
                        Pop_hiv.Data(hiv_index.date_inf,ind) = tcounter-1; % note that -4 in each branch is added so that people do not get infected or diagnosed in this step
                    elseif st==HIV_st.A23 
                        Pop_hiv.Data(hiv_index.date_inf,ind) = floor(tcounter - year/cfg.gamma_a1 - randi(floor(1+year/cfg.gamma_a23))); 
                    elseif st==HIV_st.A45 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - randi(floor(1+year/cfg.gamma_a45)));
                    elseif st==HIV_st.C 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - year/cfg.gamma_a45 - randi(floor(1+year/cfg.gamma_c)));
                    elseif st==HIV_st.EA 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - year/cfg.gamma_a45 - year/cfg.gamma_c - randi(floor(1+year/cfg.gamma_ea)));
                    elseif st==HIV_st.LA 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - year/cfg.gamma_a45 - year/cfg.gamma_c - year/cfg.gamma_ea - randi(floor(1+year/cfg.mu_la)));
                    else % this individual should not be taken care off in this branch
                        myname = mfilename;
                        error([myname, 'Time of infection is assigned to someone who was diagnosed']);
                    end
               
                    if st==HIV_st.A1 | st==HIV_st.A1D | st==HIV_st.A1T
                        Gamma=gamma_a1D;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.A23 | st==HIV_st.A23D | st==HIV_st.A23T
                        Gamma=gamma_a23D;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.A45 | st==HIV_st.A45D | st==HIV_st.A45T
                        Gamma=gamma_a45D;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.C | st==HIV_st.CD | st==HIV_st.CT
                        Gamma=gamma_cD;
                        % sample from an Erlang distribution
                        mean_dur=1/Gamma;
                        dur=ceil(chronic_dur_sample(mean_dur,'erlang',80));
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.EA | st==HIV_st.EAD | st==HIV_st.EAT
                        Gamma=gamma_eaD;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                     elseif st==HIV_st.LA | st==HIV_st.LAD | st==HIV_st.LAT
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=cfg.T*year +10;
                    end
                end
            else
                ind_infect = [];
            end

            % diagnosed

            if n_diagn>0
                ind_diagn =  datasample(ind_select,n_diagn,'Replace',false);%ind_select(unidrnd(numel(ind_select),[1, n_diagn]));
                ind_select = setdiff(ind_select, ind_diagn);

                new_diagn = ind_diagn;

                % set HIV status
                Pop_hiv.Data(hiv_index.status, ind_diagn) = randsample(HIV_st.A1D:1:HIV_st.LAD ,n_diagn,true,init_infect_seed_weight);
                Pop_hiv.Data(hiv_index.date_diagn,ind_diagn) = tcounter - 2;

                Pop_hiv.Data(hiv_index.date_art,ind_diagn)=-40000;
                Pop_hiv.Data(hiv_index.date_sup,ind_diagn)=-40000;
                
                for ind=ind_diagn
                    % retrieve HIV status
                    st = Pop_hiv.Data(hiv_index.status,ind);
                    if st==HIV_st.A1D 
                        Pop_hiv.Data(hiv_index.date_inf,ind) = tcounter-1; % note that -4 in each branch is added so that people do not get infected or diagnosed in this step
                    elseif st==HIV_st.A23D 
                        Pop_hiv.Data(hiv_index.date_inf,ind) = floor(tcounter - year/cfg.gamma_a1 - randi(floor(1+year/cfg.gamma_a23))); 
                    elseif st==HIV_st.A45D 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - randi(floor(1+year/cfg.gamma_a45)));
                    elseif st==HIV_st.CD 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - year/cfg.gamma_a45 - randi(floor(1+year/cfg.gamma_c)));
                    elseif st==HIV_st.EAD 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - year/cfg.gamma_a45 - year/cfg.gamma_c - randi(floor(1+year/cfg.gamma_ea)));
                    elseif st==HIV_st.LAD 
                        Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg.gamma_a1 - year/cfg.gamma_a23 - year/cfg.gamma_a45 - year/cfg.gamma_c - year/cfg.gamma_ea - randi(floor(1+year/cfg.mu_la)));
                    else % this individual should not be taken care off in this branch
                        myname = mfilename;
                        error([myname, 'Time of infection is assigned to someone who was diagnosed']);
                    end

                     if st==HIV_st.A1 | st==HIV_st.A1D | st==HIV_st.A1T
                        Gamma=gamma_a1D;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.A23 | st==HIV_st.A23D | st==HIV_st.A23T
                        Gamma=gamma_a23D;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.A45 | st==HIV_st.A45D | st==HIV_st.A45T
                        Gamma=gamma_a45D;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.C | st==HIV_st.CD | st==HIV_st.CT
                        Gamma=gamma_cD;
                        % sample from an Erlang distribution
                        mean_dur=1/Gamma;
                        dur=ceil(chronic_dur_sample(mean_dur,'erlang',80));
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                    elseif st==HIV_st.EA | st==HIV_st.EAD | st==HIV_st.EAT
                        Gamma=gamma_eaD;
                        % sample from an exponential distribution
                        r1 = rand;
                        dur=ceil(-log(1-r1)/Gamma);
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
                     elseif st==HIV_st.LA | st==HIV_st.LAD | st==HIV_st.LAT
                        Pop_hiv.Data(hiv_index.date_new_stage,ind)=cfg.T*year +10;
                    end
                end

               
            else
                ind_diagn = [];
            end

            % suppressed

            if n_suppr>0
                if numel(ind_select)>n_suppr
                    ind_sup = datasample(ind_select,n_suppr,'Replace',false);%ind_select(unidrnd(numel(ind_select),[1, n_suppr]));
                else
                    ind_sup = ind_select;
                end 
                new_suppr = ind_sup;
                ind_select = setdiff(ind_select, ind_sup);

                % set HIV status
                Pop_hiv.Data(hiv_index.status, ind_sup) = HIV_st.CS;
                Pop_hiv.Data(hiv_index.date_inf,ind_sup) = tcounter - 5;
                Pop_hiv.Data(hiv_index.date_diagn,ind_sup) = tcounter - 4;

                Pop_hiv.Data(hiv_index.date_art,ind_sup) = tcounter - 3;
                Pop_hiv.Data(hiv_index.date_sup,ind_sup) = tcounter - 2;
                Pop_hiv.Data(hiv_index.date_new_stage,ind_sup)=-40000;
                           
            else
                ind_sup = [];
            end


            % susceptible

            ind_susc = ind_select;

            if numel(ind_susc)>0
                Pop_hiv.Data(hiv_index.status,ind_susc)=0;
                Pop_hiv.Data(hiv_index.date_inf,ind_susc)=-40000;
                Pop_hiv.Data(hiv_index.date_diagn,ind_susc)=-40000;
                Pop_hiv.Data(hiv_index.date_art,ind_susc)=-40000;
                Pop_hiv.Data(hiv_index.date_sup,ind_susc)=-40000;
                Pop_hiv.Data(hiv_index.date_new_stage,ind_susc)=-40000;
            end

        end
    else
        ind_new_bracket = [];
    end
end