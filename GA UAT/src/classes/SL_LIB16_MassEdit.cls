/*
    Author: Prishlyak Vladimir
    Main task: https://silverline.jira.com/browse/LIB-62
    Description:  Company List Management
*/
public abstract class SL_LIB16_MassEdit
{
    public Boolean isDebug {get; set;}
    public SObject parentObject {get; set;}
    public String parentObjectName {get; set;}
    public List<MemberContainer> membersList {get; set;}
    public Map<Id, SObject> membersListBackup {get; set;}
    public String sortExpression {get; set;}
    public String sortDirection {get; set;}
    public Integer pageSize {get; set;}
    public Integer pageNumber {get; set;}
    public Integer pageCount {get; set;}
    public String tplRecordTypeName {get; set;}
    public SL_Mass_Implementation__c currMainCusSettings;
    public List<SelectOption> pageSizeValues {get; set;}
    public boolean inEditColumns {get; set;}
    public List<String> fieldNames {get; set;}
    public List<String> fieldNamesNotColumns {get; set;}
    public List<String> fieldNamesNotNulls {get; set;}
    public List<ColumnInfo> columns {get; set;}
	public map<String,String> mapFldName2FldSort;

    public String selectedColumnsCallback {get; set;}
    public String targetObjectName, targetObjectParentFieldName;
    public Set<String> shownColumnNames {get; set;}
    public boolean isViewState {get; set;}
    public boolean isPageErr {get; set;}
    public String JSONResponse {get; set;}
    public Boolean hasQueryErrors {get; set;}
    public String cb_columns {get; set;}
    public String cb_filters {get; set;}
    public String cb_advFilters {get; set;}
    public List<QuickFilter> cb_quickFilters {get; set;}
    public SL_LIB16_ME_MassEdit_FilterSOQLCompiler  filterCompiler {get; set;}
    public Set<String> fieldsAsPicklists {get; set;}
    public Set<String> fieldsFilterIgnored {get; set;}
    
    //private transient Schema.Describesobjectresult sobjectDescribe {get; set;}
    private transient Map<String, Schema.DescribeFieldResult> fieldDescribes {get; set;}
    private transient Map<String, Schema.SObjectField> sobjectFields {get; set;}
    private transient Map<String, Map<String, Schema.SObjectField>> sobjectFieldsAll {get; set;}
    private transient Map<String, Schema.DescribeSObjectResult> sobjectDescribesAll {get; set;}
    public boolean isNewView {get; set;}

    //Added by sandeep
    public String strColumnsAndFiltersTemplate
    {
        get 
        {
            if((strColumnsAndFiltersTemplate==null || strColumnsAndFiltersTemplate=='') && strView!=null && strView!='' && isNewView!=true) return strView;
            return strColumnsAndFiltersTemplate;    
        }
        set;
    }
    public List<SelectOption> lstColumnsAndFiltersTemplate {get; set;}//Added by sandeep
    public Boolean isShowCancelButton {get;set;}//Added by sandeep
    public Boolean isShowCreateLinkCancelButton {get;set;}//Added by sandeep
    public Boolean isShowDeleteButton  {get;set;}//Added by sandeep
    public Boolean isShowSaveButton {get;set;}//Added by sandeep
    public String strView {get;set;}//Added by sandeep
    public Boolean isDisabled {get;set;}//Added by sandeep
    private List<ColumnInfo> lstColumnInfo; //Added by sandeep
    public Boolean isShowTemplateNameErrorMessage  {get;set;}//Added by sandeep

	/************ MAIN param - you have to change it if you need to switch to other SF objects ************/
	protected String MainObjName = null;
	protected ID MainObjNameID = null;
	public Boolean hasNoError {get; set;}
	
    public SL_LIB16_MassEdit()
    {
        isPageErr = false;
        isDebug = isShowTemplateNameErrorMessage = false;
        inEditColumns = isShowCreateLinkCancelButton = false;
        lstColumnInfo  = new List<ColumnInfo>();

        pageNumber = 0;
        sortExpression = 'Name';
        sortDirection = 'ASC';
        hasQueryErrors = false;
        inEditColumns = false;
        strView = '';
        isShowCancelButton = isShowDeleteButton = isShowSaveButton = isDisabled = true;
        filterCompiler = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler ();
        membersList = new List<MemberContainer>();
        fieldNamesNotColumns = new List<String>();
        fieldNamesNotNulls = new List<String>();
        fieldsAsPicklists = new Set<String>();
        fieldsFilterIgnored = new Set<String>();
        cb_quickFilters = new List<QuickFilter>();


        
 		String clId = ApexPages.currentPage().getParameters().get('clId');
        String implId = null;
        if(System.currentPageReference().getParameters().get('implId')!=null && System.currentPageReference().getParameters().get('implId')!='')
    	{
    		implId = System.currentPageReference().getParameters().get('implId');
    	}
    	else if(System.currentPageReference().getParameters().get('extId')!=null && System.currentPageReference().getParameters().get('extId')!='')
    	{
    		try
    		{
    			Decimal inExtID = Decimal.valueOf(System.currentPageReference().getParameters().get('extId'));
    			for(SL_Mass_Implementation__c item:[select ID from SL_Mass_Implementation__c where ExtID__c=:inExtID limit 1])
    			{
    				implId = ''+item.ID;
    			}
    		}
    		catch(Exception ex){}
    	}
        //ApexPages.currentPage().getParameters().get('implId');
        
        if(implId!=null && implId!='')
        {
	        hasNoError = true;
			try
			{
				SL_Mass_Implementation__c item = [Select
							targetObjectSearchFieldName__c,
							targetObjectParentFieldName__c,
							targetObjectName__c,
							searchObjectName__c,
							parentObjectName__c,
							Show_Views_on_MassEdit_Page__c,
							Show_Views_on_MassAdd_Page__c,
							Search_Page_Title__c,
							Search_Object_Title__c,
							Row_Qty_Values__c,
							Name,
							ID,
							Get_Element_from_List_Tab__c
						From SL_Mass_Implementation__c
						where Id = :implId limit 1];
						
				this.MainObjName = item.name;
				this.MainObjNameID = item.ID;
				this.currMainCusSettings = item;
				
				system.debug('currMainCusSettings >>>>>>>>>>>>>>>>>>>'+currMainCusSettings);
				
			}
			catch(Exception e)
			{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect clID or problem with custom settings!'));
	        	hasNoError = false;
			}
			
	        strColumnsAndFiltersTemplate = '';
    	    lstColumnsAndFiltersTemplate = new List<SelectOption>(); 
        	pageSize = 50;
        	pageSizeValues = SL_LIB16_MassEdit.getRowQtySelectOptList(this.currMainCusSettings);
			try{ if(pageSizeValues.size()>0){ pageSize = Integer.valueOf(pageSizeValues.get(0).getValue());} }
			catch(Exception ex){}
			       
	        
	        if(mapFldName2FldSort==null)
	        {
				mapFldName2FldSort = new map<String, String>();
				for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target'])
	        	{
					mapFldName2FldSort.put(item.Field__c, item.Sort_Field__c);
		        }
	        }
        }
        
    }

    public Boolean isManageTargets {get{
        if (isManageTargets==null){
        	if(ApexPages.currentPage().getParameters().get('mt')=='1'){
                isManageTargets = true;
            } else {isManageTargets = false;}
        }
        return isManageTargets;
    } set;}
    
    
    public String implType {
        get{
    	   if(isManageTargets){
    	       return 'ManageTargets';
    	   }
    	   return 'Target';
        }
        set;
    }    
    
    /** just fill describe info about target object */
    public void fillDescribe(){
        fillDescribe(targetObjectName);
        sobjectFields = sobjectFieldsAll.get(targetObjectName);
    }
    
    private Schema.DescribeSObjectResult fillDescribe(String objName){
        if (sobjectFieldsAll==null) sobjectFieldsAll = new Map<String, Map<String, Schema.SObjectField>>();
        if (sobjectDescribesAll==null) sobjectDescribesAll = new Map<String, Schema.DescribeSObjectResult>();
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Filling Describe : ' + objName));
        sobjectDescribesAll.put(objName, Schema.getGlobalDescribe().get(objName).getDescribe());
        sobjectFieldsAll.put(objName, sobjectDescribesAll.get(objName).fields.getMap());
        return sobjectDescribesAll.get(objName);
        //return null;
    }
    
    /** returns true only if field is in target object and is editable */
    private boolean isEditable(String field){
        if (sobjectFields==null) fillDescribe();
        if (field==null || field.trim().length()==0) return false;
        if (field.indexOf('.')>=0) return false;
        Schema.Sobjectfield f = sobjectFields.get(field);
        if (f==null) return false;
        Schema.DescribeFieldResult fr = f.getDescribe();
        if (fr==null || !fr.isUpdateable()) return false;
        return true;
    }
    
    /** returns true only if field is in target object and is createable */
    /*private boolean isCreateable(String field){
        if (sobjectFields==null) fillDescribe();
        if (field==null || field.trim().length()==0) return false;
        if (field.indexOf('.')>=0) return false;
        Schema.Sobjectfield f = sobjectFields.get(field);
        if (f==null) return false;
        Schema.DescribeFieldResult fr = f.getDescribe();
        if (fr==null || !fr.isCreateable()) return false;
        return true;
    }*/
    
    /** simply return soap type of field */
    private Schema.Soaptype getSoapType(String field){
        if (field==null || field.trim().length()==0) return null;
        if (sobjectFields==null) fillDescribe();
        Schema.Sobjectfield f = sobjectFields.get(field);
        Schema.DescribeFieldResult fr = f.getDescribe();
        return fr.getSoapType();
    }
    
    private Schema.DescribeFieldResult getFieldDescribe(String field){
        if (fieldDescribes==null) fieldDescribes = new Map<String, Schema.DescribeFieldResult>();
        if (!fieldDescribes.containsKey(field)) fieldDescribes.put(field, getFieldDescribe(targetObjectName, field, ''));
        return fieldDescribes.get(field);
    }
    
    private Schema.DescribeFieldResult getFieldDescribe(String objName, String fieldName, String fullPath){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, objName + ' -> ' + fieldName));
        Schema.DescribeSObjectResult objDescr;
        try { objDescr = sobjectDescribesAll.get(objName);}
        catch (exception e) {objDescr = null;}
        if (objDescr==null) objDescr = fillDescribe(objName);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, objName + ' fields : '+sobjectFieldsAll.get(objName)));
        if (fieldName.indexOf('.')==-1)
        {
        	if(sobjectFieldsAll!=null && fieldName!=null && sobjectFieldsAll.containsKey(objName) && sobjectFieldsAll.get(objName).containsKey(fieldName)) return sobjectFieldsAll.get(objName).get(fieldName).getDescribe();
        	else return null;
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'rel : '+objName + ' -> ' + fieldName));
        //system.debug('----------------------> ' +objName + ' -> ' + fieldName);
        String relName = fieldName.substring(0, fieldName.indexOf('.'));
        String relParentField = '';
        if(relName.length()>3 && relName.substring(relName.length()-3).toLowerCase()=='__r')
        {
        	relParentField = relName.substring(0,relName.length()-1)+'c';
        }
        else{ relParentField = relName + 'Id';}
        
        
        for (Schema.SObjectField f : objDescr.fields.getMap().values()){
            String path = (fullPath.length()==0) ? ''+f : fullPath + '.' + f;
            
            if (fieldDescribes.containsKey(path))
            {
                if (fieldDescribes.get(path)!=null && fieldDescribes.get(path).getRelationshipName()!=null && fieldDescribes.get(path).getRelationshipName().toLowerCase().trim()==relName.toLowerCase().trim()) {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, path + '  ==> ' + fieldDescribes.get(path).getRelationshipName() + ' ?= ' + relName + ' == ' + (fieldDescribes.get(path).getRelationshipName().toLowerCase().trim()==relName.toLowerCase().trim())));
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'found : '+fieldDescribes.get(path).getName()));
                    objName = '' + fieldDescribes.get(path).getReferenceTo().get(0);
                    break;
                }
            }
            else if(relParentField.toLowerCase()==(''+f).toLowerCase() && (''+f.getDescribe().getType())=='REFERENCE')
            {
            	//system.debug('-----------------------fieldDescribes>>>'+ f.getDescribe().getType());
            	objName = '' + f.getDescribe().getReferenceTo().get(0);
                break;
            }
        }       
        
        fieldName = fieldName.substring(fieldName.indexOf('.')+1);
        system.debug(objName + '( ' + relName + ', '+fullPath+') ----------------------> ' + fieldName);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, objName + '( ' + relName + ' ) -> ' + fieldName));
        return getFieldDescribe(objName, fieldName, (fullPath.length()==0) ? relName : fullPath + '.' + relName);
    }
    
    /** 
     * return parent object name 
     * Can be used in page header 
     * Can be overridden */
    public virtual String getParentName(){
        return ''+parentObject.get('Name');
    }
    
    
    /** Should be overridden and return new Target object WITH PARENT FIELD SET */
    public abstract SObject getNewTargetObject();
    
    /* Not necessary
    private static Id tryCastId(Object o){
        if (o==null) return null;
        return (Id)(''+o);
    }
    
    private static Date tryCastDate(Object o){
        if (o==null) return null;
        return (Date)o;
    }
    
    private static String tryCastString(Object o){
        if (o==null) return null;
        return (''+o);
    }
    */
    
    /** Selects all target objects and creates back-up data structure */
    public void refetchMembers()
    {
        hasQueryErrors = false;
        if (sobjectFields==null) fillDescribe();
        String query = getCompiledQuery();
        //system.debug('getCompiledQuery()---------------------/'+query);
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Query: ' + query));
        List<SObject> fobjects;
        try{
            fobjects = Database.query(query);
            //inEditColumns = true;
        }
        catch (Exception e){
            hasQueryErrors = true;
            inEditColumns = true;
            //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.ERROR, 'Error: invalid search filter values format or filter lookup value not found or invalid Advanced filter.'));
            return;
        }
        membersList = new List<MemberContainer>();
        for (SObject so : fobjects)
            membersList.add(new MemberContainer(so));
        pageCount = (membersList.size()-1)/pageSize;
        pageNumber = 0;
        membersListBackup = new Map<Id, SObject>();
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Limit: ' + Limits.getScriptStatements()));
        List<String> editableFields = new List<String>();
        for (String field : fieldNames){
            if (isEditable(field)){
                editableFields.add(field);
            }
        }
        for (MemberContainer member : membersList){
            SObject obj = member.obj;
            SObject obj2 = getNewTargetObject();
            for (String field : editableFields){
                Object fdata = obj.get(field); 
                if (fdata!=null){
                    Schema.SoapType ft = getSoapType(field);
                    if (ft==Schema.SoapType.DATE) obj2.put(field, (Date)fdata);
                    else if (ft==Schema.SoapType.ID) obj2.put(field, (Id)fdata); 
                    else if (ft==Schema.SoapType.STRING) obj2.put(field, ''+fdata);
                    else obj2.put(field, fdata);
                }
            }
            membersListBackup.put(obj.Id, obj2);
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'shownColumnNames: ' + shownColumnNames));
    } 
    
    public String getCompiledQuery()
    {
        if (fieldNames==null){
            Set<String> fn = new Set<String>();
            for (ColumnInfo col : columns){
                fn.add(col.name);
                fn.add(col.sortExpression);
            }
            fieldNames = new List<String>(fn);
        }

        List<String> lstTempString = new List<String>();
        for(String objString:fieldNames)
        {
            if(objString != '' && objString != null)
            {
                lstTempString.add(objString);
            }
        }
        fieldNames =  new List<String>();
        fieldNames.addAll(lstTempString);

        String res = 'SELECT ';
        Set<String> setFieldsForSelect = new Set<String>();
        setFieldsForSelect.add('id');
        for (String field : fieldNamesNotColumns)
        {
            //if(res != null && res != ''){ res += ', ' + field;}
            setFieldsForSelect.add(field.toLowerCase());
        }
        for (String field : fieldNames){
            //if (!new Set<String>(fieldNamesNotColumns).contains(field)){ res += ', ' + field;}
            setFieldsForSelect.add(field.toLowerCase());
        }
        for (String field : setFieldsForSelect){
            res += field + ',';
        }
        res = res.substring(0, res.length()-1);
        
        res += ' FROM ' + targetObjectName;
        res += ' WHERE ' + targetObjectParentFieldName + '=\'' + parentObject.Id + '\' ';
        for (String field : fieldNamesNotNulls){
            res += ' AND ' + field + '!=null ';
        }

        cb_filters = ''; /// initialise filter string and assign it with refetched string
        cb_advFilters = ''; /// initialise advanced filter string and assign it with refetched string
        
        if(currMainCusSettings!=null)
        {
	        /// recreate cb_filters and cb_advFilters based on the filter template whose name template name is strColumnsAndFiltersTemplate
	        for(SL_View_Filter__c objFiltersTemplate:getViewFilters())
	        {
	            if(cb_filters == '' || cb_filters == null)
	            {
	                cb_filters = objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
	            }
	            else
	            {
	                cb_filters = cb_filters+'##' + objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
	            }
	            
	            cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
	        }
	
	        if (cb_advFilters!=null && cb_advFilters.trim().length()!=0){
	            filterCompiler.Initialize(cb_filters, cb_advFilters, targetObjectName);
	            filterCompiler.targetObject = this.targetObjectName;
	            filterCompiler.recordId = this.parentObject.Id;
	            String soql = filterCompiler.SOQL;
	            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'soql: ' + soql));
	            if (soql!=null && soql.trim().length()!=0){
	                res += ' AND (' + soql + ')';
	            }
	            //res += ' AND ('+compileFilterExpression(cb_advFilter, filters_List)+')';
	        } else {
	            filterCompiler = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler ();
	        }
	        for (QuickFilter f : cb_quickFilters) {
	            res += ' AND (' + f.soql + ') ';
	        }
        }
        res += ' ORDER BY ' +  ((sortExpression!=null && mapFldName2FldSort.containsKey(sortExpression))?mapFldName2FldSort.get(sortExpression):sortExpression) + ' ' + sortDirection + ' ';
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query: ' + res+' - targets: '+mapFldName2FldSort.size()));
        system.debug('---------------------------- query: ' + res);
        //res += ' LIMIT 980';
        res = res.replace(' null,','');

        return res;
    }
    
    public virtual List<SL_View_Filter__c> getViewFilters(){
    	return [Select Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c from SL_View_Filter__c where SL_View__r.Name=:strColumnsAndFiltersTemplate and SL_View__r.Implementation__c=:currMainCusSettings.ID and SL_View__r.Implementation_Type__c='Target'];
    }
    
    /*
    returns "true" if value1 is BEFORE in resulting list than value2
    TODO:
    1. Compare Objects, not Strings
    */
    public boolean compareField(String value1, String value2){
        //system.debug('---------------------------- compare: ' + value1 + ' ' + value2);
        if (sortDirection=='ASC') return (value1<value2);
        return (value1>value2);
    }
    
    /*
    TODO:
    1. no recursion
    2. path as array
    */
    public String getField(SObject so, String path){
        if (so==null) return '';
        integer p = path.indexOf('.');
        if (p==-1) return ''+so.get(path);
        return getField(so.getSObject(path.substring(0, p) ), path.substring(p+1));
    }
    
    /*
    TODO:
    1. Extract comparable value only once -- done
    2. sorting in n*log n -- done
    */
    public void changeSorting(){
        if (sortDirection=='ASC') sortDirection = 'DESC';
        else sortDirection = 'ASC';
        mems = new List<Pair>();
        for (integer i=0; i<membersList.size(); i++){
            Pair p = new Pair();
            p.member = membersList[i];
            p.value = getField(p.member.obj, ((sortExpression!=null && mapFldName2FldSort.containsKey(sortExpression))?mapFldName2FldSort.get(sortExpression):sortExpression));
            mems.add(p);
        }
        //system.debug('================================ mems: ' + mems);
        sortMems(0, mems.size()-1);
        for (integer i=0; i<mems.size(); i++){
            membersList[i] = mems[i].member;
        }
        //refetchMembers();
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Limit: ' + Limits.getScriptStatements()));
    }
    
    private class Pair{
        public MemberContainer member {get; set;}
        public String value {get; set;}
    }
    
    private List<Pair> mems {get; set;}
    public void sortMems(integer l, integer r){
        integer i = l;
        integer j = r;
        if (mems.size()<= (i+j)/2+1) return;
        String p = mems[(i+j)/2+1].value;
        do {
            while (compareField(mems[i].value, p)) i++;
            while (compareField(p, mems[j].value)) j--;
            if (i<=j) {
                Pair pr = mems[i];
                mems[i] = mems[j];
                mems[j] = pr;
                i++;
                j--;
            }
        } while (i<=j);
        if (j>l) sortMems(l, j);
        if (i<r) sortMems(i, r);
    }
    
    //public String pageNumberString {get; set;}
    
    public void voidAction()
    {
        pageCount = (membersList.size()-1)/pageSize;
        if (pageNumber >= pageCount) pageNumber = (integer)pageCount;
        if (pageNumber < 0) pageNumber = 0;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'pageNumber: ' + pageNumber));
        isShowDeleteButton = isShowSaveButton = true;
        
    }
    
    // method to fetch filter detail and selected column from the template custom setting
    public void fetchTemplateColumnAndFilterConditions()
    {
        /*List<SelectOption>  last0 = getSelectColumnsOrdered();
        List<SelectOption> lst1 = getUnselectedColumns();
        system.debug('======last0=======>>>>'+last0);
        system.debug('=====lst1========>>>>'+lst1);*/
        cb_filters = ''; 
        cb_advFilters = '';///initialise the filters to blank string
        strView = strColumnsAndFiltersTemplate;

        ///modify the filters and advanced filters string
        //system.debug('=======strColumnsAndFiltersTemplate===========???>>>>'+strColumnsAndFiltersTemplate);
        if(currMainCusSettings!=null)
        {
	        for(SL_View_Filter__c objFiltersTemplate:[Select Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c from SL_View_Filter__c where SL_View__r.Name=:strColumnsAndFiltersTemplate and SL_View__r.Implementation__c=:currMainCusSettings.ID and SL_View__r.Implementation_Type__c='Target'])
	        {
	            if(cb_filters == '' || cb_filters == null)
	            {
	                cb_filters = objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
	            }
	            else
	            {
	                cb_filters = cb_filters+'##' + objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
	            }
	            
	            cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
	        }
        }
    }   
    
    public void doSavePageSize()
    {
        if (pageSize>0 && pageSize<=100)
        {
            
            SL_View__c template = null;
            if(strColumnsAndFiltersTemplate!=null && strColumnsAndFiltersTemplate!='' && currMainCusSettings!=null)
            {
                for(SL_View__c item:[Select RowsCount__c, ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType and ((Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true)) or Implementation_Type__c='ManageTargets') limit 1])
                {
                    template = item;
                }
            }
            if(template==null && currMainCusSettings!=null)
            {
                for(SL_View__c item:[Select RowsCount__c, ID, Name From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType and ((User__c=:UserInfo.getUserId() or IsDefault__c=true) or Implementation_Type__c='ManageTargets') Order by Name limit 1])
                {
                    template = item;
                }
            }
            
            if(template!=null)
            {
                template.RowsCount__c = pageSize;
                update template;
            }
            voidAction();
        }
    }
    
    public String getLimits(){
        String res = '';
        res += 'SOQL: ' + Limits.getDmlStatements();
        return res;
    }
    
    public void stopEdit(){
        //PageReference res = new PageReference('/'+parentObject.Id);
        //res.setRedirect(true);
        //return res;
        isViewState = true;
        //refetchMembers();
    }
    
    public virtual PageReference startEdit(){
        isViewState = false;
        return null;
    }
    
    public void save(){
        doSave();
        return ;
    }
    
    public PageReference saveClose(){
        if (doSave()){
            return close();
        }
        return null;
    }
    
    public virtual PageReference close(){
        PageReference res = new PageReference('/'+parentObject.Id);
        res.setRedirect(true);
        return res;
    } 
    
    public boolean doSave(){
        List<String> editableFields = new List<String>();
        for (String field : fieldNames){
            if (isEditable(field)){
                editableFields.add(field);
            }
        }
        List<SObject> updMembers = new List<SObject>();
        for (MemberContainer member : membersList){
            SObject obj = member.obj;
            boolean added = false;
            if (obj.Id==null) {
                added = true;
            } else{
                for (String field : editableFields){
                    if (obj.get(field)!=membersListBackup.get(obj.Id).get(field))
                        added = true;
                }
            }
            if (added) updMembers.add(obj);
        }
        return castAndSave(updMembers);
    }
    
    /// method to perform operation on click of go button
    public void btnGo()
    { 
        isNewView = false;
        isShowCreateLinkCancelButton = false;
        Map<String,String> mapFieldLabel_FieldName = new Map<String,String>();
        String strColumns ='';
        String res='';
        map<String,Integer> mapNameToShowOrder =  new map<String,Integer>();
        List<String> lstStringNew = new List<String>();
        List<ColumnInfo> lstColumnInfo = new List<ColumnInfo>();
        Set<String> setColumnInfoName = new Set<String>();
        List<String> lstString = new List<String>();
        map<String,Mass_Edit_Settings__c> mapFieldName_object =  new map<String,Mass_Edit_Settings__c>();

		if(currMainCusSettings!=null)
		{
			for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c, Sort_Field__c, IsSortable__c, isEditable__c, Field_Style__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' ORDER BY Label__c])
	        {
	            mapFieldLabel_FieldName.put(item.Label__c,item.Field__c);
	            mapFieldName_object.put(item.Field__c.toLowerCase(),item);
	        }
	        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	        {
	            if(template.Columns__c != null && template.Columns__c !='')
	            {
	                strColumns = template.Columns__c.replace('*',' ');
	                lstString.addAll(strColumns.split(','));
	
	                for(String objString:lstString)
	                {
	                        if(res == ''){ res = mapFieldLabel_FieldName.get(objString);}
	                        else{ res += ';' + mapFieldLabel_FieldName.get(objString);}
	                }
	            }

				SL_LIB16_UserChoise__c choiceObject = null;
				
				for(SL_LIB16_UserChoise__c itemUC :[SELECT Id, View__c, User__c FROM SL_LIB16_UserChoise__c WHERE View__c!=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Target' AND 
		        												(Mass_Implementation__c = :currMainCusSettings.Id) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
		       	{
		       		choiceObject = itemUC;
		       		choiceObject.View__c = template.id;
		       	}
				
				if(choiceObject == null)
				{
					choiceObject = new SL_LIB16_UserChoise__c(
						Filter_Tab__c = null,
						Type__c = 'Last',
						Mass_Implementation__c = currMainCusSettings.ID,
						Implementation_Type__c = 'Target',
						View__c = template.id,
						User__c = UserInfo.getUserId()
					);
				}
				upsert choiceObject;
	        
	            cb_filters = '';
	            cb_advFilters = '';
	            
	            for(SL_View_Filter__c objFiltersTemplate:[Select Value__c, Type__c, SL_View__c, Operator__c, Id, Field__c From SL_View_Filter__c where SL_View__c =:template.ID])
	            {
	                if(cb_filters != '') cb_filters += '##';
	                cb_filters = objFiltersTemplate.Type__c + '___' + objFiltersTemplate.Field__c + '___' + objFiltersTemplate.Operator__c + '___' + (objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c) + '___' ;
	                cb_advFilters = template.Advanced_Filter__c;
	            }
	        
	            /// split cb_columns and store in a list of string
	            if(res!=null && res!=''){ lstStringNew.addAll(res.split(';')); }
	
	            if(columns!=null && columns.size()>0){ lstColumnInfo.addAll(columns);}
	            
	            
	            /// create a map of column name to order
	            /*
	            for(String str:lstStringNew)
	            {
	                mapNameToShowOrder.put(str,i);
	                i++;
	            }
	            */
	        
	            columns = new List<ColumnInfo>();
	            
	            /// create ColumnInfo
	            Integer i = 0;
	            for(String str:lstStringNew)
	            {
	                if(str!=null && str!='' && mapFieldName_object!=null && mapFieldName_object.containsKey(str.toLowerCase()))
	                {
	                    ColumnInfo objColumnInfo = new ColumnInfo(str,mapFieldName_object.get(str.toLowerCase()).Sort_Field__c,
	                                                                 mapFieldName_object.get(str.toLowerCase()).Label__c,true,true,
	                                                                 mapFieldName_object.get(str.toLowerCase()).IsSortable__c, 
	                                                                 mapFieldName_object.get(str.toLowerCase()).isEditable__c,
	                                                                 mapFieldName_object.get(str.toLowerCase()).Field_Style__c);
	                    objColumnInfo.showOrder = i;
	                    i++;
	                    columns.add(objColumnInfo);
	                    setColumnInfoName.add(str);
	                }
	            }
	            
	            /// add ColumnInfo values present in columns list
	            for(ColumnInfo objColumnInfo:lstColumnInfo)
	            {
	                if(!setColumnInfoName.contains(objColumnInfo.name)){ columns.add(objColumnInfo);}
	            }
	        
	            //saveColumns(getColumnsFromCustomSetting());
	            // NOT NEED!!!!!!!!!!!!!!!!
	            //saveColumns(res);
	            refetchMembers();
	        }
		}
        isViewState = (ApexPages.currentPage().getParameters().get('justView')!=null) ? true : false;
        loadColumnOrder();
    }

    // fetching custom settign value for a selected template
    /* Not necessary more
    private string getColumnsFromCustomSetting()
    {
        Map<String,String> mapFieldLabel_FieldName = new Map<String,String>();
        String strColumns ='';
        String strCustomSettingColumns ='';
        map<String,Integer> mapNameToShowOrder =  new map<String,Integer>();
        List<String> lstStringNew = new List<String>();
        Set<String> setColumnInfoName = new Set<String>();
        List<String> lstString = new List<String>();
        map<String,String> mapFieldName_FieldLabel =  new map<String,String>();
        
        for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c FROM Mass_Edit_Settings__c where RecordType.DeveloperName=:this.tplRecordTypeName ORDER BY Label__c])
        {
            mapFieldLabel_FieldName.put(item.Label__c,item.Field__c);
            mapFieldName_FieldLabel.put(item.Field__c,item.Label__c);
        }
        
        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where RecordType.DeveloperName = :this.tplRecordTypeName and Name =:strColumnsAndFiltersTemplate limit 1])
        {
            if(template.Columns__c != null && template.Columns__c !='')
            {
                strColumns = template.Columns__c.replace('*',' ');

                lstString.addAll(strColumns.split(','));
                for(String objString:lstString)
                {
                    if(strCustomSettingColumns == ''){ strCustomSettingColumns = mapFieldLabel_FieldName.get(objString);}
                    else{ strCustomSettingColumns += ';' + mapFieldLabel_FieldName.get(objString);}
                }
            }
            Set<String> setStringNew = new Set<String>();
            lstStringNew.addAll(strCustomSettingColumns.split(';')); /// split cb_columns and store in a list of string
            setStringNew.addAll(strCustomSettingColumns.split(';'));
            if(lstColumnInfo.IsEmpty()){ lstColumnInfo.addAll(columns);}
                
            Integer i = 0;
            
            /// create a map of column name to order
            for(String str:lstStringNew)
            {
                mapNameToShowOrder.put(str,i);
                i++;
            }
            columns = new List<ColumnInfo>();
            for(ColumnInfo objColumnInfo : lstColumnInfo)
            {
                if(setStringNew.contains(objColumnInfo.name))
                {
                    objColumnInfo.show = true;
                    objColumnInfo.showOrder = mapNameToShowOrder.get(objColumnInfo.name);
                    columns.add(objColumnInfo);
                }   
                else
                {
                    objColumnInfo.show = false;
                    columns.add(objColumnInfo);
                }
            }
            //system.debug('====columns====get string method=======>>>'+columns);
        }
        
        return strCustomSettingColumns;
        return null;
    }
    */
    
    public void deleteTemplateByname()
    {
        SL_View__c item2Delete = null;
        if(currMainCusSettings!=null)
        {
	        for(SL_View__c item:[Select ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	        {
	            item2Delete = item;
	        }
	        if(item2Delete!=null)
	        {
	        	SL_LIB16_UserChoise__c choiceObjectItem = null;

				for(SL_LIB16_UserChoise__c itemUC :[SELECT Id FROM SL_LIB16_UserChoise__c WHERE View__c=:item2Delete.ID AND (Type__c = 'Last') 
						AND Implementation_Type__c = 'Target' AND (Mass_Implementation__c = :currMainCusSettings.ID) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
				{
					choiceObjectItem = itemUC;
		    	}
	        	if(choiceObjectItem!=null) delete choiceObjectItem;
	        	
	        	try
        		{
	        		delete item2Delete;
        		}
        		catch(Exception ex)
		        {
		        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
		        	return;
		        }
	        }
        }

        lstColumnsAndFiltersTemplate = new List<SelectOption>();
        Boolean isPageLoad = true;
        String activColumnNames = '';
		if(currMainCusSettings!=null)
		{
	        for(SL_View__c objColumnsAndFiltersTemplate:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and (User__c=:UserInfo.getUserId() or IsDefault__c=true) ORDER BY Name])
	        {
	            lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
	            if(isPageLoad)
	            {
	                strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
	                if(objColumnsAndFiltersTemplate.Columns__c!=null) activColumnNames += objColumnsAndFiltersTemplate.Columns__c;
	                isPageLoad = false;
	            }
	        }
		}
        Set<String> setSelectedColumn = new Set<String>();
        if(activColumnNames!='')
        {
            for(String item : activColumnNames.split(',')){ setSelectedColumn.add(item.toLowerCase());}
        }
        
        columns = new List<ColumnInfo>();
        if(currMainCusSettings!=null)
		{
	        for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c, Field_Style__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' ORDER BY Label__c])
	        {
	            columns.add(new ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, 
	            							setSelectedColumn.contains(item.Label__c.toLowerCase()),true, item.IsSortable__c, 
	            							item.isEditable__c, item.Field_Style__c));
	        }
		}
        refetchMembers();
        btnGo();
    }
    

    /// method to perform operation on click of create new view link
    public void lnkCreateNewView()
    {
        cb_filters = ''; /// initialise filter string and assign it with refetched string
        cb_advFilters = ''; /// initialise advanced filter string and assign it with refetched string

        strView = strColumnsAndFiltersTemplate;
        isShowCancelButton = false;
        isShowCreateLinkCancelButton = true;
        isNewView = true;
        strColumnsAndFiltersTemplate = '';
        Map<ColumnInfo,String> mapColumnInfoToName = new Map<ColumnInfo,String>();
        Map<ColumnInfo,String> mapColumnInfoToLabel = new Map<ColumnInfo,String>();
        
        for(ColumnInfo objColumnInfo:columns)
        {
            //system.debug('--------objColumnInfo-------'+objColumnInfo);
            mapColumnInfoToName.put(objColumnInfo,objColumnInfo.name);
            mapColumnInfoToLabel.put(objColumnInfo,objColumnInfo.label);
        }
        
        List<ColumnInfo> lstColumnInfo = new List<ColumnInfo>();
        
        for(ColumnInfo objColumnInfo:columns)
        {
            objColumnInfo.show = false;
            objColumnInfo.name = mapColumnInfoToName.get(objColumnInfo);
            objColumnInfo.label = mapColumnInfoToLabel.get(objColumnInfo);
            objColumnInfo.sortExpression = mapColumnInfoToName.get(objColumnInfo);

            lstColumnInfo.add(objColumnInfo);
        }
        columns = new List<ColumnInfo>();
        columns.addAll(lstColumnInfo);
        
        /*
        for(ColumnInfo objColumnInfo:columns)
        {
            system.debug('--------objColumnInfo-------'+objColumnInfo);
        }
        */
        
        isShowDeleteButton = isShowSaveButton = false;
        pageCount = (membersList.size()-1)/pageSize;
        if (pageNumber >= pageCount) pageNumber = pageCount;
        if (pageNumber < 0) pageNumber = 0;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'pageNumber: ' + pageNumber));
    }

    /// method to perform operation on click of delete button
    public void btnDelete()
    {
        SL_View__c item2Delete = null;
        if(currMainCusSettings!=null)
        {
	        for(SL_View__c item:[Select ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	        {
	            item2Delete = item;
	        }
		}
        if(item2Delete!=null){ database.delete(item2Delete,false);}
    }
    
    // Called on click of Cancel button
    public void btnCancel()
    {
        try
        {
            hasQueryErrors = false;
            inEditColumns = false;
            refetchMembers();
        }
        catch(Exception ex){ }
    }

    public abstract boolean castAndSave(List<SObject> lst);
    
    public virtual class MemberContainer{
        public Boolean isSelected {get; set;} 
        public SObject obj {get; set;}
        public Integer index {get; set;}
        public MemberContainer(){}
        
        public MemberContainer(SObject obj){
            this.obj = obj;
            this.isSelected = false;
        }
        
        public MemberContainer(SObject obj, Boolean sel){
            this.obj = obj;
            this.isSelected = sel;
        }
    }

    
    public List<ColumnInfo> getColumnsShown(){
        List<ColumnInfo> res = new List<ColumnInfo>();
        Map<String,ColumnInfo> mapColumnsShown = new Map<String,ColumnInfo>();
        List<String> setLabel = new List<string>();
        for (ColumnInfo info : columns)
        {
            if (info.show){ mapColumnsShown.put(info.label,info);}
        }
        if(currMainCusSettings!=null)
        {
	        for(SL_View__c template:[Select Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType and ((Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true)) or Implementation_Type__c='ManageTargets') limit 1])
	        {
	            if(template.Columns__c != null && template.Columns__c !='')
	            {
	                setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
	            }
	        }
		}
        for (String item : setLabel)
        {
            if (item!=null && item!='' && mapColumnsShown.containsKey(item)) 
            {
                res.add(mapColumnsShown.get(item));
            }
        }
        
        
        return res;
    }
    
    
    
    public List<SelectOption> getUnselectedColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        set<String> setLabel = new set<string>();
        
        if(currMainCusSettings!=null)
        {
	        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	        {
	            if(template.Columns__c != null && template.Columns__c !='')
	            {
	                setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
	            }
	        }
        }
        
        Set<String> setAlreadyAdd = new Set<String>();
        for (ColumnInfo info : columns)
        {
            if (!setLabel.contains(info.label) && info.name!= null && info.label !=null && info.name!='' && !setAlreadyAdd.contains(info.name.toLowerCase())) 
            {
                res.add(new SelectOption(info.name, info.label));
                setAlreadyAdd.add(info.name.toLowerCase());
            }
        }
        if(res == Null){ res.add(new SelectOption('', ''));}
        return res;
    }
    
    public List<SelectOption> getSelectColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        for (ColumnInfo info : columns){
            if (info.show) res.add(new SelectOption(info.name, info.label));
        }
        return res;
    }
    
    public List<SelectOption> getSelectColumnsOrdered()
    {
        List<SelectOption> res = new List<SelectOption>();
        List<String> setLabel = new List<string>();
        map<String,String> mapMassEditLabel2Name = new map<String,String>();
        if(currMainCusSettings!=null)
        {
	        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	        {
	            if(template.Columns__c != null && template.Columns__c !='')
	            {
	                setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
	            }
	        }
        }
        
        for (ColumnInfo item : columns){ mapMassEditLabel2Name.put(item.label, item.name);}
        Set<String> setAlredyAdd = new Set<String>();
        for (String item : setLabel)
        {
            if(item!=null && item!='' && mapMassEditLabel2Name.containsKey(item) && mapMassEditLabel2Name.get(item)!=null 
                    && mapMassEditLabel2Name.get(item)!='' && !setAlredyAdd.contains(mapMassEditLabel2Name.get(item).toLowerCase()))
            {
                res.add(new SelectOption(mapMassEditLabel2Name.get(item), item)); //if (info.show)
                setAlredyAdd.add(mapMassEditLabel2Name.get(item).toLowerCase());
            }
        }
        
        return res;
    }


    public void saveIntialColumns(String scolumns)
    {
        shownColumnNames = new Set<String>();
        //Change made by Bijal for Stephens-132.
        set<String> setTempList = new set<String>();
        List<String> colsLst = new List<String>();
        List<String> colsLstTemp = scolumns.split(';');
        for(String temp : colsLstTemp)
        {
            if(!setTempList.contains(temp))
            {
                colsLst.add(temp);
                setTempList.add(temp);
            }
        }
         
        Set<String> cols = new Set<String>(colsLst);        
        for (ColumnInfo info : columns){
            if (cols.contains(info.name)) {
                info.show = true;
                shownColumnNames.add(info.name);
                for (integer i=0; i<colsLst.size(); i++){
                    if (info.name == colsLst[i]) info.showOrder = i;
                }
            }
            else info.show = false;
        }
        //saveColumnOrder();
    }
    
    public void saveColumns(String scolumns)
    {
		List<String> setSelectedFieldAPI = new List<String>();
        String strTempFields = '';
        
        isShowCancelButton = true;
        isShowCreateLinkCancelButton = false;
        if(scolumns != null && scolumns!=''){ setSelectedFieldAPI.addAll(scolumns.split(';'));}
        
		Map<String,String> mapColNameLabel = new Map<String,String>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columns){ mapColNameLabel.put(info.name, info.label);}
        
        for(String item:setSelectedFieldAPI)
        {
        	if (mapColNameLabel.containsKey(item)) strTempFields += ',' + mapColNameLabel.get(item);
        }
        if(strTempFields!='') strTempFields = strTempFields.substring(1);
        
        /*       
        for (ColumnInfo info : Columns)
        {
            if (setSelectedFieldAPI.contains(info.name)) 
            {
                if(strTempFields == ''){ strTempFields = info.label;}  
                else{ strTempFields += ',' + info.label;}
            }
        }
        */
        //system.debug('strTempFields>>>>>>>>>>>>>>>>>'+strTempFields);
           
        //system.debug('Columns>>>>>>>>>>>>>>>>>>>>'+Columns);  
        SL_View__c  template = null; ///create a object of SL_View__c to update selected columns
        List<SL_View_Filter__c> lstFiltersTemplateToInsert = new List<SL_View_Filter__c>();     
        
        //system.debug('isDisabled>>>>>>>>>>>>>>>>>'+isDisabled);
        /// perform save operation if isDisabled field is true
        if(isDisabled)
        {
            if(currMainCusSettings!=null)
            {
	            for(SL_View__c item:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	            {
	                template = item;
	            }
            }
            if(template != null)
            {
                template.Columns__c = strTempFields;
                template.Advanced_Filter__c = cb_advFilters;
                update template;
            
                /// create a list of SL_View_Filter__c whose template name is selected selectlist option 
                for(SL_View_Filter__c objFiltersTemplate : [Select Id from SL_View_Filter__c where SL_View__c =:template.ID])
                {
                    lstFiltersTemplateToInsert.add(objFiltersTemplate);
                }
                if(!lstFiltersTemplateToInsert.isEmpty()){ delete lstFiltersTemplateToInsert;}
                    
            }
        }
        /// perform save as operation
        else if(!isDisabled)
        {
            SL_View__c item2Delete = null;
            template = new SL_View__c();
            if(currMainCusSettings!=null)
            {
	            for(SL_View__c item:[Select ID, Name,Columns__c,Advanced_Filter__c,RowsCount__c,Implementation__c,Implementation_Type__c,User__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	            {
	                template = item;
	            }
	            //if(item2Delete!=null){ database.delete(item2Delete,false);}
            }

			template.Name = strColumnsAndFiltersTemplate;
            template.Columns__c = strTempFields;
            template.Advanced_Filter__c = cb_advFilters;
            template.RowsCount__c = 50;
            if(template.ID==null)
            {
            	template.Implementation__c = currMainCusSettings.ID;
            	template.Implementation_Type__c = 'Target';
            }
            template.User__c = UserInfo.getUserId();
                
            upsert template;
            
			SL_LIB16_UserChoise__c choiceObject = null;
			
			for(SL_LIB16_UserChoise__c itemUC :[SELECT Id, View__c, User__c FROM SL_LIB16_UserChoise__c WHERE View__c!=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Target' AND 
	        												(Mass_Implementation__c = :currMainCusSettings.Id) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
	       	{
	       		choiceObject = itemUC;
	       		choiceObject.View__c = template.id;
	       	}
			
			if(choiceObject == null)
			{
				choiceObject = new SL_LIB16_UserChoise__c(
					Filter_Tab__c = null,
					Type__c = 'Last',
					Mass_Implementation__c = currMainCusSettings.ID,
					Implementation_Type__c = 'Target',
					View__c = template.id,
					User__c = UserInfo.getUserId()
				);
			}
			upsert choiceObject;
            
            

            lstColumnsAndFiltersTemplate = new List<SelectOption>();
            // fetch all Template
            if(currMainCusSettings!=null)
            {
	            for(SL_View__c objColumnsAndFiltersTemplate:[SELECT Name FROM SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and (User__c=:UserInfo.getUserId() or IsDefault__c=true) ORDER By Name])
	            {
	                lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
	            }
            }
        }
            
        if(template!=null && template.ID!=null)
        {
                lstFiltersTemplateToInsert = new List<SL_View_Filter__c>();
                List<String> lstCbFilterRow = new List<String>(); /// create a list to hold the filters in form of string
                if(cb_filters != Null){ lstCbFilterRow.addAll(cb_filters.split('##'));}
                //system.debug('lstCbFilterRow>>>>>>>>>>>>>>>>>>>>'+lstCbFilterRow);
                
                if(lstCbFilterRow != null && !lstCbFilterRow.isempty())
                {
                    /// create a list of Filters Template DCM__c records to insert
                    for(String objString:lstCbFilterRow)
                    {
                        List<String> lstString = new List<String>();
                        lstString.addAll(objString.split('___'));
                        
                        if(lstString != null && lstString.size() > 1)
                        {   
                            SL_View_Filter__c objFiltersTemplate = new SL_View_Filter__c();
                            objFiltersTemplate.SL_View__c = template.ID;
                            objFiltersTemplate.Type__c = lstString[0];
                            if(lstString.size()>1)
                            objFiltersTemplate.Field__c = lstString[1];
                            if(lstString.size()>2)
                            objFiltersTemplate.Operator__c = lstString[2];
                            if(lstString.size()>3)
                            objFiltersTemplate.Value__c = lstString[3];

                            lstFiltersTemplateToInsert.add(objFiltersTemplate);
                        }
                    }
                }
                
                //system.debug('lstFiltersTemplateToInsert>>>>>>>>>>>>>>>>>>>>'+lstFiltersTemplateToInsert);
                if(!lstFiltersTemplateToInsert.isempty()){ insert lstFiltersTemplateToInsert;}
        }
        shownColumnNames = new Set<String>();
            
        //Change made by Bijal for Stephens-132.
        set<String> setTempList = new set<String>();
        List<String> colsLst = new List<String>();

        List<String> colsLstTemp = scolumns.split(';');
        for(String temp : colsLstTemp)
        {
            if(!setTempList.contains(temp))
            {
                colsLst.add(temp);
                setTempList.add(temp);
            }
        }
        Set<String> cols = new Set<String>(colsLst);        
        for (ColumnInfo info : columns)
        {
            if (cols.contains(info.name))
            {
                info.show = true;
                shownColumnNames.add(info.name);
                for (integer i=0; i<colsLst.size(); i++)
                {
                    if (info.name == colsLst[i]) info.showOrder = i;
                }
            }
            else info.show = false;
        }
        
        loadColumnOrder();
    }

    public void saveSelectedColumns()
    {
        Map<String,String> mapFieldLabel_FieldName = new Map<String,String>();
        String strColumns ='';
        String res='';
        List<String> lstString = new List<String>();

        if(currMainCusSettings!=null)
        {
	        for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' ORDER BY Label__c])
	        {
	            mapFieldLabel_FieldName.put(item.Label__c,item.Field__c);
	        }
	
	        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
	        {
	            if(template.Columns__c != null && template.Columns__c !='')
	            {
	                strColumns = template.Columns__c.replace('*',' ');
	                lstString.addAll(strColumns.split(','));
	
	                for(String objString:lstString)
	                {
	                    if(res == ''){ res = mapFieldLabel_FieldName.get(objString);}
	                    else{ res += ';' + mapFieldLabel_FieldName.get(objString);}
	                }
	            }
	        }
		}

        saveIntialColumns(res);
    }

    public void loadColumnOrder()
    {
        Double iRowCount = 50;
        SL_View__c template = null;
        if(strColumnsAndFiltersTemplate!=null && strColumnsAndFiltersTemplate!='' && currMainCusSettings!=null)
        {
            for(SL_View__c item:[Select RowsCount__c, Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
            {
                template = item;
            }
        }
        if(template==null && currMainCusSettings!=null)
        {
            for(SL_View__c item:[Select RowsCount__c, Columns__c, Name From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and (User__c=:UserInfo.getUserId() or IsDefault__c=true) Order by Name limit 1])
            {
                template = item;
            }
        }
        String cols = '';
        if(template!=null)
        { 
            if(template.RowsCount__c!=null && template.RowsCount__c>0){ iRowCount = template.RowsCount__c;}
            cols = template.Columns__c;
            
            pageSize = Math.round((Double)iRowCount);
            pageCount = (membersList.size()-1)/pageSize;
            //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'fcolumns: ' + cols));
            
        }

        if(cols=='')
        {
            //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Filling default columns'));
            for (ColumnInfo info : columns) {
                if (info.show) cols += ';' + info.name;
            }
            if (cols.length()>0) cols = cols.substring(1);          
        }
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'columns: ' + cols));
        selectedColumnsCallback = cols;
        saveSelectedColumns();
        
    }
    
    /* Not necessary
    private Integer isEqual(List<Integer> a1, List<Integer> a2) {
        if (a1==null && a2==null) return -1;
        if (a1==null || a2==null) return -1000;
        if (a1.size()!=a2.size()) return -1000;
        for (Integer i=0; i<a1.size(); i++) 
            if (a1[i]!=a2[i]) return i;
        return -1;
    } 
    */
    
    public class PermutationInfo{
        public Integer iFrom {get; set;}
        public integer iTo {get; set;}
        public PermutationInfo(integer i1, integer i2){
            this.iFrom = i1;
            this.iTO = i2;
        }
    }
    
    public void saveColumnsFilters()
    {
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'cb_columns: ' + cb_columns));
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'cb_filters: ' + cb_filters));
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'cb_afilters: ' + cb_advfilters));
        
        
        List<String> lstString = new List<String>(); /// list to hold comma separated column names
        map<String,Integer> mapNameToShowOrder = new map<String,Integer>(); /// map to store column name as key and order as value
        List<ColumnInfo> lstColumnInfo = new List<ColumnInfo>(); /// list to store ColumnInfo tepmorarily
        String strColumns ='';
        String res='';
        set<String> setColumnInfoName = new set<String>();
        map<String,Mass_Edit_Settings__c> mapFieldName_object =  new map<String,Mass_Edit_Settings__c>();
        
        if(currMainCusSettings!=null)
        {
	        for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c, Sort_Field__c, IsSortable__c, isEditable__c, Field_Style__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' ORDER BY Label__c])
	        {
	            mapFieldName_object.put(item.Field__c.toLowerCase(),item);
	        }
        }
        if(cb_columns!=null && cb_columns!='')
        {
            lstString.addAll(cb_columns.split(';')); /// split cb_columns and store in a list of string
            lstColumnInfo.addAll(columns);
            Integer i = 0;
            
            /// create a map of column name to order
            for(String str:lstString)
            {
                mapNameToShowOrder.put(str,i);
                i++;
            }
            
            columns = new List<ColumnInfo>();
            
            /// create ColumnInfo
            for(String str:lstString)
            {
                if(str!=null && str!='' && mapFieldName_object.containsKey(str.toLowerCase()))
                {
                    ColumnInfo objColumnInfo = new ColumnInfo(str, mapFieldName_object.get(str.toLowerCase()).Sort_Field__c,
                                                             mapFieldName_object.get(str.toLowerCase()).Label__c, true, true, 
                                                             mapFieldName_object.get(str.toLowerCase()).IsSortable__c, 
                                                             mapFieldName_object.get(str.toLowerCase()).isEditable__c,
                                                             mapFieldName_object.get(str.toLowerCase()).Field_Style__c);
                    objColumnInfo.showOrder = mapNameToShowOrder.get(str);
                    columns.add(objColumnInfo);
                    setColumnInfoName.add(str);
                }
            }
            //system.debug('columns1111111>>>>>>>>>>>>>>>>>>>>>'+columns);
            
            /// add ColumnInfo values present in columns list
            for(ColumnInfo objColumnInfo:lstColumnInfo)
            {
                if(!setColumnInfoName.contains(objColumnInfo.name) && objColumnInfo.name != null && objColumnInfo.label != null)
                {
                    columns.add(objColumnInfo);
                    //system.debug('-------objColumnInfo------'+objColumnInfo);
                }
            }
        }
        
        saveColumns(cb_columns);
        refetchMembers();
        btnGo();
    }
    
    public String getFiltersJSON()
    {
        String res = '';
        if(currMainCusSettings!=null)
        {
	        for(SL_View_Filter__c objFiltersTemplate:[Select Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c from SL_View_Filter__c where SL_View__r.Name=:strColumnsAndFiltersTemplate and SL_View__r.Implementation__c=:currMainCusSettings.ID and SL_View__r.Implementation_Type__c='Target'])
	        {
	            res += ', { name: "' + objFiltersTemplate.Field__c + '", operator: "' + objFiltersTemplate.Operator__c + 
	                                      '", value: "' + (objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c) + '"}';
	            cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
	        }
		}
        if (res.length()>0) res = res.substring(1);
        return '[' + res + ']';
    }
    
	public static List<SelectOption> getRowQtySelectOptList(SL_Mass_Implementation__c inImplObj)
    {
		List<SelectOption> pageSizeValues = new List<SelectOption>();
		if(inImplObj!=null && inImplObj.Row_Qty_Values__c!=null && inImplObj.Row_Qty_Values__c!='')
		{
			for(String item: inImplObj.Row_Qty_Values__c.split(',',0))
			{
				pageSizeValues.add(new SelectOption(item, item));
			}
		}
		else
		{
			pageSizeValues.add(new SelectOption('10', '10'));
			pageSizeValues.add(new SelectOption('20', '20'));
			pageSizeValues.add(new SelectOption('30', '30'));
			pageSizeValues.add(new SelectOption('50', '50'));
			pageSizeValues.add(new SelectOption('100', '100'));
		}
		
		return pageSizeValues;
    }

	public static String getRelObject4Field(String inObjName, String inFldName)
    {
    	String fldParts = inFldName;
    	if(inFldName.indexOf('.')>0){ fldParts = inFldName.substring(0,inFldName.indexOf('.'));}
    	else{ return null;}

    	String sParentField = '';
    	if(fldParts.right(3)=='__r'){ sParentField = fldParts.substring(0,fldParts.length()-3)+'__c';}
    	else{ sParentField = fldParts+'Id';}
    	
    	Schema.SObjectType dType = Schema.getGlobalDescribe().get(inObjName).getDescribe().fields.getMap().get(sParentField).getDescribe().getReferenceTo().get(0);
		return String.valueOf(dType);    	
    }

    public static Map<String, String> operatorLabels = new Map<String, String>
    {
          'equal' => 'equals'
        , 'notEqual' => 'not equal'
        , 'lessThan' => 'less than'
        , 'lessOrEqual' => 'less or equal'
        , 'greaterThan' => 'greater than'
        , 'greaterOrEqual' => 'greater or equal'
        , 'startsWith' => 'starts with'
        , 'contains' => 'contains'
        , 'notContain' => 'not contain'
        , 'includes' => 'includes'
        , 'excludes' => 'excludes'
    }; 
    
    
    
    public String getFiltersString(){
        String res = '';
        Schema.DescribeFieldResult curFieldDescribe = null;
        for (SL_LIB16_FilterSOQLCompiler.FilterSet filter : filterCompiler.m_filter_set)
        {
        	curFieldDescribe = getFieldDescribe(filter.Field);
        	if(curFieldDescribe!=null)
        	{
            	res += ', ' + curFieldDescribe.getLabel() + ' ' + operatorLabels.get(filter.Operator) + ' ' + filter.Value;
        	}
        }
        for (QuickFilter f : cb_quickFilters) {
            res += ', ' + f.text;
        }
        if (res.length()>0) {
            res = res.substring(2);
            res = 'Filters applied: ' + res;
        }
        return res;
    }
    
    
    
    public class FieldJSONObject {
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
         
        public FieldJSONObject() {
            picklistValues = new List<String>();
        }
        
        public FieldJSONObject(String p_name, String p_value, String p_type) {
            picklistValues = new List<String>();
            Name = p_name; Value = p_value; FieldType = p_type;
        }
        
        public FieldJSONObject(String p_name, String p_value, String p_type, List<String> p_picklist_values) {
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
    
    public String picklistName {
        get{
            return System.currentPageReference().getParameters().get('picklist');       
        }
    }
    
    public String recordId {
        get{
            return System.currentPageReference().getParameters().get('recordId');       
        }
    }
    
    
    
    public Pagereference EventHandler()
    {
        if(event == 'load') {
            eventActionLoad();
        }
        return null;    
    } 

    protected void eventActionLoad()
    {
        Schema.DescribeSObjectResult objDescr = fillDescribe(target);
        Map<String, Schema.SObjectField> fieldsMap = sobjectFieldsAll.get(target);
        if (picklistName==null || picklistName.trim().length()==0){
        	
        	String retVal = '';
	        JSONResponse =  '{"fields" : []}';
            
        } else {
            /** this might be not used since separate window for picklists in filters... */
            try {
                FieldJSONObject item = new FieldJSONObject(); 
                if (picklistName=='recordtypeid'){
                    //item = new FieldJSONObject();
                    String so = target;
                    List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
                    for (RecordType rt : rtLst){
                        //if (rt.Name.indexOf('Investment ')>=0) continue;
                        item.picklistValues.add(String.escapeSingleQuotes(rt.Name));
                    }
                } 
                else 
                if (item==null) {
                    //item = new FieldJSONObject();
                    //Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
                    List<Schema.PicklistEntry> picklist_list = fieldsMap.get(picklistName).getDescribe().getPicklistValues();
                    for( Schema.PicklistEntry picklist_value : picklist_list ) {
                        item.picklistValues.add(picklist_value.getValue());
                    }
                }
                JSONResponse = '{' + item.jProperty(picklistName, item.picklistValues) + '}';
            }catch(Exception e) {
                JSONResponse = '{"error" : "' + e.getMessage() + '"}';
            }
        }   
    }
    
    public String getNewJSONResponse()
    {
    	String retVal = '';
		
		string mImplID = System.currentPageReference().getParameters().get('m_impl');
        
		SL_Mass_Implementation__c filterObject = [SELECT Id, (SELECT Id,Name,API_Name__c,API_Type__c,Parent_Ref_Field__c,SF_Object__c FROM Filter_Fields__r WHERE Type__c='Target' ORDER BY Order__c) FROM SL_Mass_Implementation__c WHERE Id=:mImplID LIMIT 1];
			
		List<SL_Filter_Field__c> filterFieldsList = filterObject.Filter_Fields__r;
		
		String fieldName;
		for (SL_Filter_Field__c item: filterFieldsList) {
			fieldName = item.API_Name__c;
			if (item.Parent_Ref_Field__c != null) {
				
				String patentObjName = item.Parent_Ref_Field__c;
				
				if (patentObjName.substring(patentObjName.length() - 3, patentObjName.length()) == '__c') {
					patentObjName = patentObjName.substring(0, patentObjName.length() - 1) + 'r';
				} else if (patentObjName.substring(patentObjName.length() - 2, patentObjName.length()) == 'Id') {
					patentObjName = patentObjName.substring(0, patentObjName.length() - 2);
				}
				
				fieldName = patentObjName + '.' + fieldName;
			}
			
			if(item.API_Name__c.toLowerCase()=='recordtypeid'){ item.API_Type__c = 'PICKLIST';}
			retVal += ', '+ '{"name" : "' + item.Name + '", "value" : "' + fieldName + '", "type" : "' + item.API_Type__c;
			
			if (item.API_Type__c == 'REFERENCE') {
				
				Schema.Sobjecttype refType = Schema.getGlobalDescribe().get(item.SF_Object__c);
				Map<String, Schema.SObjectField> fieldMap = refType.getDescribe().fields.getMap();
				List<Schema.SObjectType> typesList = fieldMap.get(item.API_Name__c).getDescribe().getReferenceTo();
				if (typesList.size() > 1) {
					refType = Schema.getGlobalDescribe().get('User');
				} else {
					refType = Schema.getGlobalDescribe().get(String.valueOf(typesList.get(0)));
				}
				String keyPref = refType.getDescribe().getKeyPrefix();
				retVal += '", "prefix" : "' + keyPref;
			}
			
			retVal += '"}';
			
		}
		
        return '{"fields" : ['+(retVal!=''?retVal.substring(2):'')+']}';
    }

    protected String getJsonFromFieldsList(List<FieldJSONObject> p_fields_list)
    {
        String result = '';
        for(Integer i = 0; i < p_fields_list.size(); i++)
        {
            if(p_fields_list[i].FieldType != 'TEXTAREA')
            {
                result += p_fields_list[i].Json;
                if(i != p_fields_list.size()-1) {result += ', ';}
            }
        }
        return '{"fields" : [' + result + ']}';
    }
    
    public class QuickFilter
    {
        public String soql {get; set;}
        public String text {get; set;}
        
        public QuickFilter(){}
        
        public QuickFilter(String soql, String text)
        {
            this.soql = soql;
            this.text = text;
        }
    }

    public class MethodNotDefinedException extends Exception{}

    public virtual class ColumnInfo
    {
        public String name {get; set;}
        public String styleName {get; set;}
        public String label {get; set;}
        public String sortExpression {get; set;}
        public Boolean show {get; set;}
        public Boolean isSortable {get; set;}
        public Boolean isEditable {get; set;}
        public Boolean allowMultiedit {get; set;}
        public Integer showOrder {get; set;}
        
        public ColumnInfo(String name, String sortE, String label, Boolean show){
            this.assignVals(name, sortE, label, show, true, true, true, '');
        }

        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable, String inStyleName){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, inIsEditable, inStyleName);
        }
        
        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, inIsEditable, '');
        }
        
        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, true, '');
        }
        
        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti){
            this.assignVals(name, sortE, label, show, allowMulti, true, true, '');
        }
        
        public Boolean getIsEmpty(){
            return (label==null || label.trim().length()==0);
        }
        
        private void assignVals(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable, String inStyleName)
        {
            this.name = name;
            this.sortExpression = sortE;
            this.label = label;
            this.show = show;
            this.allowMultiedit = allowMulti;
            this.isSortable = inIsSortable;
            this.isEditable = inIsEditable;
            this.styleName = inStyleName;
        }
    }

}