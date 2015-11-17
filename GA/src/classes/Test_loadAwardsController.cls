/*******************************************************************************
Name : Test_loadAwardsController
Created By : Reena Acharya(Appirio Offshore)
Created Date : 11th April,2013
Description : Test coverage of loadAwardsController class 
*******************************************************************************/
@isTest
private class Test_loadAwardsController{

     @isTest
     static void loadAwardsController(){
         
         //A conference award should be created.
         loadAwardsController load = new loadAwardsController();
         load.awards.get(0).Name = 'test 1';
         load.UplaodAwards();
         
         Conference_Award__c  confAward = [Select id ,Name,Description__c from Conference_Award__c  where name = 'test 1'];
         system.assertEquals(confAward.Name , 'test 1');
         system.assertEquals(confAward.Description__c , null);
         
         //Description should be updated.
         load.UplaodMoreAwards();
         load.awards.get(0).Name = 'test 1';
         load.awards.get(0).Description__c = 'test';
         load.UplaodAwards();
         confAward = [Select id ,Name,Description__c from Conference_Award__c  where name =  'test 1'];
         system.assertEquals(confAward.Name , 'test 1');
         system.assertEquals(confAward.Description__c , 'test');
         
     }   
}