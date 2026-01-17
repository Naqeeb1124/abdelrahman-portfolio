%% Ramjet T-s Diagram Generator (Static + Stagnation) - Fixed for LaTeX
clear; clc; close all;

%% --- 1. Input Data ---
T_static = [216.5, 290.1, 387.2, 491.5, 538.7, 2046.5, 1833.3, 1584.3];
P_static = [12.11, 31.02, 78.64, 172.68, 238.02, 158.31, 107.73, 64.63] * 1000;
Tt = [544.0, 544.0, 544.0, 544.0, 544.0, 2200.0, 2200.0, 2200.0];
Pt = [304.45, 280.17, 258.53, 246.19, 246.19, 203.92, 203.92, 203.92] * 1000;

Cp = 1004; R = 287;

%% --- 2. Calculate Entropy Changes ---
s_stat = zeros(1, length(T_static));
s_stag = zeros(1, length(Tt));
for i = 2:length(T_static)
    s_stat(i) = s_stat(i-1) + Cp*log(T_static(i)/T_static(i-1)) - R*log(P_static(i)/P_static(i-1));
    s_stag(i) = s_stag(i-1) + Cp*log(Tt(i)/Tt(i-1)) - R*log(Pt(i)/Pt(i-1));
end
s_stat = s_stat / 1000; % kJ/kg*K
s_stag = s_stag / 1000;

%% --- 3. Plotting Setup ---
% FIX: Handle and Position for LaTeX compatibility
f_adv = figure('Units', 'inches', 'Position', [1, 1, 9, 7], 'Color', 'none');
ax = gca;
set(ax, 'Color', 'none', 'FontName', 'Arial');
hold on; grid off; box on;

% --- A. Plot Isobars (Dotted Black) ---
P_iso_list = [P_static(1), P_static(5), P_static(4)]; 
s_range = linspace(min(s_stat)-0.1, max(s_stat)+0.15, 100);
for k = 1:length(P_iso_list)
    T_iso = T_static(1) * exp( ((s_range*1000) + R*log(P_iso_list(k)/P_static(1))) / Cp );
    plot(s_range, T_iso, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.8);
    text(s_range(end)-0.05, T_iso(end)+40, sprintf('%.0f kPa', P_iso_list(k)/1000), ...
        'FontSize', 8, 'Color', [0.3 0.3 0.3], 'BackgroundColor', 'none');
end

% --- B. Plot Stagnation Cycle (Dashed Black Line) ---
plot(s_stag, Tt, 'k--s', 'LineWidth', 1.2, 'MarkerSize', 5, 'MarkerFaceColor', 'none');

% --- C. Plot Static Cycle (Solid Black Line) ---
plot(s_stat, T_static, 'k-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'k');

%% --- 4. Annotations ---
% Legend (Transparent Background)
legend({'Stagnation State (T_t, s)', 'Static State (T, s)'}, ...
    'Location', 'NorthWest', 'Color', 'none', 'EdgeColor', 'k');

xlabel('Specific Entropy Change, \Delta s [kJ/kg\cdotK]', 'FontWeight', 'bold');
ylabel('Temperature [K]', 'FontWeight', 'bold');
title('Ramjet T-s Diagram (Static & Stagnation)', 'FontSize', 14);

% Station Numbers (Static - Below markers)
for i = 1:length(T_static)
    text(s_stat(i), T_static(i)-70, num2str(i-1), 'FontSize', 10, ...
        'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'BackgroundColor', 'none');
end

% Station Numbers (Stagnation - Above markers)
text(s_stag(1), Tt(1)+60, '0_t-4_t', 'FontSize', 9, 'Color', 'k', 'BackgroundColor', 'none');
text(s_stag(6), Tt(6)+60, '5_t-7_t', 'FontSize', 9, 'Color', 'k', 'BackgroundColor', 'none');

xlim([min(s_stat)-0.1, max(s_stat)+0.2]);
ylim([0, 2600]);

%% --- 5. EXPORT ---
exportgraphics(f_adv, 'Ramjet_Ts_Advanced_Final.pdf', 'ContentType', 'vector', 'BackgroundColor', 'none');
fprintf('Advanced T-s Diagram exported successfully.\n');