% ======================================================================= %
% Description: Tensor completion of the structured data
% Calling Syntax: run main.m
% Inputs: (inline) slice value fro the optimization 
% Outputs: printed file 
% Required m-files: TensorLab librarie
% Author: Julie Durette
% Created: May 2, 2024
% Last Modified: May 3, 2024
% ======================================================================= %

% Save 1 slice for the optimization problem.
condition_slice_index = 1; % TODO this value should come from the python task assign.

%% === import TensorLab code
% 
addpath("tensorlab_src\");
savepath;

%% === Generate artificial data with missing value 
pc_missing = 0.5; % in percent, i.e. 0.5 = 50%
missing_random = false;
[T_full, T, M, N] = initializeArtificialData(pc_missing, missing_random);
% [T_full, T, M, N] = test_data();

% Figure
slice_full      = squeeze(T_full(condition_slice_index, :, :)); 
slice_Tmissing  = squeeze(T(condition_slice_index, :, :));
plotTensorSlice(slice_full, slice_Tmissing, 0, 0, M, N)

%% === Fill missing entries by averaging along Mode-3  'task' fibers T_::k

T_avg = T;

mean_T_replicated = repmat( mean(T, 3, 'omitnan'), ...
                            1, 1, size(T,3));

T_avg(isnan(T_avg)) = mean_T_replicated(isnan(T_avg));

% Figure
slice_avg      = squeeze(T_avg(condition_slice_index, :, :)); 
plotTensorSlice(slice_full, slice_Tmissing, 0, slice_avg, M, N)

%% === Fill missing entries by MAX Mode-2'computer'fibers T_:j:

% Create a copy of T
T_max_NaN = T;

% Calculate the maximum along the 1st dimension (operating condition), ignoring NaNs
max_T_dim1 = max(T, [], 1, 'omitnan');  % Max over the 1st dimension

% Calculate the maximum along the 2nd dimension (computers) from the result, ignoring NaNs
max_T_dim1_dim2 = max(max_T_dim1, [], 2, 'omitnan');  % Max over the 2nd dimension

% Replicate the max matrix to match the size of T
max_T_replicated = repmat(max_T_dim1_dim2, 1, size(T,2), size(T,3));

% Replace NaNs in the copied matrix T with the corresponding values from the replicated max matrix
T_max_NaN(isnan(T_max_NaN)) = max_T_replicated(isnan(T_max_NaN));

disp(size(T_max_NaN));  % Should display the size of T, e.g., [10 11 12]


%% === Tensor decomposition with joint context matrices 

% 
rhos = [0.8, 1, 1, 0.5]; % relative weights
R = 8; % rank
displayFreq = 10; % display frequency for optimization
maxIter = 2000; % number of iterations
cgMaxIter = 1000; % maximum number of conjugate gradient iterations

[reconstructed_T, reconstructed_M, reconstructed_N, sol, output] = structuredDataFusion(T, M, N, rhos, R, displayFreq, maxIter, cgMaxIter);

%% Errors

[error_T, error_M, error_N] = calculateReconstructionErrors(T_full, reconstructed_T, ...
                                                            M, reconstructed_M, ...
                                                            N, reconstructed_N);
disp("avg")
[error_T, error_M, error_N] = calculateReconstructionErrors(T_full, T_avg, ...
                                                            M, reconstructed_M, ...
                                                            N, reconstructed_N);

%% Save to .mat for python + slice 1:: figure

% Extract the slices and remove singleton dimensions
slice_full      = squeeze(T_full(condition_slice_index, :, :)); 
slice_Tmissing  = squeeze(T(condition_slice_index, :, :));
slice_SDF       = squeeze(reconstructed_T(condition_slice_index, :, :));
slice_avg       = squeeze(T_avg(condition_slice_index, :, :)); 
slice_max       = squeeze(T_max_NaN(condition_slice_index, :, :)); 

filename = 'exec_time.mat';
save(filename, 'slice_SDF', 'slice_avg', 'slice_full', 'slice_Tmissing', "slice_max");

% Figure
plotTensorSlice(slice_full, slice_Tmissing, slice_SDF, slice_avg, M, N)
