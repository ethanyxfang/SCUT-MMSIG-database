function [Feature, L] = getSigfeature(subcorpus, database_path)
% Read the signature data and calculate the 6-D feature descriptor

if exist([upper(subcorpus),'_feature.mat'], 'file')
    load([upper(subcorpus),'_feature.mat']);
    return;
end

Feature = cell(50, 40);
L = zeros(50, 40);

for subject = 1 : 50
    for sample = 1 : 40
        temp = dlmread(sprintf('%s%s%s%02d%s%d%s', database_path, subcorpus, '\U', subject, 'S', sample, '.txt'), ' ', 0, 0);
        x = temp(:, 1);
        y = temp(:, 2);
        data = [x, y];
        data = getFeature(data);    % getFeature() calculate the 6-D feature descriptor
        Feature{subject, sample} = data ;
        L(subject, sample) = length(data); % get the length of signature
    end
end

disp('Saving feature ...');
save([upper(subcorpus), '_feature'], 'Feature', 'L');
disp('Feature saved.');
