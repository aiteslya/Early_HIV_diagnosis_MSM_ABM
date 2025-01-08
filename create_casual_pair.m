function [all_casual_parts,rec_casual_parts, list_ids]=create_casual_pair(Population,pop_index,tcounter,ind_avail,age_attr,sero_attr,Pop_hiv,hiv_index, cum_casual_dur_distr,  all_casual_parts, rec_casual_parts, num_pairs)

list_ids = [];

age_edge=15:10:75;
age_bins=1:1:(numel(age_edge)-1);
hiv_st_bins=1:2;

a_ind = ind_avail;
% cache population as a local variable
pop = Population.Data(:,a_ind);
pop_hiv = Pop_hiv.Data(:,a_ind);

% delineate individuals into bins
% infection
% retrieve HIV status of each available person
HIV_st = pop_hiv(hiv_index.status,:);
indices = 1:numel(a_ind);
ind_susc = indices(HIV_st>=0 & HIV_st<=7);
ind_infect = setdiff(indices,ind_susc);

% divide each infected compartment into age groups
for bin_counter=1:numel(age_bins)
    ind_susc_age{bin_counter,:} = ind_susc(pop(pop_index.age_bin,ind_susc)==bin_counter);
    ind_infect_age{bin_counter,:} = ind_infect(pop(pop_index.age_bin,ind_infect)==bin_counter);
end

% select the first partners in each pair

ind1_arr=randsample(indices,num_pairs,true,pop(pop_index.casual_prop, :)/sum(pop(pop_index.casual_prop, :)));

for ind1 = ind1_arr

    % determine HIV status and therefore preference
    st_ind1 = pop_hiv(hiv_index.status,ind1);

    if st_ind1>=0 && st_ind1<=7 % HIV-negative or perceive themselves as such
        pref_sero_distr=sero_attr(:,1);
    else % HIV-positive
        pref_sero_distr=sero_attr(:,2);
    end
    
    % determine age bin and therefore preference
    bin_age1=pop(pop_index.age_bin,ind1);
    
    % access respective age mixing column
    
    pref_distr=age_attr(:,bin_age1);
    
    % determine the age group of the partner
    
    bin_age2 = sample_from_distribution(pref_distr);

    % determine the status of the partner
    
    hiv_st2 = sample_from_distribution(pref_sero_distr);

    if hiv_st2 ==1
        pop_p2_ind = ind_susc_age{bin_age2,:};
    elseif hiv_st2 ==2
        if numel(ind_infect_age{bin_age2,:})>0 % there are infected individuals in the desired age bin
            pop_p2_ind = ind_infect_age{bin_age2,:};
        else % there are no infected individuals, a partner will be selected from susceptible individuals
            pop_p2_ind = ind_susc_age{bin_age2,:};
        end
    else
        error('create_casual_pair: selected invalid HIV status');
    end
    
    % collect propensities of these individuals
    casual_prop=pop(pop_index.casual_prop, pop_p2_ind);
    % normalize the propensities into a distribution
    if sum(casual_prop)>0
        casual_prop=casual_prop/sum(casual_prop);
        if numel(pop_p2_ind)>1
            % r2 = rand;
            % cs = cumsum(casual_prop);
            % indices=1:numel(pop_p2_ind);
            % ind2 = pop_p2_ind(min(indices(cs >= r2)));
            ind2 = pop_p2_ind(sample_from_distribution(casual_prop));
        else
            ind2=pop_p2_ind;
        end
    
        if (ind1~=ind2) % we have not selected the same person 
        
            % retrieve ids of the two individuals
            id1=pop(pop_index.id,ind1);
            id2=pop(pop_index.id,ind2);
            % find steady partners of id1
            sp_id1=pop(pop_index.sp1_id,ind1);
        
            if isKey(rec_casual_parts,id1)
                num_parts_1 = numel(rec_casual_parts(id1));
            else
                num_parts_1 = 0;
            end
            if isKey(rec_casual_parts,id2)
                num_parts_2 = numel(rec_casual_parts(id2));
            else
                num_parts_2 = 0;
            end
        
            if id2~=sp_id1 & num_parts_1<100 & num_parts_2<100 % individual with id=id2 is not a steady partner of individual with id=id1
        
                start_date = tcounter;
        
                r1=rand;
                indices = 1:numel(cum_casual_dur_distr);
                j = min(indices(cum_casual_dur_distr >= r1));

                end_date = tcounter+ j;
                
                [all_casual_parts,s_fl] = addPartnership(all_casual_parts, id1, id2, start_date, end_date);
                
                if s_fl
                    rec_casual_parts = addPartnershipPast(rec_casual_parts, id1, id2, start_date, end_date);
                    list_ids = [ list_ids; sort([id1 id2])];
                % else % debug
                %     disp('create_casual_pair: could not insert the new pair into the register, as it already existsts')
                end
            % else % debug
            %     disp('create_casual_pair: could not create a pair, could be already steady partners, or the maximum number of partners is exceeded')
            end
        end

    % else % debug
    %     disp('create_casual_pair: No available people to form a casual partnership at this instance');
        % return;
    end

end

end