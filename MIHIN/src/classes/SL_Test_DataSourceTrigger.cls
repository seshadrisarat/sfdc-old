@isTest
private class SL_Test_DataSourceTrigger 
{
    static List<Data_Source__c> lstDS;
    
    private static void createData()
    {
    	lstDS = new List<Data_Source__c>{
    										new Data_Source__c(Name = 'Test DS', Data_Source__c = 'Test Data Source 1'),
    										new Data_Source__c(Name = 'Test DS', Data_Source__c = 'Test Data Source 1'),
    										new Data_Source__c(Name = 'Test DS', Data_Source__c = 'Test Data Source 2'),
    										new Data_Source__c(Name = 'Test DS', Data_Source__c = 'Test Data Source 2')
    									};
    	insert lstDS;
    }
    
    static testMethod void testForInsert() 
    {
        createData();
        
        System.assertEquals([SELECT Latest_Data_Source_Summary__c FROM Data_Source__c WHERE Id =:lstDS[0].Id].Latest_Data_Source_Summary__c, true);
        System.assertEquals([SELECT Latest_Data_Source_Summary__c FROM Data_Source__c WHERE Id =:lstDS[1].Id].Latest_Data_Source_Summary__c, false);
    }
    
    static testMethod void testForUpdate()
    {
    	createData();
    	
    	lstDS[3].Data_Source__c = 'Test Data Source 3';
    	update lstDS[3];
    	
    	System.assertEquals([SELECT Latest_Data_Source_Summary__c FROM Data_Source__c WHERE Id =:lstDS[3].Id].Latest_Data_Source_Summary__c, true);
    }
}