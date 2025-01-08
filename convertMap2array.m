function result_array = convertMap2array(partnership_map)
    % Initialize an empty result array
    result_array = [];
    
    % Extract all keys from the map
    person_ids = keys(partnership_map);
    
    % Iterate over each person
    for k = 1:length(person_ids)
        current_id = person_ids{k};
        partnerships = partnership_map(current_id);
        
        % Iterate over each partnership of the current person
        for p = 1:length(partnerships)
            partner_id = partnerships(p).id;
            
            % Ensure id1 < id2 for unique representation
            id1 = min(current_id, partner_id);
            id2 = max(current_id, partner_id);

            start_date = partnerships(p).start_date;
            end_date = partnerships(p).end_date;
            
            % Check if this pair already exists in the result array
            if ~isempty(result_array)
                exists = any(result_array(:, 1) == id1 & result_array(:, 2) == id2 & result_array(:, 3)==start_date);
            else
                exists = false;
            end

            if ~exists
                result_array = [result_array; id1, id2 start_date end_date];
            end
        end
    end
end
