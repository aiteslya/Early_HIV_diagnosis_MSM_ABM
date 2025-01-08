function [Pop_hiv,inds_not_diagn,inds_not_treat,inds_not_sup,inds_sup]=seed_infection(Population,Pop_hiv,pop_index,hiv_index,alive_ind,cfg, HIV_st, tcounter,cfg_main, rec_casual_parts)
    % this script initiates infections in various stages of epidemiological
    % progress and uptake of treatments such as ART and PrEP

    % updates: dat eof infection is now seeded depending on the stage 
    % stage of infection is seeded weighted by stages duration

    year = 365;
    % define mean sojourn times
    gamma_a1D=cfg_main.gamma_a1/year;
    gamma_a23D=cfg_main.gamma_a23/year;
    gamma_a45D=cfg_main.gamma_a45/year;
    gamma_cD=cfg_main.gamma_c/year;
    gamma_eaD=cfg_main.gamma_ea/year;

    % seeding weights
    init_infect_seed_weight = [1/cfg_main.gamma_a1 1/cfg_main.gamma_a23 1/cfg_main.gamma_a45 1/cfg_main.gamma_c 1/cfg_main.gamma_ea 1/cfg_main.mu_la];
    % normalization of weights
    init_infect_seed_weight = init_infect_seed_weight./sum(init_infect_seed_weight);

    % calculate absolute number of individuls in each infection and
    % treatment stage
    N=numel(alive_ind.Data);
    N_prep=floor(N*cfg.prep_prop_init);
    % randomize number of infected
    n_infect=floor(N*(cfg.tot_infect_prop_init_min+rand*(cfg.tot_infect_prop_init_max-cfg.tot_infect_prop_init_min)));

    N_tot_infect=n_infect;
    N_infect_diagn=floor(N_tot_infect*cfg.prop_diagn_init);
    N_infect_undiagn=N_tot_infect-N_infect_diagn;
    N_diagn_treat=floor(N_infect_diagn*cfg.prop_treat_init);
    N_diagn_untreat=N_infect_diagn-N_diagn_treat;
    N_treat_sup=floor(N_diagn_treat*cfg.prop_sup_init);
    N_treat_unsup=N_diagn_treat-N_treat_sup;

    % seed the initial number of infected
    inds = alive_ind.Data(datasample(1:numel(alive_ind.Data), N_tot_infect, 'Replace', false));

    ind_susc=setdiff(alive_ind.Data,inds);

    % seed PrEP
    % analyse Rels_casual_hist to see number of partners for the remaining
    % individuals

    if N_prep>0

        num_parts=zeros(2,numel(ind_susc));
        num_parts(1,:)=ind_susc;
        
        counter =1 ;
        for ind=ind_susc
            id=Population.Data(pop_index.id,ind);
            
            if isKey(rec_casual_parts,id)
                num_parts(2,counter) = numel(rec_casual_parts(id));
            else
                num_parts(2,counter) = 0;
            end
            counter = counter+1;
        end
    
        [~,ind_prep]=maxk(num_parts(2,:),N_prep);
        Pop_hiv.Data(hiv_index.status,ind_prep)=HIV_st.suscPrep;
    end

    % select individuals who are infected but not diagnosed
    inds_not_diagn=datasample(inds,N_infect_undiagn,'Replace',false);
    % individuals who are infected and diagnosed
    inds_diagn=setdiff(inds,inds_not_diagn);
    % distribute infected individuals by compartments
    % code for HIV status 1: A1, 2:A23, 3:A45, 4:C, 5:EA, 6:LA
    inf_stat_not_diagn=randsample(1:6,numel(inds_not_diagn),true, init_infect_seed_weight);
    Pop_hiv.Data(hiv_index.status,inds_not_diagn)=inf_stat_not_diagn;

    for ind=inds_not_diagn
        % retrieve HIV status
        st = Pop_hiv.Data(hiv_index.status,ind);
        if st==HIV_st.A1 
            Pop_hiv.Data(hiv_index.date_inf,ind) = tcounter-1; % note that -4 in each branch is added so that people do not get infected or diagnosed in this step
        elseif st==HIV_st.A23 
            Pop_hiv.Data(hiv_index.date_inf,ind) = floor(tcounter - year/cfg_main.gamma_a1 - randi(floor(1+year/cfg_main.gamma_a23))); 
        elseif st==HIV_st.A45 
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - randi(floor(1+year/cfg_main.gamma_a45)));
        elseif st==HIV_st.C 
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - randi(floor(1+year/cfg_main.gamma_c)));
        elseif st==HIV_st.EA 
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - year/cfg_main.gamma_c - randi(floor(1+year/cfg_main.gamma_ea)));
        elseif st==HIV_st.LA 
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - year/cfg_main.gamma_c - year/cfg_main.gamma_ea - randi(floor(1+year/cfg_main.mu_la)));
        else % this individual should not be taken care off in this branch
            myname = mfilename;
            error([myname, 'Time of infection is assigned to someone who was diagnosed']);
        end
    end

    % select individuals who are diagnosed but have not started the
    % treatment yet
    inds_not_treat=datasample(inds_diagn,N_diagn_untreat,'replace',false);
    % assign indices of these who are diagnosed and treated
    inds_treat=setdiff(inds_diagn,inds_not_treat);
    % distribute infected individuals by compartments
    % code for HIV status 8: A1, 9:A23, 10:A45, 11:C, 12:EA, 13:LA
    inf_stat_not_treat=randsample(8:13,numel(inds_not_treat),true, init_infect_seed_weight);
    Pop_hiv.Data(hiv_index.status,inds_not_treat)= inf_stat_not_treat;

    for ind=inds_not_treat
        % retrieve HIV status
        st = Pop_hiv.Data(hiv_index.status,ind);
        if st==HIV_st.A1D
            Pop_hiv.Data(hiv_index.date_inf,ind) = tcounter-2;
        elseif st==HIV_st.A23D
            Pop_hiv.Data(hiv_index.date_inf,ind) = floor(tcounter - year/cfg_main.gamma_a1 - randi(floor(1+year/cfg_main.gamma_a23)));
        elseif st==HIV_st.A45D
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - randi(floor(1+year/cfg_main.gamma_a45)));
        elseif st==HIV_st.CD
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - randi(floor(1+year/cfg_main.gamma_c)));
        elseif st==HIV_st.EAD
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - year/cfg_main.gamma_c - randi(floor(1+year/cfg_main.gamma_ea)));
        elseif st==HIV_st.LAD
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - year/cfg_main.gamma_c - year/cfg_main.gamma_ea - randi(floor(1+year/cfg_main.mu_la)));
        else % this individual should not be taken care off in this branch
            myname = mfilename;
            error([myname, 'Time of infection is assigned to someone who was treated or undiagnosed']);
        end
    end
    
    % assign the time of diagnosis
    Pop_hiv.Data(hiv_index.date_diagn,inds_not_treat) = tcounter-1;
   
    % select individuals who are in treatment but are not suppressed yet
    inds_not_sup=datasample(inds_treat,N_treat_unsup,'replace',false);
    % distribute infected individuals by compartents
    % code for HIV status 14: A1, 15:A23, 16:A45, 17:C, 18:EA, 19:LA
    inf_stat_not_sup=randsample(14:19,numel(inds_not_sup),true, init_infect_seed_weight);
    Pop_hiv.Data(hiv_index.status,inds_not_sup)= inf_stat_not_sup;

    for ind=inds_not_sup
        % retrieve HIV status
        st = Pop_hiv.Data(hiv_index.status,ind);
        if st==HIV_st.A1T
            Pop_hiv.Data(hiv_index.date_inf,ind) = tcounter-3;
        elseif st==HIV_st.A23T
            Pop_hiv.Data(hiv_index.date_inf,ind) = floor(tcounter - year/cfg_main.gamma_a1 - randi(floor(1+year/cfg_main.gamma_a23)));
        elseif st==HIV_st.A45T
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - randi(floor(1+year/cfg_main.gamma_a45)));
        elseif st==HIV_st.CT
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - randi(floor(1+year/cfg_main.gamma_c)));
        elseif st==HIV_st.EAT
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - year/cfg_main.gamma_c - randi(floor(1+year/cfg_main.gamma_ea)));
        elseif st==HIV_st.LAT
            Pop_hiv.Data(hiv_index.date_inf, ind) = floor(tcounter - year/cfg_main.gamma_a1 - year/cfg_main.gamma_a23 - year/cfg_main.gamma_a45 - year/cfg_main.gamma_c - year/cfg_main.gamma_ea - randi(floor(1+year/cfg_main.mu_la)));
        else % this individual should not be taken care off in this branch
            myname = mfilename;
            error([myname, 'Time of infection is assigned to someone who was only diagnosed or undiagnosed']);
        end

    end

    % depending on the status, assign the time of diagnosis
    Pop_hiv.Data(hiv_index.date_diagn,inds_not_sup) = tcounter - 2;
    % depending on the status, assign the time of starting the treatment
    Pop_hiv.Data(hiv_index.date_art, inds_not_sup) = tcounter - 1;

    % individuals who are suppressed
    inds_sup=setdiff(inds_treat,inds_not_sup);
    % distribute infected individuals by compartents
    % code for HIV status 20: A1, 21:A23, 22:A45, 23:C, 24:EA, 25:LA
    % everyone is in the chronic stage
    Pop_hiv.Data(hiv_index.status,inds_sup)= 23;

    % updated old code
    Pop_hiv.Data(hiv_index.date_inf, inds_sup) = floor(tcounter - 1 - year/cfg_main.upsilon_c - year/cfg_main.theta_a1 - year/cfg_main.eta_a1);
    Pop_hiv.Data(hiv_index.date_diagn, inds_sup) = floor(tcounter - 1 - year/cfg_main.upsilon_c);
    Pop_hiv.Data(hiv_index.date_art, inds_sup) = floor(tcounter - 1 - year/cfg_main.upsilon_c - year/cfg_main.theta_a1);
    Pop_hiv.Data(hiv_index.date_sup, inds_sup) = floor(tcounter - 1);

    % assign time when the next infection stage will take place
    % do this only for unsuppressed individuals
    % go over all infected individuals
    for ind = inds 
        st=Pop_hiv.Data(hiv_index.status,ind);
        if ismember(st,[HIV_st.A1,HIV_st.A23,HIV_st.A45,HIV_st.C,HIV_st.EA,HIV_st.LA,HIV_st.A1D,HIV_st.A23D,HIV_st.A45D,HIV_st.CD,HIV_st.EAD,HIV_st.LAD,HIV_st.A1T,HIV_st.A23T,HIV_st.A45T,HIV_st.CT,HIV_st.EAT,HIV_st.LAT])
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
                Pop_hiv.Data(hiv_index.date_new_stage,ind)=cfg_main.T*year +10;
            end
       end
    end
end