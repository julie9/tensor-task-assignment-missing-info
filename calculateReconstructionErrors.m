function [error_T, error_M, error_N] = calculateReconstructionErrors(T_full, reconstructed_T, M, reconstructed_M, N, reconstructed_N)
    % Calculate the Frobenius norm of the difference between original and reconstructed T, ignoring NaNs
    difference_T = T_full - reconstructed_T;
    difference_T(isnan(difference_T)) = 0; % Set NaNs to zero before computing norm --- not supposed to have any
    error_T = norm(difference_T(:), 'fro');
    fprintf('Reconstruction error for T (ignoring NaNs): %f\n', error_T);

    % Calculate the Frobenius norm of the difference between original and reconstructed M
    error_M = norm(M(:) - reconstructed_M(:), 'fro');
    fprintf('Reconstruction error for M: %f\n', error_M);

    % Calculate the Frobenius norm of the difference between original and reconstructed N
    error_N = norm(N(:) - reconstructed_N(:), 'fro');
    fprintf('Reconstruction error for N: %f\n', error_N);


    % Calculate the Frobenius norm of the difference between original and reconstructed T, ignoring NaNs
    difference_T = T_full - reconstructed_T;
    difference_T(isnan(difference_T)) = 0; % Set NaNs to zero before computing norm
    error_T = norm(difference_T(:), 'fro');
    T_zero(isnan(T_full)) = 0;
    relative_error_T = error_T / norm(reconstructed_T(:), 'fro');
    fprintf('Relative (to reconstructed_T) reconstruction error for T (ignoring NaNs): %f\n', relative_error_T);
    
    % Calculate the relative Frobenius norm of the difference between original and reconstructed M
    error_M = norm(M(:) - reconstructed_M(:), 'fro');
    relative_error_M = error_M / norm(M(:), 'fro');
    fprintf('Relative reconstruction error for M: %f\n', relative_error_M);
    
    % Calculate the relative Frobenius norm of the difference between original and reconstructed N
    error_N = norm(N(:) - reconstructed_N(:), 'fro');
    relative_error_N = error_N / norm(N(:), 'fro');
    fprintf('Relative reconstruction error for N: %f\n', relative_error_N);

end
