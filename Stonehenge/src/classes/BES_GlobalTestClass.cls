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
private class BES_GlobalTestClass {

    static testMethod void myUnitTest() 
    {
     	Lead myLead1 = new Lead(lastname = 'Fry', company='Fry And Sons', Property_Name__c = '10 Downing');
		insert myLead1;
		Account myAcc1 = new Account(Name = 'test acc');
		insert myAcc1;
		Database.LeadConvert lc1 = new database.LeadConvert();
		lc1.setLeadId(myLead1.id);
		lc1.setAccountId(myAcc1.id);
		lc1.setConvertedStatus('Qualified');
		lc1.setOpportunityName(myLead1.lastname);
		Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
		
		Lead myLead = new Lead(lastname = 'Fry1', company='Fry And Sons1', Property_Name__c = '10 Downing');
		insert myLead;
		Account myAcc = new Account(Name = 'test acc1');
		insert myAcc;
		
				 
		Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(myLead.id);
		lc.setAccountId(myAcc.id);
		lc.setConvertedStatus('Qualified');
		lc.setDoNotCreateOpportunity(true);
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		
		Property__c objproperty = new Property__c();
		objproperty.Name = 'Test property';
		objproperty.Yardi_ID__c = '123456789012345';
		//insert objproperty;
		
		
		PropertyStaging__c objPS = new PropertyStaging__c();
		objPS.Yardi_ID__c = '108w15st002A';
		objPS.Name = 'Test';
		objPS.Asking_Rent__c = 34;
		objPS.Availability_Date__c = Date.newInstance(2009,01,01);
		objPS.Building_Name__c = 'Test';
		objPS.Current_Rent__c = 67;
		objPS.Current_Tenant_Email__c = 'Test@Test.com';
		objPS.Current_Tenant_Name__c = 'Test';
		objPS.Current_Tenant_Notes__c = 'Test';
		objPS.UnitStatusUpdateDate__c = Date.newInstance(2010,01,28);
		objPS.Current_Tenant_Phone__c = '111-111-1111';
		objPS.Lease_Start_Date__c = Date.newInstance(2009,01,01);
		objPS.Lease_End_Date__c = Date.newInstance(2009,01,01);
		objPS.Lease_Type__c = 'Test';
		objPS.OnsiteID__c = 'Test';
		
		objPS.Move_Out_Date__c = Date.newInstance(2009,01,01);
		objPS.Number_Of_Days_Vacant__c = 56.9;
		objPS.Other_Charges__c = '67';
		objPS.Sq_Feet__c = 45.788;
		
		objPS.Unit_Description__c = 'Test';
		objPS.Unit_Number__c = '45';
		objPS.Unit_Type__c = 'Test';
		System.debug('objPS========='+objPS);
		upsert objPS Yardi_ID__c;
		
		PropertyStaging__c objPS1 = new PropertyStaging__c();
		objPS1.Yardi_ID__c = '123456789012';
		objPS1.Name = 'Test';
		objPS1.Asking_Rent__c = 34;
		objPS1.Availability_Date__c = Date.newInstance(2009,01,01);
		objPS1.Building_Name__c = 'Test';
		objPS1.Current_Rent__c = 67;
		objPS1.Current_Tenant_Email__c = 'Test@Test.com';
		objPS1.Current_Tenant_Name__c = 'Test';
		objPS1.Current_Tenant_Notes__c = 'Test';
		objPS1.UnitStatusUpdateDate__c = Date.newInstance(2010,01,28);
		objPS1.Current_Tenant_Phone__c = '111-111-1111';
		objPS1.Lease_Start_Date__c = Date.newInstance(2009,01,01);
		objPS1.Lease_End_Date__c = Date.newInstance(2009,01,01);
		objPS1.Lease_Type__c = 'Test';
		objPS1.OnsiteID__c = 'Test';
		objPS1.Move_Out_Date__c = Date.newInstance(2009,01,01);
		objPS1.Number_Of_Days_Vacant__c = 56.9;
		objPS1.Other_Charges__c = '67';
		objPS1.Sq_Feet__c = 45.788;
		
		objPS1.Unit_Description__c = 'Test';
		objPS1.Unit_Number__c = '45';
		objPS1.Unit_Type__c = 'Test';
		System.debug('objPS========='+objPS1);
		upsert objPS1 Yardi_ID__c;
		
		objPS.Unit_Status__c = 'Value 1';
		update objPS;
		
		Opportunity objOPR = new Opportunity();
		objOPR.Name = 'TY';
		objOPR.StageName = 'Prospecting';
		objOPR.Approval_Status__c = 'Approved';
		objOPR.AccountId = myAcc.Id;
		objOPR.Property__c = [select Id from Property__c Limit 1].Id;
		objOPR.Close_Date__c = Date.newInstance(2010, 05, 05);
		objOPR.CloseDate = Date.newInstance(2010, 05, 05);
		insert objOPR;
		
	
		Opportunity objOPR1 = new Opportunity(); 
		objOPR1.Name = 'TY';
		objOPR1.StageName = 'Prospecting';
		objOPR1.Approval_Status__c = 'In Process';
		objOPR1.AccountId = myAcc.Id;
		objOPR1.Property__c = [select Id from Property__c Limit 1].Id;
		objOPR1.Close_Date__c = Date.newInstance(2010, 05, 05);
		objOPR1.CloseDate = Date.newInstance(2010, 05, 05);
		insert objOPR1;
		objOPR1.Approval_Status__c = 'Approved';
		update objOPR1; 
		
    }
}