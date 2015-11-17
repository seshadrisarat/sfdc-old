/*************************************************************************
Name : Test_BatchAssociateUserAndContact
Author : Reena Acharya
Date : 3 August , 2013
Usage : For test coverage of BatchAssociateUserAndContact
**************************************************************************/
@isTest
private class Test_BatchAssociateUserAndContact {
    @IsTest(SeeAllData=true) 
    static void testBatchAssociateUserAndContact(){
        ID recordTypeID ;
        Schema.DescribeSObjectResult d = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        if(rtMapByName.containsKey('Employee'))
            recordTypeID = rtMapByName.get('Employee').getRecordTypeId();
        
        User usr = [Select id,email from User where id =: userinfo.getuserID()];
            
        contact cont = new Contact(LastName = 'test',recordTypeID = recordTypeID,Email = usr.Email);
        insert cont;
        
        Test.startTest();
        BatchAssociateUserAndContact b = new BatchAssociateUserAndContact ();
        b.query = 'Select id , Email ,User__c from Contact where id= \''+ cont.id + '\'';
        database.executeBatch(b,200);
        Test.stopTest();
    }
}