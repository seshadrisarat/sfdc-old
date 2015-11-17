global class EmployeeRollupSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.employeeRollup(null);
    }
}