function [T_full, T_missing, M, N] = initializeArtificialData(pc_missing, missing_random)

    % Define dimensions
    dimT1 = 6; % Dimension 1 of T : number of condition of operations
    dimT2 = 8; % Dimension 2 of T : number of computers/processors availables
    dimT3 = 20; % Dimension 3 of T : number of tasks
    dimM1 = dimT2; % Dimension 1 of M : processors similarity matrix
    dimM2 = dimT2; % Dimension 2 of M
    dimN1 = dimT3; % Dimension 1 of N : number of tasks
    dimN2 = 15; % Dimension 2 of N : presence of features (electrical components in the tasks)

    % Find the minimum number of columns
    R = min(dimM2, dimT2)-1;

    % -----------------------------------------------
    % Create structured matrices M and N
    % -----------------------------------------------
    
    % --------------------------------------------
    % Processor similarity matrix (8x8) 
    M = [
        1, 1, 0.4, 0.4, 0.5, 0.5, 0.5, 0.5;
        1, 1, 0.4, 0.4, 0.5, 0.5, 0.5, 0.5;
        0.4, 0.4, 1, 1, 0.6, 0.6, 0.6, 0.6;
        0.4, 0.4, 1, 1, 0.6, 0.6, 0.6, 0.6;
        0.5, 0.5, 0.6, 0.6, 1, 1, 1, 1;
        0.5, 0.5, 0.6, 0.6, 1, 1, 1, 1;
        0.5, 0.5, 0.6, 0.6, 1, 1, 1, 1;
        0.5, 0.5, 0.6, 0.6, 1, 1, 1, 1
    ];

    % --------------------------------------------
    % Initialize binary matrix for task features N 
    % (binary matrix indicating presence of components in the tasks).
    % N = randi([0, 1], dimN1, dimN2);
        
    % Create an empty binary matrix
    N = zeros(dimN1, dimN2);
    
    % Define common components (e.g., features 1, 2, and 3 are common)
    commonFeatures = [1, 2, 3];
    N(:, commonFeatures) = rand(dimN1, length(commonFeatures)) < 0.8;
    
    % Create similar tasks (e.g., tasks 4, 5, and 6 are similar to task 3)
    similarTasks = [4, 5, 6];
    baseTask = 3;
    N(similarTasks, :) = repmat(N(baseTask, :), length(similarTasks), 1);
    
    % Introduce rare components (e.g., features 14 and 15 are rare)
    rareFeatures = [14, 15];
    numRareTasks = 2;
    randomTasks = randperm(dimN1, numRareTasks);
    N(randomTasks, rareFeatures) = 1;
    
    % Fill the rest of the matrix with some randomness
    for i = 1:dimN2
    if ~ismember(i, [commonFeatures, rareFeatures])
        N(:, i) = rand(dimT3, 1) < 0.3;
    end
    end
        
    % ---------------------------------------------
    
    % Perform Non-negative matrix factorization
    [W_M, ~] = nnmf(M,R);
    [W_N, ~] = nnmf(N,R);
    
    % Select R components
    B = W_M(:, 1:R);
    C = W_N(:, 1:R);

    % Create a random A - no Context matrix with this dimension Condition of operation.
    A = abs(randn(dimT1, R));

    % ------------------------------------------------
    % Construct the initial tensor T using outer product of A, B, and C
    T_full = cpdgen({A, B, C});

    % Set a threshold
    threshold = 1e-8;
    
    % Ensure all values in T_full are greater than the threshold
    T_full(T_full <= threshold) = threshold + eps;  % eps is a very small value added to the threshold

    % -----------------------------------------------
    % Remove % of entries from T by setting them to NaN - SLICE
    T_missing = T_full;

    if missing_random
        numEntriesToRemove = round(pc_missing * numel(T_missing));
        indicesToRemove = randperm(numel(T_missing), numEntriesToRemove); 
        T_missing(indicesToRemove) = NaN;
    else
        startIdx = 1;
        endIdx = dimT3 * pc_missing;
        T_missing(:,:,startIdx:endIdx) = NaN;
        numEntriesToRemove = dimT1 * dimT2 * (endIdx - startIdx + 1);
    end
    % -----------------------------------------------
    % Display information about the tensors
    fprintf('Tensor T initialized with dimensions %d x %d x %d and %d entries set to NaN.\n', size(T_full, 1), size(T_full, 2), size(T_full, 3), numEntriesToRemove);
    fprintf('Matrix M initialized with dimensions %d x %d.\n', size(M, 1), size(M, 2));
    fprintf('Matrix N initialized with dimensions %d x %d.\n', size(N, 1), size(N, 2));

end
