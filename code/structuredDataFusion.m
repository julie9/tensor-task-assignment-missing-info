function [reconstructed_T, reconstructed_M, reconstructed_N, sol, output] = ...
    structuredDataFusion(T, M, N, rhos, R, displayFreq, maxIter, cgMaxIter)

    % Initialize model variables
    model = struct;     % Initialize model structure
    model.variables.a = randn(size(T,1), R);    % Initialize factor matrices
    model.variables.b = randn(size(T,2), R);    
    model.variables.c = randn(size(T,3), R);    
    model.variables.d = randn(size(N,2), R);    

    % Define factors and their constraints (non-negativity)
    model.factors.A = {'a', @struct_nonneg};
    model.factors.B = {'b', @struct_nonneg};
    model.factors.C = {'c', @struct_nonneg};
    model.factors.D = {'d'};

    % Set up factorizations with relative weights
    model.factorizations.tensor.data = T;
    model.factorizations.tensor.cpdi = {'A', 'B', 'C'};
    model.factorizations.tensor.relweight = rhos(1);

    model.factorizations.matrixM.data = M;
    model.factorizations.matrixM.cpd = {'B', 'B'};
    model.factorizations.matrixM.relweight = rhos(2);

    model.factorizations.matrixN.data = N;
    model.factorizations.matrixN.cpd = {'C', 'D'}; 
    model.factorizations.matrixN.relweight = rhos(3);

    % Output the solution and diagnostics
    sdf_check(model, 'print');

    % Set up regularization terms
    model.factorizations.myreg.relweight = rhos(4);   % Regularization weight
    model.factorizations.myreg.regL2 = {'A', 'B', 'C', 'D'};

    options.TolFun    = 1e-9;           % Stop earlier.
    options.Display   = displayFreq;    % View convergence progress every 10 iterations.
    options.maxIter   = maxIter;        % Maximum number of iterations.
    options.CGMaxIter = cgMaxIter;      % Recommended if structure/coupling is imposed
    
    % Perform non-linear least squares optimization
    [sol, output] = sdf_nls(model, options);

    % Reconstruct tensors and matrices
    reconstructed_T = cpdgen({sol.factors.A, sol.factors.B, sol.factors.C});
    reconstructed_M = cpdgen({sol.factors.B, sol.factors.B});
    reconstructed_N = cpdgen({sol.factors.C, sol.factors.D});
end
