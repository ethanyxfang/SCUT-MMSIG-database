function dtw_dist = cal_dist(Feature, protocol)
% Calculate the dtw-dist between all the test samples and training samples

if ~strcmp(protocol, 'random')
    dtw_dist = zeros(50, 40);
    for s = 1 : 50
        disp(sprintf('%s%d%s', 'Calculating ', s, '/50 ...'));
        for i = 1 : 40     % 20 genuine samples and 20 forged samples
            for j = 1 : 10
                if j ~= i
                    dtw_dist(s, i, j) = dtw(Feature{s,i}, Feature{s,j});
                end
            end
        end
    end
else
    dtw_dist = zeros(50, 69);
    for s = 1 : 50
        disp(sprintf('%s%d%s', 'Calculating ', s, '/50 ...'));
        for i = 1 : 20     % 20 genuine samples
            for j = 1 : 5
                if j ~= i
                    dtw_dist(s, i, j) = dtw(Feature{s,i}, Feature{s,j});
                end
            end
        end
        k = 0;
        for i = 1 : 50    % 49 random forged samples form other subjects
            if i ~= s
                k = k + 1;
                for j = 1 : 5
                    dtw_dist(s, 20+k, j) = dtw(Feature{i,1}, Feature{s,j});
                end
            end
        end
    end
end
