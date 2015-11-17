public with sharing class Prospect_Upcoming_DashboardController {
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
        
        lineItems = new List<LineItem>();
        Set<Id> teamUserIds = Utilities.getPublicTeamMembers();
        teamUserIds.add(UserInfo.getUserID());
        
        Set<String> eventIds = new Set<String>();
        if (teamUserIds != null && !teamUserIds.isEmpty()) {
            for ( Event e : [SELECT Account.Name, Account.Company_Name__c, ActivityDate FROM Event WHERE Account.OwnerId IN :teamUserIds AND Account.Status__c IN :companyStatus AND ActivityDate >= today AND ActivityDate <= NEXT_N_DAYS:7 AND Type='Prospect Meeting' order by ActivityDate LIMIT 10]) {
                String eventId = e.Account.Id + '|' + e.ActivityDate;
                if (!eventIds.contains(eventId)) {
                    lineItems.add(new LineItem(
                        e.Account.Company_Name__c,
                        e.ActivityDate
                    ));
                    eventIds.add(eventId);
                }
            }
        }
        
        if (lineItems.isEmpty()) {
            lineItems.add(new LineItem('No Meetings',null));
        }
        return lineItems;
    }
    
    static testMethod void testController() {
        ThemeDashboardController t = new ThemeDashboardController();
        t.getLineItems();
    }
}