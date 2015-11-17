/*******************************************************************************
Name : Test_loadCompaniesController
Created By : Reena Acharya(Appirio Offshore)
Created Date : 11th April,2013
Description : Test coverage of loadCompaniesController class 
*******************************************************************************/
@isTest
private class Test_loadCompaniesController{

     @isTest
     static void loadCompaniesController(){
         
         //A conference award should be created.
         loadAwardsController load = new loadAwardsController();
         load.awards.get(0).Name = 'test 1';
         load.UplaodAwards();
         
         Conference_Award__c  confAward = [Select id ,Name,Description__c from Conference_Award__c  where name = 'test 1'];
         system.assertEquals(confAward.Name , 'test 1');
         system.assertEquals(confAward.Description__c , null);
         
         loadCompaniesController loadComp = new loadCompaniesController();
         loadComp.selectConfAward.Conference_Award__c  = confAward.ID;
         loadComp.objectList.get(0).Account.Name = 'test';
         loadComp.objectList.get(0).compFin.Revenue_MM__c = 1000;
         loadComp.objectList.get(0).compConf.Rank__c = 5;
         loadComp.UplaodCompanies();
         
         loadComp.UplaodMoreCompanies();
         
         
         loadComp.objectList.get(0).Account.Name = 'test';
         loadComp.objectList.get(0).compFin.Revenue_MM__c = 1000;
         loadComp.objectList.get(0).compConf.Rank__c = 5;
         loadComp.UplaodCompanies();
         
         
     }   
}