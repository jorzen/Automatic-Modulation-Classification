clear
close all

fc=30000000;
fd=6000000;
fs=fix(6*fc/fd)*fd;
Ts=1/fs;
Td=1/fd;
N=round(Td/Ts);
M = 256;
Nsample = M*N;
T0 = Nsample*Ts;
t = Ts:Ts:T0;

Nclass = 6;
MonteCarloSum = 1000;
GammaMax = zeros(MonteCarloSum, Nclass);
SigmaAP = zeros(MonteCarloSum, Nclass);
SigmaDP = zeros(MonteCarloSum, Nclass);
SigmaAA = zeros(MonteCarloSum, Nclass);
SigmaAF = zeros(MonteCarloSum, Nclass);

SNR_array = 0:2:20;
ACC_array = zeros(1, length(SNR_array));
for idx = 1:length(SNR_array)
    SNR = SNR_array(idx)
    for MonteCarloCur = 1:MonteCarloSum
        % 2ASK signal
        G = randi([0,1],[1,M]);
        y = Digit_Modul(G, fd, fc, 'ASK', 2);
        [GammaMax(MonteCarloCur, 1), SigmaAP(MonteCarloCur, 1), ...
            SigmaDP(MonteCarloCur, 1), SigmaAA(MonteCarloCur, 1), ...
            SigmaAF(MonteCarloCur, 1)] = getFeature(y, SNR, fc, fs, fd);
        
        % 4ASK signal
        G = randi([0,3],[1,M]);
        y = Digit_Modul(G, fd, fc, 'ASK', 4);
        [GammaMax(MonteCarloCur, 2), SigmaAP(MonteCarloCur, 2), ...
            SigmaDP(MonteCarloCur, 2), SigmaAA(MonteCarloCur, 2), ...
            SigmaAF(MonteCarloCur, 2)] = getFeature(y, SNR, fc, fs, fd);
        
        % 2PSK signal
        G = randi([0,1],[1,M]);
        y = Digit_Modul(G, fd, fc, 'PSK', 2);
        [GammaMax(MonteCarloCur, 3), SigmaAP(MonteCarloCur, 3), ...
            SigmaDP(MonteCarloCur, 3), SigmaAA(MonteCarloCur, 3), ...
            SigmaAF(MonteCarloCur, 3)] = getFeature(y, SNR, fc, fs, fd);
        
        % 4PSK signal
        G = randi([0,3],[1,M]);
        y = Digit_Modul(G, fd, fc, 'PSK', 4);
        [GammaMax(MonteCarloCur, 4), SigmaAP(MonteCarloCur, 4), ...
            SigmaDP(MonteCarloCur, 4), SigmaAA(MonteCarloCur, 4), ...
            SigmaAF(MonteCarloCur, 4)] = getFeature(y, SNR, fc, fs, fd);
        
        % 2FSK signal
        G = randi([0,1],[1,M]);
        y = Digit_Modul(G, fd, fc, 'FSK', 2);
        [GammaMax(MonteCarloCur, 5), SigmaAP(MonteCarloCur, 5), ...
            SigmaDP(MonteCarloCur, 5), SigmaAA(MonteCarloCur, 5), ...
            SigmaAF(MonteCarloCur, 5)] = getFeature(y, SNR, fc, fs, fd);
        
        % 4FSK signal
        G = randi([0,3],[1,M]);
        y = Digit_Modul(G, fd, fc, 'FSK', 4);
        [GammaMax(MonteCarloCur, 6), SigmaAP(MonteCarloCur, 6), ...
            SigmaDP(MonteCarloCur, 6), SigmaAA(MonteCarloCur, 6), ...
            SigmaAF(MonteCarloCur, 6)] = getFeature(y, SNR, fc, fs, fd);
    end
    
    sum_correct = 0;
    for i=1:6
        sum_2ask = 0;
        sum_4ask = 0;
        sum_2psk = 0;
        sum_4psk = 0;
        sum_2fsk = 0;
        sum_4fsk = 0;
        [n_2ask, n_4ask, n_2psk, n_4psk, n_2fsk, n_4fsk] = ...
            recognition(GammaMax(:,i), SigmaAA(:,i), ...
            SigmaDP(:,i), SigmaAP(:,i),SigmaAF(:,i), MonteCarloSum);
        sum_2ask = sum_2ask + n_2ask;
        sum_4ask = sum_4ask + n_4ask;
        sum_2psk = sum_2psk + n_2psk;
        sum_4psk = sum_4psk + n_4psk;
        sum_2fsk = sum_2fsk + n_2fsk;
        sum_4fsk = sum_4fsk + n_4fsk;
        if i==1
            sum_correct = sum_correct + sum_2ask;
        elseif i==2
            sum_correct = sum_correct + sum_4ask;
        elseif i==3
            sum_correct = sum_correct + sum_2psk;
        elseif i==4
            sum_correct = sum_correct + sum_4psk;
        elseif i==5
            sum_correct = sum_correct + sum_2fsk;
        elseif i==6
            sum_correct = sum_correct + sum_4fsk;
        end
    end
    acc = sum_correct/6/MonteCarloSum
    ACC_array(idx) = acc;
end


%% figure out
fig1 = figure(1);
plot(SNR_array, ACC_array);
hold on;
axis([0 20 0 1]);
grid on;
saveas(fig1, ['nandi_feature_based', '.jpg'])
csvwrite(['nandi_feature_based', '.txt'], [SNR_array; ACC_array]);