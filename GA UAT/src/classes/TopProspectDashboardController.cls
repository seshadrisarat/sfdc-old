public with sharing class TopProspectDashboardController {
    private Boolean showPaloAlto;

    public List<Account> records {
        get {
            Set<Id> teamUserIds = Utilities.getPublicTeamMembers();
            Set<String> validStatus = new Set<String> {
                'Top Prospect'
            };
            records = [SELECT Name, BillingCity, BillingState FROM Account WHERE OwnerId<>NULL AND OwnerId IN :teamUserIds AND Status__c IN :validStatus LIMIT 1000];
            return records;
        }
        private set;
    }

    static testMethod void testController() {
        TopProspectDashboardController controller = new TopProspectDashboardController();
        List<Account> records = controller.records;
    }    
}