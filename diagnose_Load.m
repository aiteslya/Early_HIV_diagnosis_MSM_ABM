function [Pop_hiv, newly_diagn,prop_diagn_AHI,new_total_diagn_ind,new_AHI_diagn_ind]=diagnose_Load(Pop_hiv,hiv_index,HIV_st,cfg,infect_old,prop_diagn_AHI,tcounter,cfg_screen,new_total_diagn_ind,new_AHI_diagn_ind)

% diagnosis, but not people who were just infected on the same day

    myname=mfilename;
    year=365;
    newly_diagn=[];% list of indices who was just newly diagnosed

    if isequal(cfg_screen.type, 'max')
        upsilon_ahi1 = year;
        upsilon_ahi23 = year;
        upsilon_ahi45 = year;
        upsilon_ahi_c_6m = year;
        upsilon_ahi_c_12m = cfg.upsilon_12mon;
    elseif isequal(cfg_screen.type, 'max_12m')    
        upsilon_ahi1 = year;
        upsilon_ahi23 = year;
        upsilon_ahi45 = year;
        upsilon_ahi_c_6m = year;
        upsilon_ahi_c_12m = year;
    elseif isequal(cfg_screen.type, 'base')
        upsilon_ahi1 = cfg.upsilon_a1;
        upsilon_ahi23 = cfg.upsilon_a23;
        upsilon_ahi45 = cfg.upsilon_a45;
        upsilon_ahi_c_6m = cfg.upsilon_6mon;
        upsilon_ahi_c_12m = cfg.upsilon_12mon;
    elseif isequal(cfg_screen.type(1:4),'mult')
        upsilon_ahi1 = cfg_screen.upsilon_ahi1*cfg.upsilon_a1;
        upsilon_ahi23 = cfg_screen.upsilon_ahi23*cfg.upsilon_a23;
        upsilon_ahi45 = cfg_screen.upsilon_ahi45*cfg.upsilon_a45;
        upsilon_ahi_c_6m = cfg_screen.upsilon_ahi_c_6m*cfg.upsilon_6mon;
        upsilon_ahi_c_12m = cfg_screen.upsilon_ahi_c_12m*cfg.upsilon_12mon;
    else
        error([myname, ': type of screening is invalid at time = ', num2str(tcounter)]);
    end

    for ind=infect_old

        st = Pop_hiv.Data(hiv_index.status,ind);
        date_inf = Pop_hiv.Data(hiv_index.date_inf,ind);
        
        if st == HIV_st.A1
            upsilon = upsilon_ahi1;
        elseif st == HIV_st.A23
            upsilon = upsilon_ahi23;
        elseif st == HIV_st.A45
            upsilon = upsilon_ahi45;
        elseif st == HIV_st.C & (tcounter-date_inf)<=ceil(year/2)
            upsilon = upsilon_ahi_c_6m;
        elseif st == HIV_st.C & (tcounter-date_inf)<= year
            upsilon = upsilon_ahi_c_12m;
        elseif st == HIV_st.C
            upsilon = cfg.upsilon_c;
        elseif st == HIV_st.EA
            upsilon = cfg.upsilon_ea;
        elseif  st == HIV_st.LA
            upsilon = cfg.upsilon_la;
        else
            error([myname, ': trying to diagnose someone who cannot get diagnosed'])
        end

        upsilon_d=upsilon/year;
        r1=rand;
        if r1<upsilon_d % got diagnosed
            % total tally of diagnosed individuals during the simulation
            new_total_diagn_ind=[new_total_diagn_ind,ind];
            % diagnosed in this step
            newly_diagn=[newly_diagn, ind];
            Pop_hiv.Data(hiv_index.date_diagn,ind)=tcounter;
            if st==HIV_st.A1 
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A1D;
                
                if r1>cfg.upsilon_a1/year % AHI trajectory  
                    new_AHI_diagn_ind=[new_AHI_diagn_ind, ind];
                    prop_diagn_AHI=prop_diagn_AHI+1;
                    Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A1T;
                end
            elseif st==HIV_st.A23
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A23D;
                if r1>cfg.upsilon_a23/year % AHI trajectory
                    new_AHI_diagn_ind=[new_AHI_diagn_ind, ind ];
                    prop_diagn_AHI=prop_diagn_AHI+1;   
                    Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A23T;
                end
            elseif st==HIV_st.A45
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A45D;
                if r1>cfg.upsilon_a45/year % AHI trajectory
                    new_AHI_diagn_ind=[new_AHI_diagn_ind, ind];
                    prop_diagn_AHI=prop_diagn_AHI+1;
                    Pop_hiv.Data(hiv_index.status,ind)=HIV_st.A45T;
                end
            elseif st==HIV_st.C
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.CD;

                if (tcounter-date_inf)<=ceil(year/2)
                    if r1 > cfg.upsilon_6mon/year
                        new_AHI_diagn_ind=[new_AHI_diagn_ind, ind];
                        prop_diagn_AHI=prop_diagn_AHI+1;
                        Pop_hiv.Data(hiv_index.status,ind)=HIV_st.CT;
                    end
                elseif (tcounter-date_inf)<= year
                    if r1 > cfg.upsilon_12mon/year
                        new_AHI_diagn_ind=[new_AHI_diagn_ind, ind];
                        prop_diagn_AHI=prop_diagn_AHI+1;
                        Pop_hiv.Data(hiv_index.status,ind)=HIV_st.CT;
                    end
                end
            elseif st==HIV_st.EA
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.EAD;
            elseif  st==HIV_st.LA
                Pop_hiv.Data(hiv_index.status,ind)=HIV_st.LAD;
            else
                error([myname,': someone who should not be diagnosed is diagnosed']);
            end
        end
    end
end