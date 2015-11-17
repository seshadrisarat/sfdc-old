public with sharing class Prospect_Previous_DashboardController {
    public class LineItem {
        public Integer count {get; set;}
        public String name {get; set;}
        public Date activityDate {get; set;}

        public LineItem(String n, Date a) {
            count = 0;
            name = n;
            activityDate = a;
        }
    }
    
    public List<LineItem> lineItems;
    
    public List<LineItem> getLineItems() {
        List<String> companyStatus = new List<String>{ 
            'Top Prospect',
            'Early Investigation',
            'Monitor'
        };
        
        Set<Id> teamUserIds = Utilities.getPublicTeamMembers();
        if (teamUserIds != null && !teamUserIds.isEmpty()) {
            teamUserIds = new Set<Id>();
            teamUserIds.add(UserInfo.getUserId());
        }
        lineItems = new List<LineItem>();
        
        Set<String> eventIds = new Set<String>();
        for ( Event e : [SELECT Account.Name, Account.Company_Name__c, ActivityDate FROM Event WHERE Account.OwnerId IN :teamUserIds AND Account.Status__c IN :companyStatus AND ActivityDate < today AND ActivityDate >= LAST_N_DAYS:7 AND Type='Prospect Meeting' ORDER BY ActivityDate LIMIT 10]) {
            String eventId = e.Account.Id + '|' + e.ActivityDate;
            if (!eventIds.contains(eventId)) {
                lineItems.add(new LineItem(
                    e.Account.Company_Name__c,
                    e.ActivityDate
                ));
                eventIds.add(eventId);
            }
        }
        
        if (lineItems.isEmpty()) {
            lineItems.add(new LineItem('No Meetings',null));
        }
        return lineItems;
    }
    
    static testMethod void testController() {
        Prospect_Previous_DashboardController t = new Prospect_Previous_DashboardController();
        t.getLineItems();
    }
}