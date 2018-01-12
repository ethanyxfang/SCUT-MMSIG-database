% ------------------------------------------------------------------------ 
% BIP Lab in SCUT
% October 2017
% ------------------------------------------------------------------------ 
% This file is part of the SCUT-MMSIG database presented in:
%   Xinyi Lu, Yuxun Fang, Wenxiong Kang, Zhiyong Wang and David Dagan Feng
%   SCUT-MMSIG: A Multimodal Online Signature Database
%   CCBR 2017
% Note that this code follows the MIT License.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------

clc; clear; close all;
% dbstop if error;

%% setting
% Select the subcorpus ('mobile', 'tablet', 'inair')
subcorpus = 'inair'; 
% Select the protocol ('single', 'across5', 'across10', 'mixed', 'random')
protocol = 'mixed'; 
database_path = '..\';

%% Initialization
subject = 50;
sample = 40;
training_sample = 5;              % GS1[1...5]
forged_test = 21 : 40;            % SF
switch protocol
    case 'single'
        genuine_test = 6 : 10;    % GS1[6...10]
    case 'across5'
        genuine_test = 11 : 20;   % GS2[1...10]
    case 'across10'
        genuine_test = 11 : 20;   % GS2[1...10]
        training_sample = 10;     % reset to GS1[1...10]
    case 'mixed'
        genuine_test = 6 : 20;    % GS1[6...10]+GS2[1...10]
    case 'random'
        genuine_test = 6 : 20;    % GS1[6...10]+GS2[1...10]
        forged_test = 21 : 69;    % reset to GS1[1] of all other subjects
        sample = 69;
    otherwise
        error('Error: undefined protocol.')
end

%% Calculate the feature
disp('Calculating feature ...')
[Feature, L] = getSigfeature(subcorpus, database_path);

%% Calculate the dtw-dist between all the test sample and training sample
disp('Calculating dtw distances ...')
if strcmp(protocol, 'random')
    rstr = '_random';
else 
    rstr = '';
end
if exist([upper(subcorpus), rstr, '_dist.mat'], 'file')
    load ([upper(subcorpus), rstr, '_dist.mat']);
else
    switch subcorpus
        case 'tablet'
            disp('It will take about 4 mins...');
        case 'mobile'
            disp('It will take about 15 mins...');
        case 'inair'
            disp('It will take about 100 mins...');
    end
    dtw_dist = cal_dist(Feature, protocol);  % cal_dist() calculate the dist
    disp('Saving distances matrix ...');
    save([upper(subcorpus), rstr, '_dist.mat'], 'dtw_dist');
    disp('distances matrix saved.')
end

% only 5/10 training samples were used depending on selected protocol
dtw_dist = dtw_dist(:, :, 1 : training_sample);
% Distance normalization
for i = 1 : subject
    for j = 1 : training_sample
        dtw_dist(i, :, j) = dtw_dist(i, :, j) / (L(i, j)); 
    end
end

%% Classify
Ref_mean = zeros(subject, 1);
Test_mean = zeros(subject, sample);

for i = 1 : subject
    tem = dtw_dist(i, 1:training_sample, :);
    tem = tem(:);
    tem((tem) == 0) = [];
    Ref_mean(i) = mean(tem);   % Dref
    
%     for j = 1 : training_sample
%         tem = dtw_dist(i, j, :);
%         tem((tem) == 0) = [];
%         Test_mean(i, j) = mean(tem);
%     end
    for j = training_sample+1 : sample
        Test_mean(i, j) = mean(dtw_dist(i, j, :));   % Dtest
    end
end

dec_value = zeros(subject, sample);
for i = 1 : subject
    for j = 1 : sample
        dec_value(i, j) = Test_mean(i, j) - Ref_mean(i);  % Dtest-Dref
    end
end

%% User-independent threshold
range = 0 : 0.01 : 1;
iFA = zeros(1, length(range));
iFR = iFA;
k = 0;
for thre = range
    k = k + 1;
    for i = 1 : subject
        for j = genuine_test
            if dec_value(i, j) >= thre
                iFR(k) = iFR(k) + 1;
            end
        end
        for j = forged_test
            if dec_value(i, j) < thre
                iFA(k) = iFA(k) + 1;
            end
        end
    end
end
[EER1, TH] = ROC(iFR/length(genuine_test)/subject, iFA/length(forged_test)/subject);

disp('Result of user-independent threshold:');
disp(sprintf('%s%s%s%s%3.4f%s%3.3f', upper(subcorpus), '-', protocol,': EER=', EER1, ' TH=', (range(2)-range(1))*(TH(1)-1)));

%% User-dependent threshold
range = -1 : 0.01 : 2;
EER2 = zeros(1, subject);
for i = 1 : subject
    dFR = zeros(1, length(range));
    dFA = dFR;
    k = 0;
    for th = range
        k = k + 1;
        for j = genuine_test
            if dec_value(i, j) >= th
                dFR(k) = dFR(k) + 1;
            end
        end
        for j = forged_test
            if dec_value(i, j) < th
                dFA(k) = dFA(k) + 1;
            end
        end
    end
    EER2(i) = ROC(dFA/length(forged_test), dFR/length(genuine_test), false);
end

disp('Result of user-dependent threshold:');
disp(sprintf('%s%s%s%s%3.4f', upper(subcorpus), '-', protocol, ': EER=', mean(EER2)));