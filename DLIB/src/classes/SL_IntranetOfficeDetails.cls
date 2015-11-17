/**
 * @ClassName    : SL_IntranetOfficeDetails 
 * @JIRATicket   : Socint-319
 * @CreatedOn    : 22/Nov/13
 * @ModifiedBy   : Anil 
 * @Description  : This is class for SL_IntranetOfficeDetails to get detailed information about Intranet Offices.
 */
 
 /**
 @ Anil Kumar
 Percentage of best practices followed   : 100%
 No of SOQL queries used                 : 3
 No of collections used                  : 5
 Exception Handling implemented          : Yes
 Coding standards followed               : Yes
 Naming conventions followed             : Yes
 Third party integrations                : No
 Maximum of No of records tested with    : 
 Customer Approval                       : 
 Last Modified Date                      : 
 Approved by                             : 
 */
 
public with sharing class SL_IntranetOfficeDetails extends WidgetAbstract  
{
  public Office_Locations__c objOffice {get; set;}  //Used to setting information about selected Intranet Office.
  public officeDetailConfiguration officeConfiguration {get; set;}  //configuration of office detail widget
  public List<SL_UtilityWrappers.FieldSetDescribe> lstOfficeInfoFields {get; set;}    //List of office fields that needs to display on component.
  public List<String> lstOfficeAddress {get;set;} //Storing the Office Address
  
  public String strOfficeId {get; set;}  //Used to set Id of Intranet Office to get information about that Office.
  public String strWidgetId {get; set;}  //Used to set calling widget instance Id.
  public String strUserAddressForMap {get; set;}  //Used to store office address
  
  public String strImageWidth {get; set;}  //Used to set Image width based on layout type
  public String strMapWidth {get; set;}  //used to set map width based on layout type
  
  //default Office location fields
  //private List<String> lstDefaultOfficeInfoFields = new List<String>{'Company_Name__c','Address__c','Phone__c','Fax__c'};  
  private Set<String> setDefaultOfficeInfoFields = new Set<String>{'Company_Name__c','Address__c','Phone__c','Fax__c'};
  private List<String> lstDefaultOfficeInfoFields = new List<String>{'Company_Name__c','Address__c','Phone__c','Fax__c'};
  private Set<String> setDefaultOfficeFields = new Set<String>{'Name','Image__c', 'Id', 'Map__c'};
  
  private String strPageName;  //used to set current page name
  private String strQuery;  //used for preparing query string for Office Detail widget
  
  private Static Map<String, String> mapImageWidth = new Map<String, String>{
       '2 Column Layout Right Main Page' => '400px',
     '2 Column Layout Half Page' => '250px',
     '3 Column Layout Page' => '250px'
  };
  
  private Static Map<String, String> mapMapWidth = new Map<String, String>{
       '2 Column Layout Right Main Page' => '265px',
     '2 Column Layout Half Page' => '164px',
     '3 Column Layout Page' => '150px'
  };
  
  
  /* 
  * Constructor calling
  */
  public SL_IntranetOfficeDetails()
  {
    initializeVariables();
    
    strPageName = ApexPages.currentPage().getParameters().get('page');
        if(strPageName == null || strPageName == '')
            strPageName = 'Home';
    
    Page__c objPage = [SELECT LayoutType__c FROM Page__c WHERE Name =: strPageName LIMIT 1];
    String strLayout = objPage.LayoutType__c;
    
    if(mapImageWidth.containskey(strLayout))
      strImageWidth = mapImageWidth.get(strLayout);
    
    if(mapMapWidth.containskey(strLayout))
      strMapWidth = mapMapWidth.get(strLayout);  
  }
  
  
  /* 
  * Inner class for Office Detail widget configuration ({"backgroundColor":"","fontColor":"","heading":"","headingColor":"","initialState":"","fieldSet":""})
  */
  public class officeDetailConfiguration
  {
    public String backgroundColor {get; set;}
    public String fontColor {get; set;}
    public String headingBackground {get; set;}
    public String headingColor {get; set;}
    public String initialState {get; set;}
    public String fieldSet {get; set;}
  }
  
  
  /* 
  * Function for initializing all local and global variables 
  */
  private void initializeVariables()
  {
    objOffice = new Office_Locations__c();
    officeConfiguration = new officeDetailConfiguration();
    lstOfficeInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
    lstOfficeAddress = new List<String>();
    strOfficeId = strPageName = strWidgetId = strUserAddressForMap = '';
    strQuery = 'SELECT Id, Name, Image__c, Address__c, Company_Name__c, Fax__c, Phone__c, Map__c';

    //Default width for Image and Map
    strImageWidth = '250px';
    strMapWidth = '150px';
  }
  
  // initialize method called on component's initialize
  public override protected void initialize()
  {
  	if(!getObjectAccess('read', new Office_Locations__c().getsObjectType()))
		return ;
    OfficeDetailConfiguration();
    OfficeDetailQuery();
  }
  
  /* 
  * Function for preparing configuration for Office detail
  */
  public void OfficeDetailConfiguration()
  {
    // Fetch the configuration for the widget
    if(this.properties != null) {
      Map<String, Object> configuration = (Map<String, Object>)this.properties;

      if(configuration.containsKey('fieldSet'))       officeConfiguration.fieldSet        = String.valueOf(configuration.get('fieldSet'));
      if(configuration.containsKey('backgroundColor'))   officeConfiguration.backgroundColor   = String.valueOf(configuration.get('backgroundColor'));
      if(configuration.containsKey('fontColor'))       officeConfiguration.fontColor        = String.valueOf(configuration.get('fontColor'));
      if(configuration.containsKey('headingBackground'))   officeConfiguration.headingBackground   = String.valueOf(configuration.get('headingBackground'));
      if(configuration.containsKey('headingColor'))     officeConfiguration.headingColor      = String.valueOf(configuration.get('headingColor'));
      if(configuration.containsKey('initialState'))     officeConfiguration.initialState      = String.valueOf(configuration.get('initialState'));  
    }
  }
  
  
  /* 
  * Function for preparing query string and list of fields to be display on component
  */
  public void OfficeDetailQuery()
  {
    if(String.isNotBlank(officeConfiguration.fieldSet))
        {
         SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Office_Locations__c', officeConfiguration.fieldSet, '', '', '', setDefaultOfficeFields);
         lstOfficeInfoFields = objFieldSetWrapper.lstFieldWrapper;
        }
    
    //If fieldset is not having any fields or fieldset is not defined then add default fields for displaying it on component
    if(lstOfficeInfoFields.isEmpty())
      lstOfficeInfoFields.addAll( Utilities.describeDefaultFields( 'Office_Locations__c', lstDefaultOfficeInfoFields) );
    
    // Iterate through the fields returned previously to form a query
    for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstOfficeInfoFields)
    {
      if(!setDefaultOfficeInfoFields.contains(objFieldSetResult.fieldAPIName) && !setDefaultOfficeFields.contains(objFieldSetResult.fieldAPIName))
      {
        strQuery += ', ' + objFieldSetResult.fieldAPIName;
      }
    }  
  }
  
  /* 
  * Function for getting detail of Intranet Office based on office id
  */
  public void getOfficeDetails()
  {
  	if(!getObjectAccess('read', new Office_Locations__c().getsObjectType()))
		return ;
    List<Office_Locations__c> lstOfficeDetail = new List<Office_Locations__c>();
    lstOfficeAddress = new List<String>();
    
    //String strQueryTemp = strQuery + ' FROM Office_Locations__c WHERE Id =: strOfficeId';
    lstOfficeDetail = database.query(strQuery + ' FROM Office_Locations__c WHERE Id =: strOfficeId');
    
    if(lstOfficeDetail.size() > 0)
    {
      objOffice = lstOfficeDetail[0];
      if(lstOfficeDetail[0].Address__c != null && lstOfficeDetail[0].Address__c != '')
        lstOfficeAddress = lstOfficeDetail[0].Address__c.split('\\n');
    }  
      
    officeConfiguration.initialState = 'full';
      
  }
  
  /* 
  * unction for creating Component dynamically.
  */
  public override ApexPages.Component newComponent() 
  {
      Component.c.SL_IntranetOfficeDetails c = new Component.c.SL_IntranetOfficeDetails();   
    c.aComponentImpl = this;
      return c;
    }
}