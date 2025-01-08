function [Population, Rels_steady]=create_steady(Population,pop_index,sigma,t_counter,Rels_steady,alive_ind,steady_dur_distr,age_attr,sero_attr,Pop_hiv,hiv_index,all_casual_parts)
% create new steady pairs (per day)

% determine how many pairs can be
% created - look for individuals who are alive and do not have a steady
% partner
num_pairs = floor(sum(Population.Data(pop_index.nsteady,alive_ind.Data)<1)/2);

year=365;% duration of the year in days
sigma_d=sigma/year;% convert from probability per year to probability per day

% non-dimensionalize the distribution of relationships durations
steady_dur_distr=steady_dur_distr/sum(steady_dur_distr);
cum_steady_dur_distr=cumsum(steady_dur_distr);
% determine how many of the couples form
for counter=1:1:num_pairs
    r1=rand;
    if r1<sigma_d % attempt to create a partnership
        s_fl=0;
        while ~s_fl
            [Population,s_fl,Rels_steady]=create_steady_pair(Population,pop_index,t_counter,Rels_steady,alive_ind,age_attr,sero_attr,Pop_hiv,hiv_index,all_casual_parts);
        end
        % assign the duration
        r2=rand;
        indices = 1:numel(cum_steady_dur_distr);
        j = min(indices(cum_steady_dur_distr > r2));

        Rels_steady.Data(end,3)=t_counter;
        Rels_steady.Data(end,4)=t_counter+j;% date of end duration + current time
    end
end
end