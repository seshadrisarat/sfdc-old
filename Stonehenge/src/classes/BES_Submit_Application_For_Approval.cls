public class BES_Submit_Application_For_Approval 
{
	public static testMethod void myUnitTest() 
    {
    	Account objAcc = new Account();
    	objAcc.Name = 'Test';
    	insert objAcc;
    	
    	/*Opportunity objOpp = new Opportunity();
    	objOpp.Name = 'Test';
    	objOpp.StageName = 'Prospecting';
    	
    	objOpp.CloseDate = dtCurr;
    	objOpp.AccountId = objAcc.Id;
    	insert objOpp;
    	*/
    	String opportunityId = [select Id from Opportunity Limit 1].Id;//objOpp.Id;
    	System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Opportunity Id $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' + opportunityId);
    	String PropId = [select Id from Property__c Limit 1].Id;
    	Date dtCurr = Date.newInstance(2009, 1, 1);
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
    	List<OpportunityContactRole> lstOCRole = [select ContactId,Contact.FirstName,Contact.Email,Role from OpportunityContactRole where OpportunityId =: opportunityId limit 1];
    	Property_to_Opportunity_Connector__c objPOC = new Property_to_Opportunity_Connector__c(); //[select Property__r.Building_Name__c,Property__r.Unit_Number__c,Property__r.Unit_Type__c,Property__r.Current_Rent__c,Property__r.Asking_Rent__c,Property__r.Availability_Date__c,
			//Property__r.Number_Of_Days_Vacant__c,Property__r.Sq_Feet__c,Property__r.Unit_Status__c, Account__c,Approval_Status__c,Name,Opportunity__c,Property__c,Show_Date__c,Status__c from Property_to_Opportunity_Connector__c limit 1];
    	objPOC.Account__c = objAcc.Id;
    	objPOC.Approval_Status__c = 'In Process';
    	objPOC.Name = 'test';
    	objPOC.Opportunity__c = opportunityId;
    	objPOC.Property__c = [select Id from Property__c Limit 1 ].Id;//oppProp.Id;
    	DateTime dtCurrent = DateTime.newInstance(2009,1,1);
    	objPOC.Show_Date__c = dtCurrent;
    	objPOC.Status__c = 'In Progress';
    	insert objPOC;
    	
    	String propOpp = objPOC.Id;
    	
        ApexPages.CurrentPage().getParameters().put('id',opportunityId);
        
        BES_Submit_Application_For_Approval objBES_Submit_Application_For_Approval = new BES_Submit_Application_For_Approval();
        objBES_Submit_Application_For_Approval.GetRoles();
        searchObject objMySearchObject = new searchObject(objPOC,false);
      	objMySearchObject.selected = true;
        objMySearchObject.recId = objPOC.Id;
        objMySearchObject.BldgName = 'testing 123';
        objMySearchObject.UnitNo = '123';
        objMySearchObject.UnitType = 'test';
        objMySearchObject.AskingRent = '123';
        objMySearchObject.UnitStatus = 'Value';
        
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$ List of Search Objects' + objMySearchObject);
        objBES_Submit_Application_For_Approval.lstOCRole = lstOCRole;
        objBES_Submit_Application_For_Approval.autoRun();
        //objBES_Submit_Application_For_Approval.MysearchObject.add(objMySearchObject);
        //objBES_Submit_Application_For_Approval.MySearchObject_Paging.add(objMySearchObject);
        
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getsearchPropertyResult();

        objBES_Submit_Application_For_Approval.hidRecIds = '';
        objBES_Submit_Application_For_Approval.opportunityId = '';
        objBES_Submit_Application_For_Approval.whereClause = '';
        objBES_Submit_Application_For_Approval.OpportunityName = '';
        objBES_Submit_Application_For_Approval.BES_Error = '';
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.ResetPaging();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getPageNumber();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.NextBtnClick();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.PreviousBtnClick();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getPreviousButtonEnabled();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getNextButtonDisabled();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getTotalPageNumber();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getPageSize();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.getsearchPropertyResults();
        objBES_Submit_Application_For_Approval.cancelSubmitApproval();
        objBES_Submit_Application_For_Approval.opportunityId = opportunityId;
        objBES_Submit_Application_For_Approval.hidRecIds = propOpp;
        //objBES_Submit_Application_For_Approval.selectUnitForApproval();
        
        objBES_Submit_Application_For_Approval.PageNumber = 1;
		objBES_Submit_Application_For_Approval.PageSize = 1;
		objBES_Submit_Application_For_Approval.totalPageNumber = 1;
		objBES_Submit_Application_For_Approval.newPageIndex = 2;
		
		objBES_Submit_Application_For_Approval.renderNoRecords = false;
        objBES_Submit_Application_For_Approval.BES_IsError = false;
        objBES_Submit_Application_For_Approval.renderTable = false;		
    }
	
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
	public List<SelectOption> GetRoles()
	{
		options = new List<SelectOption>();
		options.add(new SelectOption('Tenant','Tenant'));
		options.add(new SelectOption('Guarantor','Guarantor'));
		return options;
	}
	//List<OpportunityContactRole> lstOCRole = new List<OpportunityContactRole>();
	List<OpportunityContactRole> lstWithOutContactEmailOCRole = new List<OpportunityContactRole>();
	List<OpportunityContactRole> lstWithEmailOCRole = new List<OpportunityContactRole>();
	List<OpportunityContactRole> lstOCRole
	{get;set;}
	string Email = '';
	public BES_Submit_Application_For_Approval()
	{
		//GetRoles();
		PageNumber = 0;
        totalPageNumber = 0;
        PageSize = 6;
        whereClause = '';
        //txtSearchVal = '';
        ShowContacts = false;
        opportunityId = System.currentPageReference().getParameters().get('id');
        //lstconObj = new List<ContactObject>();
        if(opportunityId != null && opportunityId != '')
        {
        	lstOCRole = [select ContactId,Contact.FirstName,Contact.Email,Role from OpportunityContactRole where OpportunityId =: opportunityId];
			OpportunityName = [Select Name from Opportunity where Id=: opportunityId].Name;
			System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ List Of Opportunity Contact Roles $$$$$$$$$$$$$$$$$$$$$$$' + lstOCRole);
			for(Integer i=0;i<lstOCRole.size();i++)
			{
				System.debug('Entered');
				Email = [select Email from Contact where Id =:lstOCRole[i].ContactId Limit 1].Email;
				if((Email == null) || (lstOCRole[i].Role != 'Tenant' && lstOCRole[i].Role != 'Guarantor'))
				{
					lstWithOutContactEmailOCRole.add(lstOCRole[i]);
				}
				else
				{
					lstWithEmailOCRole.add(lstOCRole[i]);
				}
				
			}
			if(lstWithEmailOCRole.size() > 0)
			{
				getsearchPropertyResults();
				ShowContacts = true;
			}
			else
			{
				
			}
			
			System.debug('&&&&&&&&&&&&&&&&&&&&& List of Contacts With out Email Ids&&&&&&&&&&&&&&&&' + lstWithOutContactEmailOCRole);	
        }
	}
	public PageReference autoRun()
	{
		PageReference pr ;
		if(lstWithEmailOCRole.size() <= 0)
		{
			pr = new PageReference('/apex/BES_showContacts?Id='+ opportunityId);
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
    	System.debug('**************MySearchObject_Paging'+MySearchObject_Paging+ 'renderTable'+ renderTable+ 'renderNoRecords'+renderNoRecords);
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
	
	list<searchObject> MySearchObject_Paging;
    public list<searchObject> getsearchPropertyResultsByPaging(Integer newPageIndex)
    {  
    	MySearchObject = new List<searchObject>();  
        MySearchObject_Paging = new List<searchObject>();
        if(opportunityId != null && opportunityId != '')
        {
	        if(whereClause == '' || whereClause == null)
	        {
	        	whereClause = 'where Opportunity__c=\'' + opportunityId + '\' and (Status__c = \'Open\' or Status__c = \'In Progress\')';        	       
	        }   
        }    
		List<Property_to_Opportunity_Connector__c> lstPropToOppConnector = Database.query('SELECT Id, Name,Property__r.Unit_Status__c,Property__r.Current_Rent__c,Property__r.Sq_Feet__c,Property__r.Availability_Date__c,Property__r.Asking_Rent__c,Property__r.Number_Of_Days_Vacant__c, Property__r.Unit_Type__c, Property__r.Unit_Number__c, Property__r.Building_Name__c, Property__c, Opportunity__c FROM Property_to_Opportunity_Connector__c ' + whereClause + ' order by Property__r.Building_Name__c limit 1000');
		for(Integer j = 0; j < lstPropToOppConnector.size(); j++)
		{			
			searchObject objSearch = new searchObject(lstPropToOppConnector[j], false);
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
                System.debug('-------------'+ min + '-----------'+max+'----------'+ counter);
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
    	String strPropertyId = '';
    	for(Integer i=0;i < MysearchObject.size();i++)
    	{
    		if(hidRecIds == MysearchObject[i].recId)
    		{
    			strPropertyId = MysearchObject[i].recPropertyId;
    			break;
    		}
    	}
    	Opportunity objOpp = new Opportunity(Id=opportunityId);    	
    	objOpp.Property__c = strPropertyId;
    	objOpp.StageName = 'Commit/Sent Application';
    	update objOpp;
    	
    	//Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		//req1.setComments('Submitting request for approval.');
		//req1.setObjectId(opportunityId);
		
		//Approval.ProcessResult result = Approval.process(req1);
		//if(result.isSuccess() == true)
    	//{
    		if(hidRecIds != null)
    		{  
	    		Property_to_Opportunity_Connector__c objPropertyToOppConnector = new Property_to_Opportunity_Connector__c(Id =hidRecIds);
	    		objPropertyToOppConnector.Approval_Status__c = 'In Process';
	    		objPropertyToOppConnector.Status__c = 'In Progress';
	    		update objPropertyToOppConnector;
	    		Pagereference pr = new PageReference('/apex/BES_SendApplicationToContacts?Id=' +opportunityId + '&propId=' + hidRecIds);	    	
		    	return pr;
    		}
    		else
    		{
    			BES_IsError = true;
    			BES_Error = 'Approval Request Failed';
    			return null;
    		}
    	//}
    	//else
    	//{
    		//BES_IsError = true;
    		//BES_Error = 'Approval Request Failed';
    	//}    	
    	
    }

    public Pagereference selectUnitForApprovalAndFinish()
    {
    	String strPropertyId = '';
    	for(Integer i=0;i < MysearchObject.size();i++)
    	{
    		if(hidRecIds == MysearchObject[i].recId)
    		{
    			strPropertyId = MysearchObject[i].recPropertyId;
    			break;
    		}
    	}
    	Opportunity objOpp = new Opportunity(Id=opportunityId);    	
    	objOpp.Property__c = strPropertyId;
    	objOpp.StageName = 'Commit/Sent Application';
    	update objOpp;
    	
    	//Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		//req1.setComments('Submitting request for approval.');
		//req1.setObjectId(opportunityId);
		
		//Approval.ProcessResult result = Approval.process(req1);
		//if(result.isSuccess() == true)
    	//{
    		if(hidRecIds != null)
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
    			BES_IsError = true;
    			BES_Error = 'Approval Request Failed';
    			return null;
    		}
    	//}
    	//else
    	//{
    		//BES_IsError = true;
    		//BES_Error = 'Approval Request Failed';
    	//}    	
    	
    }
    
    public Pagereference cancelSubmitApproval()
    {
    	Pagereference pr = new PageReference('/' + opportunityId);
    	System.debug('cancelSubmitApproval============' +pr);
    	return pr;
    }
   
}