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
private class SL_Test_StonehengeP2  
{
    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
    }
    
    //	SL_SchedulerToCreateRenewalOpportunity
    static testMethod void SL_SchedulerToCreateRenewalOpportunity() 
    {
    	//	Test class for - Scheduler : SL_SchedulerToCreateRenewalOpportunity and Batch : SL_BatchToCreateRenewalOpportunity
        // TO DO: implement unit test
        
        
        Test.startTest();
        
        Account objAcc1 = new Account(Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		Property__c objProperty = new Property__c(Name = 'Test Property' );
 		insert objProperty;
 		Opportunity objOpp1 = new Opportunity(Property__c = objProperty.Id,StageName = 'Signed Lease', Lease_Approved__c = True, Application_Approved__c = True, Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		
 		Contact_Role__c objCR2 = new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Guarantor');
 		insert objCR2;
 		
 		
        Prior_LeaseEndDate_Timespan__c objPrior = new Prior_LeaseEndDate_Timespan__c ( Name = 'NumberOfDays' , Timespan__c = 30.0 );
 		insert objPrior;
 		
 		
 		 
        SL_SchedulerToCreateRenewalOpportunity objSch = new SL_SchedulerToCreateRenewalOpportunity();
        // objSch.strQuery = 'Select Account__c, Name, Id, Lease_End_Date__c, Building__r.Renewal_Leasing_Agent__c, Opportunity__c from Property__c';
        database.executeBatch(new SL_BatchToCreateRenewalOpportunity('Select Account__c, Name, Id, Lease_End_Date__c, Building__r.Renewal_Leasing_Agent__c, Opportunity__c,'+
						'(Select Contact__c, Role__c From Current_Tenants__r) From Property__c where Lease_End_Date__c != null and Lease_Type__c != \'RS\'' +
						' and ' + 
						'Lease_End_Date__c <= :PriorLeaseEndDate and Opportunity__r.StageName = \'Signed Lease\'' ,objProperty.Lease_End_Date__c));
		SL_BatchToCreateRenewalOpportunity.runTestMethod = true;
        SchedulableContext SC;
        objSch.execute(SC);
        
        Test.stopTest();
    } 
    
    static testMethod void SL_BatchToCreateRenewalOpportunity()
    {
    	Test.startTest();
        Account objAcc1 = new Account(Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		
 		Opportunity objOpp1 = new Opportunity(StageName = 'Signed Lease', Lease_Approved__c = True, Application_Approved__c = True, Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		
 		Property__c objProperty = new Property__c(Opportunity__c= objOpp1.Id, Name = 'Test Property', Lease_End_Date__c = Date.Today(), Lease_Type__c = 'RX');
 		insert objProperty;
 		
 		Contact_Role__c objCR2 = new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Guarantor');
 		insert objCR2;
 		
 		
        Prior_LeaseEndDate_Timespan__c objPrior = new Prior_LeaseEndDate_Timespan__c ( Name = 'NumberOfDays' , Timespan__c = 30.0 );
 		insert objPrior;
 		String query ='Select Account__c, Name, Id, Lease_End_Date__c, Building__r.Renewal_Leasing_Agent__c, Opportunity__c,'+
						'(Select Contact__c, Role__c From Current_Tenants__r) From Property__c where Lease_End_Date__c != null and Lease_Type__c != \'RS\'' +
						' and ' + 
						'Lease_End_Date__c <= :PriorLeaseEndDate and Opportunity__r.StageName = \'Signed Lease\'' ;
 		SL_BatchToCreateRenewalOpportunity bc = new SL_BatchToCreateRenewalOpportunity(query , Date.Today() + 400);
 		
		
		Database.executeBatch(bc, 200);
		Test.stopTest();
    }
    
    static testMethod void BES_SendApplicationToContacts() 
    {
    	
        // TO DO: implement unit test
       	Test.startTest();
        
        BES_SendApplicationToContacts_New objSendApptoCon = new BES_SendApplicationToContacts_New();
        objSendApptoCon.getSearchResults();
        objSendApptoCon.getsearchResult();
        
		Account objAcc1 = new Account(FirstName = 'T', PersonEmail = 'mail.trekbin@rediffmail.com', Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		Opportunity objOpp1 = new Opportunity(Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', StageName = 'Appointments', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		Account objAcc2 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 002' );
 		insert objAcc2;
 		Account objAcc3 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 003' );
 		insert objAcc3;
 		Account objAcc4 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 004' );
 		insert objAcc4;
 		List<Contact_Role__c> lstCR = new List<Contact_Role__c>(); 
 		lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id));
 		insert lstCR;
 		
    	Property__c objProperty = new Property__c(Asking_Rent__c = 1.0,
											    Availability_Date__c = Date.newInstance(2009, 1, 1),
											    Building_Name__c = 'XYZ',
											    Current_Rent__c = 1.0,
											    Move_Out_Date__c = Date.newInstance(2009, 1, 1),
											    Name = 'ABC',
											    Number_Of_Days_Vacant__c = 1.0,
											    Sq_Feet__c = 1.0,
											    Unit_Description__c = 'ABC',
											    Unit_Number__c = '123',
											    Unit_Status__c = 'Value',
											    Unit_Type__c = 'ABC',
												OnsiteID__c = '123456'
											);
	    
	    insert objProperty;
	    
	    Property_to_Opportunity_Connector__c objPropOppConn = new Property_to_Opportunity_Connector__c(
																							    Account__c = objAcc1.Id,
																						    	Approval_Status__c = 'In Process',
																						    	Name = 'test',
																						    	Opportunity__c = objOpp1.Id,
																						    	Property__c = objProperty.Id,
																						    	Show_Date__c = DateTime.newInstance(2009,1,1),
																						    	Status__c = 'In Progress'
																						    );
    	insert objPropOppConn;
    	objSendApptoCon.SendApplicationsToRecipents();
 		ApexPages.CurrentPage().getParameters().put('id',objOpp1.Id);
 		ApexPages.CurrentPage().getParameters().put('propId',objPropOppConn.Id);
        objSendApptoCon = new BES_SendApplicationToContacts_New();
        objSendApptoCon.PreviousBtnClick();
        objSendApptoCon.NextBtnClick();
        
        objSendApptoCon.hidRecIds = [Select Id from Contact_Role__c where Opportunity__c =: objOpp1.Id limit 1].Id;
    	objSendApptoCon.ResetPaging();
    	objSendApptoCon.cancelAddProperty();
    	Integer valueofInt = objSendApptoCon.getTotalPageNumber();
    	valueofInt = objSendApptoCon.getPageNumber();
    	valueofInt = objSendApptoCon.getPageSize();
    	if(objSendApptoCon.MySearchObject.size() > 0)
    	{
    		objSendApptoCon.MySearchObject[0].selected = true; 
    	//objSendApptoCon.MySearchObject[2].selected = true; 
    	
    	objSendApptoCon.MySelectedSearchObject.add(objSendApptoCon.MySearchObject[0]);
    	objSendApptoCon.MySearchObject_Paging.add(objSendApptoCon.MySearchObject[0]);
    	objSendApptoCon.MySearchObjectClone.add(objSendApptoCon.MySearchObject[0]);
    	}
    	
    	//system.debug(objSendApptoCon.MySelectedSearchObject+'@@@@@'+objSendApptoCon.MySearchObject);
    	objSendApptoCon.GetIds();
    	objSendApptoCon.isWebServiceError = false;
    	objSendApptoCon.isApexTest = true; 
    	objSendApptoCon.SendApplicationsToRecipents();
    	
    	   	
        Test.stopTest();
    }
     
    static testMethod void BES_Submit_Application_For_Approval() 
    {
        // TO DO: implement unit test
        
        Test.startTest();
        
        BES_Submit_Application_For_Approval_New objSendApp1 = new BES_Submit_Application_For_Approval_New();
    	objSendApp1.ResetPaging();
    	objSendApp1.getsearchPropertyResult();
    	Integer PageDetail1 = objSendApp1.getPageNumber();
    	PageDetail1 = objSendApp1.getPageSize();
    	PageDetail1 = objSendApp1.getTotalPageNumber();
    	Boolean isValue1 = objSendApp1.getPreviousButtonEnabled();
    	isValue1 = objSendApp1.getNextButtonDisabled();
    	objSendApp1.autoRun();
    	objSendApp1.NextBtnClick();
    	objSendApp1.PreviousBtnClick();
    	objSendApp1.selectUnitForApproval();
    	objSendApp1.selectUnitForApprovalAndFinish();
    	objSendApp1.cancelSubmitApproval();
    	
    	
        Account objAcc1 = new Account(Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		Opportunity objOpp1 = new Opportunity(Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', StageName = 'Appointments', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		Account objAcc2 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 002' );
 		insert objAcc2;
 		Account objAcc3 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 003' );
 		insert objAcc3;
 		Account objAcc4 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 004' );
 		insert objAcc4;
 		List<Contact_Role__c> lstCR = new List<Contact_Role__c>(); 
 		
 		
    	Property__c objProperty = new Property__c(Asking_Rent__c = 1.0,
											    Availability_Date__c = Date.newInstance(2009, 1, 1),
											    Building_Name__c = 'XYZ',
											    Current_Rent__c = 1.0,
											    Move_Out_Date__c = Date.newInstance(2009, 1, 1),
											    Name = 'ABC',
											    Number_Of_Days_Vacant__c = 1.0,
											    Sq_Feet__c = 1.0,
											    Unit_Description__c = 'ABC',
											    Unit_Number__c = '123',
											    Unit_Status__c = 'Value',
											    Unit_Type__c = 'ABC'
											);
	    
	    insert objProperty;
	    
	    Property_to_Opportunity_Connector__c objPropOppConn = new Property_to_Opportunity_Connector__c(
																							    Account__c = objAcc1.Id,
																						    	Approval_Status__c = 'In Process',
																						    	Name = 'test',
																						    	Opportunity__c = objOpp1.Id,
																						    	Property__c = objProperty.Id,
																						    	Show_Date__c = DateTime.newInstance(2009,1,1),
																						    	Status__c = 'In Progress'
																						    );
    	insert objPropOppConn;
 		
 		ApexPages.CurrentPage().getParameters().put('id',objOpp1.Id);
 		
    	BES_Submit_Application_For_Approval objSendApp = new BES_Submit_Application_For_Approval();
    	objSendApp.hidRecIds = objPropOppConn.Id;
    	Integer PageDetail = objSendApp.getPageNumber();
    	PageDetail = objSendApp.getPageSize();
    	PageDetail = objSendApp.getTotalPageNumber();
    	Boolean isValue = objSendApp.getPreviousButtonEnabled();
    	isValue = objSendApp.getNextButtonDisabled();
    	objSendApp.autoRun();
    	objSendApp.ResetPaging();
    	objSendApp.NextBtnClick();
    	objSendApp.PreviousBtnClick();
    	objSendApp.selectUnitForApproval();
    	objSendApp.selectUnitForApprovalAndFinish();
    	objSendApp.cancelSubmitApproval();
    	objSendApp.getsearchPropertyResult();
    	
        Test.stopTest();
    }
    
    static testMethod void SL_OpportunityTriggerTest() 
    {
    	RecordType objRecordTypeOpportunity = [Select Id, Name From RecordType where SobjectType =: 'Opportunity' AND Name =: 'Renewal Opportunity' LIMIT 1];
    	RecordType objRecordTypeAccount = [Select Id, Name From RecordType where SobjectType =: 'Account' AND Name =: 'Client/Tenant Account' LIMIT 1];
    	RecordType objRecordTypeOpp2 = [Select Id, Name From RecordType where SobjectType =: 'Opportunity' AND Name =: 'New Lease Opportunity' LIMIT 1];
    	
    	Account objAccount = new Account(RecordTypeId = objRecordTypeAccount.Id, LastName = 'Test Account 1'
            );
    	insert objAccount;
    	
    	Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                                           Zip_Code__c = '1232123', Studio_Units__c = 12,  Studio_Plus_Units__c = 12,
                                                                           One_Bedroom_Units__c = 12, One_Bedroom_Plus_Units__c = 12,
                                                                          Two_Bedroom_Units__c = 12, Two_Bedroom_Plus_Units__c = 12, 
                                                                          Three_Bedroom_Units__c = 12, Three_Bedroom_Plus_Units__c = 12,
                                                                          Four_Bedroom_Units__c = 12, Four_Bedroom_Plus_Units__c = 12,
                                                                          Penthouse_Units__c = 12 ); 
    	insert objBuilding;
    	
    	Property__c objProperty = new Property__c(Name='Test Property 1', Building_Code__c = '4200', Building__c = objBuilding.Id);
    	insert objProperty;
    	
    	Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity 1',RecordTypeId=objRecordTypeOpp2.Id, Property__c = objProperty.Id,Account=objAccount, CloseDate = date.today().addDays(20), StageName='Appointments');
    	insert objOpportunity;
    	
    	objOpportunity.RecordTypeId = objRecordTypeOpportunity.Id;
    	objOpportunity.StageName = 'Closed Lost';
    	update objOpportunity;
    	
    	Opportunity objOpportunity2 = new Opportunity(Name = 'Test Opportunity 2',RecordTypeId=objRecordTypeOpportunity.Id, Property__c = objProperty.Id,Account=objAccount, CloseDate = date.today().addDays(20), StageName='Lease signed by tenant', Application_Approved__c = true);
    	insert objOpportunity2;
    	
		objOpportunity2.RecordTypeId = objRecordTypeOpp2.Id;
    	objOpportunity2.StageName = 'Signed Lease';
    	update objOpportunity2;
    }
    
    /*static testMethod void SL_Send_Lease_ShowContacts() 
    {
    	
        // TO DO: implement unit test
       	Test.startTest();
        
        SL_Send_Lease_ShowContacts objSendApptoCon = new SL_Send_Lease_ShowContacts();
        objSendApptoCon.getSearchResults();
        objSendApptoCon.getsearchResult();
        
		Account objAcc1 = new Account(FirstName = 'T', PersonEmail = 'mail.trekbin@rediffmail.com', Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		Opportunity objOpp1 = new Opportunity(Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', StageName = 'Appointments', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		Account objAcc2 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 002' );
 		insert objAcc2;
 		Account objAcc3 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 003' );
 		insert objAcc3;
 		Account objAcc4 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 004' );
 		insert objAcc4;
 		List<Contact_Role__c> lstCR = new List<Contact_Role__c>(); 
 		lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant'));
 		insert lstCR;
 		
    	Property__c objProperty = new Property__c(Asking_Rent__c = 1.0,
											    Availability_Date__c = Date.newInstance(2009, 1, 1),
											    Building_Name__c = 'XYZ',
											    Current_Rent__c = 1.0,
											    Move_Out_Date__c = Date.newInstance(2009, 1, 1),
											    Name = 'ABC',
											    Number_Of_Days_Vacant__c = 1.0,
											    Sq_Feet__c = 1.0,
											    Unit_Description__c = 'ABC',
											    Unit_Number__c = '123',
											    Unit_Status__c = 'Value',
											    Unit_Type__c = 'ABC',
												OnsiteID__c = '123456'
											);
	    
	    insert objProperty;
	    
	    Property_to_Opportunity_Connector__c objPropOppConn = new Property_to_Opportunity_Connector__c(
																							    Account__c = objAcc1.Id,
																						    	Approval_Status__c = 'In Process',
																						    	Name = 'test',
																						    	Opportunity__c = objOpp1.Id,
																						    	Property__c = objProperty.Id,
																						    	Show_Date__c = DateTime.newInstance(2009,1,1),
																						    	Status__c = 'In Progress'
																						    );
    	insert objPropOppConn;
    	objSendApptoCon.SendApplicationsToRecipents();
 		ApexPages.CurrentPage().getParameters().put('id',objOpp1.Id);
 		ApexPages.CurrentPage().getParameters().put('propId',objProperty.Id);
        objSendApptoCon = new SL_Send_Lease_ShowContacts();
        objSendApptoCon.PreviousBtnClick();
        objSendApptoCon.NextBtnClick();
        
        objSendApptoCon.hidRecIds = [Select Id from Contact_Role__c where Opportunity__c =: objOpp1.Id limit 1].Id;
    	objSendApptoCon.ResetPaging();
    	objSendApptoCon.cancelAddProperty();
    	Integer valueofInt = objSendApptoCon.getTotalPageNumber();
    	valueofInt = objSendApptoCon.getPageNumber();
    	valueofInt = objSendApptoCon.getPageSize();
    	objSendApptoCon.MySearchObject[0].selected = true; 
    	//objSendApptoCon.MySearchObject[2].selected = true; 
    	
    	objSendApptoCon.MySelectedSearchObject.add(objSendApptoCon.MySearchObject[0]);
    	objSendApptoCon.MySearchObject_Paging.add(objSendApptoCon.MySearchObject[0]);
    	objSendApptoCon.MySearchObjectClone.add(objSendApptoCon.MySearchObject[0]);
    	
    	system.debug(objSendApptoCon.MySelectedSearchObject+'@@@@@'+objSendApptoCon.MySearchObject);
    	objSendApptoCon.GetIds();
    	objSendApptoCon.isWebServiceError = false;
    	objSendApptoCon.isApexTest = true; 
    	objSendApptoCon.SendApplicationsToRecipents();
    	
    	
    	objAcc1.Country__c = '';
    	objAcc1.City__c = '';
    	objAcc1.State1__c = '';
    	update objAcc1;
    	
    	
        Test.stopTest();
    }*/
     
    /*static testMethod void SL_Send_Lease() 
    {
        // TO DO: implement unit test
        
        Test.startTest();
        
        SL_Send_Lease objSendApp1 = new SL_Send_Lease();
    	objSendApp1.ResetPaging();
    	objSendApp1.getsearchPropertyResult();
    	Integer PageDetail1 = objSendApp1.getPageNumber();
    	PageDetail1 = objSendApp1.getPageSize();
    	PageDetail1 = objSendApp1.getTotalPageNumber();
    	Boolean isValue1 = objSendApp1.getPreviousButtonEnabled();
    	isValue1 = objSendApp1.getNextButtonDisabled();
    	objSendApp1.autoRun();
    	objSendApp1.NextBtnClick();
    	objSendApp1.PreviousBtnClick();
    	objSendApp1.selectUnitForApproval();
    	objSendApp1.selectUnitForApprovalAndFinish();
    	objSendApp1.cancelSubmitApproval();
    	
    	
        Account objAcc1 = new Account(Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		Opportunity objOpp1 = new Opportunity(Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', StageName = 'Appointments', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		Account objAcc2 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 002' );
 		insert objAcc2;
 		Account objAcc3 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 003' );
 		insert objAcc3;
 		Account objAcc4 = new Account(PersonEmail = 'mail.trekbin@rediffmail.com', LastName = 'Test Account 004' );
 		insert objAcc4;
 		List<Contact_Role__c> lstCR = new List<Contact_Role__c>(); 
 		/*lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant'));
 		insert lstCR;*/
 		
    	/* Property__c objProperty = new Property__c(Asking_Rent__c = 1.0,
											    Availability_Date__c = Date.newInstance(2009, 1, 1),
											    Building_Name__c = 'XYZ',
											    Current_Rent__c = 1.0,
											    Move_Out_Date__c = Date.newInstance(2009, 1, 1),
											    Name = 'ABC',
											    Number_Of_Days_Vacant__c = 1.0,
											    Sq_Feet__c = 1.0,
											    Unit_Description__c = 'ABC',
											    Unit_Number__c = '123',
											    Unit_Status__c = 'Value',
											    Unit_Type__c = 'ABC'
											);
	    
	    insert objProperty;
	    
	    Property_to_Opportunity_Connector__c objPropOppConn = new Property_to_Opportunity_Connector__c(
																							    Account__c = objAcc1.Id,
																						    	Approval_Status__c = 'In Process',
																						    	Name = 'test',
																						    	Opportunity__c = objOpp1.Id,
																						    	Property__c = objProperty.Id,
																						    	Show_Date__c = DateTime.newInstance(2009,1,1),
																						    	Status__c = 'In Progress'
																						    );
    	insert objPropOppConn;
 		
 		ApexPages.CurrentPage().getParameters().put('id',objOpp1.Id);
 		
    	SL_Send_Lease objSendApp = new SL_Send_Lease();
    	objSendApp.hidRecIds = objPropOppConn.Id;
    	Integer PageDetail = objSendApp.getPageNumber();
    	PageDetail = objSendApp.getPageSize();
    	PageDetail = objSendApp.getTotalPageNumber();
    	Boolean isValue = objSendApp.getPreviousButtonEnabled();
    	isValue = objSendApp.getNextButtonDisabled();
    	objSendApp.autoRun();
    	objSendApp.ResetPaging();
    	objSendApp.NextBtnClick();
    	objSendApp.PreviousBtnClick();
    	objSendApp.selectUnitForApproval();
    	objSendApp.selectUnitForApprovalAndFinish();
    	objSendApp.cancelSubmitApproval();
    	objSendApp.getsearchPropertyResult();
    	
        Test.stopTest();
    }*/
}