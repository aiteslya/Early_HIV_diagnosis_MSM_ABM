function [Pop_hiv]=PrEPUptake(Population,Pop_hiv,hiv_index,HIV_st,alive_ind,infect_alive,cfg,prep_uptake,pop_index, rec_casual_parts)
    % this function simulates enrollment of susceptible individuals into
    % PrEP programme

    
    % Create a logical array indicating whether each element of alive_ind.Data is in infect_alive.Data
    isInfected = ismember(alive_ind.Data, infect_alive.Data);

    % Select elements from alive_ind.Data that are not in infect_alive.Data
    ind_non_infect = alive_ind.Data(~isInfected);

    % Direct logical indexing to find indices where the condition is true
    ind = ind_non_infect(Pop_hiv.Data(hiv_index.status, ind_non_infect) == HIV_st.susc);

    if numel(ind)>0
        year=365;
        prep_up_d=cfg.prep_up/year;
        % determine how many people will take up PrEP
        num_new=sum(rand(1,numel(ind))<prep_up_d);
        if num_new>0
            % determine who will take PrEP
            % schema: ind_s, age
            eligible=[];

            counter=1;
            while counter<=numel(ind) & floor(numel(eligible)/2)<num_new
                
                % determine whether this person is eligible by accessing
                % their number of partners within  the last year
                id=Population.Data(pop_index.id,ind(counter));

                num_casual_parts=numel(retrievePartners(rec_casual_parts,id));

                if num_casual_parts>=cfg.prep_thresh % number of casual partners exceeds rate
                    % get age to seed the probability of taking prep
                    age_bin=Population.Data(pop_index.age_bin,ind(counter));
                    pre_up_d=prep_uptake(age_bin);
                    eligible=[eligible;ind(counter) pre_up_d];
                end
                counter=counter+1;
            end

            if floor(numel(eligible)/2)>0 
                
                if numel(eligible(:,1))>num_new
                    ind_pr = zeros(1, num_samples);
                    weights = eligible(:,2);
                    for sample_counter = 1:num_samples
                        % Normalize weights
                        normalized_weights = weights / sum(weights);
                        
                        % Sample one index based on normalized weights
                        sample = randsample(indices, 1, true, normalized_weights);
                        
                        % Store the sampled index
                        ind_pr(sample_counter) = sample;
                        
                        % Set the weight of the sampled index to zero to simulate "without replacement"
                        weights(indices == sample) = 0;
                    end

                    %ind_pr = randsample(eligible(:,1),num_new,false,eligible(:,2)./(sum(eligible(:,2))));
                else
                    ind_pr = eligible(:,1);
                end
                
                Pop_hiv.Data(hiv_index.status,ind_pr)=HIV_st.suscPrep;
            end
        end
    end

end