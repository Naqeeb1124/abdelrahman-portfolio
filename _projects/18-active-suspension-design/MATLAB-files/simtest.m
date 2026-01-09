%% ===== 1. SETUP: ENTER YOUR MODEL NAME HERE =====
modelName = 'lqr_simulink'; % <--- CHANGE THIS

% Ensure the model is loaded
if ~bdIsLoaded(modelName)
    try
        load_system(modelName);
        fprintf('Successfully loaded model: %s\n', modelName);
    catch
        error(['Could not find model: ' modelName '. Check name/path.']);
    end
end

% Get access to the Model Workspace
modelWS = get_param(modelName, 'ModelWorkspace');

%% ===== 2. MODEL CALLBACKS =====
fprintf('\n================ MODEL CALLBACKS ================\n');
callbacks = {'InitFcn', 'StartFcn', 'StopFcn', 'PreLoadFcn', 'PostLoadFcn'};
for i = 1:length(callbacks)
    cbName = callbacks{i};
    cbCode = get_param(modelName, cbName);
    if ~isempty(cbCode)
        fprintf('\n--- %s ---\n%s\n', cbName, cbCode);
    else
        fprintf('\n--- %s ---\n(Empty)\n', cbName);
    end
end

%% ===== 3. STATE-SPACE BLOCKS (Updated for Discrete & Continuous) =====
fprintf('\n================ STATE-SPACE BLOCKS ================\n');

% Find BOTH Continuous and Discrete State-Space blocks
ssBlocks = [find_system(modelName, 'BlockType', 'StateSpace'); ...
            find_system(modelName, 'BlockType', 'DiscreteStateSpace')];

if isempty(ssBlocks)
    disp('No State-Space blocks found (Check if they are masked Subsystems).');
else
    for i = 1:length(ssBlocks)
        blk = ssBlocks{i};
        type = get_param(blk, 'BlockType');
        fprintf('\n--- Found Block: %s (%s) ---\n', get_name_short(blk), type);
        
        % Check A, B, C, D
        check_param_value(blk, 'A', modelWS);
        check_param_value(blk, 'B', modelWS);
        check_param_value(blk, 'C', modelWS);
        check_param_value(blk, 'D', modelWS);
    end
end

%% ===== 4. GAIN BLOCKS =====
fprintf('\n================ GAIN BLOCKS ================\n');
gains = find_system(modelName, 'BlockType', 'Gain');
if isempty(gains), disp('No Gain blocks.'); end
for i = 1:length(gains)
    fprintf('Block: %-25s | ', get_name_short(gains{i}));
    check_param_value(gains{i}, 'Gain', modelWS, true); % true = concise mode
end

%% ===== 5. SUM BLOCKS =====
fprintf('\n================ SUM BLOCKS ================\n');
sums = find_system(modelName, 'BlockType', 'Sum');
if isempty(sums), disp('No Sum blocks.'); end
for i = 1:length(sums)
    fprintf('Block: %-25s | Inputs: %s\n', get_name_short(sums{i}), get_param(sums{i}, 'Inputs'));
end

%% ===== 6. FROM WORKSPACE BLOCKS =====
fprintf('\n================ FROM WORKSPACE ================\n');
fw = find_system(modelName, 'BlockType', 'FromWorkspace');
if isempty(fw), disp('No FromWorkspace blocks.'); end
for i = 1:length(fw)
    fprintf('Block: %-25s | ', get_name_short(fw{i}));
    check_param_value(fw{i}, 'VariableName', modelWS, true);
end

%% ===== 7. MODEL WORKSPACE CONTENTS =====
fprintf('\n================ MODEL WORKSPACE VARIABLES ================\n');
% Get all variables in the Model Workspace
mwVars = modelWS.whos;
if isempty(mwVars)
    disp('Model Workspace is empty.');
else
    fprintf('%-20s %-15s %-10s\n', 'Name', 'Class', 'Size');
    fprintf('%s\n', repmat('-',1,50));
    for k = 1:length(mwVars)
        szStr = sprintf('%dx', mwVars(k).size);
        szStr = szStr(1:end-1); % Remove trailing 'x'
        fprintf('%-20s %-15s %-10s\n', mwVars(k).name, mwVars(k).class, szStr);
    end
end

%% ===== 8. BASE WORKSPACE CONTENTS =====
fprintf('\n================ BASE WORKSPACE VARIABLES ================\n');
% We can't pass 'whos' output easily, so we just run the command
whos

%% ===== HELPER FUNCTIONS =====

function check_param_value(blk, paramName, modelWS, concise)
    % Reads a parameter string, looks it up in Model WS first, then Base WS
    if nargin < 4, concise = false; end
    
    valStr = get_param(blk, paramName);
    foundValue = [];
    source = '';

    % 1. Try Model Workspace
    try
        foundValue = modelWS.getVariable(valStr);
        source = 'Model WS';
    catch
        % 2. Try Base Workspace
        try
            foundValue = evalin('base', valStr);
            source = 'Base WS';
        catch
            % 3. It's likely a raw number or expression
            source = 'Raw Value';
        end
    end
    
    % Formatting Output
    if concise
        if ~isempty(foundValue) && isnumeric(foundValue) && numel(foundValue) == 1
            fprintf('%s: %g (%s)\n', paramName, foundValue, source);
        else
            fprintf('%s: %s\n', paramName, valStr);
        end
    else
        % Detailed Output (for State-Space matrices, etc.)
        if strcmp(source, 'Raw Value')
             fprintf('  %s: %s\n', paramName, valStr);
        else
             sz = size(foundValue);
             fprintf('  %s: [%dx%d %s] (Source: %s, Var: %s)\n', ...
                 paramName, sz(1), sz(2), class(foundValue), source, valStr);
        end
    end
end

function name = get_name_short(fullpath)
    [~, name] = fileparts(fullpath); 
end