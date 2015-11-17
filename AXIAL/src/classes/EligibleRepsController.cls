public with sharing class EligibleRepsController {

    private final List<User> eligibleReps;

    public EligibleRepsController() {
        eligibleReps = [SELECT Id, FirstName, Sales_Pod__c, MOA__c, LastName, Eligible_To_Receive_Leads__c, Last_Lead_Assigned_Date__c
                        FROM User
                        WHERE isActive = true];
    }

    public List<User> getEligibleReps(){
        return eligibleReps;
    }

    public PageReference save(){
        update eligibleReps;
        return ApexPages.currentPage();
    }

    public Boolean getNoneEligible(){
        return eligibleReps.size() == 0;
    }
}