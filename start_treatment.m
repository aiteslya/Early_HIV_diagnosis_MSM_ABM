function [Pop_hiv,newly_treat,total_diagn_ind]=start_treatment(Pop_hiv,hiv_index,HIV_st,cfg,total_diagn_ind,tcounter)
% start treatment
    newly_treat=[];
    year=365;

    if any(Pop_hiv.Data(hiv_index.status,total_diagn_ind)<HIV_st.A1D | Pop_hiv.Data(hiv_index.status,total_diagn_ind)>HIV_st.LAD)
        error([myname,': someone who should not be treated is treated']);
    end

    for ind=total_diagn_ind
        st=Pop_hiv.Data(hiv_index.status,ind);
        if st==HIV_st.A1D
            theta=cfg.theta_a1;
        elseif st==HIV_st.A23D
            theta=cfg.theta_a23;
        elseif st==HIV_st.A45D
            theta=cfg.theta_a45;
        elseif st==HIV_st.CD
            theta=cfg.theta_c;
        elseif st==HIV_st.EAD
            theta=cfg.theta_ea;
        elseif  st==HIV_st.LAD
            theta=cfg.theta_la;
        end
        
        r1=rand;
        theta_d=theta/year;

        if r1<theta_d % started treatment
            newly_treat=[newly_treat, ind];
            Pop_hiv.Data(hiv_index.date_art,ind)=tcounter;
            if st==HIV_st.A1D
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A1T;
            elseif st==HIV_st.A23D
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A23T;
            elseif st==HIV_st.A45D
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A45T;
            elseif st==HIV_st.CD
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.CT;
            elseif st==HIV_st.EAD
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.EAT;
            elseif  st==HIV_st.LAD
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.LAT;
            else
                error([myname,': someone who should not be treated is treated']);
            end
        end
    end
    
    total_diagn_ind=setdiff(total_diagn_ind,newly_treat);
        
end
