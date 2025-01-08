% this script is a playground for hash maps encapsulation of casual
% partnerships
% prepare state space
close all;
clear variables;
clc;

% define the container

all_partnerships = containers.Map('KeyType', 'double', 'ValueType', 'any');
recent_partnerships = containers.Map('KeyType', 'double', 'ValueType', 'any');

N=100;
n_rels = 100;
Pop=1:N;

rng(1);

% create 20 partnerships
tcounter=0;
for rels_counter=1:n_rels
    % pick two random individuals
    ids=randsample(Pop,2,true);

    start_date = tcounter;
    
    % check partnerships of id1
    if ~partnershipExists(all_partnerships, ids(1), ids(2))
        end_date = 2;
        all_partnerships = addPartnership(all_partnerships, ids(1), ids(2), start_date, end_date);
    end
end

% simulate break up because the time ran out
current_keys = keys(all_partnerships);
keysToRemove = [];

for k = 1:length(current_keys)
    currentKey = current_keys{k};
        
    updated_partnerships = [];
        
    for p = all_partnerships(currentKey)
        if p.end_date ~= 2
            updated_partnerships = [updated_partnerships, p];
        else
            % If partnership is removed, calculate its duration and add to the durations array
            partnership_duration = p.end_date - p.start_date;
        end
    end
    
    if isempty(updated_partnerships)
        keysToRemove(end+1) = currentKey;
    else
        all_partnerships(currentKey) = updated_partnerships;
    end
end

% Remove keys with no partnerships
for i = 1:length(keysToRemove)
    if isKey(all_partnerships, keysToRemove(i))
        remove(all_partnerships, keysToRemove(i));
    end
end

% simulate death

[all_partnerships] = handleDeath(all_partnerships, ids(1));