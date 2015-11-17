/**
* @ClassName    :   SL_Manage_Assumptions_Controller 
* @JIRATicket   :   slpsa-11
* @CreatedOn    :   
* @ModifiedBy   :   
* @Description  :   This is controler of "SL_Manage_Assumptions" page
*/

/**
Percentage of best practices followed   : 100%
 No of SOSL queries used                    : 0
No of collections used                  : 4
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 20
Customer Approval                       :
Last Modified Date                      : 18/Jun/13
Approved by                             :

*/

public with sharing class SL_Manage_Assumptions_Controller 
{
    public List<SelectOption> showSizeOptions   {get;set;}
    public Integer noOfRecords                  {get;set;}
    public Integer showSize                     {get;set;}
    public String sortBy                        {get;set;}
    public String sortDir                       {get;set;}
    public String pageNumInput                  {get; set{pageNumInput = value; setCon.setPageNumber(calcPageNum());}}
    public String displayPagination             {get {return (String.valueOf((pageNum * showSize)+1-showSize) + '-' + String.valueOf(((pageNum * showSize)>noOfRecords?noOfRecords:(pageNum * showSize))) + ' of ' + noOfRecords);}}
    public Boolean hasNext                      {get {return setCon.getHasNext();}set;}
    public Boolean hasPrevious                  {get {return setCon.getHasPrevious();}set;}
    public Integer pageNum                      {get {return setCon.getPageNumber();}set;}  
    public Integer pageNumCount                 {get { Double tempPageCount = (Double)setCon.getResultSize()/(Double)setCon.getPageSize(); if(tempPageCount > Integer.ValueOf(tempPageCount)) tempPageCount = integer.ValueOf(tempPageCount)+1;  return integer.ValueOf(tempPageCount); }set;}  
    public void first()                         {setCon.first();pageNumInput = String.valueOf(pageNum); pageNumberTemp=pageNum; getAssumptions();}
    public void last()                          {setCon.last();pageNumInput = String.valueOf(pageNum); pageNumberTemp=pageNum; getAssumptions();}
    public void prev()                          {setCon.previous();pageNumInput = String.valueOf(pageNum); pageNumberTemp=pageNum; getAssumptions();}
    public void next()                          {setCon.next();pageNumInput = String.valueOf(pageNum); pageNumberTemp=pageNum; getAssumptions();}
    public String ChangeOrderId                 {get;set;}
    public String ChangeOrderName               {get;set;}
    public String OpptyId                       {get;set;}
    public String OpptyName                     {get;set;}
    public String ClientName                    {get;set;}
    public String ProjectName                   {get;set;}
    public String ProjectId                     {get;set;}
    public string strSearchText                 {get;set;}
    public string strFilterText                 {get;set;}
    public String strAssumptionId               {get;set;}
    public String strPAId                       {get;set;}
    public Boolean isOppty                      {get{if(ChangeOrderId==null || ChangeOrderId=='' ){return true;} return false;} set;}
    public Assumption__c newAssumption          {get;set;}
    public Assumption__c filterAssumptionLog    {get;set;}
    public Assumption__c filterAssumption       {get;set;}
    public Map<String,String> params            {get;set;}
    public list<AssumptionWrapper> myData       {get;set;}
    public List<ProjectAssumptionWrapper> lstExistingAssumptionWrapper      {get;set;}
    
    private Integer pageNumberTemp = 0;
    private String whereString = '';
    private string strSearchTextTemp = '';
    private Set<Id> setAssumptionId;//This set is used to keep the Id of the assumption not to query for Available section.
    
    ///static variable for fetching ad hoc assumptions due to changes made for SLPSA-11
    private static String strAssumption = 'AD HOC ASSUMPTIONS';
    
    /* newly added*/
    public Project_Assumption__c objProjectAssumption {get;set;}
    
    public ApexPages.StandardSetController setCon 
    {
        get
        {
            if(setCon == null)
            {
                String queryString = '';
                String sortString = '';  
                whereString = '';   
                string strSearch = '';    
                getExistingAssumptions();     
                try
                {
                    
                    if(filterAssumption != null && (filterAssumption.Industries__c != null || filterAssumption.Task_Type__c != null ||filterAssumption.Component__c != null))
                    {
                        filterAssumptionLog = new Assumption__c(Industries__c = filterAssumption.Industries__c,
                                                                Task_Type__c = filterAssumption.Task_Type__c,
                                                                Component__c = filterAssumption.Component__c);

                        if(filterAssumption.Task_Type__c != null && !filterAssumption.Task_Type__c.contains('All'))
                            whereString += dynamicWhereClause('Task_Type__c');
                            
                        if(filterAssumption.Industries__c != null && !filterAssumption.Industries__c.contains('All'))
                            whereString += dynamicWhereClause('Industries__c');
                            
                        if(filterAssumption.Component__c != null && !filterAssumption.Component__c.contains('All'))
                            whereString += dynamicWhereClause('Component__c');
                        
                        if(whereString == '')
                            whereString = ' WHERE ';
                        else
                            whereString += ' AND ';
                        
                        whereString += ' Id NOT IN:setAssumptionId AND Do_Not_Add_to_Library__c = false';
                    }
                    else
                    {
                        whereString = ' WHERE Id NOT IN:setAssumptionId AND Do_Not_Add_to_Library__c = false ';
                    }

                    // If searchText isn't blank, adding this condition in where clause
                    if(strSearchText != null && strSearchText != '' )
                    {
                        strSearch = string.escapeSingleQuotes(strSearchText);
                        if(strSearchText.contains('_'))
                            strSearch = strSearchText.replace('_','\\_') ;
                        if(strSearchText.contains('%'))
                            strSearch = strSearchText.replace('%','\\%') ;
                            
                        whereString += ' AND ( Name Like \'%'+strSearch +'%\' OR Assumption_Detail_UI__c  Like \'%'+strSearch +'%\' )';
                        
                        if(strSearchText != strSearchTextTemp)
                            pageNumberTemp = 0; 
                        strSearchTextTemp = strSearchText;
                    }

                    sortString = ' ORDER BY ' + sortBy + ' ' + sortDir;
                    queryString = 'Select Id, Name, Industries__c, Task_Type__c, View_Edit__c, Assumption_Detail_UI__c,Number_of_Times_Used__c, Component__c, Assumption_Detail__c from Assumption__c' + whereString + sortString;
                   
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                   
                    // Pagination  starts
                    noOfRecords = setCon.getResultSize();
                    setCon.setPageSize(showSize);
                    double totalRec = noOfRecords;
                    
                    if(pageNumberTemp !=0  && showSize != 0 && ((noOfRecords < totalRec && pageNumberTemp <= noOfRecords+1) || (noOfRecords == totalRec && pageNumberTemp <= noOfRecords)))
                    {
                        if(showSize != 0 &&  noOfRecords/showSize >= pageNumberTemp)
                            setCon.setPageNumber(pageNumberTemp);
                        pageNumInput = string.valueOf(pageNumberTemp);
                    }
                    else
                    {
                        setCon.setPageNumber(1);
                        pageNumInput = '1';
                    }
                }
                catch(Exception ex)
                {
                    system.debug('==============Exception======='+ex+'===@line======='+ex.getLineNumber());
                }
            }
            return setCon;
        }
        set;
    }
    //Constructor
    public SL_Manage_Assumptions_Controller()
    {
        params = System.currentPageReference().getParameters();
        ChangeOrderId= params.get('coId');
        ChangeOrderName= params.get('coName');
        OpptyId = params.get('oppId');
        OpptyName = params.get('oppName');
        ProjectId = params.get('projId');
        ProjectName = params.get('projName');
        ClientName = params.get('client');
        newAssumption = new Assumption__c();
        filterAssumption = new Assumption__c();
        filterAssumptionLog = new Assumption__c();
        setAssumptionId = new Set<Id>();  
       
        
        lstExistingAssumptionWrapper = new List<ProjectAssumptionWrapper>();
        showSizeOptions = querySizeOptions(); 
           
        objProjectAssumption = new Project_Assumption__c();
        
        showSize = 10;
        sortBy='Number_of_Times_Used__c';
        sortDir='DESC';   
        pageNumInput = '1';
        strAssumptionId = strPAId = strSearchText = strSearchTextTemp = strFilterText ='';
       
        //Calling this method in constructor to get the already created project Assumption and avoid them for bing displayed on the Available assumption
       
        getAssumptions();
    }

    // Helper Method to populate the SizeOptions for the page.
    public List<SelectOption> querySizeOptions() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('10','10 per page'));
        options.add(new SelectOption('25','25 per page'));
        options.add(new SelectOption('50','50 per page'));
        options.add(new SelectOption('100','100 per page'));
        options.add(new SelectOption('200','200 per page'));
        return options;
    }

    // Helper Method to dynamically build a where clause for filtering.
    public String dynamicWhereClause(String fieldName)
    {
        String retVal='';
        String nonNullWhere = (whereString.length() == 0? ' WHERE ':' AND ');
        retVal += nonNullWhere;
        retVal += fieldName + ' INCLUDES(';
        
        String values = (String)filterAssumption.get(fieldName);
        
        for(String srtPickListVal : values.split(';'))
            retVal += '\''+srtPickListVal+'\',';
            
        
        if(retVal.length() >= 1)
            retVal = retVal.substring(0,retVal.length()-1);
            
        retVal += ',\'All\' )';
        
        return retVal;
    }
    
    // Helper method to calculate the page number based on the page input "pageNumInput"
    private Integer calcPageNum()
    {
        Integer page = Integer.valueOf(pageNumInput);
        
        if(page > 0)
        {
            if(page>pageNumCount)
            {
                page = pageNumCount;
                pageNumInput = String.valueOf(pageNumCount);
            }
        }
        else
            page=1;
            
        return page;
    }
    
    //Removing filters and search text on click of remove link
    public void removeFiltersAndSearchText()
    {
        if(strFilterText == 'industries')
        {
            filterAssumption.put('Industries__c',null);
            filterAssumptionLog.put('Industries__c',null);
        }
        else if(strFilterText == 'taskType')
        {
            filterAssumption.put('Task_Type__c',null);
            filterAssumptionLog.put('Task_Type__c',null);
        }
        else if(strFilterText == 'components')
        {
            filterAssumption.put('Component__c',null);
            filterAssumptionLog.put('Component__c',null);
        }
        else if(strFilterText =='search')
        {
            strSearchText = '';
        }
        //To get the updated list of Available assumption
        refresh();
    }
    
    // Adding Assumption record to list myData
    public List<AssumptionWrapper> getAssumptions(){
        
        myData = new List<AssumptionWrapper>();
        for (Assumption__c assumption: (List<Assumption__c>)setCon.getRecords())
            myData.add(new AssumptionWrapper(assumption));
            
        return myData;
    }
    
    // Helper method to get Existing Assumption record
    public List<ProjectAssumptionWrapper> getExistingAssumptions()
    {
        lstExistingAssumptionWrapper = new List<ProjectAssumptionWrapper>();
        setAssumptionId = new Set<Id>();
        String query = 'SELECT Id, Assumption__c, View_Edit__c, Assumption_Detail_UI__c, Sort_Order__c, Assumption_Detail__c, Change_Order__c FROM Project_Assumption__c WHERE ';
        
        if(ChangeOrderId != null && ChangeOrderId != '')    
            query += 'Change_Order__c = \'' + ChangeOrderId +'\'';
        else if(OpptyId != null && OpptyId != '')
            query += 'Opportunity__c = \'' + OpptyId +'\'';
            
        query+= ' ORDER BY Sort_Order__c ASC NULLS LAST';   
        if((ChangeOrderId != null && ChangeOrderId != '') || (OpptyId != null && OpptyId != ''))
        {
            for(Project_Assumption__c objProjectAssumption : Database.query(query))
            {
                setAssumptionId.add(objProjectAssumption.Assumption__c);
                lstExistingAssumptionWrapper.add(new ProjectAssumptionWrapper(objProjectAssumption));
            }
        }
        return lstExistingAssumptionWrapper;
    }
    
    // Public method to refresh the page.
    public pageReference refresh()
    {
        pageNumberTemp = pageNum;
        setCon = null;
        getAssumptions();
        getExistingAssumptions();
        return null;
    }

    // Public method used to re-init the filterAssumption
    public void resetFilter()
    {
        newAssumption = new Assumption__c();
        objProjectAssumption = new Project_Assumption__c();     
        filterAssumption = new Assumption__c(Industries__c = filterAssumptionLog.Industries__c,Task_Type__c = filterAssumptionLog.Task_Type__c,Component__c = filterAssumptionLog.Component__c);
    }

    // Inserting Project_Assumption__c record when "Add Selected" button is clicked or on double click of page block
    public void addSelected() 
    {
       
        try
        {
            list<Project_Assumption__c> lstPAToInsert = new list<Project_Assumption__c>();
            
            if(strAssumptionId != null && strAssumptionId != '')
            {
                setAssumptionId.add(strAssumptionId);
                if(ChangeOrderId != null && ChangeOrderId != '')    
                    lstPAToInsert.add(new Project_Assumption__c(Assumption__c = strAssumptionId, Change_Order__c = ChangeOrderId));
                else if(OpptyId != null && OpptyId != '')
                    lstPAToInsert.add(new Project_Assumption__c(Assumption__c = strAssumptionId, Opportunity__c = OpptyId));
                            
                strAssumptionId ='';
            }
            else
            {
                for(AssumptionWrapper objAssWrapper : myData)
                {
                    if(objAssWrapper.selected)
                    {
                        setAssumptionId.add(objAssWrapper.assumption.Id);
                        
                        if(ChangeOrderId != null && ChangeOrderId != '')    
                            lstPAToInsert.add(new Project_Assumption__c(Assumption__c=objAssWrapper.assumption.Id, Change_Order__c=ChangeOrderId));
                        else if(OpptyId != null && OpptyId != '')
                            lstPAToInsert.add(new Project_Assumption__c(Assumption__c=objAssWrapper.assumption.Id, Opportunity__c=OpptyId));
                    }
                }
            }
            if(lstPAToInsert.size() > 0)
                insert lstPAToInsert;
                   
            //To get the updated list of Available assumption
             refresh();
        }
        catch(Exception ex)
        {
            system.debug('==============Exception======='+ex+'===@line======='+ex.getLineNumber());
        }
    }
    
    // Inserting Project_Assumption__c record when "Remove Selected" button is clicked or on double click of page block
    public void removeSelected()
    {
        try
        {
            List<Project_Assumption__c> lstPAToDelete = new List<Project_Assumption__c>();
            if(strAssumptionId != null && strAssumptionId != '' && strPAId != null && strPAId != '')
            {
                setAssumptionId.remove(strAssumptionId);
                lstPAToDelete.add(new Project_Assumption__c(Id= strPAId));
                strAssumptionId = strPAId = '';
            }
            else
            {
                for(ProjectAssumptionWrapper objAssWrapper : lstExistingAssumptionWrapper)
                {
                    if(objAssWrapper.isSelected)
                    {
                        setAssumptionId.remove(objAssWrapper.projectAssumption.Assumption__c);
                        lstPAToDelete.add(objAssWrapper.projectAssumption);
                    }
                }
            }
            if(lstPAToDelete.size() > 0)
                delete lstPAToDelete;
                    
            //To get the updated list of Available assumption
            refresh();  
        }
        catch(Exception ex)
        {
            system.debug('==============Exception======='+ex+'===@line======='+ex.getLineNumber());
        }
    }

    // Public method to add a new assumption to the CO or Oppty as well as check to see if this assumption should be added to the assumption library.
    public void createNewAssumption() 
    {
        try
        {
            insert newAssumption;
            
            //To get the updated list of Available assumption
            refresh();
            newAssumption = new Assumption__c();
        }
        catch(Exception ex)
        {
            system.debug('==============Exception======='+ex+'===@line======='+ex.getLineNumber());
        }
    }

    // Public method to add a new assumption to the CO or Oppty as well as check to see if this assumption should be added to the assumption library.
    public void createAndAddNewAssumption() 
    {
        try
        {
            insert newAssumption;
            
            if(newAssumption.Id != null )
            {
                Project_Assumption__c objPA = new Project_Assumption__c(Assumption__c = newAssumption.Id);
                
                if(OpptyId != null && OpptyId != '')
                    objPA.Opportunity__c = OpptyId;
                else if(ChangeOrderId != null && ChangeOrderId != '')
                    objPA.Change_Order__c = ChangeOrderId;
                insert objPA;
                setAssumptionId.add(newAssumption.Id);
            }
            
            //To get the updated list of Available assumption
            refresh();
            newAssumption = new Assumption__c();
        }
        catch(Exception ex)
        {
            system.debug('==============Exception======='+ex+'===@line======='+ex.getLineNumber());
        }
    }
    
    // Public method to add a new assumption to the CO or Oppty as well as check to see if this assumption should be added to the assumption library.
    public void createNewAdHocAssumption() 
    {
        try
        {
            List<Assumption__c> lstDNATLAssumption = new List<Assumption__c>();
            
            //Querying the existing Do_Not_Add_to_Library Assumption
            lstDNATLAssumption = [Select Id, Name, Assumption_Detail__c From Assumption__c where Name =: strAssumption limit 1];
            
            //if Do_Not_Add_to_Library Assumption not present in database then creating the new one
            ///Commented code due to changes made for SLPSA-11
            /*if(lstDNATLAssumption.isEmpty())
            {
                Assumption__c newAssumption = new Assumption__c(Do_Not_Add_to_Library__c = true, 
                                                                Name = 'DO NOT ADD TO LIBRARY', 
                                                                Assumption_Detail__c = objProjectAssumption.Assumption_Detail_One_time_use__c);
                insert newAssumption;
                lstDNATLAssumption.add(newAssumption);
            }*/
            
            //Creating the project assumption record
            objProjectAssumption.Assumption__c = lstDNATLAssumption[0].Id;
            
            if(OpptyId != null && OpptyId != '')
                objProjectAssumption.Opportunity__c = OpptyId;
            else if(ChangeOrderId != null && ChangeOrderId != '')
                objProjectAssumption.Change_Order__c = ChangeOrderId;
                
            insert objProjectAssumption;
            
            objProjectAssumption = new Project_Assumption__c();
        }
        catch(Exception ex)
        {
            system.debug('==============Exception======='+ex+'===@line======='+ex.getLineNumber());
        }
    }

    public PageReference back() 
    {
        PageReference retPage = new PageReference('/'+ (isOppty?OpptyId:ChangeOrderId) );
        retPage.setRedirect(true);
        return retPage;
        
    }
    
    //Public Wrapper class for the assumptions to allow selection and disabling.
    public class AssumptionWrapper 
    {
        public Assumption__c assumption {get; set;}
        public Boolean selected {get; set;}
        public Boolean disabled {get;set;}
    
        public AssumptionWrapper(Assumption__c a) 
        {
            this.assumption = a; 
            this.selected = false;
            this.disabled = false;
        }
    }
    
    //Public Wrapper class for the displaying the project assumptions on left sode.
    public class ProjectAssumptionWrapper 
    {
        public Project_Assumption__c projectAssumption {get; set;}
        public Boolean isSelected {get; set;}
        public Boolean isDisabled {get;set;}
    
        public ProjectAssumptionWrapper(Project_Assumption__c pa) 
        {
            this.projectAssumption = pa; 
            this.isSelected = false;
            this.isDisabled = false;
        }
    }
}