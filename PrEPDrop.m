function [Pop_hiv]=PrEPDrop(Pop_hiv,hiv_index,HIV_st,alive_ind,infect_alive,cfg)
    % this function simulates enrollment of susceptible individuals into
    % PrEP programme
    year=365;% duration of day in years
    pre_drop_d=cfg.prep_drop/year; % convert probability per year into probability per day

    % find indices of these who are susceptible among these who are alive
    ind_non_infect=setdiff(alive_ind.Data,infect_alive.Data);
    % among non_infected individuals find these who use PrEP
    ind=ind_non_infect(find(Pop_hiv.Data(hiv_index.status,ind_non_infect)==HIV_st.suscPrep));
    if numel(ind)>0
        for counter=1:1:numel(ind)
            r1=rand;
            if r1<pre_drop_d
                Pop_hiv.Data(hiv_index.status,ind(counter))=HIV_st.susc;
            end
        end
    end
end