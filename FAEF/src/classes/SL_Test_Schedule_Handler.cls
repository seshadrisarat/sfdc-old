@isTest 
public with sharing class SL_Test_Schedule_Handler 
{
    //Test method for class SL_Schedule_Handler
    static testmethod void test_SL_Schedule_Handler()
    {
    	RecordType objRecordType = [Select Id From RecordType where SobjectType='Account' LIMIT 1];
    	RecordType objRecordType1 = [Select Id From RecordType where SobjectType='Opportunity' LIMIT 1];
    	
    	Account objAccount = new Account(Name = 'Test', RecordTypeId = objRecordType.Id, Master_Lease_Number__c = '2013107');
        Account objAccount2 = new Account(Name = 'Test2', RecordTypeId = objRecordType.Id);
    	insert objAccount;
    	insert objAccount2;        
    	System.assertNotEquals(objAccount.Id, null);
    	
    	Opportunity objOpportunity = new Opportunity(AccountId = objAccount.Id, RecordTypeId = objRecordType1.Id, Name = 'TestOpp', CloseDate = Date.today() + 10 , StageName = 'Lost');
        Opportunity objOpportunity2 = new Opportunity(AccountId = objAccount.Id, RecordTypeId = objRecordType1.Id, Name = 'TestOpp', CloseDate = Date.today() + 10 , StageName = 'Lost');
    	insert objOpportunity;
        insert objOpportunity2;
    	System.assertNotEquals(objOpportunity.Id, null);
    	System.assertEquals(objOpportunity.AccountId, objAccount.Id); 
    	
    	
    	Letter_of_Intent__c sObjLOI = new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id,Account__c = objAccount.Id);
    	insert sObjLOI;
    	
    	Letter_of_Intent__c sObjLOI2 = new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id,Account__c = objAccount2.Id);
    	insert sObjLOI2;
        
        Letter_of_Intent__c sObjLOI3 = new Letter_of_Intent__c(Opportunity__c = objOpportunity2.Id,Account__c = objAccount.Id);
    	insert sObjLOI3;
    	
    	List<Guarantor_Co_Lessee__c> lstGL = new List<Guarantor_Co_Lessee__c>{
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount2.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount2.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount2.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount2.Id),
    																			new Guarantor_Co_Lessee__c(Account__c = objAccount2.Id)
    																		 };
    																		 
    	insert lstGL;
    	List<Funding_Source__c> lstFundingSource = new List<Funding_Source__c>{
    																		  new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id,Funding_Source_Name__c = objAccount.Id),
    																		  new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id,Funding_Source_Name__c = objAccount2.Id),
    																		  new Funding_Source__c(Letter_of_Intent__c = sObjLOI2.Id,Funding_Source_Name__c = objAccount.Id),
    																		  new Funding_Source__c(Letter_of_Intent__c = sObjLOI2.Id,Funding_Source_Name__c = objAccount2.Id)
    																		  };
    	insert lstFundingSource;
    	
    	System.assertNotEquals(sObjLOI.Id, null);
    	
    	List<Schedule__c> lstSchedule = new List<Schedule__c>{
            	new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '00', 
            					Financial_Product__c = 'First Amendment Deal', Selected_FMA_Option__c = 'Option 2 - Extension',
            					Base_Lease_Termination_Date__c = Date.today(), Notice_Days_Required__c = 90, Extension_Period_Months__c = 3,
            					FMA_Purchase_Option_Percent__c = 25, Contract_Extension_Renewal_Frequency__c = 'annual', 
            					Payment_Amount__c = 12000, Stage__c = 'Application Incomplete'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '01',
                				Financial_Product__c = 'First Amendment Deal', Selected_FMA_Option__c = 'Option 1 - Purchase',
            					Base_Lease_Termination_Date__c = Date.today(), Notice_Days_Required__c = 30, 
            					Payment_Frequency__c = 'semi-annual', FMA_Extension_Period_in_Months__c = 8, Extension_Period_Months__c = 3,
            					Contract_Extension_Renewal_Rental_Amount__c = 6000, Stage__c = 'Application Incomplete'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '02',
                				Financial_Product__c = 'First Amendment Deal', Selected_FMA_Option__c = 'Option 2 - Extension',
            					Payment_Frequency__c = 'quarterly', FMA_Extension_Period_in_Months__c = 5,
            					Payment_Amount__c = 3000, Stage__c = 'Application Incomplete'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '03'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '04'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'do not autonumber me',Lessee_PO_Number__c = '05', Is_Dataload__c=true),
                new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '06'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI2.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '07'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI2.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '08'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI2.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '09'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI2.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '10'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI2.Id, Schedule_Number__c = 'Do Not Edit',Lessee_PO_Number__c = '11'),
                new Schedule__c(Letter_of_Intent__c = sObjLOI3.Id,Schedule_Number__c = 'Do Not Edit')
    														 };
    	insert lstSchedule;
    	SL_Schedule_Handler.isFirstUpdateCall = true;
        lstSchedule[1].Stage__c = 'Booked';
        lstSchedule[1].Selected_FMA_Option__c = 'Option 2 - Extension';
        lstSchedule[1].FMA_Extension_Period_in_Months__c = 7;
    	lstSchedule[1].FMA_Extension_Notice_Received__c = Date.today();
    	lstSchedule[1].FMA_Renewal_Effective_Date__c = Date.today();  
        update lstSchedule[1];
        
    	
    	SL_Schedule_Handler.isFirstUpdateCall = true;
        lstSchedule[0].Stage__c = 'Booked';
    	lstSchedule[0].Selected_FMA_Option__c = 'Option 1 - Purchase';
    	lstSchedule[0].FMA_Extension_Notice_Received__c = Date.today().addDays(2);
    	lstSchedule[0].FMA_Renewal_Effective_Date__c = Date.today().addDays(30);
        update lstSchedule[0];
    	
    	SL_Schedule_Handler.isFirstUpdateCall = true;
    	lstSchedule[2].Base_Lease_Termination_Date__c = Date.today();
    	lstSchedule[2].Notice_Days_Required__c = 90;
    	lstSchedule[2].Extension_Period_Months__c = 5;
    	lstSchedule[2].Stage__c = 'Booked';
    	lstSchedule[2].FMA_Extension_Notice_Received__c = Date.today().addDays(2);
    	lstSchedule[2].FMA_Renewal_Effective_Date__c = Date.today().addDays(30);
    	update lstSchedule[2];
    	
    	System.assertEquals(lstSchedule[5].Schedule_Number__c, 'do not autonumber me');
    	System.assertEquals(lstSchedule[4].Letter_of_Intent__c, sObjLOI.Id);
    	System.assertEquals(lstSchedule[7].Letter_of_Intent__c, sObjLOI2.Id);
    	//System.assertEquals([SELECT Schedule_Number__c FROM Schedule__c WHERE Schedule_Number__c = '1234567-01' LIMIT 1].Schedule_Number__c, '1234567-01');
        System.assertEquals([SELECT Id FROM Schedule__c].size(),13);
        System.assertEquals([SELECT Id FROM Schedule__c WHERE Letter_of_Intent__c = :sObjLOI.Id].size(),7);
        System.assertEquals([SELECT Id FROM Schedule__c WHERE Letter_of_Intent__c = :sObjLOI2.Id].size(),5);
        System.assertEquals([SELECT Funding_Source__c FROM Schedule__c WHERE ID =: lstSchedule[0].Id].Funding_Source__c, lstFundingSource[1].Id);
    }
}