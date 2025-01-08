function [Pop_hiv,newly_sup,total_treat_ind]=get_suppressed(Pop_hiv,hiv_index,HIV_st,cfg,total_treat_ind,tcounter)
% individuals become suppressed
myname=mfilename;
year=365;

newly_sup=[];
if numel(total_treat_ind)>0
    
    for ind=total_treat_ind
        st=Pop_hiv.Data(hiv_index.status,ind);

        if st==HIV_st.A1T
            eta=cfg.eta_a1;
        elseif st==HIV_st.A23T
            eta=cfg.eta_a23;
        elseif st==HIV_st.A45T
            eta=cfg.eta_a45;
        elseif st==HIV_st.CT
            eta=cfg.eta_c;
        elseif st==HIV_st.EAT
            eta=cfg.eta_ea;
        elseif  st==HIV_st.LAT
            eta=cfg.eta_la;
        else
            error([myname,': someone who should not be suppressed is suppressed']);
        end
        
        % % alternative to the above, most of the time runs a tad faster
        % if st>=HIV_st.A1T && st<=HIV_st.LAT
        %     eta2 = cfg.eta_a1*(st==HIV_st.A1T)+cfg.eta_a23*(st==HIV_st.A23T)+cfg.eta_a45*(st==HIV_st.A45T)+cfg.eta_c*(st==HIV_st.CT)+cfg.eta_ea*(st==HIV_st.EAT)+cfg.eta_la*(st==HIV_st.LAT);
        % else
        %     error([myname,': someone who should not be suppressed is suppressed']);
        % end
   
        eta_d=eta/year;
        r1=rand;
        if r1<eta_d % got suppressed
            newly_sup=[newly_sup, ind];
            Pop_hiv.Data(hiv_index.date_sup,ind)=tcounter;
            if st==HIV_st.A1T
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A1S;
                Pop_hiv.Data(hiv_index.date_sup,ind) = tcounter;
            elseif st==HIV_st.A23T
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A23S;
                Pop_hiv.Data(hiv_index.date_sup,ind) = tcounter;
            elseif st==HIV_st.A45T
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A45S;
                Pop_hiv.Data(hiv_index.date_sup,ind) = tcounter;
            elseif st==HIV_st.CT
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.CS;
                Pop_hiv.Data(hiv_index.date_sup,ind) = tcounter;
            elseif st==HIV_st.EAT
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.EAS;
                Pop_hiv.Data(hiv_index.date_sup,ind) = tcounter;
            elseif  st==HIV_st.LAT
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.LAS;
                Pop_hiv.Data(hiv_index.date_sup,ind) = tcounter;
            else
                error([myname,': someone who should not be suppressed is suppressed']);
            end
        end
    end

    total_treat_ind=setdiff(total_treat_ind,newly_sup);
end
end