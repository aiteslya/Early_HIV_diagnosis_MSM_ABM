function st=ACS_steady_cur(data)
%ACS_steady_cur analyses data set who schema follows that of the ACS data set and
%returns how many individuals indicated that they have a steady partner
%(st(1,2)) and how many individuals indicated that they do not have a
%steady parner (st(1,1))

    st=zeros(1,2);
    % remove form the data these who did not reply to question CORE VP01 
    % Heeft u in de afgelopen 6 maanden (een) vaste relatie(s) gehad met 
    % een man? CORE VP01

    ind=find(isnan(data.vp01));
    data(ind,:)=[];

    % are you currently in a relationship
    no_sum=0;
    yes_sum=0;

    vp01_no_ind=find(data.vp01==0);
    vp01_no_num=numel(vp01_no_ind);
    no_sum=no_sum+vp01_no_num;

    % remove these who had no steady partner within the last 6 months, they
    % will not come up again (and also been counted)
    data(vp01_no_ind,:)=[];

    % proceed to vp03 Is/was dit dezelfde partner als bij de vorige vragenlijst? VP03
    % validate the data
    % see if anyone who could respond to this question did not respond
    ind_vp03_miss=find(isnan(data.vp03));
    if numel(ind_vp03_miss)>0 % someone who should have filled out vp03 did not do so
        disp(['Problem with vp03. ',num2str(numel(ind_vp03_miss)),' records are invalid.']);
        data(ind_vp03_miss,:)=[];
    end

    num_vp03=size(data,1);% number of records with vp03 responded to 
    ind_vp03_yes=find(data.vp03==1);
    ind_vp03_no=setdiff((1:1:num_vp03)',ind_vp03_yes);

    % investigate these who said no, they proceeded to vp02
    data_vp03_no=data(ind_vp03_no,:);

    % find these who said no
    ind_vp02_no=find(data_vp03_no.vp02==0);
    no_sum=no_sum+numel(ind_vp02_no);
    % find these who said yes
    ind_vp02_yes=find(data_vp03_no.vp02==1);
    yes_sum=yes_sum+numel(ind_vp02_yes);
    
    % investigate these who said yes to vp03
    data_vp03_yes=data(ind_vp03_yes,:);
    
    % proceed to question vp03a
    % find these records that should have a response to it, but do not
    ind_vp03a_miss=find(isnan(data_vp03_yes.vp03a));
    if numel(ind_vp03a_miss)>0
        disp(['Problem with vp03a. ',num2str(numel(ind_vp03a_miss)),' records are invalid.']);
        data_vp03_yes(ind_vp03a_miss,:)=[];
    end
    
    % find these who said no
    ind_vp03a_no=find(data_vp03_yes.vp03a==0);
    no_sum=no_sum+numel(ind_vp03a_no);
    % find these who said yes
    ind_vp03a_yes=find(data_vp03_yes.vp03a==1);
    yes_sum=yes_sum+numel(ind_vp03a_yes);

    st(1,1)=no_sum;
    st(1,2)=yes_sum;
end