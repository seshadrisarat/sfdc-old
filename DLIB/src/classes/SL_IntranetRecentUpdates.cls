/**
* @ClassName    : SL_IntranetRecentUpdates 
* @JIRATicket   : Socint-281
* @CreatedOn    : 26/Nov/13
* @ModifiedBy   : Sruti 
* @Description  : This is the Implementation class of SL_IntranetRecentUpdatesController.
*/

/**
@ Sruti
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 2
No of collections used                  : 2
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       :  
Last Modified Date                      : 
Approved by                             : 
*/
public with sharing class SL_IntranetRecentUpdates extends WidgetAbstract 
{
    public List<RecentUpdateWrapper> lstRecentUpdates   {get;set;}//List of Recent Update records to be displayed in the page
    public Integer intRecentUpdateCount 				{get;set;} // variable to count RecentUpdates
    public ConfigRecentUpdate objConfig 				{get;set;} //inner class object to hold configuration fields value
    
    private Set<String> setSobjectNames;// Set of Sobject's API name, to include in the Recent Update section
    private List<String> lstObjectNames; 		// List of Object whose Recent Updates will be shown
    //Default list of objects for Recent Updates 
    private static List<String> lstDefaultObjects = new List<String>{'Notification__c', 'Intranet_Event__c','Intranet_App__c', 'ContentVersion'};
  
    
    /*---Start Main Class Constructor----*/ 
    public SL_IntranetRecentUpdates()
    {
        initializeVariables();
    }
    /*--End --Constructor---*/
    
    //Inner class to hold configuration fields
    public class ConfigRecentUpdate
    {
    	public Integer intTotalRecords 		{get;set;} // to dispaly no of total records
        Integer intNumberToDisplay  = 5;	//to display no of recent update at a time.
    }
    
    
    /* Start           - Method for intializing variables and collectors
       @Name           - initialize
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for intializing variables and collectors
    */
    private void initializeVariables()
    {
    	objConfig = new ConfigRecentUpdate();
    	lstObjectNames = new List<String>();
        lstRecentUpdates = new List<RecentUpdateWrapper>();
        setSobjectNames = new Set<String>();
        intRecentUpdateCount = objConfig.intNumberToDisplay = objConfig.intTotalRecords = 0;
    }
    
    
    public override protected void initialize()
    {
    	 try
        {
        	if(!getObjectAccess('read', new Recent_Updates__c().getsObjectType()))
				return ;
            widgetConfiguration();
            getRecentUpdates();
        }
        catch(Exception e){
            system.debug(e.getMessage()+'============'+e.getLineNumber());
        }
    }
    
    
    /* Start           - Method for getting widget configuration
       @Name           - widgetConfiguration
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting configuration fields and thier values
    */
    private void widgetConfiguration()
    {
        lstObjectNames = new List<String>();
        
        if(this.properties != null)
        {
        	Map<String, Object> configuration = (Map<String, Object>)this.properties;
        	
        	if(configuration.get('heading') == null || configuration.get('heading') == '' )
        	{
        		((map<String, object>)properties).put('heading', 'Recent Updates');
        	}
        	
        	objConfig.intNumberToDisplay = (configuration.get('numbertodisplay') != null && configuration.get('numbertodisplay') != '' ) ? Integer.valueOf(configuration.get('numbertodisplay')) : 5;
        	objConfig.intTotalRecords = (configuration.get('TotalRecords') != null && configuration.get('TotalRecords') != '' )? Integer.valueOf(configuration.get('TotalRecords')) : 10;
        	
        	intRecentUpdateCount = objConfig.intNumberToDisplay;
        	
        	if(configuration.get('Objects') != '')
            {
                for(String s : String.valueOf(configuration.get('Objects')).trim().split(','))
                {
                    setSobjectNames.add(s.trim());
                }
            }   
            else
                 setSobjectNames.addAll(lstDefaultObjects);   
        }
    }
    
    
    /* Start - Method for getting Recent Updates.
       @Name           - getRecentUpdates
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting Recent Updates.
    */
    public void getRecentUpdates()
    {
        lstRecentUpdates = new List<RecentUpdateWrapper>(); 
        Set<Id> setAppIds = new Set<Id>();
        Set<Id> setIntranetEventIds = new Set<Id>();
        Set<Id> setIntranetEventIdsToDisplay = new Set<Id>();
        Set<Id> setNotificationIds = new Set<Id>(); 
        Set<Id> setNotificationsIdToDisplay = new Set<Id>();
        Set<Id> setContentVersionIds = new Set<Id>();
        Map<Id,string> mapCVIdToFileType = new Map<Id,string>();// Map of Content Version Id to File Type, to be used to diplay file type in the page
        Map<Id,String> mapAppIdToAppLink = new Map<Id,String>();//Map of App Id to App Link
        Map<String, Boolean> mapObjectAccess = new Map<String, Boolean>(); //Map for object access 
        mapObjectAccess.put('Intranet_App__c', getObjectAccess('read', new Intranet_App__c().getsObjectType()) );
        mapObjectAccess.put('Intranet_Event__c', getObjectAccess('read', new Intranet_Event__c().getsObjectType()) );
        mapObjectAccess.put('Notification__c', getObjectAccess('read', new Notification__c().getsObjectType()) );
		
        try
        {
            date dt = date.today();
            //Querying recent updated records   
            List<Recent_Updates__c> listRecentUpdates = [Select Id, Name, CreatedDate, LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                         From Recent_Updates__c where Sobject_Type__c != null AND Related_To__c != null order by Last_Updated__c desc nulls last limit 300];
            
            //Adding sobject Ids to respective sets to be used to get more detailed information related sobject
            for(Recent_Updates__c obj : listRecentUpdates)
            {
            	if(obj.Sobject_Type__c != null)
            	{
	                if(obj.Sobject_Type__c == 'Intranet_App__c' && mapObjectAccess.get('Intranet_App__c'))
	                	setAppIds.add(obj.Related_To__c);
	                else if(obj.Sobject_Type__c == 'Intranet_Event__c' && mapObjectAccess.get('Intranet_Event__c'))
	                    setIntranetEventIds.add(obj.Related_To__c);
	                else if(obj.Sobject_Type__c == 'Notification__c' && mapObjectAccess.get('Notification__c'))
	                    setNotificationIds.add(obj.Related_To__c);
	                else if(obj.Sobject_Type__c == 'ContentVersion')
	                    setContentVersionIds.add(obj.Related_To__c);
            	}  
            }
            
    
            //Retreiving Users offices 
            String userOfficeLocationIds = [Select Id, Selected_Offices_Ids__c from User where Id = :Userinfo.getUserId()].Selected_Offices_Ids__c;
            Set<String> setLoggedinUserOfficesId = new Set<String>();
            if(String.isNotEmpty(userOfficeLocationIds)) 
                setLoggedinUserOfficesId.addAll(userOfficeLocationIds.split(';'));
            
            	//setSobjectNames.addAll(lstObjectNames); 
           	OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
           	 
            //Checking if set contains Intranet_Event__c
            if(setSobjectNames.contains('Intranet_Event__c'))
            {   
                //Querying list of Intranet Events to be displayed in the page
                for(Intranet_Event__c objIE : [select Id, Name, Event_Type__c, Selected_Offices_Ids__c, For_All_Offices__c, Venue__c, Date_of_Event__c, End_Date__c, RecordType.Name, Comments__c
                                               from Intranet_Event__c where Id IN: setIntranetEventIds 
                                               order by Date_of_Event__c asc, Name asc
                                               limit 1000
                                              ])
                {
                    //Notification will be displayed to the user if its intended to all offices or Its part of User's office
                    if((officesSpec.satisfiedBy(objIE)) && (objIE.Date_of_Event__c != null && objIE.Date_of_Event__c >= Date.Today() && (objIE.End_Date__c == null || objIE.End_Date__c != null)))
                    {
                            setIntranetEventIdsToDisplay.add(objIE.Id);
                    }
                } 
            }
            
            //Checking if set contains ContentVersion
            if(setSobjectNames.contains('ContentVersion'))
            {
                //Query string for Content Version
                String strQueryCV = 'Select Id, Title, IsLatest, FeaturedContentBoost, Description, FileType, ContentUrl, For_All_Offices__c, Selected_Offices_Ids__c From ContentVersion ' +
                                        'where Id IN:  setContentVersionIds and IsLatest = true order by CreatedDate DESC limit 1000' ;
                
                //Getting all Content Records 
                for(ContentVersion objCV : database.query(strQueryCV))
                {
                    if(officesSpec.satisfiedBy(objCV))
                    {
                        if(objCV.FileType != null)
                            mapCVIdToFileType.put(objCV.Id, objCV.FileType);
                        else
                            mapCVIdToFileType.put(objCV.Id, '');
                    }
                }
            }
            
            //Checking if set contains Notification__c
            if(setSobjectNames.contains('Notification__c'))
            {   
                //Query string for Notification
                String strQuery = 'Select Notification_Detail__c, For_All_Departments__c, Selected_Department_Ids__c, For_All_Offices__c, Selected_Offices_Ids__c, Id, Name, CreatedDate, CreatedBy.SmallPhotoUrl, CreatedById ' + 
                                  ' From Notification__c' + 
                                  ' Where Active__c = true and (Display_As_Of__c <=:dt and Expiry_Date__c >=:dt) AND Id IN: setNotificationIds order By LastModifiedDate DESC Limit 1000'; 
                
                //Iterate through all the queried Notifications and filter based on the logged in user's offices
                for(Notification__c objNotify : database.query(strQuery))
                {
                    //Notification will be displayed to the user if its intended to all offices or Its part of User's office
                    if(officesSpec.satisfiedBy(objNotify))
                    {
                        setNotificationsIdToDisplay.add(objNotify.Id);
                    }
                }
            }
            
            //Checking if set contains Intranet_App__c
            if(setSobjectNames.contains('Intranet_App__c'))
            {
                //Getting records for App and Links widget based on the logged in user's offices
                for(Intranet_App__c obj : [Select Id, Name, For_All_Offices__c, Selected_Office_Ids__c, URL__c, Active__c 
                                           From Intranet_App__c 
                                           where Active__c = true and Id IN: setAppIds  order by Name ASC limit 1000])
                {
                    if(officesSpec.satisfiedBy(obj))
                    {
                        //Storing App Id to URL to mapAppIdToAppLink to be used in the page for click event
                        String strLink = (obj.URL__c != Null && obj.URL__c != '') ? ((obj.URL__c.startswith('http://') || obj.URL__c.startswith('https://') ) ? obj.URL__c : 'https://'+obj.URL__c) : '';
                        mapAppIdToAppLink.put(obj.Id, strLink);
                    }
                }
            }
            
            
            //Adding Recent Update record to  lstRecentUpdates to be displayed in the page
            for(Recent_Updates__c obj : listRecentUpdates)
            {
                if(setSobjectNames.contains(obj.Sobject_Type__c) && (setNotificationsIdToDisplay.contains(obj.Related_To__c) || setIntranetEventIdsToDisplay.contains(obj.Related_To__c) 
                	|| mapAppIdToAppLink.containsKey(obj.Related_To__c) || mapCVIdToFileType.containsKey(obj.Related_To__c)) && (Test.isrunningTest() || lstRecentUpdates.size() < objConfig.intTotalRecords))
                {
                    String strAppLink = mapAppIdToAppLink.containsKey(obj.Related_To__c) ? ( mapAppIdToAppLink.get(obj.Related_To__c) != null ?
                    mapAppIdToAppLink.get(obj.Related_To__c) : '') : '';
                    String strCVFileType = mapCVIdToFileType.containsKey(obj.Related_To__c) ? ( mapCVIdToFileType.get(obj.Related_To__c) != null ?
                    mapCVIdToFileType.get(obj.Related_To__c) : '') : ''; 
                    lstRecentUpdates.add(new RecentUpdateWrapper(obj, strAppLink, strCVFileType));
                }
            }
            listRecentUpdates = new List<Recent_Updates__c>();
        }
        catch(Exception e)
        {
            system.debug(e.getMessage()+'============'+e.getLineNumber());
        }
    }
    /** End : getRecentUpdates method **/
    
    
    /* Wrapper class for  Recent Updates */
    public class RecentUpdateWrapper
    {
        public Recent_Updates__c objRU    {get;set;}
        public String strAppURL         {get;set;}
        public String strFileType       {get;set;}
        
        public RecentUpdateWrapper(Recent_Updates__c objRecentUpdates, String strAppLink, String strCVFileType)
        {
            objRU = objRecentUpdates;
            strAppURL = strAppLink; 
            strFileType = strCVFileType;
        } 
    }
    /* End : Recent Updates Wrapper class */
    
    
    /* Start - Method for showMoreRecords functionality
       @Name           - showMoreRecords
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for displaying more Recent Updates.
    */
    public void showMoreRecords()
    {
        intRecentUpdateCount = intRecentUpdateCount + objConfig.intNumberToDisplay ;
        if(intRecentUpdateCount > objConfig.intTotalRecords)
        	intRecentUpdateCount = objConfig.intTotalRecords; 
    }
    
    //Function for creating Component dynamically.
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetRecentUpdates c = new Component.c.SL_IntranetRecentUpdates();   
        c.aComponentImpl = this;
        return c; 
    }
}