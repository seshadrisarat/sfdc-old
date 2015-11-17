/*
*       M2M2_Controller is used to perform Controller logic for Many to Many 2 VF page.
*       This controller is used for display the custom UI for adding and managing many to many junction data.
* 
*       Author  :   Wilson Ng 
*       Date    :   October 9, 2012
* 
*/
public with sharing virtual class M2M2_Controller {
    
    // static variables for URL parameter inputs
    public static final String PARAM_CONFIGNAME = 'cn';
    public static final String PARAM_FROMID = 'id';
    public static final String PARAM_FROMNAME = 'fn';
    public static final String PARAM_RETURL = 'retURL';

    // static variables for field set names
    public static final String FIELDSET_CREATENEWFIELDS = 'M2M2_Create_New_Fields';
    public static final String FIELDSET_SEARCHRESULTFIELDS = 'M2M2_Search_Result_Fields';
    public static final String FIELDSET_MANAGEFIELDS = 'M2M2_Manage_Fields';
    
    // Properties
    public final sObject rec;
    public String configName{get; set;}
    public String retUrl{get; set;}
    public Id fromId{get; set;}
    public String fromName{get; set;}
    public String fromField{get; private set;}
    public String fromObjectName{get; private set;}
    public String toField{get; private set;}
    public String toObjectLabel{get; private set;}
    public M2M2_Controller controller{get;set;}
    public string objectName{get;private set;}
    public string searchObjectName{get;private set;}
    public string searchObjectPrefix{get;private set;}
    public string tabInFocus{get;set;}
    public transient String actionIds{get;set;}
    public boolean isFatalError{get; private set;}
    public boolean hasOtherFields{get; private set;}
    public boolean isCreateNewMode{get; private set;}
    public boolean useM2M2{get; private set;}
    public string pageName{get;set;}
    // list properties
    public boolean queryPerformed{get;set;}
    public list<SobjectWrapper> manageList{get;set;}
    public list<Schema.FieldSetMember> manageFieldSet{get; private set;}
    
    // search properties
    public String searchTerm{get;set;}
    public List<sObject> searchResults{get;private set;}
    public boolean searchPerformed{get;private set;}
    public list<Schema.FieldSetMember> searchFieldSet{get; private set;}
    
    // create new properties
    public sObject createNewRec { get; set; }
    public list<Schema.FieldSetMember> createFieldSet{get; private set;}
    
    // Properties - label merges
    public string searchPageTitleOverride{get; set;}
    public string searchPageTitle{get { return searchPageTitleOverride!=null?searchPageTitleOverride:String.format(system.Label.M2M2_SearchPageTitle, new string[]{toObjectLabelPlural==null?'':toObjectLabelPlural}); } }
    public String searchInitialMsg{get{ return String.format(system.Label.M2M2_SearchInitialMsg, new string[]{toObjectLabelPlural==null?'':toObjectLabelPlural}); }}
    public String searchTabLabel{get{ return String.format(system.Label.M2M2_SearchTabLabel, new string[]{toObjectLabelPlural==null?'':toObjectLabelPlural}); }}
    public String manageTabLabel{get{ return String.format(system.Label.M2M2_ManageTabLabel, new string[]{toObjectLabelPlural==null?'':toObjectLabelPlural}); }}
    
    // Controller private variables
    protected M2M2_Config__c currConfig;
    protected string toObjectName;
    protected string toObjectLabelPlural;
    protected Integer maxSearchResults;
    protected boolean isTextSearch;
    protected boolean allowDuplicates;
    protected string filterClause;
    protected Schema.sObjectType searchSobj;
    protected Schema.sObjectType createSobj;
    protected Schema.sObjectType manageSobj;
    protected boolean insertJunctionRecordOnCreateNew;
    protected string EDIT_MANAGE_MESSAGE = '<p/>Remember to<a href="javascript: clickMassEdit();">click here</a>and manage the records that were just added.';
    
    // constructor using sobject standardcontroller
    public M2M2_Controller(ApexPages.StandardController stdController) {
        system.debug('in standard controller - '+this);
        // configuration values are passed directly into the properties variables
        this.rec = stdController.getRecord();
        
        initialize();
    }
    // constructor using custom controller
    public M2M2_Controller() {
        system.debug('in custom controller - '+this);
        // configuration values comes in through the url parameters
        map<String, String> params = ApexPages.currentPage().getParameters(); 
        system.debug('url parameter are: '+params);
        configName = params.get(PARAM_CONFIGNAME);
        retUrl = params.get(PARAM_RETURL);
        fromId = (Id)params.get(PARAM_FROMID);
        fromName = params.get(PARAM_FROMNAME);
        pageName = ApexPages.currentPage().getUrl() != null ? string.valueOf(ApexPages.currentPage().getUrl().split('\\?')[0]).replace('/apex/','') : 'none';
        
        initialize();
    }
    protected virtual void initialize(){
        controller = this;
        isFatalError = false;
        isCreateNewMode = false;
        hasOtherFields = false;
        insertJunctionRecordOnCreateNew = true;
        

    }
    
    public M2M2_Config__c getCurrConfig() { return this.currConfig; }
    
    // process input configuration variables
    public virtual PageReference myinitfunc() {
        system.debug('in myinitfunc...configName['+configName+'], fromId['+fromId+'], fromName['+fromName+'], retURL['+retURL+']');
        
        try {
            // retrieve link configuration from custom settings
            if(isEmpty(configName))
                throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Missing Many to Many 2 Configuration Name.'}));
    
            currConfig = M2M2_Config__c.getInstance(configName);
            if(currConfig == null)
                throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Invalid Many to Many 2 Configuration Name ['+configName+']'}));
    
            // store config values into controller variables
            system.debug('current config: ' + currConfig);
            useM2M2 = currConfig.Use_M2M2__c;
            objectName = currConfig.ObjectName__c;
            toField = currConfig.ToField__c;
            fromField = currConfig.FromField__c;
            maxSearchResults = currConfig.SearchResultLimit__c!=null?currConfig.SearchResultLimit__c.intValue():50;
            isTextSearch = currConfig.IsTextSearch__c;
            allowDuplicates = currConfig.AllowDuplicates__c;
            filterClause = currConfig.FilterClause__c;
            
            // search variables
            searchTerm = '';        
            searchResults = new List<sObject>();
            searchPerformed = false;
            tabInFocus = 'theManageTab';
            
            // many to many 2 specific configurations
            if(useM2M2) {
                // describe field sets
                describeManageFieldset(objectName, FIELDSET_MANAGEFIELDS);
                Schema.Sobjectfield fromFld = manageSobj.getDescribe().fields.getMap().get(fromField);
                if(fromFld==null)
                    throw new M2M2_Exception('Invalid From field ['+fromField+']');
                fromObjectName = string.valueof(fromFld.getDescribe().getReferenceTo()[0]);
                Schema.Sobjectfield toFld = manageSobj.getDescribe().fields.getMap().get(toField);
                if(toFld==null)
                    throw new M2M2_Exception('Invalid To field ['+toField+']');
                searchObjectName = string.valueof(toFld.getDescribe().getReferenceTo()[0]);
                describeCreateNewFieldSet(searchObjectName, FIELDSET_CREATENEWFIELDS);
                describeSearchFieldset(searchObjectName, FIELDSET_SEARCHRESULTFIELDS);
                
                Schema.DescribesObjectResult sObjDescribe = searchSobj.getDescribe(); 
                searchObjectPrefix = sObjDescribe.getKeyPrefix();
                toObjectName = sObjDescribe.getName();
                toObjectLabel = sObjDescribe.getLabel();
                toObjectLabelPlural = string.isNotEmpty(currConfig.Tab_Label__c) ? currConfig.Tab_Label__c : sObjDescribe.getLabelPlural();
                
                return goQuery();
            }
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Configuration_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
        }
        return null;
    }
    
    protected void describeManageFieldset(string obj, string fldset) {
        system.debug('in describeManageFieldset('+obj+','+fldset+')');
        // describe and validate generic sobjects, references and field sets
        manageSobj = Schema.getGlobalDescribe().get(obj);
        if(manageSobj==null)
            throw new M2M2_Exception('Invalid object ['+obj+']');
        if(manageSobj.getDescribe().fieldSets.getMap().get(fldset)==null)
            throw new M2M2_Exception('Missing Manage FieldSet ['+fldset+'] for object ['+obj+']');
        // get Field Sets
        manageFieldSet = manageSobj.getDescribe().fieldSets.getMap().get(fldset).getFields();
    }
    
    protected void describeCreateNewFieldset(string obj, string fldset) {
        system.debug('in describeCreateNewFieldset('+obj+','+fldset+')');
        // describe and validate generic sobjects, references and field sets
        createSobj = Schema.getGlobalDescribe().get(obj);
        if(createSobj==null)
            throw new M2M2_Exception('Invalid object ['+obj+']');               
        if(createSobj.getDescribe().fieldSets.getMap().get(fldset)==null)
            throw new M2M2_Exception('Missing Create New FieldSet ['+fldset+'] for object ['+obj+']');
        // get Field Sets
        createFieldSet = createSobj.getDescribe().fieldSets.getMap().get(fldset).getFields();
    }
    
    protected void describeSearchFieldset(string obj, string fldset) {
        system.debug('in describeSearchFieldset('+obj+','+fldset+')');
        // describe and validate generic sobjects, references and field sets
        searchSobj = Schema.getGlobalDescribe().get(obj);
        if(searchSobj==null)
            throw new M2M2_Exception('Invalid object ['+obj+']');   
        if(searchSobj.getDescribe().fieldSets.getMap().get(fldset)==null)
            throw new M2M2_Exception('Missing Search Result FieldSet ['+fldset+'] for object ['+obj+']');
        // get Field Sets
        searchFieldSet = searchSobj.getDescribe().fieldSets.getMap().get(fldset).getFields();
    }
    
    // method provides support for looking up labels
    public list<SobjectLabelWrapper> getManageFieldLabelWrappers() {
        list<SobjectLabelWrapper> retList = new list<SobjectLabelWrapper>();
        if(manageFieldSet != null)
            for (FieldSetMember currMem : manageFieldSet)
                retList.add(new SobjectLabelWrapper(objectName, currMem));
        return retList;
    }
    public list<SobjectLabelWrapper> getCreateNewFieldLabelWrappers() {
        list<SobjectLabelWrapper> retList = new list<SobjectLabelWrapper>();
        if(createFieldSet != null)
            for (FieldSetMember currMem : createFieldSet)
                retList.add(new SobjectLabelWrapper(searchObjectName, currMem));
        return retList;
    }
    
    // performs query to retrieve existing entries
    public PageReference goQuery(){
                
        try {
       
            system.debug('Config ID: ' + currConfig.id);
            string fieldString = '';
            for (FieldSetMember currMem : manageFieldSet){
                string fieldname = currMem.getFieldPath();
                fieldString +=  fieldname + ',';
                if(fieldname!='Id' && fieldname!='Name' && fieldname!=fromField && fieldname!=toField && fieldname.endsWith('__c') && !fieldname.contains('.'))
                    this.hasOtherFields = true;
            }
            fieldString = fieldString.subString(0,fieldString.length()-1);
            
            // query existing records for the primary parent (i.e. fromId)
            Id fromId = this.fromId;
            String soqlQuery = 'SELECT '+fieldString+' FROM '+objectName+' WHERE '+fromField+' = :fromId';     // VF limit is 1000 rows
            
            
            //I'm really not sure if the section is supposed to be here. I think it is. I found it commented out, but it does exactly what I want when enabled
            //unless and invalid query filter is passed in of course.
            /*
            if(currConfig.FilterClause__c != null && currConfig.FilterClause__c.length() > 0)
            {
                soqlQuery += ' and ' + currConfig.FilterClause__c;
            }
            */
            soqlQuery += ' ORDER BY name LIMIT 1000';
            system.debug('SOQL Query:'+soqlQuery);
            this.manageList = new list<SobjectWrapper>();
            
            list<sObject> records = database.query(soqlQuery);     

            for(sObject sobj : records)
            {
                this.manageList.add(new SobjectWrapper(sobj));
            }
            //TODO - sorting
            queryPerformed = true;
            return null;
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }
        
    }
    
    public PageReference siteSurvery()
    {
        PageReference ref = Page.loop__looplus;
        ref.getParameters().put('eid', ApexPages.currentPage().getParameters().get('id'));
        return Page.loop__looplus;
    }
    // action performs search
    public PageReference goSearch(){
        try {
            this.tabInFocus = 'theSearchTab';
            searchPerformed = false;
            
            if (!isEmpty(searchTerm)){
                if (searchTerm.trim().length()<2){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, system.Label.M2M2_SearchTooShort));
                    return null;
                }
                
                Integer maxSize = maxSearchResults + 1;
                string fieldString = '';
                for (FieldSetMember currMem : searchFieldSet){
                    fieldString += currMem.getFieldPath() + ',';    
                }
                fieldString = fieldString.subString(0,fieldString.length()-1);
                
                string extraFilter = this.filterClause;
                if(isTextSearch) {
                    // do text search, i.e. SOSL
                    String escapedSearchTerm = escapeSearchString(searchTerm);
                    extraFilter = (!isEmpty(extraFilter) ? ' WHERE '+extraFilter : '');
                    String soslQuery = 'FIND {'+escapedSearchTerm+'*} RETURNING '+this.toObjectName+' ('+fieldString+extraFilter+' ORDER BY name) LIMIT '+maxSize;  
                    system.debug('SOSL Text Query:'+soslQuery);
                    List<List<SObject>> searchList = search.query(soslQuery);
                    searchResults = searchList[0];
                    if (searchResults.size()==maxSize){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(system.Label.M2M2_TooManyResults, new String[]{maxSearchResults.format()}) ));
                        searchResults.remove(maxSize-1);
                    }
                }
                else {
                    // do name search, i.e. SOQL

                    string subMarketCondition = '';
                    /*
                    if(this.toObjectName == 'Property__c')
                    {
                        subMarketCondition = ' or submarket__r.name like :nameSearchTerm';
                    }
                    else if(this.toObjectName == 'Listing__c')
                    {
                        subMarketCondition = ' or property__r.submarket__r.name like :nameSearchTerm';
                    }                    
                    else if(this.toObjectName == 'Lease__c')
                    {
                        subMarketCondition = ' or Listing__r.property__r.submarket__r.name like :nameSearchTerm';
                    }    
                    */  
                    
                                  
                    String nameSearchTerm = '%'+searchTerm+'%';
                    extraFilter = (!isEmpty(extraFilter) ? ' AND '+extraFilter : '');
                    if(this.toObjectName == 'Property_Lease__c')
                    {
                        extraFilter += ' or (Property__r.Location_Neighborhood__r.name like :nameSearchTerm or Property__r.submarket__r.name like :nameSearchTerm)';
                    }                     
                    // 11-19 - property_lease__c hack
                    String soqlQuery = 'SELECT '+fieldString+' FROM '+this.toObjectName+' WHERE ('+(toObjectName=='Property_Lease__c'?'Lease__r.Name':'Name')+' like :nameSearchTerm' + subMarketCondition+') '+extraFilter+' ORDER BY name LIMIT '+maxSize;
                    system.debug('SOQL Name Query:'+soqlQuery);
                    searchResults = database.query(soqlQuery);
                    if (searchResults.size()==maxSize){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(system.Label.M2M2_TooManyResults, new String[]{maxSearchResults.format()}) ));
                        searchResults.remove(maxSize-1);
                    }
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }
    }
    
    // action renders the create new record section
    public PageReference createNewRecord() {
        this.isCreateNewMode = true;
        // remove all search results
        searchPerformed = false;
        searchResults = new List<sObject>();
        
        this.tabInFocus = 'theSearchTab';
        // Property_Lease__c fix...actually a hack
        this.createNewRec = createObject(toObjectName=='Property_Lease__c'?'Lease__c':toObjectName);
        // another work-around.  if dealproperties, set thor_ownership__c default value to thor owned.  Note: better fix may be parse the m2m2_config.filter_clause
        if(this.currConfig.Name == 'DealProperties')
            this.createNewRec.put('Thor_Ownership__c', 'Thor Owned');
        
        return null;
    }
    public PageReference createNewSave(){
        return createNewSaveInternal(false);
    }
    public PageReference createNewSaveNew(){
        return createNewSaveInternal(true);
    }
    private PageReference createNewSaveInternal(boolean anotherNew){
        system.debug('in create new record save.  anotherNew: ' + anotherNew + ', new rec is: ' + createNewRec);
        
        try {
            insert createNewRec;
            if(insertJunctionRecordOnCreateNew) {           // insert junction record.  Overrid-able from inherited class
                try {
                    Sobject newRec = createObject(objectName);
                    newRec.put(this.fromField, this.fromId);
                    newRec.put(this.toField, createNewRec.Id);
                    insert newRec;
                }
                catch (Exception ex2) {
                    system.debug('junction insert exception: ' + ex2);      // ignore DUPLICATE_VALUE exception
                    if(!ex2.getMessage().contains('DUPLICATE_VALUE'))
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Junction record was not created.' ));
                }
            }
            
            //TODO - label
            string msg = 'New record created.';
            if(hasOtherFields)
                msg += EDIT_MANAGE_MESSAGE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, msg));
            goQuery();
            return (anotherNew ? createNewRecord() : cancelCreateNew());
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }
    }
    public PageReference cancelCreateNew() {
        this.createNewRec = null;
        this.isCreateNewMode = false;
        return null;
    }
    
    // action to add the junction records
    public PageReference addNewRecords(){
        return addNewRecords('theSearchTab');
    }
    public PageReference addNewRecords(string focusTab) {
        system.debug('in add new records, action ids are: ' + actionIds);
        this.tabInFocus = focusTab;
        integer totalCnt = 0, insCnt = 0, dupeCnt = 0;
        try {
            if(!isEmpty(this.actionIds)) {
                list<string> processIds = this.actionIds.split(',');
                // if property lease ids, then we need convert them to lease ids --- another lease hack
                if(this.actionIds.startsWith(Schema.getGlobalDescribe().get('Property_Lease__c').getDescribe().getKeyPrefix()))
                    processIds = retrieveLeaseIds('Property_Lease__c', processIds);             
                list<sObject> insList = new list<sObject>();
                set<string> idList = new set<string>();
                idList.addAll(processIds);       // remove duplicates in processIds
                totalCnt = idList.size();
                goQuery();                                      // get latest data from database
                for(id toId : idList) {
                    if(allowDuplicates || !oneExists(this.manageList, toId)) {      // remove duplicates from database
                        Sobject newRec = createObject(objectName);
                        newRec.put(this.fromField, this.fromId);
                        newRec.put(this.toField, toId);
                        insList.add(newRec);
                        insCnt++;
                    }
                    else {
                        dupeCnt++;
                    }
                }
                if(insList.size() > 0)
                    insert insList;
                
                string msg = (insCnt != totalCnt) ? 
                        String.format('{1} out of {0} records have been added;  {2} records were already added previously.', new string[] { totalCnt.format(), insCnt.format(), dupeCnt.format() }) :
                        String.format('{0} records added.', new string[] { totalCnt.format() });
                if(hasOtherFields && insCnt > 0)
                    msg += EDIT_MANAGE_MESSAGE;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, msg));

            }
            
            return goQuery();       // re-run query to retrieve data into list again (for sorting)
        }
        catch (Exception ex) {
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Cannot add record that references itself')) {
                // do nothing
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] { ex.getMessage() } )));
                this.isFatalError = true;
            }
            return null;
        }
    }
    
    // mass update existing items
    public PageReference massEdit() {
        this.tabInFocus = 'theManageTab';
        for(SobjectWrapper wrp : manageList)
            wrp.isEdit = true;
        return null;
    }
    public boolean getIsMassEdit() {
        for(SobjectWrapper wrp : manageList)
            if(wrp.isEdit==true)
                return true;
        return false;
    }
    public PageReference massEditSaveAll() {
        system.debug('in mass edit save all');

        try {
            list<sobject> updList = new list<sobject>();
            for(sobjectWrapper wrp : manageList)
                if(wrp.isEdit)
                    updList.add(wrp.record);
            if(updList.size() > 0)
                update updList;

            // toggle all isEdit to false
            for(sobjectWrapper wrp : manageList)
                wrp.isEdit = false;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format('{0} records updated.', new String[]{updList.size().format()}) ));
            return null;
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }
    }
   
    public PageReference siteSurvey() {
        return siteSurvey('theSearchTab');
    } 
      
    public PageReference siteSurvey(string focusTab) {
        system.debug('in site survey box checker, action ids are: ' + actionIds);
        this.tabInFocus = focusTab;

        try {
            if(!isEmpty(this.actionIds)) 
            {
                //first, clear the box on all existing site surveys. 
                list<Site_Survey__c> siteSurveys = new list<Site_Survey__c>();
                set<string> activeSiteSurveys = new set<string>(this.actionIds.split(','));
                for(sObjectWrapper obj : manageList)
                {
                    
                    Site_Survey__c thisSurvey = new Site_Survey__c(id=obj.record.id);
                    thisSurvey.Include_in_Site_Survey__c = activeSiteSurveys.contains(obj.record.id) ? true : false;
                    siteSurveys.add(thisSurvey);
                }
                if(siteSurveys.size() > 0)
                {
                    update siteSurveys;
                    //TODO - label
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format('{0} records added to site survey.', new String[]{activeSiteSurveys.size().format()}) ));
                    return goQuery();                                        
                }
            }
            else
            {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select at least one record to generate a site survey from'));
            }            
            return null;
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }
    }

    // mass delete existing items
    public PageReference massDelete() {
        return massDelete('theSearchTab');
    }    
    public PageReference massDelete(string focusTab) {
        system.debug('in mass delete, action ids are: ' + actionIds);
        this.tabInFocus = focusTab;
        try {
            if(!isEmpty(this.actionIds)) {
                list<sObject> delList = new list<sObject>();
                for(id id : this.actionIds.split(',')) {
                    SobjectWrapper oneSobjectItem = findOne(manageList, id);
                    if(oneSobjectItem != null && oneSobjectItem.record != null && oneSobjectItem.record.Id != null)
                        delList.add(oneSobjectItem.record);
                }
                if(delList.size() > 0)
                    delete delList;
                    
                //TODO - label
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format('{0} records deleted.', new String[]{delList.size().format()}) ));
                return goQuery();
            }
            return null;
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }
    }
    
    //
    // one item methods
    public Id oneItem { get; set; }
    public PageReference editOne() {
        SobjectWrapper oneSobjectItem = findOne(manageList, oneItem);
        if(oneSobjectItem != null)
            oneSobjectItem.isEdit = true;
        return null;
    }
    public PageReference saveOne() {
        try {
            SobjectWrapper oneSobjectItem = findOne(manageList, oneItem);
            if(oneSobjectItem != null) {
                update oneSobjectItem.record;
                oneSobjectItem.isEdit = false;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '1 record updated.'));
            return null;
        }
        catch (Exception ex) {
            // throw an exception
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.M2M2_Fatal_Error, new string[] {ex.getMessage()})));
            this.isFatalError = true;
            return null;
        }      
    }
    protected SobjectWrapper findOne(list<SobjectWrapper> mylist, id rowId) {
        for(SobjectWrapper ddcw : mylist)
            if(ddcw.record.Id == rowId)
                return ddcw;
        return null;
    }
    protected SobjectWrapper findOneToId(list<SobjectWrapper> mylist, id toId) {
        for(SobjectWrapper ddcw : mylist)
            if(ddcw.record.get(this.toField) == toId)
                return ddcw;
        return null;
    }
    protected boolean oneExists(list<SobjectWrapper> mylist, id toId) {
        return (findOneToId(mylist, toId)!=null);
    }
        
    //
    // protected reusable methods
    protected boolean isEmpty(string str) {
        return (str==null || str=='');
    }
    protected string escapeSearchString(string searchString){
        return searchString.replaceAll('\\?','\\\\?').replaceAll('&','\\\\&').replaceAll('\\|','\\\\|').replaceAll('!','\\\\!')
            .replaceAll('\\{','\\\\{').replaceAll('\\}','\\\\}').replaceAll('\\[','\\\\[').replaceAll('\\]','\\\\]')
            .replaceAll('\\(','\\\\(').replaceAll('\\)','\\\\)').replaceAll('\\^','\\\\^').replaceAll('~','\\\\~')
            .replaceAll(':','\\\\:').replaceAll('\\\\','\\\\').replaceAll('"','\\\\"').replaceAll('\'','\\\\\'')
            .replaceAll('\\+','\\\\+').replaceAll('-',' ');//.replaceAll('-','\\\\-');
    }
    public string concatenateApexPagesMessages() {
        string msg = '';
        for(ApexPages.Message m : ApexPages.getMessages())
            msg += m.getSummary() + ';';
        return msg;
    }
    
    
    //
    // creates sobject instance
    public static sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
            throw new M2M2_Exception('Unable to describe sobject: '+typeName);
        }
        // Instantiate an sObject with the type passed in as an argument at run time.
        return targetType.newSObject();
    }
    
    //
    // lease functions
    // retrieve a list of lease ids from list of proeprty_lease ids
    private static list<string> retrieveLeaseIds(string objectname, list<string> ids) {
        // retrive lease ids from objectname
        string query = 'select Lease__c from '+objectname+' where id in :ids limit 1000';
        system.debug(objectname+' SOQL query: ' + query);
        list<id> leaseids = new list<id>();
        for(sobject sobj : database.query(query))
            leaseids.add((Id)sobj.get('Lease__c'));
        return leaseids;
    }
    
    
    //
    // wrapper classes
    public class SobjectWrapper {
        public SObject record { get; set; }
        public boolean isEdit { get; set; }
        public SobjectWrapper(SObject sobj) {
            record = sobj;
            isEdit = false;
        }
    }
    
    //
    public class FieldLabelWrapper {
        public string fld { get; private set; }
        public string labl { get; private set; }
        public FieldLabelWrapper(string f, string l) {
            this.fld = f;
            this.labl = l;
        }
    }
    
    //
    public class SobjectLabelWrapper {
        public string fieldObject { get; private set; }
        public FieldSetMember fieldSetMember { get; private set; }
        public string fieldPath { get; private set; }
        public string labelObject { get; private set; }
        public string labelField { get; private set; }
        public boolean canEdit { get; private set; }
        public boolean isSelfLookup { get; private set; }
        public boolean isRequired { get; private set; }

        public SobjectLabelWrapper(string obj, FieldSetMember fsm) {
            this.fieldObject = obj;
            this.fieldSetMember = fsm;
            // compute other field values
            this.fieldPath = fieldSetMember.getFieldPath();
            string[] parts = fieldPath.split('\\.');
            string currObj = fieldObject;
            for(integer i=0; i<parts.size()-1; i++) // loop thru all objects until last one (2nd to last node in fieldPath)
                currObj = string.valueof(Schema.getGlobalDescribe().get(currObj).getDescribe().fields.getMap().get(parts[i].endsWith('__r')?parts[i].replace('__r', '__c'):parts[i]+'Id').getDescribe().getReferenceTo()[0]);
            this.labelObject = currObj;
            this.labelField = (parts.size() > 1 ? parts[parts.size()-1] : parts[0]);
            this.canEdit = (fieldObject == labelObject);
            this.isSelfLookup = fieldPath.startsWith(fieldObject.replace('__c', ''));
            this.isRequired = fieldSetMember.getDBRequired() || fieldSetMember.getRequired();
        }
    }
    
    // exception class
    public class M2M2_Exception extends Exception {}
    
    //
    // Test methods
    @isTest
    static void testThisClass(){
        
        // insert config record: Property_Contact__c
        M2M2_Config__c testConfig = new M2M2_Config__c(Name='PropertyContacts', ObjectName__c='Property_Contact__c', FromField__c='Property__c', ToField__c='Contact__c', 
                                    AllowDuplicates__c=false, FilterClause__c='Account.RecordType.DeveloperName in (\'Management_Company\', \'Property_Owner\', \'Landlord\')', 
                                    IsTextSearch__c=false, SearchResultLimit__c=10, Tab_Label__c='contacts', Use_M2M2__c=true);
        insert testConfig;
        
        // insert property
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='test loc');
        insert loc;
        Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id);
        insert prop;
        
        // insert account and contacts
        Account testAccount = new Account(Name='test landlord', RecordType=new RecordType(Name='Landlord'));        // note: M2M2 filter requires contact parent account recordtype equals management company, property owner or landlord
        insert testAccount;
        list<Contact> testContacts = new list<Contact>();
        testContacts.add(new Contact(LastName='testContact1', AccountId=testAccount.Id, Phone='555-1212', Email='test@test.com'));
        testContacts.add(new Contact(LastName='testContact2', AccountId=testAccount.Id, Phone='555-1212', Email='test@test.com'));
        testContacts.add(new Contact(LastName='testContact3', AccountId=testAccount.Id, Phone='555-1212', Email='test@test.com'));
        testContacts.add(new Contact(LastName='testContact4', AccountId=testAccount.Id, Phone='555-1212', Email='test@test.com'));
        insert testContacts;
        
        Test.startTest();
        
        // set initial page and controller instance
        PageReference testPageReference = Page.M2M2_Page; 
        map<string, string> params = testPageReference.getParameters();
        params.put(M2M2_Controller.PARAM_CONFIGNAME, 'PropertyContacts');
        params.put(M2M2_Controller.PARAM_FROMID, prop.Id);
        params.put(M2M2_Controller.PARAM_FROMNAME, prop.Name);
        params.put(M2M2_Controller.PARAM_RETURL, '/'+prop.Id);
        Test.setCurrentPage(testPageReference);
        M2M2_Controller testController = new M2M2_Controller(new ApexPages.StandardController(prop));       // cover both custom and standard controller
        testController = new M2M2_Controller();
        testController.myinitfunc();
        system.assertEquals(false, ApexPages.hasMessages(), 'Error: VF page/controller initialization has errors - ' + testController.concatenateApexPagesMessages());
        
        // retrieve public variables
        testController.getManageFieldLabelWrappers();
        testController.getCreateNewFieldLabelWrappers();
        
        // perform search
        testController.searchTerm = 'testContact';
        testController.goSearch();
        system.assertEquals(4, testController.searchResults.size());
        system.assertEquals(true, testController.searchPerformed);
        
        // add to manage list
        testController.actionIds = '' + testContacts[0].Id + ',' + testContacts[1].Id;      // add 2 rows
        testController.addNewRecords();
        system.assertEquals(2, testController.manageList.size(), 'Error: Did not add correct number to manage list.');
        system.assert(testController.concatenateApexPagesMessages().containsIgnoreCase('2 records added.'), 'Error: Did not display number of records added.');
        
        // use quick create new
        testController.createNewRecord();
        testController.createNewRec.put('LastName', 'test last name');
        testController.createNewRec.put('FirstName', 'test first name');
        testController.createNewRec.put('Phone', '555-1212');
        testController.createNewRec.put('EMail', 'test@test.com');
        testController.createNewRec.put('AccountId', testAccount.Id);       // Note: contact parent account recordtype must be satisfy because of named filter lookup criteria
        testController.createNewSave();
        list<Contact> testContactList = [select Id from Contact];
        system.assertEquals(5, testContactList.size(), 'Error: Quick create new did not create new parent Contact record.');
        system.assertEquals(3, testController.manageList.size(), 'Error: Quick create new did not create new junction record to manage list.');
        
        // update single row
        testController.oneItem = testController.manageList[0].record.Id;
        testController.editOne();
        system.assertEquals(true, testController.manageList[0].isEdit, 'Error: Edit one row did not place record mode isEdit to true.');
        testController.saveOne();
        system.assert(testController.concatenateApexPagesMessages().containsIgnoreCase('1 record updated.'), 'Error: Did not display number of records updated.');
        
        // mass edit mode
        testController.massEdit();
        system.assertEquals(true, testController.getIsMassEdit(), 'Error: Mass Edit did not place all records mode isEdit to true.'); 
        testController.massEditSaveAll();
        system.assert(testController.concatenateApexPagesMessages().containsIgnoreCase('3 records updated.'), 'Error: Did not display number of records updated.');
        
        // mass delete rows
        testController.actionIds = '' + testController.manageList[0].record.Id + ',' + testController.manageList[1].record.Id;      // delete 2 rows...1 row should remain
        testController.massDelete();
        system.assert(testController.concatenateApexPagesMessages().containsIgnoreCase('2 records deleted.'), 'Error: Did not display number of records deleted.');
        system.assertEquals(1, testController.manageList.size(), 'Error: Did not delete correct number from manage list.');
        
        // perform a bad search
        testController.searchTerm = 'xxxx';
        testController.goSearch();
        system.assertEquals(0, testController.searchResults.size());
        system.assertEquals(true, testController.searchPerformed);

        // perform too short search
        testController.searchTerm = 'a';
        testController.goSearch();
        system.assertEquals(0, testController.searchResults.size());
        system.assertEquals(false, testController.searchPerformed);
        system.assert(testController.concatenateApexPagesMessages().containsIgnoreCase(system.Label.M2M2_SearchTooShort), 'Error: Did not display search too short message.');

        // perform text search
        testController.isTextSearch = true;
        testController.searchTerm = 'testContact';
        testController.goSearch();
        //system.assertEquals(5, testController.searchResults.size());
        //system.assertEquals(true, testController.searchPerformed);
        
        
        Test.stopTest();
    }
}