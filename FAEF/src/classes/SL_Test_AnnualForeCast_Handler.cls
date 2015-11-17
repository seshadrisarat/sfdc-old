/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_AnnualForeCast_Handler {

    static testMethod void myUnitTestToPreventDuplicateAnnualForecastForsameSchedule() {
        Account objAcc = new Account(Name = 'Test Acc - 1');
        insert objAcc ;
        system.assert(objAcc.Id != NULL);
        
        Letter_of_Intent__c objLetterofIntent = new Letter_of_Intent__c(Facility_Rating__c = '5', Account__c = objAcc.Id);
        insert objLetterofIntent ;
        system.assert(objLetterofIntent.Id != NULL);
        
        Schedule__c objSchedule1 = new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Test Schedule 1', Count_for_A_A__c = 'Yes');
        Schedule__c objSchedule2 = new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Test Schedule 2', Count_for_A_A__c = 'NO');
		List<Schedule__c> lstScheduleToInsert = new List<Schedule__c>{objSchedule1, objSchedule2};
		insert lstScheduleToInsert ;
		system.assert(lstScheduleToInsert[0].Id != NULL);
		system.assert(lstScheduleToInsert[1].Id != NULL);
		
		Test.StartTest();
		Annual_Forecast__c objAnnualForeCast1 = new Annual_Forecast__c(Fiscal_Year__c = '2014', Schedule__c = lstScheduleToInsert[0].Id);
		Annual_Forecast__c objAnnualForeCast2 = new Annual_Forecast__c(Fiscal_Year__c = '2014', Schedule__c = lstScheduleToInsert[1].Id);       
        List<Annual_Forecast__c> lstAnnualForecastToInsert = new List<Annual_Forecast__c>{objAnnualForeCast1, objAnnualForeCast2};
        insert lstAnnualForecastToInsert;
        system.assert(lstScheduleToInsert[0].Id != NULL);
		system.assert(lstScheduleToInsert[1].Id != NULL);
		
        Annual_Forecast__c objAnnualForeCast3 = new Annual_Forecast__c(Fiscal_Year__c = '2014', Schedule__c = lstScheduleToInsert[0].Id);
        try{
        	insert objAnnualForeCast3;
        }
        catch(DMLException ex){
        	// objAnnualForeCast3 is not inserted
        	system.assert(objAnnualForeCast3.Id == NULL);
        }
        
        //Updating objAnnualForeCast2
        objAnnualForeCast2.Schedule__c = lstScheduleToInsert[0].Id;
        
        try{
        	update objAnnualForeCast2;
        }
        catch(DMLException ex){
        	// objAnnualForeCast2 is not updated to Schedule to objSchedule1 from objSchedule2 
        	system.assertEquals([Select Schedule__c, Id From Annual_Forecast__c Where Id =: objAnnualForeCast2.Id].Schedule__c, lstScheduleToInsert[1].Id);
        	system.assert(ex.getMessage().contains(Label.SL_PreventAnnualForeCastErrorMessage));
        }
        
		//Deleting objAnnualForeCast1 and Updating objAnnualForeCast2 whcih will be successful
        delete  objAnnualForeCast1;
        objAnnualForeCast2.Schedule__c = lstScheduleToInsert[0].Id;
    	update objAnnualForeCast2;
    	// objAnnualForeCast2 is updated to Schedule to objSchedule1 from objSchedule2  as there is only one Schedule and objAnnualForecast1 is deleted
    	system.assertEquals([Select Schedule__c, Id From Annual_Forecast__c Where Id =: objAnnualForeCast2.Id].Schedule__c,  lstScheduleToInsert[0].Id);
    
        try{
        	undelete objAnnualForeCast1;
        }
        catch(DMLException ex){
        	// Not able to undelete objAnnualForeCast1 as  objAnnualForeCast2 has the same Schedule and Forecast year values
        	system.assert(ex.getMessage().contains(Label.SL_PreventAnnualForeCastErrorMessage));
        }
        
        // As objAnnualForeCast1 is not undeleted so in DataBase only one Annual_Forecast__c is there, checking by assert Statement 
        system.assertEquals([Select Schedule__c, Id From Annual_Forecast__c].size(), 1);
        
        Test.stopTest();
    }
}