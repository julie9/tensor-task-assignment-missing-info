function plotTensorSlice(slice_full, slice_Tmissing, slice_SDF, slice_avg, M, N)
    
    % Determine the common color scale across all slices
    minVal = -1; %min([min(slice_Tmissing(:)), min(slice_SDF(:)), min(slice_avg(:)), min(M(:)), min(N(:))]);
    maxVal = max([max(slice_Tmissing(:)), max(slice_SDF(:)), max(slice_avg(:)), max(M(:)), max(N(:))]);

    fig = figure;

    % Figure position
    desiredWidth = 1500; %  in pixels
    desiredHeight = desiredWidth / 3; % in pixels to maintain a ratio
    fig.Position = [100, 100, desiredWidth, desiredHeight];

    % Plot the full slice
    ax1 = subplot(2, 3, 1); 
    imagesc(slice_full); 
    colorbar; 
    title('Full Slice');
    ylabel('Dim2 processors');
    xlabel('Dim3 tasks');
    axis equal tight;
    clim([minVal maxVal]); 
    colormap(ax1, "parula")

    % Plot the original slice with NaN
    slice_Tmissing(isnan(slice_Tmissing)) = -inf;
    ax2 = subplot(2, 3, 4);
    imagesc(slice_Tmissing); 
    colorbar; 
    title('Slice with missing entries');
    ylabel('Dim2 processors');
    xlabel('Dim3 tasks');
    axis equal tight; 
    clim([minVal maxVal]);
    colormap(ax2, [0 0 0; parula(128)])

    % Plot the reconstructed slice
    ax3 = subplot(2, 3, 2); 
    imagesc(slice_SDF);
    colorbar;
    title('Reconstructed Slice');
    ylabel('Dim2 processors');
    xlabel('Dim3 tasks');
    axis equal tight;
    clim([minVal maxVal]);
    colormap(ax3, "parula")

    % Plot the averaged NaN slice
    ax4 = subplot(2, 3, 5); 
    imagesc(slice_avg);
    colorbar;
    title('Averaged NaN Slice');
    ylabel('Dim2 processors');
    xlabel('Dim3 tasks');
    axis equal tight;
    clim([minVal maxVal]);
    colormap(ax4, "parula")

    % Plot matrix M
    ax5 = subplot(2, 3, 3); 
    imagesc(M);
    colorbar;
    title('Matrix M Processor similarity');
    xlabel('Dim2 processors');
    ylabel('Dim2 processors');
    axis equal tight;
    clim([0 1]);
    colormap(ax5,"gray");

    % Plot matrix N Computer
    ax6 = subplot(2, 3, 6); 
    imagesc(N');
    colorbar;
    title('Matrix N Task features');
    xlabel('Dim3 tasks');
    ylabel('Dim4 task components');
    axis equal tight;
    clim([0 1]);
    colormap(ax6,"hot");
        
    print(gcf, 'fig_sliceMode1.svg', '-dsvg'); % Save the figure as an SVG file

end
