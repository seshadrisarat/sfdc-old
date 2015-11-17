/*
*       AdvancedSearch_Controller is used to perform Controller logic for new Advanced Search VF page.  This controller inherits the Many to Many 2 controller.
*       This controller is used for display the custom UI for adding and managing many to many junction data for Advanced Searches.
* 
*       Author  :   Wilson Ng 
*       Date    :   October 18, 2012
* 
*/
public with sharing virtual class AdvancedSearch_Controller extends M2M2_Controller {
    
    // static variables for field set names for Advanced Search filter fields
    public static final String FIELDSET_FILTERFIELDS = 'AdvancedSearch_Filter_Fields';
    public static final String FILTER_OBJECT = 'AdvancedSearch_Filter__c';

    
    public AdvancedSearch_Controller controller{get;set;}
    public string advSearchObjectName{get; private set;}
    public boolean showListviews{get; private set;}
    public boolean useSalesforceCreateNew{get; private set;}
    
    // filter properties
    public sObject filterRec{get;set;}
    public list<FieldLabelWrapper> filterFields { get; private set;}
    public list<Schema.FieldSetMember> filterFieldSet{get; private set;}
    
    // Properties - label merges
    public String advSearchTabLabel{get{ return String.format(System.Label.M2M2_SearchTabLabel, new string[]{toObjectLabelPlural==null?'':toObjectLabelPlural}); }}
    
    public boolean useAdvancedSearch{get; private set;}
    protected Schema.sObjectType advSearchSobj;
    public boolean isAdvancedSearchMode{get;private set;}

    // constructor using sobject standardcontroller
    public AdvancedSearch_Controller(ApexPages.StandardController stdController) {
        system.debug('in AdvancedSearch standard controller - '+this);

        // configuration values are passed directly into the properties variables
        rec = stdController.getRecord();
        
        initialize();
    }
    // constructor using custom controller
    public AdvancedSearch_Controller() {
        system.debug('in AdvancedSearch custom controller - '+this);
        // configuration values comes in through the url parameters
        map<String, String> params = ApexPages.currentPage().getParameters(); 
        system.debug('url parameter are: '+params);
        configName = params.get(PARAM_CONFIGNAME);
        retUrl = params.get(PARAM_RETURL);
        fromId = (Id)params.get(PARAM_FROMID);
        fromName = params.get(PARAM_FROMNAME);
        
        initialize();
    }
    protected virtual override void initialize(){
        super.initialize();
        
        controller = this;
        searchPerformed = false;
        isAdvancedSearchMode = false;
    }
    
    // process input configuration variables
    public virtual override PageReference myinitfunc() {
        system.debug('in AdvancedSearch myinitfunc...configName['+configName+'], fromId['+fromId+'], fromName['+fromName+'], retURL['+retURL+']');
        
        // initialize base
        super.myinitfunc();
        
        try {
            // specific advanced search configurations
            advSearchObjectName = currConfig.Search_Object_Name__c;
            useAdvancedSearch = currConfig.Use_Advanced_Search__c;
            insertJunctionRecordOnCreateNew = useM2M2;
            showListviews = currConfig.Use_Listviews__c;
            useSalesforceCreateNew = currConfig.Use_Salesforce_Create_New__c;
            
            // describe and validate generic sobjects, references and field sets for AdvancedSearch
            advSearchSobj = Schema.getGlobalDescribe().get(advSearchObjectName);            
            if(advSearchSobj.getDescribe().fieldSets.getMap().get(FIELDSET_FILTERFIELDS)==null)
                throw new AdvancedSearch_Exception('Missing Filter FieldSet ['+FIELDSET_FILTERFIELDS+'] for object ['+advSearchObjectName+']');
                
            // get Field Sets
            filterFieldSet = advSearchSobj.getDescribe().fieldSets.getMap().get(FIELDSET_FILTERFIELDS).getFields();
            filterRec = createObject(FILTER_OBJECT);
            filterFields = new list<FieldLabelWrapper>();
            for (FieldSetMember currMem : this.filterFieldSet){
                string fieldname = currMem.getFieldPath();

                if(fieldname.contains('.'))
                    fieldname = fieldname.substring(fieldname.lastIndexOf('.')+1);
                if(fieldname!='Id') 
                {
                    
                    if(fieldname=='Listing_Status__c')
                    {
                        filterRec.put(fieldName,'Vacant;Occupied;None');
                    }
                    
                    schema.displaytype fldtype = currMem.getType();
                    // handle low and high ranges for these data types
                    if(fldtype==schema.displaytype.double || fldtype==schema.displaytype.integer || fldtype==schema.displaytype.date || 
                                fldtype==schema.displaytype.datetime || fldtype==schema.displaytype.percent || fldtype==schema.displaytype.currency) {
                        this.filterFields.add(new FieldLabelWrapper(fieldname.replace('__c', '_low__c'), currMem.getLabel()+' (low)'));
                        this.filterFields.add(new FieldLabelWrapper(fieldname.replace('__c', '_high__c'), currMem.getLabel()+' (high)'));
                    }
                    else
                        this.filterFields.add(new FieldLabelWrapper(fieldname, currMem.getLabel()));
                }
            }
            tabInFocus = useM2M2 ? 'theManageTab' : 'theSearchTab';
            
            // initialize simple search
            if (searchSobj == null || searchSobj != advSearchSobj) {                
                
                // describe fieldsets
                super.describeCreateNewFieldset((advSearchObjectName=='Property_Lease__c'?'Lease__c':advSearchObjectName), FIELDSET_CREATENEWFIELDS);       // yet another property_lease hack
                super.describeSearchFieldset(advSearchObjectName, FIELDSET_SEARCHRESULTFIELDS);
                Schema.DescribesObjectResult sObjDescribe = advSearchSobj.getDescribe(); 
                searchObjectName = sObjDescribe.getName();
                searchObjectPrefix = sObjDescribe.getKeyPrefix();
                toObjectName = sObjDescribe.getName();
                toObjectLabel = sObjDescribe.getLabel();
                toObjectLabelPlural = string.isNotEmpty(currConfig.Tab_Label__c) ? currConfig.Tab_Label__c : sObjDescribe.getLabelPlural();
            
                // search variables
                searchTerm = '';        
                searchResults = new List<sObject>();
                searchPerformed = false;
            }
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.AdvancedSearch_Configuration_Error, new string[] {ex.getMessage()})));
            isFatalError = true;
        }
        return null;
    }
    
    public PageReference showAdvancedSearch(){
        isAdvancedSearchMode = !isAdvancedSearchMode;
        if(isAdvancedSearchMode)
            isCreateNewMode = false;
        return null;
    }
    
    
    public PageReference createNewRecord2(){
        // initialize new record
        isAdvancedSearchMode = false;
        return createNewRecord();
    }
    
    public PageReference goSearch2(){
        return (isAdvancedSearchMode ? goAdvancedSearch() : goSearch());
    }
    
    // action performs advanced search
    private PageReference goAdvancedSearch(){
        try {
            this.tabInFocus = 'theSearchTab';
            searchPerformed = false;
            if (filterRec!=null) {
                system.debug('search filter rec: '+filterRec);
                if(isEmpty(filterRec)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.AdvancedSearch_NoSearchCriterias));
                    return null;
                }
                
                Integer maxSize = maxSearchResults + 1;
                string fieldString = '';
                for (FieldSetMember currMem : searchFieldSet){
                    fieldString += currMem.getFieldPath() + ',';    
                }
                fieldString = fieldString.subString(0,fieldString.length()-1);
                
                // generate where filter clause from filterrec
                string whereClause = buildWhereclause(this.filterRec);
                
                // do advanced search, i.e. SOQL
                String soqlQuery = 'SELECT '+fieldString+' FROM '+advSearchObjectName+whereClause+' ORDER BY name LIMIT '+maxSize;
                System.debug('SOQL Name Query:'+soqlQuery);
                sObject filterRec = this.filterRec;
                searchResults = database.query(soqlQuery);
                if (searchResults.size()==maxSize){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(System.Label.M2M2_TooManyResults, new String[]{maxSearchResults.format()}) ));
                    searchResults.remove(maxSize-1);
                }
                searchPerformed = true;
            }
            else{
                searchResults = new List<sObject>();
            }
            return null;
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.AdvancedSearch_Fatal_Error, new string[] {ex.getMessage()})));
            isFatalError = true;
            return null;
        }
    }
    
    private string buildWhereclause(sObject record) {
        string retStr = '';
        for(FieldLabelWrapper filterfld : filterFields) {
            try {
                string vl = String.valueOf(record.get(filterfld.fld));
                if(!isEmpty(vl)) {
                    vl = string.escapeSingleQuotes(vl.trim());
                    fieldsetmember fsm = getFieldSetMember(this.filterFieldSet, filterfld.fld.replace('_low__c','__c').replace('_high__c','__c'));
                    schema.displaytype ty = fsm.getType();
                    string fd = fsm.getFieldPath();
                    string op = (filterfld.fld.contains('_low__c') ? ' >= ' :
                                    filterfld.fld.contains('_high__c') ? ' <= ' :
                                    ty==schema.displaytype.picklist ? ' in ' :
                                    ty==schema.displaytype.boolean ? ' = ' :
                                    ' like ');
                    if(!isEmpty(retStr))
                        retStr += ' AND ';
                    if(fd == 'Location_Neighborhood_name__c' || (advSearchObjectName == 'Property_Lease__c' && fd == 'Property__r.Location_Neighborhood_name__c'))
                    {
                        retStr += '(';
                    }

                    retStr += fd + op +
                            (ty==schema.displaytype.picklist ? '(\''+vl.replaceAll(';', '\',\'').replace('None','')+'\')' : 
                            ty==schema.displaytype.date ? vl.substring(0, vl.indexOf(' ')) :
                            ty==schema.displaytype.datetime ? vl.replace(' ', 'T')+'Z' :
                            ty==schema.displaytype.boolean||ty==schema.displaytype.double||ty==schema.displaytype.integer||ty==schema.displaytype.percent||ty==schema.displaytype.currency ? vl : 
                            '\'%'+vl+'%\' '); 
                    
                    //special condition for searching for a neighborhood. We need to search both neighbordhoods and sub neighborhoods that match the text given for the
                    //search string in the case of searching for 'Location_Neighborhood_name__c'. Since different objects have different ways of getting at that field on the
                    //Location_Neighborhood__c object, we need different where statments.
                    if(fd == 'Location_Neighborhood_name__c')
                    {                                        
                        if(advSearchObjectName == 'Listing__c')
                        {
                            retStr += ' or Property__r.Submarket__r.name like \'%'+vl+'%\')';
                        }
                        else if(advSearchObjectName == 'Property__c')
                        {
                            retStr += ' or Submarket__r.name like \'%'+vl+'%\')'; 
                        }                       
                        else
                        {
                            retStr += ')';
                        }
                    } 
                    else if(advSearchObjectName == 'Property_Lease__c' && fd == 'Property__r.Location_Neighborhood_name__c')
                    {
                        retStr += ' or Property__r.submarket__r.name like \'%'+vl+'%\')';
                    }  
                }
            } catch (SObjectException soe) {
                // do nothing and continue
            }
        }
        // add extra filter clause from the M2M2 custom setting record, if and only if
        //the field specified in the where clause has not already been set by the user
        if(!isEmpty(filterClause)) 
        {
            boolean applyCondition = true;
            
            for(FieldLabelWrapper filterfld : filterFields)
            {
                fieldsetmember fsm = getFieldSetMember(this.filterFieldSet, filterfld.fld.replace('_low__c','__c').replace('_high__c','__c'));
                schema.displaytype ty = fsm.getType();
                string fd = fsm.getFieldPath();   
                system.debug('\n\n\n Testing to See if '+fd+' appeares in ' + filterClause + ' if so, wont apply filter');         
                
                if(filterClause.containsIgnoreCase(fd))
                {
                    system.debug('WE HAVE A MATCH! DONT APPLY SECOND CONDITION!');
                    applycondition = false;
                    break;
                }
            }
            
            if(applyCondition)
            {
                if(!isEmpty(retStr))
                {
                    
                    retStr += ' AND ';
                }
                retStr += filterClause;
            }
        }
        if(!isEmpty(retStr))
            retStr = ' WHERE ' + retStr;
        
        system.debug('\n\n\n---------------- WHERE CLAUSE!: ' + retStr);
        return retStr;
    }
    
    private FieldSetMember getFieldSetMember(list<schema.FieldSetMember> fsmList, string fld) {
        for (FieldSetMember currMem : fsmList)
            if(fld == currMem.getFieldPath() || currMem.getFieldPath().endsWith(fld))
                return currMem;
        throw new AdvancedSearch_Exception(String.format(Label.AdvancedSearch_Fatal_Error, new string[] {'Unknown field, '+fld}));
    }
    
    private boolean isEmpty(sObject record) {
        // loop thru all defined fields in the fieldset
        for(FieldLabelWrapper fld : filterFields) {
            try {
                if(!isEmpty(String.valueOf(record.get(fld.fld))))
                    return false;
            }
            catch (SObjectException soe) {
                // ignore and continue
            }
        }
        return true;
    }
    
    // exception class
    public class AdvancedSearch_Exception extends Exception {}
    
    
    //
    // Test methods 
    @isTest
    static void testThisClass(){
        
        // insert config record: Deal_Property__c
        M2M2_Config__c testConfig = new M2M2_Config__c(Name='DealProperties', ObjectName__c='Deal_Property__c', FromField__c='Deal__c', ToField__c='Property__c', 
                                    AllowDuplicates__c=false, FilterClause__c='Thor_Ownership__c in (\'Thor Owned\')', 
                                    IsTextSearch__c=false, SearchResultLimit__c=10, Tab_Label__c='properties', Use_M2M2__c=false,
                                    Search_Object_Name__c='Property__c', Use_Salesforce_Create_New__c=true, Use_Listviews__c=false, Use_Advanced_Search__c=true);
        insert testConfig;

        // insert deal
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        
        // insert properties
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='testloc');
        insert loc;
        list<Property__c> props = new list<Property__c>();
        props.add(new Property__c(Name='test property1', Location_Neighborhood__c=loc.Id, Frontage_Ft__c=100, Thor_Ownership__c='Thor Owned'));         // note: M2M2 filter requires property ownership equals thor owned
        props.add(new Property__c(Name='test property2', Location_Neighborhood__c=loc.Id, Frontage_Ft__c=200, Thor_Ownership__c='Thor Prospect'));
        props.add(new Property__c(Name='test property3', Location_Neighborhood__c=loc.Id, Frontage_Ft__c=300, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property4', Location_Neighborhood__c=loc.Id, Frontage_Ft__c=400, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property5', Location_Neighborhood__c=loc.Id, Frontage_Ft__c=500, Thor_Ownership__c='Non-Thor Owned'));
        insert props;
        
        Test.startTest();
        
        // set initial page and controller instance
        PageReference testPageReference = Page.AdvancedSearch_Page; 
        map<string, string> params = testPageReference.getParameters();
        params.put(M2M2_Controller.PARAM_CONFIGNAME, 'DealProperties');
        params.put(M2M2_Controller.PARAM_FROMID, deal.Id);
        params.put(M2M2_Controller.PARAM_FROMNAME, deal.Name);
        params.put(M2M2_Controller.PARAM_RETURL, '/'+deal.Id);
        Test.setCurrentPage(testPageReference);
        AdvancedSearch_Controller testController = new AdvancedSearch_Controller(new ApexPages.StandardController(deal));       // cover both custom and standard controller
        testController = new AdvancedSearch_Controller();
        testController.myinitfunc();
        system.assertEquals(false, ApexPages.hasMessages(), 'Error: VF page/controller initialization has errors - ' + testController.concatenateApexPagesMessages());
        
        // perform advanced search
        testController.showAdvancedSearch();
        system.assertEquals(true, testController.isAdvancedSearchMode, 'Error: Controller did not enter into advanced search mode.');
        testController.filterRec.put('Name', 'test');
        testController.filterRec.put('Frontage_Ft_low__c', 50);
        testController.filterRec.put('Frontage_Ft_high__c', 500);
        testController.goSearch2();
        system.assertEquals(3, testController.searchResults.size());        // note: only thor owned properties are returned
        system.assertEquals(true, testController.searchPerformed);
        
        Test.stopTest();
    }
}