function [Pop_hiv, infect_alive, infect_source_data,infect_target_data, all_casual_parts, rec_casual_parts, new_rels_casual, newly_infect]=create_casual(Population,Pop_hiv,pop_index,tcounter,alive_ind,casual_dur_distr,age_attr,sero_attr,condom,burn_fl,infect_source_data,infect_target_data,infect_alive,hiv_index,cfg,HIV_st, all_casual_parts, rec_casual_parts)
                                                                                                                              
% initialize the container for newly infected
newly_infect = [];
% create new casual pairs (per day)
ind_avail = alive_ind.Data(find(Population.Data(pop_index.casual_prop,alive_ind.Data)>0));
% determine how many pairs can be created

num_pairs=numel(alive_ind.Data);

year=365;% duration of the year in days
sigma_d=cfg.sigma_cas/year;% convert from probability per year to probability per day

% non-dimensionalize the distribution of relationships durations
casual_dur_distr=casual_dur_distr/sum(casual_dur_distr);
cum_casual_dur_distr=cumsum(casual_dur_distr);

% determine how many of the couples form

r1_arr=rand(1,num_pairs);
num_pairs_real=sum(r1_arr<sigma_d);

% array to keep track of couples created in this step for whom the first
% sexual contact has already taken place
new_rels_casual = [];

[all_casual_parts, rec_casual_parts, list_ids] = create_casual_pair(Population,pop_index,tcounter,ind_avail,age_attr,sero_attr,Pop_hiv,hiv_index, cum_casual_dur_distr, all_casual_parts, rec_casual_parts,num_pairs_real);

if ~isempty(list_ids)
    new_rels_casual = [new_rels_casual; list_ids];

    if burn_fl % burn in is over simulate the infection
        % simulate infection
        n_pairs = size(list_ids,1);

        % select only pairs when one person is infected and can transmit
        % and the other is susceptible
        transmit_pairs = [];
        for counter_pairs = 1:n_pairs
            id1 = list_ids(counter_pairs,1);
            id2 = list_ids(counter_pairs,2);
            list_can_trans = [HIV_st.A1 HIV_st.A23 HIV_st.A45 HIV_st.C HIV_st.EA HIV_st.LA HIV_st.A1D HIV_st.A23D HIV_st.A45D HIV_st.CD HIV_st.EAD HIV_st.LAD HIV_st.A1T HIV_st.A23T HIV_st.A45T HIV_st.CT HIV_st.EAT HIV_st.LAT];
            ind1 = find(Pop_hiv.Data(hiv_index.id,:)==id1);
            ind2 = find(Pop_hiv.Data(hiv_index.id,:)==id2);

            cond1 = ismember(Pop_hiv.Data(hiv_index.status,ind1),list_can_trans) && (Pop_hiv.Data(hiv_index.status,ind2)==HIV_st.susc || Pop_hiv.Data(hiv_index.status,ind2)==HIV_st.suscPrep);
            cond2 = ismember(Pop_hiv.Data(hiv_index.status,ind2),list_can_trans) && (Pop_hiv.Data(hiv_index.status,ind1)==HIV_st.susc || Pop_hiv.Data(hiv_index.status,ind1)==HIV_st.suscPrep);
            if cond1 || cond2
                transmit_pairs = [transmit_pairs; sort([id1 id2])];
            end
        end
        
        if height(transmit_pairs)>0 & cfg.fl
            for counter_pairs = 1:height(transmit_pairs)
                id1 = transmit_pairs(counter_pairs,1);
                id2 = transmit_pairs(counter_pairs,2);
                [Pop_hiv,infect_alive,infect_source_data,infect_target_data, newly_infect] = infect_new_casual(Population,Pop_hiv,pop_index,hiv_index,cfg,infect_alive,tcounter,HIV_st,id1,id2,condom,infect_source_data,infect_target_data, newly_infect);
            end
            % infect_alive.Data=[infect_alive.Data, newly_infect];
        end
    end
else
    warning('Create_casual: could not create a single pair');
end

end