function arr = read_array(Folder_core_str, sim_type, num_pars, num_batch, n_points, file_str)
    arr = nan(num_pars*num_batch, n_points);
 
   
        for pars_counter = 1:num_pars
            for batch_counter = 1:num_batch
               % if ~(isequal(sim_type,'mult_8') & pars_counter==46 & (ismember(batch_counter,[15,17])))
                    file_path_str = fullfile([Folder_core_str, num2str(pars_counter),'_batch_',num2str(batch_counter), '_' , sim_type], file_str);
                        
                    arr((pars_counter-1)*num_batch+batch_counter,:) = readmatrix(file_path_str);
                        
                    % process strings and store them
                    % replace all nans in cs_indid_out with 0's
                    ind_nan = isnan(arr((pars_counter-1)*num_batch+batch_counter,:));
                    arr((pars_counter-1)*num_batch+batch_counter,ind_nan) = 0;
                    
                    line_read = fliplr(arr((pars_counter-1)*num_batch+batch_counter,:));
                    ind_non_0=find(line_read~=0,1);
                    line_read(:,1:(ind_non_0-1))=line_read(:,ind_non_0);
                    arr((pars_counter-1)*num_batch+batch_counter,:)=fliplr(line_read);
              %  end
            end
        end
    
end