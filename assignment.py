#!/usr/bin/env python3.11

# Task Assignment Problem


import gurobipy as gp
from gurobipy import GRB

def taskAssignment(nbTasks, nbProcessors, processorTimeLimit, fixedCosts, executionTime, ref=None):

    # Range of tasks and processors
    tasks = range(nbTasks)
    processors = range(nbProcessors)

    # Model
    m = gp.Model("taskAssignment")

    # --- Decision variables ---
    # Processor open decision variables: open[p] == 1 if processor p is open.
    open = m.addVars(processors, vtype=GRB.BINARY, obj=fixedCosts, name="open")

    # Task assignment decision variables: assign[t,p] captures the
    # assignment of task t to processor p. It is binary.
    assign = m.addVars(processors, tasks, vtype=GRB.BINARY, obj=executionTime, name="assign")

    # Define Slack Variables, one for each processor to account for the difference between the total execution time and the processor time limit
    epsilon = m.addVars(processors, vtype=GRB.CONTINUOUS, obj=10.0, name="slack")


    # --- Objective function ---
    # The objective is to minimize the total fixed and variable costs
    m.ModelSense = GRB.MINIMIZE

    # --- Constraints ---
    # Execution time constraints
    m.addConstrs(
        (gp.quicksum(assign[p, t] * executionTime[p, t] for t in tasks) <= processorTimeLimit[p] * open[p] + epsilon[p] for p in processors),
        "Capacity"
    )

    # Task assignment constraints
    # Ensure that each task is assigned to exactly one processor
    m.addConstrs((assign.sum("*", t) == 1 for t in tasks), "TaskAssignment")

    # --- Optimization -- 
    # Save model
    m.write("taskAssignmentPY.lp")

    # Guess at the starting point: close the processor with the highest fixed costs;
    # open all others
    for p in processors:
        open[p].Start = 1.0

    # Now close the processor with the highest fixed cost
    print("Initial guess:")
    maxFixed = max(fixedCosts)
    for p in processors:
        if fixedCosts[p] == maxFixed:
            open[p].Start = 0.0
            print(f"Closing processor {p}")
            break
    print("")

    # Solve
    m.optimize()

    # --- Output ---
    # Print solution
    total_cost = 0
    print(f"\nTOTAL EXECUTION TIME: {m.ObjVal:g}")
    print("SOLUTION:")
    for t in tasks:
        for p in processors:
            if assign[p, t].X > 0:
                total_cost += executionTime[p][t]
                print(f"Task {t} assigned to processor {p} with fixed cost of {fixedCosts[p]:g} and an execution time of {executionTime[p][t]:g} seconds")
    for p in processors:
        total_cost += fixedCosts[p] * open[p].X
    print(f"Total cost: {total_cost:g}")

    total_cost_ref = 0
    if ref is not None:        
        print("SOLUTION with REF exec time:")
        for t in tasks:
            for p in processors:
                if assign[p, t].X > 0:
                    total_cost_ref += ref[p][t]
                    print(f"Task {t} assigned to processor {p} with fixed cost of {fixedCosts[p]:g} and an execution time of {ref[p][t]:g} seconds")
        for p in processors:
            total_cost_ref += fixedCosts[p] * open[p].X
        print(f"Total cost (ref): {total_cost_ref:g}")

                                        
    # Calculate and print the total execution time per processor
    for p in processors:
        execution_time_per_proc = 0
        for t in tasks:
            if assign[p, t].X > 0: # Check if the task is assigned to the processor
                # Add the execution time of the task to the total execution time for the processor
                execution_time_per_proc += executionTime[p][t]
        print(f"Processor {p} total execution time: {execution_time_per_proc:g} seconds")

    # Save the model for inspection
    m.write("taskAssignmentPY.sol")
    
    return total_cost, total_cost_ref
