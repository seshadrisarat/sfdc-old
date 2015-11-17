public with sharing class RecentActivities {
    
    public class LineItem {
        public Task record { get; set; }
        public Set<String> users { get; set; }
        public LineItem(Task record) {
            this.record = record;
            users = new Set<String> { record.Owner.Name };
        }
    }
    
    public List<LineItem> records { get; private set; }

    public RecentActivities(ApexPages.StandardController controller) {
        records = new List<LineItem>();
        try {
            Set<Id> whatIds = new Set<Id> { controller.getRecord().Id };
            for (Deal__c d : [SELECT Id FROM Deal__c WHERE Related_Company__c=:controller.getRecord().Id]) {
                whatIds.add(d.Id);
            }

            Map<Id, LineItem> lineItems = new Map<Id, LineItem>();
            records = new List<LineItem>();
            for (Task t : [SELECT AccountId, ParentId__c, WhatId, Completed_Date__c, ActivityDate, Description, Next_Steps__c, Owner.Name FROM Task WHERE IsClosed=TRUE AND WhatId IN :whatIds ORDER BY ActivityDate DESC, LastModifiedDate DESC, ParentId__c ASC]) {
                if (t.ParentId__c == null) {
                    LineItem li = new LineItem(t);
                    lineItems.put(t.Id, li);
                    records.add(li);
                } else {
                    lineItems.get(t.ParentId__c).users.add(t.Owner.Name);
                }
            }
        } catch (Exception e) {
        }
    }
}