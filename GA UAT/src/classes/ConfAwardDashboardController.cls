public with sharing class ConfAwardDashboardController 
{
    public List<Conference_Award__c> getAwards()
    {
        Set<Id> teamUserIds = Utilities.getPublicTeamMembers();
        List<Conference_Award__c> l = [SELECT name, date__c FROM Conference_Award__c WHERE isDeleted=FALSE AND OwnerID IN :teamUserIds AND date__c >= TODAY and date__c <= NEXT_N_DAYS:120 ORDER BY date__c asc LIMIT 10];
        return l;
    }
    
    static testMethod void testController() {
        ConfAwardDashboardController t = new ConfAwardDashboardController();
        t.getAwards();
    }
}