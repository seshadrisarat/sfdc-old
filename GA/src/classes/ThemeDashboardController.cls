public with sharing class ThemeDashboardController 
{
    public class LineItem {
        public Integer count {get; set;}
        public String name {get; set;}
        public String active {get; set;}
        public String priority {get; set;}
        public LineItem() {
            count = 0;
            name = '-';
            active = '-';
            priority = '-';
        }
        
        public LineItem(String n, String a, String p) {
            count = 0;
            name = n;
            active = a;
            priority = p;
        }
    }
    
    public Map<String, LineItem> lineItems;
    
    public List<LineItem> getLineItems()
    {
        
        lineItems = new Map<String, LineItem>();
        Set<Id> teamUserIds = Utilities.getPublicTeamMembers();
        teamUserIds.add(UserInfo.getUserID());
        
        for (Theme__c t : [Select Theme_Name__c, Active__c, Priority__c FROM Theme__c WHERE Active__c != 'Inactive' AND OwnerId IN :teamUserIds ORDER BY Active__c, Priority__c LIMIT 100 ]) {
            String key = t.Active__c + '-' + t.Priority__c;
            
            if (lineItems.get(t.Theme_Name__c) == null) {
                lineItems.put(t.Theme_Name__c, new LineItem(
                    t.Theme_Name__c,
                    t.Active__c,
                    t.Priority__c
                ));
            }
            lineItems.get(t.Theme_Name__c).Count++;
        }
        return lineItems.values();
    }
    
    static testMethod void testController() {
        ThemeDashboardController t = new ThemeDashboardController();
        t.getLineItems();
    }
}