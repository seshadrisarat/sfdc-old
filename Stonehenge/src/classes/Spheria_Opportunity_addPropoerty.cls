public with sharing class Spheria_Opportunity_addPropoerty {

//   /apex/BES_SendApplicationToContacts?Id=006Q0000003hyFA

	public static testMethod void test()
	{
		Account objAcc = new Account();
    	objAcc.Name = 'Test';
    	insert objAcc;
    	
    	Opportunity objOpp = new Opportunity();
    	objOpp.Name = 'Test';
    	objOpp.StageName = 'Prospecting';
    	Date dtCurr = Date.newInstance(2009, 1, 1);
    	objOpp.CloseDate = dtCurr;
    	objOpp.AccountId = objAcc.Id;
    	insert objOpp;
    	
    	String opportunityId = objOpp.Id;
    	
    	Property__c oppProp = new Property__c();
	    oppProp.Asking_Rent__c = 1.0;
	    oppProp.Availability_Date__c = dtCurr;
	    oppProp.Building_Name__c = 'XYZ';
	    oppProp.Current_Rent__c = 1.0;
	    oppProp.Move_Out_Date__c = dtCurr;
	    oppProp.Name = 'ABC';
	    oppProp.Number_Of_Days_Vacant__c = 1.0;
	    oppProp.Sq_Feet__c = 1.0;
	    oppProp.Unit_Description__c = 'ABC';
	    oppProp.Unit_Number__c = '123';
	    oppProp.Unit_Status__c = 'Value';
	    oppProp.Unit_Type__c = 'ABC';
	    insert oppProp;
    	
    	Property_to_Opportunity_Connector__c objpoc = new Property_to_Opportunity_Connector__c();
    	objpoc.Property__c = oppProp.Id;
    	objpoc.Opportunity__c = objOpp.Id;
    	insert objpoc;
    	
    	OpportunityContactRole objOCR = [Select Id,Role,Opportunity.Name,OpportunityId,Contact.Name,Contact.Email,ContactId From OpportunityContactRole limit 1 ];//new OpportunityContactRole();
    	    	
    	//String propOpp = objPOC.Id;
    	
        ApexPages.CurrentPage().getParameters().put('id',objOpp.Id);
        
        Spheria_Opportunity_addPropoerty objClass = new Spheria_Opportunity_addPropoerty();
        objClass.opportunityId = opportunityId;
        Opportunity tmpOpp = objClass.getOppObj();
        tmpOpp.Property__c = oppProp.ID;
        objClass.setOppObj(tmpOpp);
        
        Pagereference refPage = objClass.SaveProperty();
        refPage = objClass.cancelAddProperty();
        refPage = objClass.SendApplicationsToRecipents();
        
	}

    public string opportunityId
    {	get; set;	}

    public Opportunity oppObj = new Opportunity();
    
	public Opportunity getOppObj(){ return oppObj;}
	public void setOppObj(Opportunity inVal){ oppObj=inVal;}

	public Spheria_Opportunity_addPropoerty()
	{
		opportunityId = System.currentPageReference().getParameters().get('Id');
	}	

	
	public Pagereference SaveProperty()
    {
    	if(oppObj.Property__c!=null && opportunityId!=null && opportunityId!='')
    	{
    		for(Opportunity oppObjCurr:[select ID,Property__c from Opportunity where ID=:opportunityId limit 1])
    		{
    			oppObjCurr.Property__c = oppObj.Property__c;
    			update oppObjCurr;
    		} 
    	}
    	
    	Pagereference pr = new PageReference('/' +opportunityId);    	
    	return pr;
    }
    
    
	public Pagereference cancelAddProperty()
    {

    	Pagereference pr = new PageReference('/' +opportunityId);    	
    	return pr;
    }
    
    public Pagereference SendApplicationsToRecipents()
    {
    	if(oppObj.Property__c!=null && opportunityId!=null && opportunityId!='')
    	{
    		for(Opportunity oppObjCurr:[select ID,Property__c from Opportunity where ID=:opportunityId limit 1])
    		{
    			oppObjCurr.Property__c = oppObj.Property__c;
    			update oppObjCurr;
    		} 
    	}

    	Pagereference pr = new PageReference('/apex/BES_SendApplicationToContacts?Id=' +opportunityId);    	
    	return pr;
    }
}