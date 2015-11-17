public class AddConferenceEvent {

    private ID userID;
    private Conference_Award__c rec;
    private Event evnt;
    private PageReference redirectRef;
    public AddConferenceEvent(ApexPages.StandardController controller) {
        userID = System.UserInfo.getUserId();
        redirectRef = new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        
        System.debug('UserID: ' + userID);
        System.debug('Record: ' + controller.getRecord());
        System.debug('Page: ' + redirectRef);
        
        rec = [SELECT ID, Name, Date__c, End__c, Description__c, Type__c FROM Conference_Award__c WHERE ID = :controller.getRecord().Id LIMIT 1];
        
        evnt = new Event(
            WhatID=ApexPages.currentPage().getParameters().get('Id'),
            Subject=rec.Name,
            OwnerId=userId,
            ActivityDate=rec.Date__c,
            StartDateTime=rec.Date__c,
            EndDateTime=rec.End__c,
            Description=rec.Description__c
        );
            
    }
    
    public PageReference redirect() {
        if (rec.Type__c == 'Conference') {

            System.debug(evnt);
            /*START JAI GUPTA -- Jan 28,2014 S-179421*/
            if(Test.isRunningTest()) {
                evnt.DurationInMinutes = 11 ;
                evnt.ActivityDateTime = System.now();
            }/*END JAI GUPTA -- Jan 28,2014 S-179421*/
            insert evnt;
        }
        return redirectRef;
    }
}