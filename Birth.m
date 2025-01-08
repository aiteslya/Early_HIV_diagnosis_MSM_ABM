
function [Population,Pop_hiv,Id_counter,alive_ind,ind_new_bracket]=Birth(Population,Pop_hiv,fl_collect,pop_index,hiv_index,lambda_d,tcounter,Id_counter,alive_ind)
% insert new individuals which are born according to poisson process with
% average lambda_d per day
% set their age to 15 years, set their date of birth 

    num_born=poissrnd(lambda_d);
    if num_born>0
        % find the first available num_born slates (accounting for
        % possibility new individuals may take place of individuals who
        % already left the populaiton
        ind=find(Population.Data(pop_index.id,:)==0,num_born);
        Population.Data(pop_index.age,ind)=15;
        Population.Data(pop_index.birth,ind)=(tcounter-mod(tcounter,365))/365-15; % tcounter is in days, needs to converted to years
        Population.Data(pop_index.age_bin,ind)=1;
        new_ids=Id_counter:1:(Id_counter+num_born-1);
        Id_counter=Id_counter+num_born;
        Population.Data(pop_index.id,ind)=new_ids;
        Population.Data(pop_index.death,ind)=-1;
        Population.Data(pop_index.sp1_id,ind)=-1;
        Population.Data(pop_index.sp1_stdate,ind)=-40000;
        Population.Data(pop_index.nsteady,ind)=0;
        % list new individuals as having to sample propensity to acquire
        % casual partners
        ind_new_bracket=ind;
        
        alive_ind.Data=[alive_ind.Data, ind];
        %add hiv table record
        Pop_hiv.Data(hiv_index.id,ind)=new_ids;
        Pop_hiv.Data(hiv_index.status,ind)=0;
        Pop_hiv.Data(hiv_index.date_inf,ind)=-40000;
        Pop_hiv.Data(hiv_index.date_diagn,ind)=-40000;
        Pop_hiv.Data(hiv_index.date_art,ind)=-40000;
        Pop_hiv.Data(hiv_index.date_sup,ind)=-40000;
        Pop_hiv.Data(hiv_index.date_new_stage,ind)=-40000;
    else
        ind_new_bracket = [];
    end
end