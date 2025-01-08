function [Pop_hiv]=Infection_Advance(Pop_hiv,hiv_index,cfg,infect_alive,HIV_st,tcounter)
% this function goes over all individuals who are infected and determines whether they advance to the next stage

% convert probabilities from per year to per day
year=365; % duration of a year in days
gamma_a23D=cfg.gamma_a23/year;
gamma_a45D=cfg.gamma_a45/year;
gamma_cD=cfg.gamma_c/year;
gamma_eaD=cfg.gamma_ea/year;

for ind=infect_alive.Data
    st=Pop_hiv.Data(hiv_index.status,ind);
    if ismember(st,[HIV_st.A1,HIV_st.A23,HIV_st.A45,HIV_st.C,HIV_st.EA,HIV_st.A1D,HIV_st.A23D,HIV_st.A45D,HIV_st.CD,HIV_st.EAD,HIV_st.A1T,HIV_st.A23T,HIV_st.A45T,HIV_st.CT,HIV_st.EAT])
        % new version, where durations of infections were sampled from distributions  
        if Pop_hiv.Data(hiv_index.date_new_stage,ind)==tcounter % time to move to the next stage and sample the duration of that stage
            if st==HIV_st.A1 | st==HIV_st.A1D | st==HIV_st.A1T
                Gamma=gamma_a23D;
                % update status
                Pop_hiv.Data(hiv_index.status,ind)=Pop_hiv.Data(hiv_index.status,ind)+1;
                % sample form the exponential distribution
                dur=ceil(-log(1-rand)/Gamma);
                Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
            elseif st==HIV_st.A23 | st==HIV_st.A23D | st==HIV_st.A23T
                Gamma=gamma_a45D;
                % update status
                Pop_hiv.Data(hiv_index.status,ind)=Pop_hiv.Data(hiv_index.status,ind)+1;
                % sample form the exponential distribution
                dur=ceil(-log(1-rand)/Gamma);
                Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
            elseif st==HIV_st.A45 | st==HIV_st.A45D | st==HIV_st.A45T
                Gamma=gamma_cD;
                mean_dur=1/Gamma;
                dur=ceil(chronic_dur_sample(mean_dur,'erlang',80));
                % update status
                Pop_hiv.Data(hiv_index.status,ind)=Pop_hiv.Data(hiv_index.status,ind)+1;
                Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
            elseif st==HIV_st.C | st==HIV_st.CD | st==HIV_st.CT
                Gamma=gamma_eaD;
                % update status
                Pop_hiv.Data(hiv_index.status,ind)=Pop_hiv.Data(hiv_index.status,ind)+1;
                % sample form the exponential distribution
                dur=ceil(-log(1-rand)/Gamma);
                Pop_hiv.Data(hiv_index.date_new_stage,ind)=tcounter+dur;
             elseif st==HIV_st.EA | st==HIV_st.EAD | st==HIV_st.EAT
                % update status
                Pop_hiv.Data(hiv_index.status,ind)=Pop_hiv.Data(hiv_index.status,ind)+1;
                Pop_hiv.Data(hiv_index.date_new_stage,ind)=cfg.T*year +10;
            end
        end     
    end
end

end