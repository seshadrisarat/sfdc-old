@isTest(SeeAllData=true)
public class RHX_ConsumerActions_TEST{
	
    static testMethod void ConsumerActions() {
        
        List<sObject> sourceList = [SELECT Id
FROM ConsumerActions__c
                    			LIMIT 1];

        if(sourceList.size() == 0) {
            sourceList.add(
                	new ConsumerActions__c()
                );
        }
	Database.upsert(sourceList);        
    }

}