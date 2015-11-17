/************************************************************************************************************
* Name          : GACompanyDirectoryController
* Created Date  : 2 May 2013
* Created By    : Appirio Offshore (Hemant)
* Description   : Controller Class for VF Page: GACompanyDirectory [To display the Search results for the contacts (GA Comapny Employees)]
* Related Story : S-105969 
************************************************************************************************************/
public class GACompanyDirectoryController {
    
    //constants
    private static final string PICKLIST_OPTION_NONE = '--None--';
    private static final string RECORDTYPE_ALL = 'All';
    private static final string DEFAULT_RECORDTYPE_EMPLOYEE = 'Employee';
    private static final String ERROR_MESSAGE = 'There are large number of records queried that cannot be shown on the page. Please apply the filters to refine your search criteria.';
  	private static final Integer PAGE_SIZE_DEFAULT = 100;
  	private static final Integer MAX_ROW_COUNT_LIMIT = 10000;
    
  public List<Contact> allContLst {get;set;}
  public List<Contact> contLst {
  	get  
        {  
	        if(con != null)  
	            return (List<Contact>)con.getRecords();  
	        else  
	            return new List<Contact>();  
        }  
    set;}  
  public Boolean showData{get;set;}
  private Set<Id> usrIdSet;
  
  Map<String, String> mapOfPhoto{get;set;}
    
    //For Contact (User)
    public String contName{get;set;}  
    
    //For Location
    public String selectedLocation{get;set;}  
    public List<SelectOption> locationList{get;set;}
    
    //For Title
    public String selectedTitle{get;set;}  
    
    //For RecordType Filter
    public String selectedRecordType{get;set;}  
    public List<SelectOption> recordTypeList{get;set;}

    //constructor
    public GACompanyDirectoryController(){
        init();
    }
    
    //initialization method
    private void init(){
        
    //load the Filter options
    loadFilterOptions();
    //setting default value = Employee for Record type
    selectedRecordType = DEFAULT_RECORDTYPE_EMPLOYEE;
    showData = false;
    allContLst = new List<Contact>();
    mapOfPhoto = new Map<String,String>();
    usrIdSet = new Set<Id>();
    }
    
    //loading Filters Picklist values
    private void loadFilterOptions(){
        
        locationList = new List<SelectOption>{new SelectOption('', PICKLIST_OPTION_NONE)};
        recordTypeList = new List<SelectOption>();
        
        //using custom setting GA_Company_Directory_Filters__c
    for(GA_Company_Directory_Filters__c GACompDirFltr : GA_Company_Directory_Filters__c.getAll().values()){
        //loading Location Picklist values
        if(GACompDirFltr.Location_Picklist__c != null){
        for(String loc : GACompDirFltr.Location_Picklist__c.split(';')){
            locationList.add(new SelectOption(loc, loc));
          }               
        }
    }
    
    //loading Record type Picklist values
    recordTypeList.add(new SelectOption(RECORDTYPE_ALL, RECORDTYPE_ALL));
    for(RecordType rt: [Select Id, Name, SobjectType from RecordType Where SobjectType = 'Contact' And IsActive = true order By Name]){
        recordTypeList.add(new SelectOption(rt.Name, rt.Name)); 
    }
    }
    
    /**
    * This method is used to retrive leads meeting the filter criteria
    */
    public void retriveContactData(){
    try{
        showData = true;
        con = new ApexPages.StandardSetController(Database.getQueryLocator(getContactQuery()));
      
      	// sets the number of records in each page set
      	con.setPageSize(PAGE_SIZE_DEFAULT);
    }
    catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,ERROR_MESSAGE));
      return;
    }
    }
    
    //method to get the Contacts query 
   private String getContactQuery(){
     String soqlQry = 'select Id, User__c, User__r.SmallPhotoUrl, User__r.Name, Name, FirstName, LastName, Title, MailingCity, RecordType.Name, MobilePhone, Phone, Email From Contact';
        
     String soqlQry_Where = getSOQLQuery_WhereCondition();
     
     soqlQry += soqlQry_Where + getSOQLQuery_LimitCondition();
     system.debug('*********soqlQry**********' + soqlQry);
     return soqlQry; 
    }
    
    // method to get the where condition query after applying the filters
    private String getSOQLQuery_WhereCondition(){
        String soqlQry_Where = ' Where CreatedBy.Name != null';
     
     //adding name filter
     if(contName != null && contName != ''){
       soqlQry_Where += ' AND Name Like \'%' + contName + '%\'';
     }
     //adding location filter
     if(selectedLocation != null && selectedLocation != ''){
       soqlQry_Where += ' AND MailingCity =: selectedLocation';
     }
     //adding title filter
     if(selectedTitle != null && selectedTitle != ''){
       soqlQry_Where += ' AND Title Like \'%' + selectedTitle + '%\'';
     }
     //adding RecordType filter
     if(selectedRecordType != null && selectedRecordType != '' && selectedRecordType != RECORDTYPE_ALL){
       soqlQry_Where += ' AND RecordType.Name =: selectedRecordType';
     }
     
     //adding Order By filter
     soqlQry_Where += ' Order By LastName, FirstName';
     
     return soqlQry_Where; 
    }
    
    // method to get the limit condition query 
    private String getSOQLQuery_LimitCondition(){
      return ' Limit ' + String.valueOf(MAX_ROW_COUNT_LIMIT);
    }
    
    // method to redirect the user to Export file 
    public PageReference exportPDF(){
    	allContLst = (List<Contact>) Database.query(getContactQuery());
      PageReference pg = new PageReference('/apex/GACompanyDirectoryExport');      
      pg.getHeaders().put('content-disposition', 'attachment; filename=GACompanyDirectoryExport_' + String.valueOf(Date.today())+'.pdf');
      return pg; 
    }
    
    /******************** Pagination Implementation Start ************************/
    
    //Instantiate the StandardSetController
    public ApexPages.StandardSetController con{get; set;}
    
    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    //Returns the previous page of records
    public void previous()
    {
        con.previous();
    }
    
    //Returns the first page of records
    public void first()
    {
        con.first();
    }
    
    //Returns the last page of records
    public void last()
    {
        con.last();
    }
 
    //Returns the next page of records
    public void next()
    {
        con.next();
    }
    /******************** Pagination Implementation End   ************************/
}