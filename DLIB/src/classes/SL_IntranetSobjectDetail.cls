/**
* \arg ClassName  : SL_IntranetSobjectDetail
* \arg JIRATicket : SOCINT-326
* \arg CreatedOn  : Lodhi, 28/Oct/2013 
* \arg ModifiedBy : 
* \arg Description: 
*/
public with sharing class SL_IntranetSobjectDetail extends WidgetPaginatorAbstract implements IChatterable
{
    /* Start - Variables */
    public SL_IntranetChatterPlugIn Chatter	{	get; set;	}
    
    public transient List<SobjectWrapper> lstSobjectWrapper {   get;set;    }//<! This list will contains the Sobejct records to display in the component.
    public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper       {   get;set;    }//<! This list will contains the field API name to render.
    public List<Attachment> lstAttachment           {   get;set;    }//<! This list used to show the attachment.
    public String sObjectName                       {   get;set;    }//<! This string variable is use to dispaly the Sobject Name.
    public Id strSobjectId {
        get; 
        set {
            strSobjectId = !String.isEmpty(value) ? value : null;           
        }       
    }//<! This variable is used to keep the id of the Sobject need to display or not.
    
    public String strFieldSet                       {   get;set;    }//<! This variable is used to set the field set name from the List widget
    public String strHeading                        {   get;set;    }
    public Boolean showSection                      {   get;set;    }//<! This variable is used to display section controller.
    public Boolean showFeed                         {   get;set;    }//<! This variable is used to decide weather to show the feeds.
    public Boolean showAttachment                   {   get;set;    }//<! decide weather need to display attachment.
    public Boolean initialState                     {   get;set;    }//<! intail state of the component hidden or full.
    public Boolean viewAllRecords                   {   get;set;    }//<! This variable is used for see all records.
    public Boolean showFieldLabel                   {   get;set;    }
    public Boolean isNext                           {   get;set;    }
    /*Pagination Variables for Attachment */
    public Integer startIndexAttach                 {   get;set;    } 
    public Integer rowsPerPageAttach                {   get;set;    }
    public Integer totalPagesAttach                 {   get;set;    }
    public Integer pageNoAttach                     {   get;set;    }
    public Integer totalRecordsAttach               {   get;set;    }
    public Boolean isNextAttach                     {   get;set;    }
    public Integer lstSobjectSize   				{	get;set;	}
    public Boolean isDetailRecordCalled				{	get;set;	}
    /* End */
    private String strQuery = '';
    private  Integer pageSize = 5;
    /* End - Variables */
    
    /* Start - Contructor */
    public SL_IntranetSobjectDetail()
    {
        intialization();
    }
    /* End - Contructor */
    
    /* Start - Wrapper class for Sobject */
    public class SobjectWrapper
    {
        public Sobject sObj     {   get;set;    }//<! Sobject to store the Sobject.
        
        /* Start Constructor of Inner class*/
        public SobjectWrapper(Sobject sObj)
        {
            this.sObj = sObj;
        }   
        /* End */   
    }
    /* End - Wrapper class for Sobject */

    /* 
     * Name: intialization
     * Parameters: NA
     * Description: This function is used to intialize all the global public and private variables.
     */
    private void intialization()
    {
        lstSobjectSize = 0;
        lstSobjectWrapper = new List<SobjectWrapper>();
        lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
        lstAttachment = new List<Attachment>();
        strSobjectId = null;
        sObjectName = strFieldSet = strHeading = '';
        showSection = viewAllRecords = showAttachment = initialState = showFieldLabel = isNext = isNextAttach = false;
        /* overriding the Paginator class vars */
        totalPages = startIndex = pageNo = rowsPerPage = 0;
        startIndexAttach = totalPagesAttach = rowsPerPageAttach = pageNoAttach = totalRecordsAttach = 0;
        /* End of overriding */
        
        for(SL_Intranet_PaginationSettings__c objPagination : [SELECT Name, Documents_PageSize__c, Documents_PageSize_Mobile__c 
                                                                        FROM SL_Intranet_PaginationSettings__c limit 1])
        {
            if(objPagination.Documents_PageSize__c != null)
                pageSize = Integer.valueOf(objPagination.Documents_PageSize__c);
        }
    }
    /* End */
    
    /*Method to get instance of generic chatter component(SL_IntranetChatterPlugIn)*/
    public SL_IntranetChatterPlugIn initChatter() {
		
		SL_IntranetChatterPlugIn plugin = new SL_IntranetChatterPlugIn();
		plugin.initializeParam('Sobject',id);
		return plugin;
	}  
	
	
    public override protected void initialize()
    {
    	sObjectConfig(); 
    	Chatter = initChatter();//binding generic chatter instance to controller variable
    }
    
    
    /* 
     * Name: sObjectConfig
     * Parameters: NA
     * Description: This function is use to get records of Sobject 
     */
     public void sObjectConfig()
     {
        lstSobjectWrapper = new List<SobjectWrapper>(); // always resets this list
        
        showSection = true;         
        lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
        lstAttachment = new List<Attachment>();
        showAttachment = false;
        showFeed = false;
        initialState = false;  
        
        if(Test.isRunningTest())
            id = [Select Name,Configuration__c from PageRegionWidget__c LIMIT 1].Name;
            
        //ConfigJSON oJSON = new ConfigJSON();
        String strSobjectName = '';
        String strFieldSetName;
        String strFilterCriteria;
		
        // Fetch the configuration for the widget		
		if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('sobjectname')) 			
			{
				strSobjectName = String.valueOf(configuration.get('sobjectname'));
			}
			
			if(String.isBlank(strSobjectName) || !getObjectAccess('read', Schema.getGlobalDescribe().get(strSobjectName)))
				return ;

			if(configuration.containsKey('fieldsetname')) 		strFieldSetName 		= String.valueOf(configuration.get('fieldsetname'));
			if(configuration.containsKey('filtercriteria')) 	strFilterCriteria	 	= String.valueOf(configuration.get('filtercriteria'));
			if(configuration.containsKey('heading')) 			strHeading 	 			= String.valueOf(configuration.get('heading'));
			if(configuration.containsKey('showfieldlabel')) 	showfieldlabel	 	 	= Boolean.valueOf(configuration.get('showfieldlabel'));
			
			if(configuration.containsKey('showfeed') && strSobjectId != null && 
						sObjectName == strSobjectName && !String.isEmpty(strFieldSetName)) 			
			{
				showfeed = Boolean.valueOf(configuration.get('showfeed'));
			}
			
			if(configuration.containsKey('showattachment') && strSobjectId != null && 
						sObjectName == strSobjectName && !String.isEmpty(strFieldSetName)) 	
			{
				showAttachment = Boolean.valueOf(configuration.get('showattachment'));
			}
			
			if(configuration.containsKey('initialstate') && 
			   String.valueOf(configuration.get('initialstate')) == 'hidden')
			{
				initialState = false;
			}
			else if(String.valueOf(configuration.get('initialstate')) != null)
				initialState = true;
		}
		
		
        Id sobjectId;
        String sObjectAPIName;
        
        if(strSobjectId != null)
        {
            sobjectId = strSobjectId;
            sObjectAPIName = sobjectId.getSObjectType().getDescribe().getName();	
			
            if(sObjectAPIName != strSobjectName) strSobjectId = null;
        }
            
        if(strSobjectId != null && sObjectName == strSobjectName && !String.isEmpty(strFieldSetName))
        {
            startIndex = 0;
            this.initialState = true;
                
            getRecords( String.escapeSingleQuotes(sObjectName), String.escapeSingleQuotes(strFieldSetName), String.escapeSingleQuotes(strSobjectId), '');
            queryRecords();
            //feedParentId = (String)strSobjectId;
            isDetailRecordCalled = true;
            //getFeedItems();
            getAttachmentRecords();
        }
        else if(viewAllRecords && sObjectName == strSobjectName && strFieldSetName != null && strFieldSetName !='')
        {
            this.initialState = true;
            getRecords(String.escapeSingleQuotes(sObjectName), String.escapeSingleQuotes(strFieldSetName), null, '');
            queryRecords();
        }
        else if(strSobjectName != null && strSobjectName != '' && strFieldSetName != null && strFieldSetName !='')
        {
            sObjectName = strSobjectName;
            String filter = '';
            if(strFilterCriteria != null && strFilterCriteria != '')
                filter = strFilterCriteria;

            getRecords(String.escapeSingleQuotes(strSobjectName), String.escapeSingleQuotes(strFieldSetName), null, filter);
            queryRecords();
        }
        else 
        {                   
            lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
            lstAttachment = new List<Attachment>();
            strSobjectId = null;
            sObjectName = strFieldSet = '';
            showSection = viewAllRecords = showAttachment = initialState = false;
        }
        lstSobjectSize = lstSobjectWrapper.size();
     }
     /* End */
     
     private void getRecords(String sobjName, String fieldSet, Id strSobjectId, String filter)
     {      
        lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();

        try
        {
            String strFilterCriteria = '';
            
            if(strSobjectId != null)
                strFilterCriteria += ' Id=:strSobjectId';
            else if(filter != null && filter != '')
                strFilterCriteria += ' '+ filter;
            
            // Fetch the query string and fieldsets describe results from Utilities
            SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( sobjName, fieldSet, 
                                                                                                        strFilterCriteria, ' ORDER BY CreatedDate DESC', '', new Set<String>() );

            lstFieldWrapper = objFieldSetWrapper.lstFieldWrapper;
            strQuery = objFieldSetWrapper.strQuery + ' LIMIT 250';    
        }
        catch(Exception ex) // DML and describe exceptions expected
        {
            system.debug('Exception ex : '+ex.getMessage());
        }
     }
     /* End */
     
     private void queryRecords()
	 {
        for(Sobject sObj : Database.query(strQuery))
        {
            lstSobjectWrapper.add(new SobjectWrapper(sObj));
        }
        
        totalRecords = lstSobjectWrapper.size();
        rowsPerPage = pageSize;
        totalPages = Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1;
        if(pageNo == totalPages -1)
            isNext = false;
        else
            isNext = true;
	 }
     
     private void getAttachmentRecords()
     {
        lstAttachment = new List<Attachment>();
        lstAttachment = [SELECT Id, Name FROM Attachment WHERE ParentId =: strSobjectId ORDER BY CreatedDate DESC LIMIT 250];
        totalRecordsAttach = lstAttachment.size();
        rowsPerPageAttach = pageSize;
        totalPagesAttach = Math.mod(totalRecordsAttach, pageSize) == 0 ? totalRecordsAttach/pageSize : (totalRecordsAttach/pageSize) + 1;
        
        if(totalPagesAttach > 1)
            isNextAttach = true;
     }
     
     /* Name: nextRecords
        Param: None
        description: To get the records of Next page
    */
    public void nextRecordsAttachment()
    {
        getAttachmentRecords();
        if(startIndexAttach + rowsPerPageAttach < totalRecordsAttach)
        {
            startIndexAttach += rowsPerPageAttach;
            pageNoAttach += 1;  
            
            if(pageNoAttach == totalPagesAttach - 1)
                isNextAttach = false;
            else
                isNextAttach = true;
        }
    }
    /* End : nextRecords Methods */
    
    
    /*  Name: prevRecords
        Param: None
        Description: To get the records of Previous page  
    */
    public void prevRecordsAttachment()
    {
        getAttachmentRecords();
        if(startIndexAttach - rowsPerPageAttach >= 0)
        {
            startIndexAttach -= rowsPerPageAttach;
            pageNoAttach -= 1;
            
            if(pageNoAttach == totalPagesAttach - 1)
                isNextAttach = false;
            else
                isNextAttach = true;
        }
    }
    /* End : prevRecords Methods */
    
    /*  Name: goToPage
        param: None
        Description: To get the records of particulat page  
    */
    public void goToPageAttachment()
    {
        getAttachmentRecords();
        Integer pageNumber = Integer.valueOf(Apexpages.currentPage().getparameters().get('pageNoAttach')); 
        
        pageNoAttach = pageNumber;
        startIndexAttach = rowsPerPageAttach * (pageNumber - 1);
    }
    /* End : goToPage Methods */
     
    /*  Name: showInitialState
        param: None
        Description: To initialise the widget on click of list view widget
    */
    public void showInitialState()
    {
        intialization();
        sObjectConfig();
    }
    
    /* 
     * Name: newComponent
     * Parameters: NA
     * Description: This function is used to create the dynamic component
     */
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetSobjectDetail c = new Component.c.SL_IntranetSobjectDetail();   
        c.aComponentImpl = this;
        return c;
    }
    /* End */
}