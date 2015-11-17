/**
* \arg ClassName      : SL_Test_Util_SharingController
* \arg JIRATicket     : HIL-4
* \arg CreatedOn      : 13/FEB/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_Util_SharingController class and is used to check the functionality for creation of sharing records.
*/
@isTest
private class SL_Test_Util_SharingController 
{
    static List<Rep_Code__c> lstRepCode;
    static List<Note__c> lstNote;
    static List<Rep_Code_User__c> lstRepCodeUser;
    static List<User> lstUser;
    
    //function for creating data
    static void createData()
    {
    	Id profileId = [SELECT Id FROM Profile WHERE Name =:'Standard User' LIMIT 1].Id;
    	
    	lstUser = new List<User>{
		    						new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing', 
		    								 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileId, 
		    								 TimeZoneSidKey='America/Los_Angeles', UserName='user211.79874@user.com'),
		    						new User(Alias = 'User2', Email='user3424@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', 
		    								 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileId, 
		    								 TimeZoneSidKey='America/Los_Angeles', UserName='user5461.79874@user.com')
    							};		 
        insert lstUser;
        
        lstRepCode = new List<Rep_Code__c>{
        										new Rep_Code__c(Name = 'Test 1', Rep_Code__c = '1234'),
        										new Rep_Code__c(Name = 'Test 2', Rep_Code__c = '12345'),
        										new Rep_Code__c(Name = 'Test 3', Rep_Code__c = '123456')
        								  };
        insert lstRepCode;
        
        lstRepCodeUser = new List<Rep_Code_User__c>{
        												new Rep_Code_User__c(Name = 'Test rep code user 1', Rep_Code__c = lstRepCode[0].Id, User__c = lstUser[0].Id),
        												new Rep_Code_User__c(Name = 'Test rep code user 2', Rep_Code__c = lstRepCode[0].Id, User__c = lstUser[1].Id),
        												new Rep_Code_User__c(Name = 'Test rep code user 3', Rep_Code__c = lstRepCode[1].Id, User__c = lstUser[0].Id),
        												new Rep_Code_User__c(Name = 'Test rep code user 4', Rep_Code__c = lstRepCode[1].Id, User__c = lstUser[1].Id),
        												new Rep_Code_User__c(Name = 'Test rep code user 5', Rep_Code__c = lstRepCode[2].Id, User__c = lstUser[0].Id)
        										   };
        insert lstRepCodeUser;
        
        lstNote = new List<Note__c>{
        								new Note__c(Name = 'Test Note 1', Rep_Code__c = lstRepCode[0].Id),
        								new Note__c(Name = 'Test Note 2', Rep_Code__c = lstRepCode[1].Id),
        								new Note__c(Name = 'Test Note 3', Rep_Code__c = lstRepCode[2].Id),
        								new Note__c(Name = 'Test Note 4', Rep_Code__c = lstRepCode[0].Id),
        								new Note__c(Name = 'Test Note 5', Rep_Code__c = lstRepCode[1].Id),
        								new Note__c(Name = 'Test Note 6', Rep_Code__c = lstRepCode[2].Id)
        							};
        insert lstNote;
    }
    
    //function for checking functionality for creation of sharing records.
    static testMethod void checkForSharing() 
    {
        createData();
        
        System.assertEquals([SELECT COUNT() FROM Note__Share WHERE ParentId=:lstNote[0].Id AND RowCause=:'Manual'], 2);
        System.assertEquals([SELECT COUNT() FROM Note__Share WHERE ParentId=:lstNote[1].Id AND RowCause=:'Manual'], 2);
        System.assertEquals([SELECT COUNT() FROM Note__Share WHERE ParentId=:lstNote[2].Id AND RowCause=:'Manual'], 1);
    }
}