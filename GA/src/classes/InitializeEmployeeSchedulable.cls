global class InitializeEmployeeSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.initializeEmployee(null);
    }
}