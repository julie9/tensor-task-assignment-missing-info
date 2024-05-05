import numpy as np
import scipy.io
import assignment

def load_mat_files():
    # Load the .mat file
    mat_contents = scipy.io.loadmat('exec_time.mat')

    # Extract the matrix
    slice_SDF = mat_contents['slice_SDF']
    slice_avg = mat_contents['slice_avg']
    slice_full = mat_contents['slice_full']

    # Verify the shape if needed
    print(slice_SDF.shape)
    print(slice_avg.shape)

    return slice_SDF, slice_avg, slice_full


if __name__ == "__main__":
    
    nbTasks = 20
    nbProcessors = 8

    processorTime = [1] * nbProcessors   # Processor execution capacities in seconds
    fixedCosts =  [1]*nbProcessors #[1, 1, 0.4, 0.4, 0.5, 0.5, 0.5, 0.5] # Fixed costs for each processor (rental, power, priority, maintenance, etc.)

    # Execution second for each processor
    # Each row corresponds to a processor, and each column corresponds to a task.
    # The value at executionCosts[p][t] represents the time of executing task t on processor p.
    # This matrix is used to calculate the total time of executing all tasks on the assigned processors.
    # execution_time = [
    #     # task 0, task 1, task 2, task 3, task 4
    #     [2.      , 3.   , 4.    , 5.    , 6.],    # Processor 0
    #     [1.5     , 2.5  , 3.5   , 4.5   , 5.5],  # Processor 1
    #     [1.      , 2.   , 3.    , 4.    , 5.],    # Processor 2
    #     [0.5     , 1.5  , 2.5   , 3.5   , 4.5],  # Processor 3
    #     [0.25    , 0.75 , 1.25  , 1.75  , 2.25], # Processor 4
    #     ]
    
    exec_time_SDF, exec_time_avg, exec_time_full = load_mat_files()
    execution_time_avg = exec_time_avg[:nbProcessors, :nbTasks] 
    execution_time_full = exec_time_full[:nbProcessors, :nbTasks] 
    execution_time_SDF = exec_time_SDF[:nbProcessors, :nbTasks] 
    
    print("--------------------- SDF Execution Time ---------------------")
    obj = assignment.taskAssignment(nbTasks, nbProcessors, processorTime, fixedCosts, execution_time_SDF, ref=execution_time_full)

    print("--------------------- Average Execution Time ---------------------")
    obj_avg = assignment.taskAssignment(nbTasks, nbProcessors, processorTime, fixedCosts, execution_time_avg, ref=execution_time_full)

    print("--------------------- Results ---------------------")
    print(f"with tensor completion: {obj[0]:.3f} ref {obj[1]:.3f}")
    print(f"with averaging: {obj_avg[0]:.3f} ref {obj_avg[1]:.3f}")