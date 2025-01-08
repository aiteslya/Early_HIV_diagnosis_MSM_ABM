function [num_unknown_parts,num_known_parts]=Distr_non_steady(data)
% function returns two arrays: the number of unknown
% non-steady partners acquired in the last 6 months and the
% number of known non-steady partners acquired in the last 6 months

% input: table data: organized using ACS schema

% note 1: the function assumes that LP01 entries contain either 0 or 1
    
    % create array which contains the number of known partners for each
    % record
    num_resp=size(data,1);
    num_known_parts=zeros(num_resp,1);
    % create array which contains the number of unknown partners for each
    % record
    num_unknown_parts=zeros(num_resp,1);

    % find indices of everyone who indicated they had non-steady partners
    % within the last 6 months
    ind=find(data.LP01~=0); % from this point we only working entries indicated in ind

    % count the number of unknown partners
    ind_un=find(data(ind,:).ALP01a>0);
    num_unknown_parts(ind(ind_un,:),:)=data(ind(ind_un,:),:).ALP01a;
    
    % count the number of known partners
    ind_k=find(data(ind,:).blp01a>0);
    num_known_parts(ind(ind_k,:),:)=data(ind(ind_k,:),:).blp01a;

    % check for the validity of the output
    assert(sum(isnan(num_known_parts))==0);
    assert(sum(isnan(num_unknown_parts))==0);

end