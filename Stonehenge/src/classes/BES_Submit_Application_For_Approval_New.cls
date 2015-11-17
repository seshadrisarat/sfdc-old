public class BES_Submit_Application_For_Approval_New
{
	public Integer PageNumber;
    public Integer PageSize;
    public Integer totalPageNumber;
    public Integer newPageIndex = 1;
	
	public string hidRecIds
	{	get;set;	}
	public Boolean ShowContacts
	{	get;set;	}
	public string opportunityId
	{	get;set;	}
	
	public string whereClause
	{	get;set;	}
	
	public Boolean renderTable
	{	get;set;	}
	
	public Boolean renderNoRecords
	{	get;set;	}
	
	public String OpportunityName
	{	get;set;	}
	
	public String BES_Error
	{	get;set;	}
	Public Boolean BES_IsDisable
	{
		get;set;
	}
	public Boolean BES_IsError
	{	get;set;	}
	public List<SelectOption> options;
	List<Contact_Role__c> lstWithOutContactEmailOCRole = new List<Contact_Role__c>();
	List<Contact_Role__c> lstWithEmailOCRole = new List<Contact_Role__c>();
	List<Contact_Role__c> lstOCRole 
	{get;set;}
	string Email = '';
	/*	Constructor		*/
	public BES_Submit_Application_For_Approval_New()
	{
		lstOCRole = new List<Contact_Role__c>();
		PageNumber = 0;
        totalPageNumber = 0;
        PageSize = 6;
        whereClause = '';
        //txtSearchVal = '';
        ShowContacts = false;
        OpportunityName = '';
        opportunityId = System.currentPageReference().getParameters().get('id');
        //	Check Whether any Contact role with Role as Tenant or Guarantor with a valid Contact Email exists
        if(opportunityId != null && opportunityId != '')
        {
        	for(Contact_Role__c objCR: [Select Contact__c, Contact__r.PersonEmail , Role__c, Opportunity__c, Opportunity__r.Name From Contact_Role__c  where Opportunity__c =: opportunityId])
        	{
        		lstOCRole.add(objCR);
        	}
			if(!lstOCRole.isEmpty())
				OpportunityName = lstOCRole[0].Opportunity__r.Name;
				for(Integer i=0;i<lstOCRole.size();i++)
				{
						if((lstOCRole[i].Contact__r.PersonEmail == null) || (lstOCRole[i].Role__c != 'Tenant' && lstOCRole[i].Role__c != 'Guarantor'))
							lstWithOutContactEmailOCRole.add(lstOCRole[i]);
						else
							lstWithEmailOCRole.add(lstOCRole[i]);
				}
			if(lstWithEmailOCRole.size() > 0)
			{
				getsearchPropertyResults();
				ShowContacts = true;
			}
        }
	}
	public PageReference autoRun()
	{
		PageReference pr ;
		if(lstWithEmailOCRole.size() <= 0)
		{
			pr = new PageReference('/apex/BES_showContacts_New?Id='+ opportunityId);
			pr.setRedirect(true); 
        	return pr; 
		}
		else
		{
			return null;
		}
	}
	
	public PageReference getsearchPropertyResults()
    {
    	PageNumber = 0;  
        getsearchPropertyResultsByPaging(1);        
        return null;
    }
    
    public PageReference ResetPaging()
    {
        PageNumber = 0;
        totalPageNumber = 0;
        PageSize = 6;
        MySearchObject_Paging = new List<searchObject>();
        renderTable = false;
    	renderNoRecords = true;
    	BES_IsDisable = true; 
        return null;
    }
    
    public Integer getPageNumber()
    {
        return PageNumber;
    }
    
	public PageReference NextBtnClick() 
    {      
    	getsearchPropertyResultsByPaging(PageNumber + 1);
        return null;
    }
    
    public PageReference PreviousBtnClick() 
    {        
    	getsearchPropertyResultsByPaging(PageNumber - 1);        
        return null;
    }
    
    public Boolean getPreviousButtonEnabled()
    {
        return !(PageNumber > 1);
    }
    
    public Boolean getNextButtonDisabled()
    {
        if (MySearchObject == null) 
            return true;    
        else
            return ((PageNumber * PageSize) >= MySearchObject.size());
    }
    
    public Integer getTotalPageNumber()
    {
        if (totalPageNumber == 0 && MySearchObject !=null)
        {
            totalPageNumber = MySearchObject.size() / PageSize;
            Integer mod = MySearchObject.size() - (totalPageNumber * PageSize);
            if (mod > 0)
            totalPageNumber++;
        }
        return totalPageNumber;
    }
    
    public Integer getPageSize()
    {
        return PageSize;
    }
	
	List<searchobject> MysearchObject;
	public class searchobject
	{
		public string recId {get;set;}
		public string recPropertyId {get;set;}
		public string BldgName {get;set;}
		public string UnitNo {get;set;}
		public string UnitType {get;set;}
		public string AskingRent {get;set;}
		public string UnitStatus {get;set;}
		public Boolean selected{get; set;}
		public string recDaysVacant {get;set;}
		public string recLastRent {get;set;}
		public string recEstCompletionDate {get;set;}
		public string recUnitSF {get;set;}
		 
		public searchObject(Property_to_Opportunity_Connector__c proOpp, Boolean s)
        {            
			recId = proOpp.Id;
			recPropertyId = proOpp.Property__c;
			BldgName = proOpp.Property__r.Building_Name__c;
			if(proOpp.Property__r.Unit_Number__c != null)
				UnitNo = proOpp.Property__r.Unit_Number__c;
			else
				UnitNo = '0';
			
			if(proOpp.Property__r.Unit_Type__c != null)
				UnitType = proOpp.Property__r.Unit_Type__c;
			else
				UnitType = '';
				
			if(proOpp.Property__r.Asking_Rent__c != null)	
        		AskingRent = String.valueOf(proOpp.Property__r.Asking_Rent__c);
        	else
        		AskingRent = '0';
        		
        	if(proOpp.Property__r.Current_Rent__c != null)        	
        		recLastRent = String.valueOf(proOpp.Property__r.Current_Rent__c);
        	else
        		recLastRent = '0';
        		
        	if(proOpp.Property__r.Availability_Date__c != null)
        		recEstCompletionDate = proOpp.Property__r.Availability_Date__c.format();
        	else
        		recEstCompletionDate = '';
        		
        	if(proOpp.Property__r.Number_Of_Days_Vacant__c != null)
        		recDaysVacant = String.valueOf(proOpp.Property__r.Number_Of_Days_Vacant__c);
        	else
        		recDaysVacant = '';
        				
        	if(proOpp.Property__r.Sq_Feet__c != null)
        		recUnitSF = String.valueOf(proOpp.Property__r.Sq_Feet__c);
        	else
        		recUnitSF = '';
        		 
        	if(proOpp.Property__r.Unit_Status__c != null)	 		
				UnitStatus = proOpp.Property__r.Unit_Status__c;
			else
				UnitStatus = '';
				
            selected = s;
        }
	}
	
	public list<searchObject> getsearchPropertyResult()
    { 
        if(MySearchObject_Paging != null && MySearchObject_Paging.size() > 0)
		{   	  
	        return MySearchObject_Paging;	           
	    }
	    else
	    {
	        ResetPaging();		            	
	        return null;	            
	    }
    }    
	
	public list<searchObject> MySearchObject_Paging;
    public list<searchObject> getsearchPropertyResultsByPaging(Integer newPageIndex)
    {  
    	MySearchObject = new List<searchObject>();  
        MySearchObject_Paging = new List<searchObject>();
         Opportunity currentOpp = new Opportunity();
        if(opportunityId != null && opportunityId != '')
        {
	      	currentOpp = [Select Property__c From Opportunity Where Id =: opportunityId];
	        if(whereClause == '' || whereClause == null)
	        {
	        	whereClause = 'where Opportunity__c=\'' + opportunityId + '\' and (Status__c = \'Open\' or Status__c = \'In Progress\')';        	       
	        }   
        }    
		List<Property_to_Opportunity_Connector__c> lstPropToOppConnector = Database.query('SELECT Id, Name,Property__r.Unit_Status__c,Property__r.Current_Rent__c,Property__r.Sq_Feet__c,Property__r.Availability_Date__c,Property__r.Asking_Rent__c,Property__r.Number_Of_Days_Vacant__c, Property__r.Unit_Type__c, Property__r.Unit_Number__c, Property__r.Building_Name__c, Property__c, Opportunity__c FROM Property_to_Opportunity_Connector__c ' + whereClause + ' order by Property__r.Building_Name__c limit 1000');
		for(Integer j = 0; j < lstPropToOppConnector.size(); j++)
		{			
			Boolean temp = false;
			if(currentOpp.Property__c == lstPropToOppConnector[j].Property__c)
				temp = true;
			searchObject objSearch = new searchObject(lstPropToOppConnector[j], temp);
			MySearchObject.add(objSearch);					          
		}
		MySearchObject_Paging = new List<searchObject>();		
        if(MySearchObject != null && MySearchObject.size() > 0)
        {           
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            Integer PNum;
            Integer PSize;
            totalPageNumber = 0;
            PNum = PageNumber;
            PSize = PageSize;
			if (newPageIndex > PNum)
            {
                min = PNum * PSize;
                max = newPageIndex * PSize;
            }
            else
            {
                max = ( PNum -1 ) * PSize;
                min = max - PSize;                
            }
            System.Debug('MySearchObject2 = ' + MySearchObject.size());
             for(searchObject c : MySearchObject)
            {
                counter++;
                if (counter > min && counter <= max)
                {                    
                    MySearchObject_Paging.add(c);        
                }           
            }
            System.Debug('newPageIndex = ' + newPageIndex);
            PageNumber = newPageIndex;
            if (MySearchObject_Paging == null || MySearchObject_Paging.size() <= 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        }
        else
        {
            if (MySearchObject_Paging == null || MySearchObject_Paging.size() <= 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        }
        if(MySearchObject_Paging.size() > 0)
        {
        	renderTable = true;
        	renderNoRecords = false; 
        	BES_IsDisable = true;       	
        }
        else
        {
        	MySearchObject_Paging = new List<searchObject>();
        	System.Debug('list size = '+MySearchObject_Paging.size());
        	renderTable = false;
        	renderNoRecords = true;
        	BES_IsDisable = false;
        }
        //getsearchPropertyResult();
        return MySearchObject_Paging;        
    }
    
    public Pagereference selectUnitForApproval()
    {
    	try
    	{	
	    	String strPropertyId = '';
	    	if(!MysearchObject.isEmpty())		//		Added by Rahul 23/06
		    	for(Integer i=0;i < MysearchObject.size();i++)
		    	{
		    		if(hidRecIds == MysearchObject[i].recId)
		    		{
		    			strPropertyId = MysearchObject[i].recPropertyId;
		    			break;
		    		}
		    	}
	    	if(strPropertyId != '')			//		Added by Rahul 23/06
	    	{
	    		Opportunity objOpp = new Opportunity(Id=opportunityId);    	
		    	objOpp.Property__c = strPropertyId;
		    	objOpp.StageName = 'Commit/Sent Application';
		    	update objOpp;
	    	}
    		if(hidRecIds != null && hidRecIds != '')		//		Added by Rahul 23/06
    		{  
	    		Property_to_Opportunity_Connector__c objPropertyToOppConnector = new Property_to_Opportunity_Connector__c(Id =hidRecIds);
	    		objPropertyToOppConnector.Approval_Status__c = 'In Process';
	    		objPropertyToOppConnector.Status__c = 'In Progress';
	    		update objPropertyToOppConnector;
	    		Pagereference pr = new PageReference('/apex/BES_SendApplicationToContacts_New?Id=' +opportunityId + '&propId=' + hidRecIds);	    	
		    	return pr;
    		}
    		else
    		{
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please Select one Unit'));
    			return null;
    		}
    	}
    	catch(DMLException e)
    	{
			ApexPages.addmessages(e);
    		return null;
    	}	
	
	    	
    }

    public Pagereference selectUnitForApprovalAndFinish()
    {
    	try
    	{	
	    	String strPropertyId = '';
	    	if(!MysearchObject.isEmpty())		//		Added by Rahul 23/06
		    	for(Integer i=0;i < MysearchObject.size();i++)
		    	{
		    		if(hidRecIds == MysearchObject[i].recId)
		    		{
		    			strPropertyId = MysearchObject[i].recPropertyId;
		    			break;
		    		}
		    	}
		    If(strPropertyId != '')				//		Added by Rahul 23/06
		    {
		    	Opportunity objOpp = new Opportunity(Id=opportunityId);    	
		    	objOpp.Property__c = strPropertyId;
		    	objOpp.StageName = 'Commit/Sent Application';
		    	update objOpp;
		    }
    		if(hidRecIds != null && hidRecIds != '')	//		Added by Rahul 23/06
    		{  
	    		Property_to_Opportunity_Connector__c objPropertyToOppConnector = new Property_to_Opportunity_Connector__c(Id =hidRecIds);
	    		objPropertyToOppConnector.Approval_Status__c = 'In Process';
	    		objPropertyToOppConnector.Status__c = 'In Progress';
	    		update objPropertyToOppConnector;
	    		Pagereference pr = new PageReference('/' +opportunityId);	    	
		    	return pr;
    		}
    		else
    		{
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please Select one Unit'));
    			return null;
    		}
    	}
    	catch(DMLException e)
    	{
			ApexPages.addmessages(e);
    		return null;
    	}	
    }
    
    public Pagereference cancelSubmitApproval()
    {
    	Pagereference pr = new PageReference('/' + opportunityId);
    	return pr;
    }
    
    @isTest
    static void BES_Submit_Application_For_Approval() 
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
 		/*lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant'));
 		insert lstCR;*/
 		
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
 		
    	BES_Submit_Application_For_Approval_New objSendApp = new BES_Submit_Application_For_Approval_New();
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
   
}