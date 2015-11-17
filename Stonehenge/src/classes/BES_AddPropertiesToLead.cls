public with sharing class BES_AddPropertiesToLead 
{
	
	public static testMethod void myUnitTest() 
    {
    	Lead objLead = new Lead();
    	objLead.LastName = 'Test';
    	objLead.Property_Name__c = '10 Downing';
    	Date dtCurr = Date.newInstance(2009, 1, 1);
    	insert objLead;
    	
    	Property__c oppProp = new Property__c();
	    oppProp.Asking_Rent__c = 1.0;
	    oppProp.Availability_Date__c = dtCurr;
	    oppProp.Building_Name__c = 'XYZ';
	    oppProp.Unit_Rent__c = 1.0;
	    oppProp.Move_Out_Date__c = dtCurr;
	    oppProp.Name = 'ABC';
	    oppProp.Number_Of_Days_Vacant__c = 1.0;
	    oppProp.Sq_Feet__c = 1.0;
	    oppProp.Unit_Description__c = 'ABC';
	    oppProp.Unit_Number__c = '123';
	    oppProp.Unit_Status__c = 'Value';
	    oppProp.Unit_Type__c = 'ABC';
	    oppProp.Unit_Type_standard__c = 'Studio';
	    insert oppProp;
	     
    	String LeadId = objLead.Id;
    	
        ApexPages.CurrentPage().getParameters().put('id',LeadId);
        ApexPages.CurrentPage().getParameters().put('isTestMode','true');
        BES_AddPropertiesToLead objBES_AddPropertiesToLead = new BES_AddPropertiesToLead();
        objBES_AddPropertiesToLead.isTestMode = true;
        objBES_AddPropertiesToLead.whereClause = '';
        objBES_AddPropertiesToLead.hidRecIds = '';
        objBES_AddPropertiesToLead.hidSelectedIds = '';
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.LeadName = 'XYZ';
        objBES_AddPropertiesToLead.getSearchResults();
        objBES_AddPropertiesToLead.getSearchResults();
        objBES_AddPropertiesToLead.getSearchResults();
        objBES_AddPropertiesToLead.getSearchResults();
      	objBES_AddPropertiesToLead.GetIds();  
        objBES_AddPropertiesToLead.saveOppToPropertiesConnector();
        objBES_AddPropertiesToLead.insertRecords();
        objBES_AddPropertiesToLead.cancelAddProperty(); 
        
        searchObject objMySearchObject = new searchObject(oppProp,false);
        objMySearchObject.selected = true;
        objMySearchObject.recId = oppProp.Id;
        objMySearchObject.recBLD = 'testing 123';
        objMySearchObject.recUnit = '123';
        objMySearchObject.recUnitType = 'Studio';
        objMySearchObject.recUnitSF = '1234';
        objMySearchObject.recMoveOutDate = '09/10/2009';
        
        objBES_AddPropertiesToLead.MySearchObject.add(objMySearchObject);
        objBES_AddPropertiesToLead.MySearchObject_Paging.add(objMySearchObject);
        objBES_AddPropertiesToLead.MySearchObjectClone.add(objMySearchObject);
        objBES_AddPropertiesToLead.MySearchObject.add(objMySearchObject);
        
        objBES_AddPropertiesToLead.saveOppToPropertiesConnector();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.ResetPaging();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.NextBtnClick();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.PreviousBtnClick();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.getPageNumber();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.getPageSize();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.getPreviousButtonEnabled();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.getNextButtonDisabled();
        objBES_AddPropertiesToLead.LeadId = LeadId;
        objBES_AddPropertiesToLead.getTotalPageNumber();
        objBES_AddPropertiesToLead.LeadId = LeadId;
       	objBES_AddPropertiesToLead.sortColumnSelected();
       	objBES_AddPropertiesToLead.getSearchResultsByPaging(1);
        Property_to_Opportunity_Connector__c objPOC = new Property_to_Opportunity_Connector__c();
        DateTime POC = DateTime.newInstance(2009, 1, 1);
        objPOC.Show_Date__c = POC;
        objPOC.Lead__c = LeadId;
        objBES_AddPropertiesToLead.lstProperty_to_Opportunity_Connector.add(objPOC);
        objBES_AddPropertiesToLead.insertRecords();     
       
        objBES_AddPropertiesToLead.PageNumber = 1;
		objBES_AddPropertiesToLead.PageSize = 1;
		objBES_AddPropertiesToLead.totalPageNumber = 1;
		objBES_AddPropertiesToLead.newPageIndex = 2;		
        
        objBES_AddPropertiesToLead.renderNoRecords = false;
        objBES_AddPropertiesToLead.renderSearch = false;
        objBES_AddPropertiesToLead.renderTable = false;
    }
	public Integer PageNumber;
    public Integer PageSize;
    public Integer totalPageNumber;
    public Integer newPageIndex = 1;
        
	public boolean isTestMode 			{	get;set;	}
    public string whereClause 			{	get;set;	}
    public Boolean renderTable 			{	get;set;	}
    public Boolean renderSearch 		{	get;set;	}
    public Boolean renderNoRecords 		{	get;set;	}
    public string hidRecIds 			{	get;set;	}
    public string hidSelectedIds 		{	get;set;	}
    public string LeadId		 		{	get;set;	}
    public string LeadName		 		{	get;set;	}
    public string LeadOwnerID 			{	get;set;	}
    
    boolean SearchClick = false;
	
	String[] selectedBuilding   = new String[]{};
	public String[] getSelectedBuilding() { return selectedBuilding; }
	public void setSelectedBuilding(String[] selectedBuilding) { this.selectedBuilding = selectedBuilding; }	

	String[] selectedUnitStatus = new String[]{};
	public String[] getSelectedUnitStatus() { return selectedUnitStatus; }
	public void setSelectedUnitStatus(String[] selectedUnitStatus) { this.selectedUnitStatus = selectedUnitStatus; }	

	String[] selectedUnitType   = new String[]{};
	public String[] getSelectedUnitType() { return selectedUnitType; }
	public void setSelectedUnitType(String[] selectedUnitType) { this.selectedUnitType = selectedUnitType; }	
	

    public BES_AddPropertiesToLead() {		
		PageNumber = 0;
		whereClause = '';
        totalPageNumber = 0;
        PageSize = 50;
        LeadId = System.currentPageReference().getParameters().get('id');
        string strtest = System.currentPageReference().getParameters().get('isTestMode');
        if(strtest != null && strtest == 'true') /***/ isTestMode = true;
        if(LeadId != '' && LeadId != null) {
        	for(Lead item : Database.query('SELECT Id, Name, OwnerId FROM Lead WHERE Id= \'' + LeadId + '\' limit 1')) {
	        	LeadName    = item.Name;
	        	LeadOwnerID = item.OwnerId;
	        }
	        
        }        
        preparingHour();
        preparingMin();
        preparingMeridiem();
        preparingBuilding();
        preparingUnitType();
        preparingUnitStatus();
        getSearchResults();         
	}

	public List<Property__c> lstUniqueBuilding {	get;set;	}
	

	public List<SelectOption> hour     {get;set;}
	public List<SelectOption> min      {get;set;}
	public List<SelectOption> meridiem {get;set;}
	public List<SelectOption> building {get;set;}
	public List<SelectOption> unitType {get;set;}
	public List<SelectOption> unitStatus {get;set;}
	
	
	
	public void preparingHour() {
		List<SelectOption> options = new List<SelectOption>();
		for(Integer i = 1; i < 13; i++) {
        	 String strMin = ''+i;
        	 if(strMin.length() == 1) 	/***/ options.add(new SelectOption(''+i, '0' + strMin));
			 else 						/***/ options.add(new SelectOption(''+i, ''+i)); 
        }
        hour = options;
	}
	
	public void preparingMin() {
		List<Integer> lstMin = new List<Integer>{00,15,30,45};
		List<SelectOption> options = new List<SelectOption>();
		for(Integer i = 0; i < lstMin.size(); i++) {
        	 String strMin = ''+lstMin[i];
        	 if(strMin.length() == 1) 	/***/ options.add(new SelectOption(''+lstMin[i],'0'+ strMin));
			 else 						/***/ options.add(new SelectOption(''+lstMin[i],''+lstMin[i])); 
        }
        min = options;
	}
	
	public void preparingMeridiem() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('AM','AM'));
		options.add(new SelectOption('PM','PM'));
	    meridiem = options;
	}
	
	public void preparingBuilding() {
		lstUniqueBuilding = new List<Property__c>();
		List<SelectOption> options = new List<SelectOption>();
   		options.add(new SelectOption('' , ''));
		for(Schema.PicklistEntry item : Property__c.Property_Name_Friendly_Picklist__c.getDescribe().getPicklistValues()) { 
			 options.add(new SelectOption(item.getValue(), item.getLabel())); 
        }
        building = options;
	}
	
	public void preparingUnitStatus() {
		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry item : Property__c.Unit_Status__c.getDescribe().getPicklistValues())
        	if(item.getValue() != '6. Comm/Condo' && item.getValue() != '7. Unavailable')
			 	options.add(new SelectOption(item.getValue(), item.getLabel()));
        unitStatus = options;
	}
	
	public void preparingUnitType() {
		List<SelectOption> options = new List<SelectOption>();
		for (Schema.PicklistEntry item : Property__c.Unit_Type_standard__c.getDescribe().getPicklistValues())
			 options.add(new SelectOption(item.getValue(), item.getLabel())); 
        unitType = options;
	}


	
	public void GetIds() {    	
    	for(searchObject s: MySearchObject_Paging) {	    	
	    	for(searchObject objSearchObject : MySelectedSearchObject) { 
	        	if(objSearchObject.recid != s.recid)  
			    	if(s.selected == true) /***/ MySearchObjectClone.add(s);			    		
		    }
		    if(MySelectedSearchObject.size() == 0)			  
			    if(s.selected) /***/ MySearchObjectClone.add(s);				    
	    }		    
    }
    
	public List<searchObject> MySelectedSearchObject = new list<searchObject>();
	public String printErrorMessage {	get;set;	}
	public Boolean isError 			{	get;set;	}
	
	/*Add Property To Opportunity Connector Records*/
	public PageReference saveOppToPropertiesConnector() {
		String[] strIds;
		if(hidRecIds != null && hidRecIds != '') /***/ strIds = hidRecIds.split(',');
        if(MySearchObject_Paging != null && MySearchObject_Paging.size() > 0) {
            for(searchObject objSearchObject : MySearchObject_Paging) {
                if (objSearchObject.selected == true) {
                    Boolean isExist = false;                
                    for(searchObject objISSearchObject : MySelectedSearchObject)
                        if(objSearchObject.recId == objISSearchObject.recId) /***/ isExist = true;
                    if(!isExist) /***/ MySelectedSearchObject.add(objSearchObject);                       
                }
            }
        }        
        for(searchObject objSearchObject : MySearchObjectClone) { 
    		Boolean isTrue = false;
        	for(searchObject objISSearchObject : MySelectedSearchObject)
	            if(objSearchObject.recId == objISSearchObject.recId) 
	                isTrue = true;
    		if(!isTrue)
            	MySelectedSearchObject.add(objSearchObject);
		}
        for(Integer i = 0; strIds != null && i < strIds.size(); i++) {
        	for(searchObject SO : MySearchObject) {        	
	        	Boolean isTrue = false;
	        	for(searchObject objISSearchObject : MySelectedSearchObject)
		            if(SO.recId == objISSearchObject.recId)
		                isTrue = true;
        		if(!isTrue)
	            	if(SO.recId == strIds[i]) {
	            		So.selected = true;
		            	MySelectedSearchObject.add(SO);			           
	            	}
        	}
        }
   	
        //if(MySelectedSearchObject.size() > 0 && validateDatePickerValues)
        if(MySelectedSearchObject.size() > 0 ) {
        	insertRecords();
        	if(chkError == 'false') {
        		Pagereference pr = new PageReference('/' +leadId);
        		//chkError = 'true';
        		return pr;
        	} else {
        		chkError = 'false';
        		return null;
        	}
        } else /***/ return null;
	}
	
	Datetime dtShowDate;
	Datetime dtShowEndDate;
	String chkError = 'false';
	String chkError1 = 'false';			
	
	/*Add Property To Opportunity Connector Records*/
	public List<Property_to_Opportunity_Connector__c> lstProperty_to_Opportunity_Connector 	{	get;set;	}
	public List<DateTime> lstEndDateTime 													{	get;set;	}
	public List<Property_to_Opportunity_Connector__c> lstExisting_Connector_Records 		{	get;set;	}
	public List<Event> lstCreateEvent_Records 												{	get;set;	}
	/*Insert Connector Records*/
	
	
	
	
	public Pagereference insertRecords() {
		//Iterate through MySelectedSearchObject;
		lstExisting_Connector_Records = [Select Property__c , Lead__c from Property_to_Opportunity_Connector__c where Lead__c =: leadId];		
		lstProperty_to_Opportunity_Connector = new List<Property_to_Opportunity_Connector__c>();
		lstEndDateTime = new List<DateTime>();
		for(Integer i=0;i < MySelectedSearchObject.size();i++) {		
			Boolean isExistInDB = false;			
			for(Integer j = 0;j < lstExisting_Connector_Records.size();j++) {
				if(MySelectedSearchObject[i].recId == lstExisting_Connector_Records[j].Property__c) {
					isExistInDB = true;
					break;
				}
			}
			Property_to_Opportunity_Connector__c objPOC = new Property_to_Opportunity_Connector__c();						 
			if(MySelectedSearchObject[i].objPropertyToLead.Move_Out_Date__c != null && !isExistInDB)
			{
				Integer intDay        = MySelectedSearchObject[i].objPropertyToLead.Move_Out_Date__c.day();
				Integer intMonth      = MySelectedSearchObject[i].objPropertyToLead.Move_Out_Date__c.month();				
				Integer intYear       = MySelectedSearchObject[i].objPropertyToLead.Move_Out_Date__c.year();
				Integer intHour       = Integer.valueof(MySelectedSearchObject[i].selectedHour);
				Integer intMin        = Integer.valueof(MySelectedSearchObject[i].selectedMin);
				String strMeridiem    = MySelectedSearchObject[i].selectedMeridiem;
				
				//	Modified by Rahul on 23rd August, http://silverline.jira.com/browse/STONEPII-24
				if(strMeridiem == 'AM' && intHour == 12) intHour = 0;
				else if(strMeridiem == 'PM' && intHour != 12) intHour = intHour + 12;
					
				Integer intSec = 0;
				dtShowDate = datetime.newInstance(intYear, intMonth, intDay, intHour,intMin, intSec);
				if(dtShowDate != null) {
					System.debug('LESS'+dtShowDate);
					objPOC.Show_Date__c = dtShowDate;
					objPOC.Property__c = MySelectedSearchObject[i].recId ;
					objPOC.Lead__c = leadId;
					objPOC.Name = leadName + '-' + MySelectedSearchObject[i].recName;
					lstProperty_to_Opportunity_Connector.add(objPOC);
					lstEndDateTime.add(dtShowEndDate);
				} else {
					chkError = 'true';
					isError = true;
					printErrorMessage = 'Error Message: Please enter Show Date/Time for selected Property.';
				}
			}		
			else if(MySelectedSearchObject[i].objPropertyToLead.Move_Out_Date__c == null && !isExistInDB)
			{	
				isError = true;
				chkError = 'true';
				printErrorMessage = 'Error Message: Please enter Show Date/Time for selected Property.';	
			}		
		}
		if(lstProperty_to_Opportunity_Connector.size() > 0) {
			if(chkError == 'false') {
				insert lstProperty_to_Opportunity_Connector;	
			} else {	
				isError = true;
				printErrorMessage = 'Error Message: Please enter Show Date/Time for selected Property.';
			}
			/*Start Code for Creating Activity*/
				lstCreateEvent_Records = new List<Event>();	
				for(Integer z=0; z < lstProperty_to_Opportunity_Connector.size();z++) {	
					if(lstProperty_to_Opportunity_Connector[z].Show_Date__c != null) {
						if(leadId != '') {	
							Event objEvent = new Event();
							objEvent.WhoId = LeadId ;
							objEvent.StartDateTime = lstProperty_to_Opportunity_Connector[z].Show_Date__c;
							objEvent.EndDateTime = lstProperty_to_Opportunity_Connector[z].Show_Date__c.addMinutes(30);
							objEvent.Type = 'Showing';
							objEvent.OwnerId = leadOwnerID;
							objEvent.Subject = 'Showing - '+ MySelectedSearchObject[z].recName; 	
							lstCreateEvent_Records.add(objEvent);
						}
					} else /***/ chkError = 'true';
				}		
				if(lstCreateEvent_Records.size() > 0) {
					if(chkError == 'false') {
						insert lstCreateEvent_Records;
					} else {
						isError = true;
						printErrorMessage = 'Error Message: Please enter Show Date/Time for selected Property.';
						
						return null;
					}
				}
			/*End Code for Creating Activity*/		
		} else {
			isError = true;
			printErrorMessage = 'Error Message: Please enter Show Date/Time for selected Property.';
		}
		return null;
	}
	/*Insert Connector Records*/
	
	
	/*Paging functions*/
	public PageReference ResetPaging() {
        PageNumber            = 0;
        totalPageNumber       = 0;
        PageSize              = 50;
        MySearchObject_Paging = new List<searchObject>();
        renderTable           = false;
    	renderNoRecords       = true;  
        return null;
    }

	public Integer getPageNumber() { return PageNumber; }

	public PageReference NextBtnClick() {      
    	GetIds();
    	getSearchResultsByPaging(PageNumber + 1);
        return null;
    }

    public PageReference PreviousBtnClick() {        
    	GetIds();
    	getSearchResultsByPaging(PageNumber - 1);        
        return null;
    }
    
    public Integer getPageSize() { return PageSize; }
    
    public Boolean getPreviousButtonEnabled() { return !(PageNumber > 1); }
    
    public Boolean getNextButtonDisabled() {
        if (MySearchObject == null) /***/ return true;    
        else 						/***/ return ((PageNumber * PageSize) >= MySearchObject.size());
    }
    
    public Integer getTotalPageNumber() {
        if (totalPageNumber == 0 && MySearchObject !=null) {
            totalPageNumber = MySearchObject.size() / PageSize;
            Integer mod = MySearchObject.size() - (totalPageNumber * PageSize);
            if (mod > 0)
            totalPageNumber++;
        }
        return totalPageNumber;
    }
    
    public list<searchObject> getsearchResult() { 
		if(MySearchObject_Paging != null && MySearchObject_Paging.size() > 0) {   
        	return MySearchObject_Paging;	           
        } else {
            ResetPaging();		            	
            return null;	            
        }
    }    
    
    public PageReference getSearchResults() {
    	PageNumber = 0;  
    	isError = false;
        getSearchResultsByPaging(1);        
        return null;
    }
    
    list<searchObject> MySearchObject_Paging;
    
    public list<searchObject> getSearchResultsByPaging(Integer newPageIndex) {  
    	MySearchObject = new List<searchObject>();  
        if(selectedBuilding.size() > 0 && selectedUnitStatus.size() > 0 && selectedUnitType.size() > 0) {
        	whereClause = 'where Property_Name_Friendly__c in :selectedBuilding and Unit_Status__c in :selectedUnitStatus and Unit_Type_standard__c in :selectedUnitType';
        }
        else if(selectedBuilding.size() > 0 && selectedUnitStatus.size() > 0) {
        	whereClause = 'where Property_Name_Friendly__c in :selectedBuilding and Unit_Status__c in :selectedUnitStatus';
        }
        else if(selectedUnitStatus.size() > 0 && selectedUnitType.size() > 0) {
        	whereClause = 'where Unit_Status__c in :selectedUnitStatus and Unit_Type_standard__c in :selectedUnitType';
        }
        else if(selectedBuilding.size() > 0 && selectedUnitType.size() > 0) {
        	whereClause = 'where Property_Name_Friendly__c in :selectedBuilding and Unit_Type_standard__c in :selectedUnitType';
        }
        else if(selectedBuilding.size() > 0) {
        	whereClause = 'where Property_Name_Friendly__c in :selectedBuilding';
        }
        else if(selectedUnitStatus.size() > 0) {
        	whereClause = 'where Unit_Status__c in :selectedUnitStatus';
        } 
        else if(selectedUnitType.size() > 0) {
        	whereClause = 'where Unit_Type_standard__c in :selectedUnitType';
        }
        else if(selectedBuilding.size() == 0 && selectedUnitStatus.size() == 0 && selectedUnitType.size() == 0) {
        	whereClause = 'where Unit_Status__c !=\'6. Comm/Condo\' and Unit_Status__c !=\'7. Unavailable\' ';
        }
		String sortFullExp = sortExpression  + ' ' + sortDirection;
        List<Property__c> lstProperties;
        if(isTestMode == null || !isTestMode) {
        	lstProperties = Database.query('Select Id,Name ,Unit_Type_standard__c, Unit_Status__c, Unit_Number__c, Sq_Feet__c, Number_Of_Days_Vacant__c, Move_Out_Date__c, Unit_Rent__c, Property_Name_Friendly__c, Availability_Date__c, Asking_Rent__c From Property__c ' + whereClause + ' order by  ' + sortFullExp + '  limit 1000');
        } else {
        	lstProperties = Database.query('Select Id,Name ,Unit_Type_standard__c, Unit_Status__c, Unit_Number__c, Sq_Feet__c, Number_Of_Days_Vacant__c, Move_Out_Date__c, Unit_Rent__c, Property_Name_Friendly__c, Availability_Date__c, Asking_Rent__c From Property__c ' + whereClause + ' order by  ' + sortFullExp + '  limit 10');        	       
        }
	    //List<Property__c> lstProperties= Database.query('SELECT Id, Name FROM Property__c ' + whereClause + ' order by Name limit 1000');
		for(Integer j = 0; j < lstProperties.size(); j++) {
			searchObject objSearch = new searchObject(lstProperties[j], false);
			MySearchObject.add(objSearch);	
		}
		
		MySearchObject_Paging = new List<searchObject>();		
        if(MySearchObject != null && MySearchObject.size() > 0) {
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            Integer PNum;
            Integer PSize;
            totalPageNumber = 0;
            PNum = PageNumber;
            PSize = PageSize;
			if (newPageIndex > PNum) {
                min = PNum * PSize;
                max = newPageIndex * PSize;
            } else {
                max = ( PNum -1 ) * PSize;
                min = max - PSize;                
            }
            for(searchObject c : MySearchObject) {
                counter++;
                if (counter > min && counter <= max) /***/ MySearchObject_Paging.add(c);        
            }
            
            PageNumber = newPageIndex;
            if (MySearchObject_Paging == null || MySearchObject_Paging.size() <= 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        } else {
            if (MySearchObject_Paging == null || MySearchObject_Paging.size() <= 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        }
        if(MySearchObject_Paging.size() > 0) {
        	renderTable = true;
        	renderNoRecords = false;        	
        } else {
        	MySearchObject_Paging = new List<searchObject>();
        	renderTable = false;
        	renderNoRecords = true;
        }
        return MySearchObject_Paging;        
    }
	/*Paging Functions*/
	
	
	/*Inner Class*/
	list<searchObject> MySearchObject;
	list<searchObject> MySearchObjectClone = new list<searchObject>();
	
	public class searchObject {
        public Boolean selected				{get; set;}
        public string recId 				{get;set;}
        public string recName 				{get;set;}
        public string recBLD 				{get;set;}
        public string recUnit 				{get;set;}
        public string recUnitType 			{get;set;}
        public string recUnitSF 			{get;set;}
        public string recMoveOutDate 		{get;set;}
        public string recDaysVacant 		{get;set;}
        public string recLastRent 			{get;set;}
        public string recAskingRent 		{get;set;}
        public string recEstCompletionDate 	{get;set;}
        public string recUnitStatus 		{get;set;}
        public string recAvailFlag 			{get;set;}
        public string selectedHour 			{get;set;}
        public string selectedMin 			{get;set;}
        public string selectedMeridiem 		{get;set;}
        public string selectedEndHour 		{get;set;}
        public string selectedEndMin 		{get;set;}
        public string selectedEndMeridiem 	{get;set;}
        
        public string recShowDateTime {get;set;}
         
        public Property__c objPropertyToLead{get;set;}
        
		public searchObject(Property__c prty, Boolean s) {
        	recName = prty.Name;
        	if(prty.Property_Name_Friendly__c != null && prty.Property_Name_Friendly__c != '')
            	recBLD = prty.Property_Name_Friendly__c;
            else
            	recBLD = 'Test';
           
        	recUnit = prty.Unit_Number__c;
        
        	if(prty.Unit_Type_standard__c != null) 		/***/ recUnitType = prty.Unit_Type_standard__c;
            else 										/***/ recUnitType = '';
            
        	if(prty.Sq_Feet__c != null) 				/***/ recUnitSF = ''+prty.Sq_Feet__c;
        	else 										/***/ recUnitSF = '';  
        		
        	if(prty.Move_Out_Date__c != null) 			/***/ recMoveOutDate = prty.Move_Out_Date__c.format();
        	else 										/***/ recMoveOutDate = '';
        	
        	if(prty.Number_Of_Days_Vacant__c != null) 	/***/ recDaysVacant = ''+prty.Number_Of_Days_Vacant__c;
        	else 										/***/ recDaysVacant = '';
        		
        	if(prty.Unit_Rent__c != null) 				/***/ recLastRent = ''+Spheria_Common_Library.NumberFormat(prty.Unit_Rent__c);
        	else 										/***/ recLastRent = '0';
        		
        	if(prty.Asking_Rent__c != null)				/***/ recAskingRent = ''+Spheria_Common_Library.NumberFormat(prty.Asking_Rent__c);
        	else 										/***/ recAskingRent = '0';
        		
        	if(prty.Availability_Date__c != null) 		/***/ recEstCompletionDate = prty.Availability_Date__c.format();
        	else 										/***/ recEstCompletionDate = '';
        		
        	if(prty.Unit_Status__c != null) 			/***/ recUnitStatus = prty.Unit_Status__c;
            else 										/***/ recUnitStatus = '';
            	
            recAvailFlag = '';
         	objPropertyToLead = new Property__c();
    		recId = prty.Id;
    		selected = s;
           
        }
    }   
	/*Inner Class*/   
	
	public Pagereference cancelAddProperty() {
    	Pagereference pr = new PageReference('/' +leadId);    	
    	return pr;
    }  	

	/*Start Sorting Generic Function*/
	public String sortDirection = 'ASC';
    public String sortExp = 'Property_Name_Friendly__c';

	public String sortExpression {
		get { return sortExp; }
		set {
			//if the column is clicked on then switch between Ascending and Descending modes
			if (value == sortExp) 	/***/ sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
			else 					/***/ sortDirection = 'ASC';
			sortExp = value;
		}
	}

	public String getSortDirection() {
		//if not column is selected 
		if (sortExpression == null || sortExpression == '') /***/ return 'ASC';
		else 												/***/ return sortDirection;
	}

	public void setSortDirection(String value) { sortDirection = value; }
	
	public PageReference sortColumnSelected() {
	    PageNumber = 0;
		whereClause = '';
        totalPageNumber = 0;
        PageSize = 50;
        getSearchResults(); 
       return null;
    }
    /*
	public Integer PageNumber;
    public Integer PageSize;
    public Integer totalPageNumber;
    public Integer newPageIndex = 1;
        
    public boolean isTestMode
    {	get;set;	}
	
    public string selectedBuilding
    {	get;set;	}
    
    public string selectedUnitStatus
    {	get;set;	}     
    
    public string whereClause
    {	get; set;	}
    
    public Boolean renderTable
    {	get;set;	}
    
    public Boolean renderSearch
    {	get;set;	}
    
    public Boolean renderNoRecords
    {	get;set;	}
    
    public string hidRecIds
    {	get; set;	}
    
    public string hidSelectedIds 
    {	get; set;	}
    
    public string leadId
    {	get; set;	}
    public string leadName
    {	get; set;	}
    
    
    boolean SearchClick = false;
    
    
    public BES_AddPropertiesToLead()
	{		
		PageNumber = 0;
		whereClause = '';
        totalPageNumber = 0;
        PageSize = 6;
        leadId = System.currentPageReference().getParameters().get('id');
        string strtest = System.currentPageReference().getParameters().get('isTestMode');
        if(strtest != null && strtest == 'true')
        	isTestMode = true;
        if(leadId != '' && leadId != null)
        	leadName = [Select Name From Lead where Id=: leadId].Name;        
        getSearchResults();         
	}
	public List<Property__c> lstUniqueBuilding
	{	get;set;	}
	
	public List<SelectOption> getBuilding() 
	{
		lstUniqueBuilding = new List<Property__c>();
		List<SelectOption> options = new List<SelectOption>();
		List<Property__c> lstAllProperties;
		if(isTestMode == null || !isTestMode)
		{
		 	lstAllProperties= Database.query('SELECT Id, Name, Building_Name__c FROM Property__c order by Name limit 1000');
		}
		else
		{
			lstAllProperties= Database.query('SELECT Id, Name, Building_Name__c FROM Property__c order by Name limit 10');
		}
		options.add(new SelectOption('','----Select----'));		
		for(Integer i = 0; i < lstAllProperties.size(); i++)
        {
        	Boolean isExist = false;
        	for(Integer j = 0; j < lstUniqueBuilding.size(); j++)
        	{
        		if(lstUniqueBuilding[j].Building_Name__c == lstAllProperties[i].Building_Name__c )
        		{
        			isExist = true;
        			break;
        		}
        	}
        	if(!isExist)
        	{   
        		if(lstAllProperties[i].Building_Name__c != null && lstAllProperties[i].Building_Name__c != '')
        		{      		
					options.add(new SelectOption(lstAllProperties[i].Building_Name__c,lstAllProperties[i].Building_Name__c));
					lstUniqueBuilding.add(lstAllProperties[i]);
        		}
        	} 
        }		
        return options;
	}
	public List<SelectOption> getUnitStatus() 
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','----Select----'));
		Schema.DescribeFieldResult F = Property__c.Unit_Status__c.getDescribe();
        List<Schema.PicklistEntry> lstUnitStatusPicklistValues = F.getPicklistValues();				
		for(Integer i = 0; i < lstUnitStatusPicklistValues.size(); i++)
        {
			 options.add(new SelectOption(lstUnitStatusPicklistValues[i].getValue(),lstUnitStatusPicklistValues[i].getLabel())); 
        }		
        return options;
	}
	public List<SelectOption> getHour() 
	{
		List<SelectOption> options = new List<SelectOption>();
		for(Integer i = 1; i < 13; i++)
        {
        	 String strMin = String.valueof(i);
        	 if(strMin.length() == 1)        	 
			 	options.add(new SelectOption(String.valueOf(i),'0'+ strMin));
			 else
			 	options.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
        }		
        return options;
	}
	public List<SelectOption> getMin() 
	{
		List<SelectOption> options = new List<SelectOption>();
		for(Integer i = 0; i < 60; i++)
        {
        	 String strMin = String.valueof(i);
        	 if(strMin.length() == 1)        	 
			 	options.add(new SelectOption(String.valueOf(i),'0'+ strMin));
			 else
			 	options.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
        }		
        return options;
	}
	public List<SelectOption> getMeridiem() 
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('AM','AM'));
		options.add(new SelectOption('PM','PM'));
	    return options;
	}
	public void GetIds()
    {    	
    	for(searchObject s: MySearchObject_Paging)
	    {	    	
	    	for(searchObject objSearchObject : MySelectedSearchObject)
	        { 
	        	if(objSearchObject.recid != s.recid)
	        	{  
			    	if(s.selected == true)
			    	{			    		
			    		MySearchObjectClone.add(s);			    		
			    	}
	        	}   
		    }
		    if(MySelectedSearchObject.size() == 0)
		    {			  
			    if(s.selected)
				{				    
				    MySearchObjectClone.add(s);				    
				}	    	
	   		}
	    }		    
    }
	public List<searchObject> MySelectedSearchObject = new list<searchObject>();
	public String printErrorMessage
	{	get;set;	}
	public Boolean isError
	{	get;set;	}
	/*Add Property To Opportunity Connector Records*//*
	public PageReference saveOppToPropertiesConnector()
	{
		String[] strIds;
		if(hidRecIds != null && hidRecIds != '')
		{
			strIds = hidRecIds.split(',');
		}       
        if(MySearchObject_Paging != null && MySearchObject_Paging.size() > 0)
        {
            for(searchObject objSearchObject : MySearchObject_Paging)
            {
                if (objSearchObject.selected == true) 
                {
                    Boolean isExist = false;                
                    for(searchObject objISSearchObject : MySelectedSearchObject)
                    {
                        if(objSearchObject.recId == objISSearchObject.recId)
                        {
                            isExist = true;
                        }
                    }
                    if(!isExist)
                    {                       
                        MySelectedSearchObject.add(objSearchObject);                       
                    }
                }
            }
        }        
        for(searchObject objSearchObject : MySearchObjectClone)
	    { 
    		Boolean isTrue = false;
        	for(searchObject objISSearchObject : MySelectedSearchObject)
	        {
	            if(objSearchObject.recId == objISSearchObject.recId)
	            {
	                isTrue = true;
	            }
	        }
    		if(!isTrue)
    		{
            	MySelectedSearchObject.add(objSearchObject);
    		}   
		}
        for(Integer i = 0; strIds != null && i < strIds.size(); i++)
        {
        	for(searchObject SO : MySearchObject) 
        	{        	
	        	Boolean isTrue = false;
	        	for(searchObject objISSearchObject : MySelectedSearchObject)
		        {
		            if(SO.recId == objISSearchObject.recId)
		            {
		                isTrue = true;
		            }
		        }        		
        		if(!isTrue)
        		{
	            	if(SO.recId == strIds[i])
	            	{
	            		So.selected = true;
		            	MySelectedSearchObject.add(SO);			           
	            	}
        		}
        	}
        }
        //System.debug('&&&&&&&&& MySelectedSearchObject.size == ' + MySelectedSearchObject.size());
        //System.debug('&&&&&&&&& MySelectedSearchObject == ' + MySelectedSearchObject);
        /*Boolean validateDatePickerValues = true;
        for(Integer i=0;i < MySelectedSearchObject.size();i++)
		{
			if(MySelectedSearchObject[i].objPropertyToOpportunity.Move_Out_Date__c == null)
			{
				validateDatePickerValues = false;
				break;
			}
		}
        //if(MySelectedSearchObject.size() > 0 && validateDatePickerValues)
        if(MySelectedSearchObject.size() > 0)
        {
        	insertRecords();
        	Pagereference pr = new PageReference('/' +leadId);    						
    		return pr;
        }
        else
        {
        	return null;
        }
        /*else if(!validateDatePickerValues)
        {
        	printErrorMessage = 'Please Enter Date for selected Properties';
        	isError = true;
        	return null;
        }*/        		
	}
	
	
	/*Add Property To Opportunity Connector Records*//*
	public List<Property_to_Opportunity_Connector__c> lstProperty_to_Opportunity_Connector
	{	get;set;	}
	public List<Property_to_Opportunity_Connector__c> lstExisting_Connector_Records
	{	get;set;	}
	public List<Task> lstCreateTask_Records
	{	get;set;	}
	/*Insert Connector Records*//*
	public Pagereference insertRecords()
	{
		//Iterate through MySelectedSearchObject;
		lstExisting_Connector_Records = [Select Property__c , Lead__c from Property_to_Opportunity_Connector__c where Lead__c =: leadId];		
		lstProperty_to_Opportunity_Connector = new List<Property_to_Opportunity_Connector__c>();
		//lstProperty_to_Opportunity_Connector = new List<Property_to_Opportunity_Connector__c>(); 
		for(Integer i=0;i < MySelectedSearchObject.size();i++)
		{		
			Boolean isExistInDB = false;			
			for(Integer j = 0;j < lstExisting_Connector_Records.size();j++)
			{
				if(MySelectedSearchObject[i].recId == lstExisting_Connector_Records[j].Property__c)
				{
					isExistInDB = true;
					break;
				}
			}
			Property_to_Opportunity_Connector__c objPOC = new Property_to_Opportunity_Connector__c();						 			
			if(MySelectedSearchObject[i].objPropertyToOpportunity.Move_Out_Date__c != null && !isExistInDB)
			{
				Integer intDay = MySelectedSearchObject[i].objPropertyToOpportunity.Move_Out_Date__c.day();
				Integer intMonth = MySelectedSearchObject[i].objPropertyToOpportunity.Move_Out_Date__c.month();				
				Integer intYear = MySelectedSearchObject[i].objPropertyToOpportunity.Move_Out_Date__c.year();
				Integer intHour = Integer.valueof(MySelectedSearchObject[i].selectedHour);
				Integer intMin = Integer.valueof(MySelectedSearchObject[i].selectedMin);
				String strMeridiem = MySelectedSearchObject[i].selectedMeridiem;
				if(strMeridiem == 'AM')
				{
					if(intHour == 12)
					{
						intHour = 0;
					}
				}
				else if(strMeridiem == 'PM')
				{
					if(intHour != 12)
					{
						intHour = intHour + 12;
					}
				}				
				Integer intSec = 0;
				Datetime dtShowDate = datetime.newInstance(intYear, intMonth, intDay, intHour,intMin, intSec);
				
				objPOC.Show_Date__c = dtShowDate;
				objPOC.Property__c = MySelectedSearchObject[i].recId ;
				objPOC.Lead__c = leadId;
				objPOC.Name = leadName + '-' + MySelectedSearchObject[i].recName;
				lstProperty_to_Opportunity_Connector.add(objPOC);								
			}
			else if(MySelectedSearchObject[i].objPropertyToOpportunity.Move_Out_Date__c == null && !isExistInDB)
			{				
				objPOC.Property__c = MySelectedSearchObject[i].recId ;
				objPOC.Lead__c = leadId;
				objPOC.Name = leadName + '-' + MySelectedSearchObject[i].recName;
				lstProperty_to_Opportunity_Connector.add(objPOC);
			}			
		}
		if(lstProperty_to_Opportunity_Connector.size() > 0)
		{
			insert lstProperty_to_Opportunity_Connector;
			/*Start Code for Creating Activity*//*
				lstCreateTask_Records = new List<Task>();	
				for(Integer z=0; z < lstProperty_to_Opportunity_Connector.size();z++)
				{					
					Task objTask = new Task();
					objTask.WhoId = leadId;
					objTask.Subject = 'Call'; 					
					objTask.OwnerId = Userinfo.getUserId();
					lstCreateTask_Records.add(objTask);			
				}		
				if(lstCreateTask_Records.size() > 0)
				{
					insert lstCreateTask_Records;
				}
			/*End Code for Creating Activity*/
		/*}
		return null;
	}*/
	/*Insert Connector Records*/
	/*Paging functions*//*
	public PageReference ResetPaging()
    {
        PageNumber = 0;
        totalPageNumber = 0;
        PageSize = 6;
        MySearchObject_Paging = new List<searchObject>();
        renderTable = false;
    	renderNoRecords = true;  
        return null;
    }
	public Integer getPageNumber()
    {
        return PageNumber;
    }
	public PageReference NextBtnClick() 
    {      
    	GetIds();
    	getSearchResultsByPaging(PageNumber + 1);
        return null;
    }
    public PageReference PreviousBtnClick() 
    {        
    	GetIds();
    	getSearchResultsByPaging(PageNumber - 1);        
        return null;
    }
    public Integer getPageSize()
    {
        return PageSize;
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
    public list<searchObject> getsearchResult()
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
    
    public PageReference getSearchResults()
    {
    	PageNumber = 0;  
    	isError = false;
        getSearchResultsByPaging(1);        
        return null;
    }
    
    list<searchObject> MySearchObject_Paging;
    public list<searchObject> getSearchResultsByPaging(Integer newPageIndex)
    {  
    	MySearchObject = new List<searchObject>();  
        MySearchObject_Paging = new List<searchObject>();
        if(selectedBuilding != '' && selectedBuilding != null && selectedUnitStatus != '' && selectedUnitStatus != null)
        {
        	whereClause = 'where Building_Name__c=\'' + selectedBuilding + '\' and Unit_Status__c=\'' + selectedUnitStatus + '\'';
        }
        else if(selectedBuilding != '' && selectedBuilding != null)
        {
        	whereClause = 'where Building_Name__c=\'' + selectedBuilding + '\'';
        }
        else if(selectedUnitStatus != '' && selectedUnitStatus != null)
        {
        	whereClause = 'where Unit_Status__c=\'' + selectedUnitStatus + '\'';
        } 
        else if((selectedBuilding == '' || selectedBuilding == null ) && (selectedUnitStatus == '' || selectedUnitStatus == null))
        {
        	whereClause = '';
        }
		String sortFullExp = sortExpression  + ' ' + sortDirection;
        List<Property__c> lstProperties;
        if(isTestMode == null || !isTestMode)
        {
        	lstProperties= Database.query('Select Id, Name ,Unit_Type__c, Unit_Status__c, Unit_Number__c, Sq_Feet__c, Number_Of_Days_Vacant__c, Move_Out_Date__c, Current_Rent__c, Building_Name__c, Availability_Date__c, Asking_Rent__c From Property__c ' + whereClause + ' order by ' + sortFullExp + ' limit 1000');        	       	    
        }
        else
        {
        	lstProperties= Database.query('Select Id, Name ,Unit_Type__c, Unit_Status__c, Unit_Number__c, Sq_Feet__c, Number_Of_Days_Vacant__c, Move_Out_Date__c, Current_Rent__c, Building_Name__c, Availability_Date__c, Asking_Rent__c From Property__c ' + whereClause + ' order by ' + sortFullExp + ' limit 10');        	       	    
        }
		for(Integer j = 0; j < lstProperties.size(); j++)
		{			
			searchObject objSearch = new searchObject(lstProperties[j], false);
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
            for(searchObject c : MySearchObject)
            {
                counter++;
                if (counter > min && counter <= max)
                {                    
                    MySearchObject_Paging.add(c);        
                }           
            }
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
        }
        else
        {
        	MySearchObject_Paging = new List<searchObject>();
        	renderTable = false;
        	renderNoRecords = true;
        }
        return MySearchObject_Paging;        
    }
	/*Paging Functions*/
	/*Inner Class*//*
	list<searchObject> MySearchObject;
	list<searchObject> MySearchObjectClone = new list<searchObject>();
	public class searchObject
    {
        public Boolean selected{get; set;}
        public string recId {get;set;}
        public string recName {get;set;}
        public string recBLD {get;set;}
        public string recUnit {get;set;}
        public string recUnitType {get;set;}
        public string recUnitSF {get;set;}
        public string recMoveOutDate {get;set;}
        public string recDaysVacant {get;set;}
        public string recLastRent {get;set;}
        public string recAskingRent {get;set;}
        public string recEstCompletionDate {get;set;}
        public string recUnitStatus {get;set;}
        public string recAvailFlag {get;set;}
        public string selectedHour {get;set;}
        public string selectedMin {get;set;}
        public string selectedMeridiem {get;set;}
        
        public string recShowDateTime {get;set;}
         
        public Property__c objPropertyToOpportunity{get;set;}
        
		public searchObject(Property__c prty, Boolean s)
        {              
        	recName = prty.Name;
            recBLD = prty.Building_Name__c;
        	recUnit = prty.Unit_Number__c;
        	recUnitType = prty.Unit_Type__c;
        	if(prty.Sq_Feet__c != null)
        		recUnitSF = String.valueOf(prty.Sq_Feet__c);
        	else
        		recUnitSF = '';        	
        	if(prty.Move_Out_Date__c != null)
        		recMoveOutDate = prty.Move_Out_Date__c.format();
        	else
        		recMoveOutDate = '';
        	if(prty.Number_Of_Days_Vacant__c != null)
        		recDaysVacant = String.valueOf(prty.Number_Of_Days_Vacant__c);
        	else
        		recDaysVacant = '';
        	if(prty.Current_Rent__c != null)        	
        		recLastRent = String.valueOf(prty.Current_Rent__c);
        	else
        		recLastRent = '0';
        	if(prty.Asking_Rent__c != null)	
        		recAskingRent = String.valueOf(prty.Asking_Rent__c);
        	else
        		recAskingRent = '0';
        	if(prty.Availability_Date__c != null)
        		recEstCompletionDate = prty.Availability_Date__c.format();
        	else
        		recEstCompletionDate = '';
        	if(prty.Unit_Status__c != null)
            	recUnitStatus = prty.Unit_Status__c;
            else
            	recUnitStatus = '';
            recAvailFlag = '';
         	objPropertyToOpportunity = new Property__c();
    		recId = prty.Id;
            selected = s;
        }
    }   
	/*Inner Class*/   
	/*
	public Pagereference cancelAddProperty()
    {
    	Pagereference pr = new PageReference('/' +leadId);    	
    	return pr;
    }

	/*Start Sorting Generic Function*//*
	public String sortDirection = 'ASC';
    public String sortExp = 'Building_Name__c';

	public String sortExpression
	{
		get
		{
			return sortExp;
		}
		set
		{
			//if the column is clicked on then switch between Ascending and Descending modes
			if (value == sortExp)
				sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
			else
				sortDirection = 'ASC';
			sortExp = value;
		}
	}

	public String getSortDirection()
	{
		//if not column is selected 
		if (sortExpression == null || sortExpression == '')
			return 'ASC';
		else
			return sortDirection;
	}

	public void setSortDirection(String value)
	{  
		sortDirection = value;
	}
	public PageReference sortColumnSelected() 
	{
	    PageNumber = 0;
		whereClause = '';
        totalPageNumber = 0;
        PageSize = 6;
        getSearchResults(); 
       return null;
    }
	/*End Sorting Generic Function*/
//}