function d = rel_dist(tar_v, sim_v)
% this function calculates relative distance between target vector and
% simulated vector
    [n0, m0] = size(tar_v);
    [n1, m1] = size(sim_v);

    if n0~=n1 | m0~=m1
        myname=mfilename;
        error([myname, ': vectors must be of the same size.']);
    else
        if n0 ==1 | m0 ==1
            % d = sum(abs((tar_v-sim_v)./tar_v));
             d = max(abs((tar_v-sim_v)./tar_v));
        else
            %d = sum(sum(abs((tar_v-sim_v)./tar_v)));
            %d = max(max(abs((tar_v-sim_v)./tar_v)));
            d = max(max(abs(tar_v-sim_v)));
        end
    end
end