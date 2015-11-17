/*
  created: Serg Brull & Vladidmir Prishlyak
*/
public virtual with sharing class CompanyListSearch_Controller {
 
    public List<Account> searchAccounts {get; set;}
    public Boolean hasSearched {get; set;}
    public Integer searchAccountsCount {get; set;}
    public Integer tickTableRows {get; set;}
    public String Query {get; set;}

    public boolean isTest = false;
    
    
    public String SearchParam {get; set;}
    public String SearchQ {get; set;}
    public String SearchObj {get; set;}
    public String SearchSection {get; set;}
    
    /*Main*/
    public List<JSONObject> m_target_object_fields_list_project;
    public List<JSONObject> m_target_object_fields_list_company;
    public List<JSONObject> m_target_object_fields_list_calllog;

    public FilterSOQLCompiler m_filters = new FilterSOQLCompiler();
    protected SL_ME_DescribeObject_Core m_describe_object_core = null;
    
    protected List<CompanyExtend> m_companies {get; set;}
    public Company_List_Member__c addCLObj { get; set; }
    
    public Blob csvContentFile { get; set; }
    public String csvNameFile { get; set; }
    
    public CompanyListSearch_Controller() {
        m_describe_object_core = SL_ME_DescribeObject_Core.getInstance();
        m_target_object_fields_list_project = new List<JSONObject>();
        m_target_object_fields_list_company = new List<JSONObject>();
        m_target_object_fields_list_calllog = new List<JSONObject>();
        
        addCLObj = new Company_List_Member__c();
        tickTableRows = 20;
        Query = '';
        hasSearched = false;
        SearchSection='F';
    }

    public String CompanyListID {
        get { return System.currentPageReference().getParameters().get('clid');}
    }
    
    

    Company_List__c m_company_list = null;
    public Company_List__c CompanyList {
        get {
            if(!isNullOrEmpty(CompanyListID)) {
                if(m_company_list == null || CompanyListID != m_company_list.Id)
                m_company_list = [select Id, Name from Company_List__c where id=:CompanyListID limit 1];
            }
            return m_company_list;
        }
    }


    /* Sorting */
    protected String m_sort_direction = 'ASC'; 
    protected String m_sort_expresion = 'Name';
    public String sortExpression {
        get { 
            return m_sort_expresion;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == m_sort_expresion) {
                m_sort_direction = (m_sort_direction == 'ASC')? 'DESC' : 'ASC';
            } else { 
                m_sort_direction = 'ASC';
            }
            m_sort_expresion = value;
        }
    }
    
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (m_sort_expresion == null || m_sort_expresion == '') return 'ASC';
        else return m_sort_direction;
    }

    public void setSortDirection(String value)
    {  
        m_sort_expresion = value;
    }
    
    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController m_std_controller {get; set;}
     
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<CompanyExtend> getAccounts() {
        m_companies = new List<CompanyExtend>();
        if(m_std_controller!=null) {
            for (Account company : (List<Account>)m_std_controller.getRecords())
                    m_companies.add(new CompanyExtend(company));
        }
        return m_companies;
    }
     
    // displays the selected items
    public PageReference process() {
        for (CompanyExtend company : m_companies) {
            if (company.checked)
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, company.Item.name));
        }
        return null;
    }
    
    /*Pager*/ 
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            if(m_std_controller==null) return false;
            return m_std_controller.getHasNext();
        }
    }
     
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            if(m_std_controller==null) return false;
                return m_std_controller.getHasPrevious();
            }
        }
     
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            if(m_std_controller==null) return null;
            return m_std_controller.getPageNumber();
        }
    }
        
    public Integer pageSize {
        get {
            if(m_std_controller==null) return 0;
            Integer prefix =  (Math.mod((Long)m_std_controller.getResultSize(),(Long)m_std_controller.getPageSize()) != 0)? 1 : 0;
            return  (m_std_controller.getResultSize() / m_std_controller.getPageSize())+prefix;
        }
    }
     
    // returns the first page of records
    public void first() {
        if(m_std_controller!=null) m_std_controller.first();
        }
     
    // returns the last page of records
    public void last() {
        if(m_std_controller!=null) m_std_controller.last();
    }
     
    // returns the previous page of records
    public void previous() {
        if(m_std_controller!=null) m_std_controller.previous();
    }
     
    // returns the next page of records
    public void next() {
        if(m_std_controller!=null) m_std_controller.next();
    }
     
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
            if(m_std_controller!=null) m_std_controller.cancel();
    }   
    
    // add to this Company List
    public PageReference doAdd() {
            
            if(m_companies.size()>0)
            {
                //Select c.Name, c.Deal_Name__c, c.Counterparty_Name__c From Counterparty_Log__c c
                List<Company_List_Member__c> list2Insert = new List<Company_List_Member__c>();
                Company_List_Member__c tmpCLObj = null;
                
                for(CompanyExtend awObj:m_companies)
                {
                    if(awObj.checked)
                    {
                        tmpCLObj = new Company_List_Member__c();
                        //tmpCLObj.Name = CompanyList.Name+' - '+awObj.Item.Name;
                        tmpCLObj.Company__c = awObj.Item.ID;
                        tmpCLObj.Company_List__c = CompanyList.ID;
                        list2Insert.add(tmpCLObj);
                    }
                }
                if(list2Insert.size()>0) insert list2Insert;
            }
            
            PageReference pageRef = new PageReference('/' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;         
            
            
            //System.debug('--------------- '+accounts);
            //return null;
    }
    
    public PageReference doAddContinue() {
        csvContentFile = null;
        doAdd();
        doSearch();
        return null;    
    }
    
    
    public PageReference clSearch()
    {
        hasSearched = true;
        m_companies = new List<CompanyExtend>();
        m_std_controller = null;
        
        listToUpdateAccountIds = new Set<Id>();
        csvContentFile = null;
        return null;
    }
    
    private Set<Id> listToUpdateAccountIds = new Set<Id>();
    
    public PageReference doSearch() {
            // Search block for Selected Deal in the bottom Lookup
            // Search from Company List
            m_companies = new List<CompanyExtend>();
            m_std_controller = null;
            
            
            System.debug('!!!!!!!!!!!!!!!!SearchSection: '+SearchSection);
            System.debug('!!!!!!!!!!!!!!!!addCLObj: '+addCLObj);
            
            
            if(addCLObj!=null && addCLObj.Company_List__c!=null && SearchSection == 'CL')
            {
                hasSearched = true;
                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
                String SQLTxt = 'Select Type, Name, Industry, BillingCity, BillingState, BillingCountry From Account '
                + 'where id in (Select c.Company__c From Company_List_Member__c c where c.Company_List__c=\''+addCLObj.Company_List__c+'\') '
                + 'AND Id NOT IN (select Company__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\') '
                + 'Order BY '+sortFullExp+' limit 9000';
                try
                {
                    m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(SQLTxt));
                }
                catch(Exception e) {
                    m_std_controller = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect existing Deal!'));
                }
            }
            // Search with Filter
            else if(SearchQ!=null && SearchParam!=null && SearchSection == 'F')
            {
                hasSearched = true;
                m_filters.Initialize(SearchQ, SearchParam, TargetObject);
                String MFilters_SOQL_VALUE = m_filters.SOQL;
                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
                String addWhere = '';
                
                //trace = '{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}';
                //trace = m_filters.trace;
                system.debug('-----------------------------------{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}');
                if(MFilters_SOQL_VALUE!=null && MFilters_SOQL_VALUE!='') addWhere = ' '+MFilters_SOQL_VALUE;
                
                //****** START Search BLOCK-1: When user choosed Deal Object 
                //****** END Search BLOCK-1: When user choosed Deal Object

                if (addWhere==''){
                    addWhere = ' WHERE Id NOT IN (select Company__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\')';
                }
                else
                {
                    addWhere = ' WHERE (Id NOT IN (select Company__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\'))'
                             + ' AND ' 
                             + '('+addWhere+')';
                }

                String SQLTxt = 'Select Type, Name, Industry, BillingCity, BillingState, BillingCountry From Account '
                +addWhere+' Order BY '+sortFullExp+' limit 9000';
                
                system.debug('-----------------------------------SQLTxt: ' + SQLTxt);

                try
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query:: ' + SQLTxt));
                    m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(SQLTxt));
                }
                catch(Exception e) {
                    m_std_controller = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: invalid search filter values or invalid Advanced filter.'));
                }
                
                // sets the number of records in each page set
                if(m_std_controller!=null)
                {
                    m_std_controller.setPageSize(tickTableRows);
                    m_std_controller.first();
                }
            }
            
            return null;
        }   
    
        public PageReference doCancel()
        {
            PageReference pageRef = new PageReference('/' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;
        }
    
        public PageReference doReset()
        {
            PageReference pageRef = new PageReference('/apex/CompanyListSearch?clid=' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;
        }   
    
    // Sergey CODE
    String m_trace = 'trace:: ';
    public String trace {
        get {
            return m_trace; 
        }
        set {
            m_trace += value + ' | \n' ;
        }
    }
    
    public String target {
        get{
            return System.currentPageReference().getParameters().get('target');     
        }
    }
    
    public String event {
        get{
            return System.currentPageReference().getParameters().get('event');      
        }
    }

    public String filterSet {
        get{
            return System.currentPageReference().getParameters().get('filters');        
        }
    }

    public String filterAdvenced {
        get{
            return System.currentPageReference().getParameters().get('advenced');       
        }
    }
    
    public String picklistName {
        get{
            return System.currentPageReference().getParameters().get('picklist');       
        }
    }
    
    public String JSONResponse {
        get;
        set; 
    } 
    
    public String TargetObject {
        get {
            String result = 'Account';
            if(target == '1') {
                result = 'Project__c';
            } else if(target == '2') {
                result = 'Account';
            } else if(target == '3') {
                result = 'Call_Log__c';
            }
            return result;  
        }
    } 
    
    public Pagereference EventHandler() {
        if(event == 'load') {
            eventActionLoad();
        } else if(event == 'search') {
            eventActionSearch();
        }
        return null;    
    } 

    protected void eventActionLoad() {
        if( m_target_object_fields_list_project.isEmpty() || m_target_object_fields_list_company.isEmpty() || m_target_object_fields_list_calllog.isEmpty()) {
                getFieldsByObject();
        } 
        if(isNullOrEmpty(picklistName) == false) {
            JSONResponse = getPicklistJson();       
        } else 
        if(target == '1') {
            JSONResponse = getJsonFromFieldsList(m_target_object_fields_list_project);  
        } else if(target == '2') {
            JSONResponse = getJsonFromFieldsList(m_target_object_fields_list_company);
        } else if(target == '3') {
            JSONResponse = getJsonFromFieldsList(m_target_object_fields_list_calllog);
        }   
    }
    
    protected String getJsonFromFieldsList(List<JSONObject> p_fields_list) {
        String result = '';
        for(Integer i = 0; i < p_fields_list.size(); i++) {
            result += p_fields_list[i].Json;
            if(i != p_fields_list.size()-1) {
                result += ', ';
            }
        }
        return '{"fields" : [' + result + ']}';
    }
    
    protected void eventActionSearch() {
        //m_filters.Initialize(SearchQ, SearchParam);
        //m_filters.Initialize('STRING|name|equal|Blabla##PHONE|phone|equal|(05)22222', '1 AND 2');
        //m_filters.Initialize(filterSet, filterAdvenced);
        //JSONResponse = '{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + m_filters.SOQL + ')"}';
        //JSONResponse =  ' trace: ' + m_filters.trace;
    }
    
    protected List<JSONObject> sortingFields(List<JSONObject> p_list) {
        /*List<JSONObject> result = new List<JSONObject>();
        List<String> key_list = new List<String>();
        
        for(JSONObject current_object : p_list) { 
            key_list.add(current_object.Value); 
        }
        key_list.sort();
        
        
        for(String key : key_list) {
                result.add(getItemByNameFromList(p_list, key));
        }   
        return result;*/
        List<JSONObject> res = new List<JSONObject>();
        while (p_list.size()>0){
            JSONObject mo = p_list.get(0);
            p_list.remove(0);
            integer i = 0;
            while (i<p_list.size()){
                if (p_list.get(i).Value < mo.Value){
                    p_list.add(mo);
                    mo = p_list.get(i);
                    p_list.remove(i);
                } else i++;
            }
            res.add(mo);
        }
        return res; 
    }
    
    protected JSONObject getItemByNameFromList(List<JSONObject> p_list, String p_item_name) {
        JSONObject result = null;
        for(JSONObject current_object : p_list) { 
            if(current_object.Value == p_item_name) {
                result = current_object;
                break;
            }
        }
        return result;
    }

    public List<LookUpPickListValue> getLCPickListValue()
    {
        List<LookUpPickListValue> returnList = new List<LookUpPickListValue>();
        integer ccounter = 0;
        try { 
            if (picklistName=='recordtypeid'){
                String so = '';
                if(target == '1') {
                    so = 'Project__c';
                } else if(target == '2') {
                    so = 'Account';
                } else if(target == '3') {
                    so = 'Call_Log__c';
                }
                List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
                for (RecordType rt : rtLst){
                    //if (rt.Name.indexOf('Investment ')>=0) continue;
                    returnList.add(new LookUpPickListValue(''+ccounter,String.escapeSingleQuotes(rt.Name)));
                    ccounter++;
                }
            } else {
                System.debug('Target::::::::::::'+TargetObject.toLowerCase());
                Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
                System.debug('picklistName::::::::::::'+picklistName);
                System.debug('describe_result.get(picklistName)::::::::::::'+describe_result.get(picklistName));
                List<Schema.PicklistEntry> picklist_list = describe_result.get(picklistName).getPicklistValues();
                for( Schema.PicklistEntry picklist_value : picklist_list ) {
                    returnList.add(new LookUpPickListValue(''+ccounter,picklist_value.getValue()));
                    ccounter++;
                }
            }
        }catch(Exception e) {
            return null;
        }
        
        return returnList;
    }
    
    protected String getPicklistJson() {
        JSONObject item = new JSONObject();
        try { 
            if (picklistName=='recordtypeid'){
                String so = '';
                if(target == '1') {
                    so = 'Project__c';
                } else if(target == '2') {
                    so = 'Account';
                } else if(target == '3') {
                    so = 'Call_Log__c';
                }
                List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
                for (RecordType rt : rtLst){
                    //if (rt.Name.indexOf('Investment ')>=0) continue;
                    item.picklistValues.add(String.escapeSingleQuotes(rt.Name));
                }
            } else {
                Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
                List<Schema.PicklistEntry> picklist_list = describe_result.get(picklistName).getPicklistValues();
                for( Schema.PicklistEntry picklist_value : picklist_list ) {
                    item.picklistValues.add(picklist_value.getValue());
                }
            }
        }catch(Exception e) {
            return '{"error" : "' + e.getMessage() + '"}';
        }
        return '{' + item.jProperty(picklistName, item.picklistValues) + '}';
    }
    
    protected void getFieldsByObject() {
        Set<String> forbidFields_Account = new Set<String>{};
        Set<String> forbidFields_Project = new Set<String>{};
        Set<String> forbidFields_CallLog = new Set<String>{};
        Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
        Map<String,JSONObject> m_target_object_fields_list_project_PreMAP = new Map<String,JSONObject>();
        Map<String,JSONObject> m_target_object_fields_list_company_PreMAP = new Map<String,JSONObject>();
        Map<String,JSONObject> m_target_object_fields_list_calllog_PreMAP = new Map<String,JSONObject>();
        
        for (String field_name : describe_result.keySet()) {
            String field_type = describe_result.get(field_name).getType().name();
            
            if(field_type == 'TEXTAREA') {
                continue;
            }

            
            JSONObject item = new JSONObject(
                    field_name, 
                    describe_result.get(field_name).getLabel(), 
                    field_type
            );
            
            if (item.FieldType == 'REFERENCE') {
                if (field_name=='recordtypeid'){
                    item.FieldType = 'PICKLIST';
                } else {
                    List<Schema.sObjectType> refereced_to_list = describe_result.get(field_name).getReferenceTo();
                    if(!refereced_to_list.isEmpty()) {
                        item.Prefix = refereced_to_list.get(0).getDescribe().getKeyPrefix();
                    }
                }
            } 

            
            if(TargetObject == 'Project__c' && !forbidFields_Project.contains(field_name)) {
                trace = 'to Project list: ' + field_name;
                //m_target_object_fields_list_project.add(item);
                m_target_object_fields_list_project_PreMAP.put(describe_result.get(field_name).getLabel(),item);    
            } else if(TargetObject == 'Account' && !forbidFields_Account.contains(field_name)) {
                //m_target_object_fields_list_company.add(item);
                m_target_object_fields_list_company_PreMAP.put(field_name,item);
            } else if(TargetObject == 'Call_Log__c' && !forbidFields_CallLog.contains(field_name)) {
                //m_target_object_fields_list_calllog.add(item);
                m_target_object_fields_list_calllog_PreMAP.put(describe_result.get(field_name).getLabel(),item);
            }               
        }
        
        if(m_target_object_fields_list_project_PreMAP.size()>0) m_target_object_fields_list_project = m_target_object_fields_list_project_PreMAP.values();
        if(m_target_object_fields_list_company_PreMAP.size()>0) m_target_object_fields_list_company = m_target_object_fields_list_company_PreMAP.values();
        if(m_target_object_fields_list_calllog_PreMAP.size()>0) m_target_object_fields_list_calllog = m_target_object_fields_list_calllog_PreMAP.values();
        
        system.debug('=========================================== countFields: ' + m_target_object_fields_list_company.size());
        
        m_target_object_fields_list_project = sortingFields(m_target_object_fields_list_project);
        m_target_object_fields_list_company = sortingFields(m_target_object_fields_list_company);
        m_target_object_fields_list_calllog = sortingFields(m_target_object_fields_list_calllog);
    }
    
    
    
    protected Boolean isNullOrEmpty(String p_str) {
        return (p_str == null || p_str == ''); 
    }
    
    
    
     /* 
    Credit to 
    http://wiki.developerforce.com/index.php/Code_Samples#Parse_a_CSV_with_APEX
    */
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
        List<String> lines = new List<String>();
    
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
         
        if(contents.length() > 3000000)  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'parse error. file size is too big. '));
        else
        {   
            if(contents.contains(',"""')) contents = contents.replaceAll(',"""',',"DBLQT');
            if(contents.contains('""",')) contents = contents.replaceAll('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
            if(contents.contains('""')) contents = contents.replaceAll('""','DBLQT');
            try {
                lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            } catch (System.ListException e) {
                System.debug('Limits exceeded?' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        
        
        Integer num = 0;
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }

    public class LookUpPickListValue
    {
        public String  ID   {get;set;}
        public String  Value {get;set;}
        
        public LookUpPickListValue(String inID, String inValue) {
            ID = inID;
            Value = inValue;
        }
    }
    
    public class csvRowValue
    {
        public String  PitchBookId   {get;set;}
        public String  AccountId {get;set;}
        public String  AccountName {get;set;}
        public csvRowValue(String p_PitchBookId, String p_AccountId, String p_AccountName) 
        {
            PitchBookId = p_PitchBookId;
            AccountId = p_AccountId;
            AccountName = p_AccountName;
        }
    }

    /* JSONObject class */
    public class JSONObject {
        public String  Name                 {get;set;}
        public String  Value                {get;set;}
        public String  FieldType            {get;set;} 
        public List<String> picklistValues  {get;set;}
        public String Prefix                {get;set;}
        
        public String Json {
            get{
                String result = '';
                result += jProperty('name', Value) + ', ';
                result += jProperty('value', Name) + ', ' ;
                result += jProperty('type', FieldType) ;
                if(Prefix != null && Prefix != '') {
                    result += ', ' + jProperty('prefix', Prefix) ;  
                }
                /*(if (FieldType == 'PICKLIST') {
                    result += ', ';
                    result += jProperty('picklistValues', picklistValues);
                }*/
                return '{' +  result + '}';             
            }
        }
         
        public JSONObject() {
            picklistValues = new List<String>();
        }
        
        public JSONObject(String p_name, String p_value, String p_type) {
            picklistValues = new List<String>();
            Name = p_name; Value = p_value; FieldType = p_type;
        }
        
        public JSONObject(String p_name, String p_value, String p_type, List<String> p_picklist_values) {
            Name = p_name; Value = p_value; FieldType = p_type;
            picklistValues = p_picklist_values;
        }
    
        public String jQ(String p_str) {
            return '"' + p_str + '"';
        }
        
        public String jProperty(String p_name, String p_value) {
            return jQ(p_name) + ' : ' + jQ(p_value);
        }

        public String jProperty(String p_name, List<String> p_value) {
            String result = '';
            for(Integer i = 0; i < p_value.size(); i++) {
                result += '{' + jProperty('value', p_value[i]) + '}';
                if(i != p_value.size()-1) {
                    result += ', ';
                }
            }
            return jQ(p_name) + ' : ' + '['+ result +']';
        }
    }
    
    public with sharing class CompanyExtend {
        public Boolean Checked{ get; set; }
        public Account Item { get; set;}
 
        public CompanyExtend() {
            Item = new Account();
            Checked = false;
        }
 
        public CompanyExtend(Account p_company) {
            Item = p_company;
            Checked = false;
        }
    }
    
    /*
    public static testmethod void doTest(){
        
        ID Account_RecordTypeId = [Select Id From RecordType where SobjectType='Account' and DeveloperName='Investment_Firm'].ID;
        ID Contact_RecordTypeId = [Select Id From RecordType where SobjectType='Contact' and DeveloperName='Contact'].ID;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Account_RecordTypeId;
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.RecordTypeId = Account_RecordTypeId;
        insert acc2;

        Account acc3 = new Account();
        acc3.Name = 'Test3';
        acc3.RecordTypeId = Account_RecordTypeId;
        insert acc3;

        Contact cont1 = new Contact();
        cont1.RecordTypeId = Contact_RecordTypeId;
        cont1.AccountID = acc.ID;
        cont1.LastName = 'Petrov';
        insert cont1;
        
        Contact cont2 = new Contact();
        cont2.RecordTypeId = Contact_RecordTypeId;
        cont2.AccountID = acc2.ID;
        cont2.LastName = 'Ivanov';
        insert cont2;


        Date sDate = date.newinstance(2009, 2, 10);
        Date eDate = date.newinstance(2010, 10, 10);
        Opportunity opp = new Opportunity(Name='Test Opportunity Object', AccountId=acc.ID, CloseDate=eDate, StageName='Preliminary');
        insert opp;
        
        Company_List__c cll1 = new Company_List__c();
        cll1.Name = 'Company_List-1';
        insert cll1;

        Company_List__c cll2 = new Company_List__c();
        cll2.Name = 'Company_List-2';
        insert cll2;
        
        Company_List_Member__c cl1 = new Company_List_Member__c();
        cl1.Company_List__c = cll1.ID;
        cl1.Company__c = acc.ID;
        cl1.Contact__c = cont1.ID;
        insert cl1;

        Company_List_Member__c cl2 = new Company_List_Member__c();
        cl2.Company_List__c = cll1.ID;
        cl2.Company__c = acc2.ID;
        cl2.Contact__c = cont2.ID;
        insert cl2;
        
        Company_List_Member__c cl4 = new Company_List_Member__c();
        cl4.Company_List__c = cll2.ID;
        cl4.Company__c = acc.ID;
        cl4.Contact__c = cont1.ID;
        insert cl4;
        
        Company_List_Member__c cl3 = new Company_List_Member__c();
        cl3.Company_List__c = cll2.ID;
        cl3.Company__c = acc2.ID;
        cl3.Contact__c = cont2.ID;
        insert cl3; 
    
        
        //ApexPages.StandardController sc = new ApexPages.StandardController(deal1);
        CompanyListSearch_Controller cls;
        Test.startTest();
        System.currentPageReference().getParameters().put('clid',cll1.ID);
        cls = new CompanyListSearch_Controller();
        
        String tmpStr = cls.sortExpression;
        cls.sortExpression = 'ID';
        cls.sortExpression = 'ID';
        cls.sortExpression = '';
        tmpStr = cls.getSortDirection();
        cls.sortExpression = 'Name';
        cls.setSortDirection('DESC');
        
        tmpStr = cls.getSortDirection();
        
        PageReference pageref;
        
        List<CompanyExtend> AWList = cls.getAccounts();
        Integer iPageNumb = cls.pageNumber;
        iPageNumb = cls.pageSize;
        Boolean Flag = cls.hasNext;
        Flag = cls.hasPrevious;
        
        cls.SearchQ = 'ID='+cll1.ID;
        cls.SearchParam = '1';
        cls.SearchObj = '1';
        cls.tickTableRows = 1;
        pageref = cls.doSearch();
        
        cls.addCLObj.Company_List__c = cll1.ID;
        cls.isTest = true;
        pageref = cls.doSearch();
        AWList = cls.getAccounts();
        pageref = cls.process();
        Flag = cls.hasNext;
        Flag = cls.hasPrevious;
        iPageNumb = cls.pageNumber;
        iPageNumb = cls.pageSize;
        cls.last();
        cls.first();
        cls.next();
        cls.previous();
        cls.cancel();
        
        pageref = cls.doAdd();
        pageref = cls.doCancel();
        pageref = cls.doReset();
        cls.trace = 'test!!!';
        tmpStr = cls.trace;
        tmpStr = cls.target;
        tmpStr = cls.event;
        tmpStr = cls.filterSet;
        tmpStr = cls.filterAdvenced;
        tmpStr = cls.picklistName;
        tmpStr = cls.TargetObject;
        pageref = cls.EventHandler();
        tmpStr = cls.getPicklistJson();

        JSONObject JSObj = new JSONObject();
        JSObj = new JSONObject('ID','1273461802747','ID');
        tmpStr = JSObj.Json;

        Test.stopTest();
    }
    */
    
}