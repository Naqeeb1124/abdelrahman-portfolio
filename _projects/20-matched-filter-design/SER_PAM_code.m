clear; clc; close all;

%% 1. System Parameters
if ~exist('M_values', 'var'), M_values = [2, 4, 8, 16]; end % Keep small for speed
if ~exist('EbN0dB', 'var'), EbN0dB = 0:2:14; end
if ~exist('num_symbols', 'var'), num_symbols = 1e5; end

osr     = 8;     % Oversampling factor (samples per symbol)
rolloff = 0.5;   % Rolloff for RRC
span    = 6;     % Filter span in symbols

% Initialize Results
SER_sim_rect = cell(1, length(M_values));
SER_sim_rcos = cell(1, length(M_values));

% Prepare Figure
figure('Color','w'); hold on; grid on;

%% 2. Design the Filters

% --- A. Rectangular Filter Design ---
% We create a unit-energy rectangular pulse.
% Ideally: Amplitude = 1/sqrt(T). Here T=osr samples.
rect_pulse = ones(1, osr) / sqrt(osr); 

% --- B. RRC Filter Design (using Objects) ---
txfilter = comm.RaisedCosineTransmitFilter( ...
    'Shape','Square root', ...
    'RolloffFactor',rolloff, ...
    'FilterSpanInSymbols',span, ...
    'OutputSamplesPerSymbol',osr, ...
    'Gain', 1); % Unity gain usually implies unit energy if configured right

rxfilter = comm.RaisedCosineReceiveFilter( ...
    'Shape','Square root', ...
    'RolloffFactor',rolloff, ...
    'FilterSpanInSymbols',span, ...
    'InputSamplesPerSymbol',osr, ...
    'DecimationFactor',osr, ... % The filter handles downsampling
    'Gain', 1); 

%% 3. Main Simulation Loop
for m_idx = 1:length(M_values)
    M = M_values(m_idx);
    k = log2(M); % Bits per symbol
    
    % Unit-Average-Energy PAM Constellation
    % This ensures E_s (avg symbol energy) = 1
    constellation = (2*(0:M-1) - (M-1)) * sqrt(3/(M^2-1));
    
    current_SER_rect = zeros(size(EbN0dB));
    current_SER_rcos = zeros(size(EbN0dB));
    
    fprintf('Simulating M = %d...\n', M);
    
    for eb_idx = 1:length(EbN0dB)
        % Calculate Noise Variance
        % For Unit Energy Signal & Unit Energy Filter:
        % N0 = Eb / SNR -> sigma^2 = N0/2
        Es = 1; % Normalized constellation
        Eb = Es / k;
        EbN0_lin = 10^(EbN0dB(eb_idx)/10);
        N0 = Eb / EbN0_lin;
        sigma = sqrt(N0 / 2);
        
        % Generate Symbols
        sym_indices = randi([0 M-1], num_symbols, 1);
        s_tx = constellation(sym_indices + 1).'; % Map to constellation
        
        %% ==================================================
        %  PATH 1: RECTANGULAR (Explicit Waveform Processing)
        %  This satisfies the "Design" requirement.
        %% ==================================================
        
        % 1. Pulse Shaping (Upsample & Convolve)
        %    kron is a shortcut for upsampling + conv with rect
        tx_wave_rect = kron(s_tx, rect_pulse.');
        
        % 2. Channel (Add Noise to Waveform)
        noise_rect = sigma * randn(size(tx_wave_rect));
        rx_wave_rect = tx_wave_rect + noise_rect;
        
        % 3. Matched Filter (The Receiver)
        %    Convolve with matched filter (time-reversed pulse)
        mf_output_rect = conv(rx_wave_rect, fliplr(rect_pulse));
        
        % 4. Downsampling
        %    Sample at optimal instants (t=T, 2T, etc.)
        %    The peak occurs at index 'osr' because pulse length is 'osr'
        samp_idx = osr : osr : (num_symbols * osr);
        r_rect_down = mf_output_rect(samp_idx);
        
        % 5. Detection
        [~, det_idx] = min(abs(r_rect_down - constellation), [], 2);
        current_SER_rect(eb_idx) = mean((det_idx-1) ~= sym_indices);
        
        %% ==================================================
        %  PATH 2: RAISED COSINE (RRC)
        %  Using System Objects (Standard Industry Practice)
        %% ==================================================
        reset(txfilter); reset(rxfilter);
        
        % 1. Pulse Shaping
        %    Note: We pad with zeros to flush the filter delays
        tx_wave_rcos = txfilter([s_tx; zeros(span, 1)]);
        
        % 2. Channel (Add Noise to Waveform)
        %    Crucial: Noise is added BEFORE the receive filter
        noise_rcos = sigma * randn(size(tx_wave_rcos));
        rx_wave_rcos = tx_wave_rcos + noise_rcos;
        
        % 3. Matched Filter & Downsampling
        %    rxfilter object performs convolution AND decimation
        r_rcos_full = rxfilter(rx_wave_rcos);
        
        % 4. Delay Correction
        %    RRC filters have a delay of 'span' symbols
        start_idx = span + 1;
        r_rcos_down = r_rcos_full(start_idx : start_idx + num_symbols - 1);
        
        % 5. Detection
        [~, det_idx_rcos] = min(abs(r_rcos_down - constellation), [], 2);
        current_SER_rcos(eb_idx) = mean((det_idx_rcos-1) ~= sym_indices);
        
    end
    
    %% Theoretical SER (for validation)
    SER_theory = 2*(M-1)/M * qfunc(sqrt(6*k*10.^(EbN0dB/10)/(M^2-1)));
    
    %% Plotting
    semilogy(EbN0dB, current_SER_rect, 'o-', 'LineWidth', 1.5, ...
        'DisplayName', ['Rect M=' num2str(M)]);
    semilogy(EbN0dB, current_SER_rcos, 's--', 'LineWidth', 1.5, ...
        'DisplayName', ['RRC M=' num2str(M)]);
    semilogy(EbN0dB, SER_theory, 'k:', 'LineWidth', 1.2, ...
        'DisplayName', ['Theory M=' num2str(M)]);
end

%% Finalize Plot
xlabel('E_b/N_0 (dB)');
ylabel('Symbol Error Rate (SER)');
title('Matched Filter Design: Rectangular vs RRC');
legend('Location','southwest');

% --- FORCE LOG SCALE ---
set(gca, 'YScale', 'log'); 

% Set limits so 0 errors (which are -Inf in log) don't break the zoom
ylim([1e-5 1]); 

% Turn on major and minor grids to see the log lines clearly
grid on;
grid minor;