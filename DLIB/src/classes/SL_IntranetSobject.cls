/**
* \arg ClassName  : SL_IntranetSobject
* \arg JIRATicket : SOCINT-326
* \arg CreatedOn  : Lodhi, 24/Oct/2013 
* \arg ModifiedBy : 
* \arg Description: 
*/
 
/**
* \arg ClassName  : SL_IntranetSobject
* \arg JIRATicket : SOCINT-326
* \arg CreatedOn  : Lodhi, 24/Oct/2013 
* \arg ModifiedBy : 
* \arg Description: 
*/

public with sharing class SL_IntranetSobject extends WidgetAbstract 
{
	/* Start - Variables */
	public List<SobjectWrapper> lstSobjectWrapper	{	get;set;	}//<! This list will contains the Sobejct records to display in the component.
	public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper		{	get;set;	}//<! This list will contains the field API name to render.
	public String sObjectName						{	get;set;	}//<! This string variable is use to dispaly the Sobject Name.
	public String strHeading						{	get;set;	}
	public Boolean showSection						{	get;set;	}//<! This variable is used to display section controller.
	public Boolean showFieldLabel					{	get;set;	}
	public String lstViewName                       {   get;set;    }
	public String strWidgetId						{   get;set;    }
	public Integer numRecordstodisplay				{   get;set;    }
	public Integer mobilePaginationSize				{	get;set;	}
	public Integer sObjectListSize 					{	get;set;	}
	public Integer TotalRecords 					{	get;set;	}
	public Id chatterTopicId						{	get;set;	}
		
	public String picklistFilterApiName { get; private set; }
	public Boolean isPicklistFilterOn { get; private set; }
	public String picklistFilterValue { get; set; }
	
	private String sObjectPrefix;
	
	private String strQuery;
	private Integer numberToDisplay;
	private Boolean isShowMore = false;
	
	/* End - Variables */
	
	/* Start Constructor */
	public SL_IntranetSobject()
	{	
		intialization();
	}
	/* End */
	
	/* Start - Wrapper class for Sobject */
	public class SobjectWrapper
	{
		public Sobject sObj		{	get;set;	}//<! Sobject to store the Sobject.
		
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
		strQuery = sObjectName = '';
		showSection = false;
		lstSobjectWrapper = new List<SobjectWrapper>();
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		sObjectListSize = 10;
		TotalRecords = 0;
		numberToDisplay = 0;
		numRecordstodisplay = 5;
		lstViewName = '';
		isPicklistFilterOn = false;
	}
	/* End */
	
	// initialize method called on component's initialize
    public override protected void initialize()
    {
    	widgetConfiguration();
     	
     	// TODO: remove such test dependency injection
 		if(Test.isRunningTest())
			Id = [Select Name, Configuration__c from PageRegionWidget__c LIMIT 1].Name;

		if(ApexPages.currentPage().getParameters().containsKey('topicId')) {
			String chatterTopicIdParam = ApexPages.currentPage().getParameters().get('topicId');

			if(!String.isBlank(chatterTopicIdParam)) {
				chatterTopicId = (Id)chatterTopicIdParam;
			} 
		}
		
		queryRecords(strQuery);
    }
	
	/**
	* Configuration: 
	* {
	*   "sobjectname": "Intranet_App__c", "fieldsetname": "wc", 
	*   "heading": "Object List View", "showfieldlabel": false, 
	*   "filtercriteria": "", "numbertodisplay": 4, "TotalRecords": 10, "disableLinks": false, 
	*   "picklistfilter": "" 
	* }
	**/
	private void widgetConfiguration()
    {
        if(Test.isRunningTest())
			Id = [Select Name,Configuration__c from PageRegionWidget__c LIMIT 1].Name;
				
		showSection = true;
     	lstSobjectWrapper = new List<SobjectWrapper>();
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
		try
		{
	     	String fieldsetname = '';
	     	String filtercriteria = '';
	     	
	     	// Fetch the configuration for the widget
			if(this.properties != null) {
				
				if(this.properties.containsKey('sobjectname')) {
					sObjectName = String.valueOf(this.properties.get('sobjectname'));					
					sObjectPrefix = Utilities.sObjectDesribeHelper(sObjectName).getKeyPrefix();
				}
				
				if(String.isBlank(sObjectName) || !getObjectAccess('read', Schema.getGlobalDescribe().get(sObjectName)))
					return;				
					
				if(this.properties.containsKey('fieldsetname')) 		
					fieldsetname = String.valueOf(this.properties.get('fieldsetname'));
					
				if(this.properties.containsKey('filtercriteria')) 	
					filtercriteria = String.valueOf(this.properties.get('filtercriteria'));
				
				if(this.properties.containsKey('numbertodisplay') && this.properties.get('numbertodisplay') != '') 	
					numberToDisplay	= Integer.valueOf(this.properties.get('numbertodisplay'));
				
				if(this.properties.containsKey('TotalRecords') && this.properties.get('TotalRecords') != '') 		
					TotalRecords = Integer.valueOf(this.properties.get('TotalRecords'));
				
				if(this.properties.get('showfieldlabel') == null || this.properties.get('showfieldlabel') == '')
					this.properties.put('showfieldlabel', false);
					
				if(this.properties.containsKey('picklistfilter')) {
					picklistFilterApiName = (String)this.properties.get('picklistfilter');
					if(!String.isBlank(picklistFilterApiName)) isPicklistFilterOn = true; 
				}
			}


	     	// Fetch the query string and fieldsets describe results from Utilities
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 
     			sObjectName, fieldsetname, filtercriteria, 
				' ORDER BY CreatedDate DESC', ' LIMIT 250', new Set<String>() 
			);
     		
     		lstFieldWrapper = objFieldSetWrapper.lstFieldWrapper;
     		strQuery = objFieldSetWrapper.strQuery;
     		
     		if(numberToDisplay > 0)
     			numRecordstodisplay = numberToDisplay;
     			
     		else if(numberToDisplay == 0 || numberToDisplay == null)
     			numberToDisplay = numRecordstodisplay = 5;
     				
     		if(TotalRecords == 0 || TotalRecords == null)
     			TotalRecords = 10;
	     }
	     catch(Exception ex) // DML and describe exceptions expected
	     {
	     	system.debug('Exception ex : '+ex.getMessage());
	     }	
    }
      
    public void showMoreRecords()
	{
		numRecordstodisplay += numberToDisplay;
		if(numRecordstodisplay > TotalRecords)
			numRecordstodisplay = TotalRecords;
		
		if(String.isNotBlank(lstViewName)){
			isShowMore = true;
			gtListViewDetail();
		}
	}
	
	public void getMoreRecordsForMobile()
	{
		queryRecords(strQuery);
		numRecordstodisplay += numberToDisplay;
	}
		
	/* 
     * Name: chatterTopicRecords
     * Parameters: NA
     * Description: This function is use to get records of Sobject based on chatter Topic Id
     */
	 public PageReference chatterTopicRecords() {
	 	// reset records number to initial number
	 	numRecordstodisplay = numberToDisplay;	 	
	 	queryRecords(strQuery);	 	
	 	return null;
	 }
	 
	 private Set<Id> getTopicEntitiesIds(Id chatterTopicId, String sObjectPrefix) {
		Set<Id> entities = new Set<Id>();
		for(TopicAssignment o : [
	 		SELECT id, EntityId 
	 		FROM TopicAssignment 
	 		WHERE TopicId =: chatterTopicId AND EntityKeyPrefix =: this.sObjectPrefix LIMIT 1000
	 	])
	 		entities.add(o.EntityId);
	 		
	 	return entities;	
	 }	
	 
	 private void queryRecords(String strQuery) {
	 	lstSobjectWrapper = new List<SobjectWrapper>();
	 		
	 	// TODO: should be removed from implementation classes	
		if(Test.isRunningTest())
			strQuery = 'Select Id, Name From Contact';
		
		if(String.isBlank(strQuery)) {
			sObjectListSize = 0;
			return;
		}
		
		List<SobjectWrapper> temp = new List<SobjectWrapper>();
		
		// apply query decomposition and filtering
		strQuery = filterQuery(strQuery); 
		
	    for(Sobject o : Database.query(strQuery)) 
	    	temp.add( new SobjectWrapper(o) );
	    	   
	    // apply object filtering	    
	    if(chatterTopicId != null) {
	    	Set<Id> topicEntitiesIds = getTopicEntitiesIds(chatterTopicId, this.sObjectPrefix);
	    	for(SobjectWrapper o2 : temp) {
	    		if(topicEntitiesIds.contains(o2.sObj.Id))
	    			lstSobjectWrapper.add(o2);	
	    	}
	 				
	    }
	    else lstSobjectWrapper = temp;
	    		
 		sObjectListSize = lstSobjectWrapper.size();
	 }
	 
	 
	 /* 
     * Name: gtListViewDetail
     * Parameters: NA
     * Description: Dispalying List View records
     */
     public void gtListViewDetail()
     {
        lstSobjectWrapper = new List<SobjectWrapper>();
        if(Id != null)
        {
        	if(!isShowMore)
            	numRecordstodisplay = numberToDisplay;
            
            if(Test.isRunningTest())
                strQuery = 'Select Id, Name From Contact';
            
            List<String> lstRecordIds = new List<String>();
            Map<String, SobjectWrapper> mapSobjectWrapper = new Map<String, SobjectWrapper>();
            
            
            if(String.isNotBlank(strQuery))
            {
            	Set<Id> setsObjectIds = new Set<Id>();
            
                for(Sobject sObj : Database.query(strQuery.removeEndIgnoreCase('LIMIT 250')))
                {
                	setsObjectIds.add(String.valueOf(sObj.get('id')));
                	lstRecordIds.add(String.valueOf(sObj.get('id')));
                }
                ApexPages.StandardSetController objSSC = new ApexPages.StandardSetController(database.getQueryLocator(strQuery));
                
                objSSC.setPageSize(200);
                
                for(SelectOption objSS : objSSC.getListViewOptions())
                {
                	
                    if(objSS.getLabel() == lstViewName)
                    {
                        objSSC.setFilterId(objSS.getValue());
                        for(sObject sobj : objSSC.getRecords())
                        {
                        	if(setsObjectIds.contains(String.valueOf(sobj.get('id'))))
                        	{
	                            SobjectWrapper sw = new SobjectWrapper(sobj);
	                            mapSobjectWrapper.put(String.valueOf(sobj.get('id')), sw);
                        	}
                        }
                    }
                }
                
                lstSobjectWrapper = new List<SobjectWrapper>();
                
                for(String objId : lstRecordIds)
                {
                	if(mapSobjectWrapper.containskey(objId))
                		lstSobjectWrapper.add(mapSobjectWrapper.get(objId));
                }
	            sObjectListSize = lstSobjectWrapper.size();
	            isShowMore = false;
            }
        }
     }
     /* End */
     
    private String filterQuery(String tempQuery) {
    	
    	if(!String.isEmpty(picklistFilterValue)) {
 			// quick fix - alter query with additional criterion	
 			String part1;
 			String part2;
 			
 			Integer ind = tempQuery.indexOf(' WHERE ');
 			if(ind != -1) {
 				part1 = tempQuery.substring(0, ind + 7);
 				part2 = tempQuery.substring(ind + 7);
 				tempQuery = part1 + String.escapeSingleQuotes(picklistFilterApiName) 
 					+ ' = \'' + String.escapeSingleQuotes(picklistFilterValue) + '\' AND ' + part2;
 				system.debug('SL_DEBUG: ' + tempQuery);
 			}
 			else {
 				ind = tempQuery.indexOf(' FROM ' + sObjectName);
 				if(ind != -1) {
 					part1 = tempQuery.substring(0, ind + 6 + sObjectName.length());
 					part2 = tempQuery.substring(ind + 6 + sObjectName.length());
 					tempQuery = part1 + ' WHERE ' 
 						+ String.escapeSingleQuotes(picklistFilterApiName) 
 						+ ' = \'' + String.escapeSingleQuotes(picklistFilterValue) + '\' ' + part2;
 					system.debug('SL_DEBUG: ' + tempQuery);
 				}
 			}
 		}    	
    	
    	return tempQuery;
    }
     
    public PageReference applyFilter() {
    	// reset to initial state reocrds
    	numRecordstodisplay = numberToDisplay;
    	queryRecords(strQuery);
	   
	 	return null;
    }
     
	/* 
     * Name: newComponent
     * Parameters: NA
     * Description: This function is used to create the dynamic component
     */
	public override ApexPages.Component newComponent() 
	{
    	//respective component name will be used here.
		Component.c.SL_IntranetSobject c = new Component.c.SL_IntranetSobject();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End */
}