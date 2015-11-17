public with sharing class Spheria_Account_Quick_Create_New {
//	last changed by Rahul, 11th August, http://silverline.jira.com/browse/STONEPII-18
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
		
		
		//sc = new ApexPages.standardController(ppItem);
    	System.currentPageReference().getParameters().put('oppid',objOPR.ID);
    	Spheria_Account_Quick_Create_New SAQCObj = new Spheria_Account_Quick_Create_New();
    	
    	ID testID = SAQCObj.getPersonRecTypeId();
    	
    	SAQCObj.setOppID(SAQCObj.getOppID());
		SAQCObj.setAccObj(SAQCObj.getAccObj());
		SAQCObj.setConObj(SAQCObj.getConObj());
		SAQCObj.setOppContactRoleObj(SAQCObj.getOppContactRoleObj());
		
		SAQCObj.contactObj.FirstName = 'Test Fname';
		SAQCObj.contactObj.LastName = 'Test Lname';
		SAQCObj.contactObj.MobilePhone = '234523452345';
		SAQCObj.contactObj.Email = 'test@yahoo.com';
		SAQCObj.oppContactRoleObj.Role__c = 'Other';
		
		PageReference refPage = SAQCObj.cancel();
		refPage = SAQCObj.save();
    }
	
	
	public Account accObj = new Account();
	public Contact contactObj = new Contact();
	public Contact_Role__c oppContactRoleObj = new Contact_Role__c();
	public String OppID = System.currentPageReference().getParameters().get('oppid');
	
	
	public ID getPersonRecTypeId()
	{
		RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True limit 1];
		return recType.ID;
	}
	
	public String getOppID(){ return OppID;}
	public void setOppID(String inVal){ OppID=inVal;} 
	
	public Spheria_Account_Quick_Create_New() 
	{
		accObj.RecordTypeId = getPersonRecTypeId();
	}
	
	public Account getAccObj(){ return accObj;}
	public void setAccObj(Account inVal){ accObj=inVal;}

	public Contact getConObj(){ return contactObj;}
	public void setConObj(Contact inVal){ contactObj=inVal;}

	public Contact_Role__c getOppContactRoleObj(){ return oppContactRoleObj;}
	public void setOppContactRoleObj(Contact_Role__c inVal){ oppContactRoleObj=inVal;}
	
	public PageReference save() 
    {
    	Integer numberOfContactRoles = 0;
    	
    	accObj.RecordTypeId = getPersonRecTypeId();
    	accObj.FirstName 				= contactObj.FirstName;
    	accObj.LastName 				= contactObj.LastName;
    	
    	accObj.PersonHomePhone 			= contactObj.Phone;
    	accObj.Phone 					= contactObj.Phone;
    	accObj.PersonMobilePhone 		= contactObj.MobilePhone;
    	accObj.PersonEmail 				= contactObj.Email;
		
    	try {
    		upsert accObj;
		    ID pContactID = accObj.Id;
		    /*system.debug(accObj.Id+'----'+accObj.PersonContactId);
		    if(pContactID==null)
		    {
		    	Contact contObj = [Select c.IsPersonAccount, c.Id, c.AccountId From Contact c where c.IsPersonAccount=true and c.AccountId=:accObj.ID limit 1];
		    	if(contObj!=null) pContactID = contObj.ID;
		    }*/
		    
		    
		    numberOfContactRoles = [Select count() From Contact_Role__c Where Opportunity__c =: OppID];
		    
		    oppContactRoleObj.Contact__c = pContactID;
		    oppContactRoleObj.Opportunity__c = OppID;
		    oppContactRoleObj.isAdditionalApplicant__c = (numberOfContactRoles == 0) ? false : true;
		    upsert oppContactRoleObj;
		    
		    PageReference pageRef = new PageReference('/apex/Spheria_Account_Quick_Create_Finish');   
        	pageRef.setRedirect(true);   
        	return pageRef;
		    
    	} catch (DmlException exc) {
        	ApexPages.addMessages(exc);
    	}
    	
    	return null;
    }
    
    public PageReference cancel() 
    {
    	return null;
    }
}