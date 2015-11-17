/*
	Author: Prishlyak Vladimir
	Main task: https://silverline.jira.com/browse/LIB-62
	Description:  Company List Management
	Description (vbabin): Please be aware that this class is also used in Manage Targets functionality.
*/
public without sharing class SL_LIB16_MassEdit_CompanyListMember extends SL_LIB16_MassEdit
{

    public Map<String, String> filterLabels{get; set;}
    public String dateFormat {get{return SL_LIB16_DateObject.dateFormat;}set;}
    
    public List<SL_View_Filter__c> filters {
        get {
            if(filters == null){
                filters = [Select Value__c, Type__c, SL_View__c, Operator__c, Id, Field__c, SL_View__r.Advanced_Filter__c From SL_View_Filter__c where SL_View__c=:view.ID and (Operator__c = 'equal' OR Operator__c = 'includes') and (Type__c !='ID')];
                Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
                Schema.sObjectType objType = globalDescription.get(targetObjectName); 
                Schema.DescribeSObjectResult r1 = objType.getDescribe(); 
                Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();
                Integer i = 0;
                List<SL_View_Filter__c> filtersNew = new List<SL_View_Filter__c>();
                try{
                    for(SL_View_Filter__c f: filters){
                        String obj = '';
                        String obj_r = '';
                        String field = f.Field__c;
                        Map<String , Schema.SObjectField> mfl = mapFieldList;
                        if(field.contains('.')){ // Handle nested filters
                            String[] strs = field.split('\\.');
                            obj_r = strs[0];
                            obj = obj_r.replace('__r', '__c');
                            field = strs[1];
                            if(filterObj.getSObject(obj_r)==null){
                                String o = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(this.currMainCusSettings.targetObjectName__c, obj.replace('__r', '__c'));
                                Schema.sObjectType ot = globalDescription.get(o);
                                r1 = ot.getDescribe(); 
                                mfl = r1.fields.getMap();
                                filterObj.putSObject(obj_r, ot.newSObject());
                            }
                        }
                        filterLabels.put(f.Field__c, mfl.get(field).getDescribe().getLabel());
                        if(mfl.get(field).getDescribe().isUpdateable()){
                            if(f.Type__c=='REFERENCE'){
                                String value = f.Value__c;
                                try{ID n = (ID)f.Value__c;}
                                catch(Exception e){
                                    String so = '';
                                    if(obj!=''){
                                        so = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(obj, field);
                                    } else {
                                        so = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(this.currMainCusSettings.targetObjectName__c, field);
                                    }
                                    String query = 'SELECT Id, Name FROM ' + so + ' WHERE Name=\''+value+'\' LIMIT 1';
                                    try{
                                        SObject rt = Database.query(query).get(0);
                                        value = String.valueOf(rt.Id);
                                        putToSObject(filterObj, field, value, obj_r);
                                    } catch (Exception ex){
                                        System.Debug(ex.getMessage() + '<br/>' +query);
                                    }
                                }
                            } else if (f.Type__c=='DATE'){
                                putToSObject(filterObj, field, Date.valueOf(f.Value__c), obj_r);
                            } else if (f.Type__c=='DATETIME'){
                                String prepareDate = f.Value__c.replace('T', ' ').replace('Z','');
                                putToSObject(filterObj, field, Date.valueOf(prepareDate), obj_r);
                            } else if (f.Type__c=='ID'){
                                putToSObject(filterObj, field, (ID)f.Value__c, obj_r);
                            } else {
                                putToSObject(filterObj, field, f.Value__c, obj_r);
                            }
                            filtersNew.add(f);
                        }
                    }
                }
                catch(Exception ex){
                    System.Debug('ERROR preparing the filters: (line ' + ex.getLineNumber() + ') - ' + ex.getMessage() + ' STACK: ' + ex.getStackTraceString());
                }
                filters = filtersNew;
            }
            return filters;
        } 
        set;
    }
    
    public SL_View__c view {
        get{
            if(view == null){
                List<SL_View__c> vs = [Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType limit 1];
                for(SL_View__c v: vs){view = v;}
            }
            return view;
        } 
        set;
    }
    
    public SObject filterObj {get; set;}
    
    public String shortUrl {
        get{
            if(shortUrl!=null && shortUrl!=''){
                return shortUrl;
            }
            shortUrl = Apexpages.currentPage().getUrl();
            if(shortUrl==null || shortUrl=='') return shortUrl;
            if(shortUrl.indexOf('?')!=-1){ shortUrl = shortUrl.substring(0,shortUrl.indexOf('?'));}
            return shortUrl;
        }
        set;
    }
    
	public SL_LIB16_MassEdit_CompanyListMember()
    {
        super();
        filterLabels = new Map<String, String>();
        String clId = ApexPages.currentPage().getParameters().get('clId');
        if(hasNoError)
        {
	        tplRecordTypeName = this.MainObjName;
			if(this.currMainCusSettings!=null)
			{
				if(this.currMainCusSettings.targetObjectName__c != null) targetObjectName = this.currMainCusSettings.targetObjectName__c.toLowerCase();
				if(this.currMainCusSettings.targetObjectParentFieldName__c != null) targetObjectParentFieldName = this.currMainCusSettings.targetObjectParentFieldName__c.toLowerCase();
				if(this.currMainCusSettings.parentObjectName__c != null)
				{
	            	parentObjectName = this.currMainCusSettings.parentObjectName__c.toLowerCase();
				    	
				    if(parentObjectName != null)
				    {
				    	String qTxt = 'SELECT Id, Name FROM '+parentObjectName+' WHERE Id = \''+clId+'\'';
				    	for(SObject item: Database.query(qTxt)){ parentObject = item;}
				    }
				}
				List<String> lTemp = new List<String>();
                filterObj = Schema.getGlobalDescribe().get(this.currMainCusSettings.targetObjectName__c).newSObject();
			}
			
			Boolean isPageLoad = true;
	        String activColumnNames = '';
			SL_LIB16_UserChoise__c curUserChoise = null;
			for(SL_LIB16_UserChoise__c item:[SELECT Id, View__c, View__r.Name, View__r.Columns__c, View__r.RowsCount__c, Implementation_Type__c FROM SL_LIB16_UserChoise__c 
							WHERE View__c != null and Mass_Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and User__c=:UserInfo.getUserId() limit 1])
    		{
    			curUserChoise = item;
    		}
			
			if(curUserChoise!=null)
			{
				isPageLoad = false;
				strColumnsAndFiltersTemplate = curUserChoise.View__r.Name;
				if(curUserChoise.View__r.Columns__c!=null) activColumnNames += curUserChoise.View__r.Columns__c;
				pageSize = (integer)curUserChoise.View__r.RowsCount__c;
			}
			for(SL_View__c objColumnsAndFiltersTemplate:[Select Name, Id, Columns__c, RowsCount__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType])
			{
				lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
				if(isPageLoad)
				{
					strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
					if(objColumnsAndFiltersTemplate.Columns__c!=null) activColumnNames += objColumnsAndFiltersTemplate.Columns__c;
					isPageLoad = false;
					pageSize = (integer)objColumnsAndFiltersTemplate.RowsCount__c;
				}
			}
			Set<String> setSelectedColumn = new Set<String>();
			if(activColumnNames!='')
			{
				for(String item : activColumnNames.split(',')){ setSelectedColumn.add(item.toLowerCase());}
			}
			
			columns = new List<ColumnInfo>();
	        for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' ORDER BY Label__c])
	        { 
	          columns.add(new ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, setSelectedColumn.contains(item.Label__c.toLowerCase()), true, item.IsSortable__c, item.isEditable__c));
	        }
	        system.debug('columns>>>>> '+columns);
	        refetchMembers();
        }
    }

    public SL_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
    	SL_LIB209_ctrl_SearchBlockParams retVal = new SL_LIB209_ctrl_SearchBlockParams();
    	retVal.tabs = new List<SelectOption>();
    	retVal.tabsObjName = new List<SelectOption>{new selectOption('Target_'+currMainCusSettings.ID,this.currMainCusSettings.targetObjectName__c)};
    	retVal.mainSelTarget = 'Target_'+currMainCusSettings.ID;
    	retVal.locationBase = '/apex/SL_LIB16_MassEdit_JSON?m_impl='+currMainCusSettings.ID+'&evtmp=';
    	retVal.searchBtnClick = '';
    	retVal.FiltersJSON = this.getFiltersJSON();
    	retVal.cb_target = 'Main';
    	retVal.cb_advFilters = this.cb_advFilters;
    	retVal.dateFormat = SL_LIB16_DateObject.dateFormat;
    	
    	return retVal;
    }
    
    public override List<SL_View_Filter__c> getViewFilters(){
        if(isManageTargets){
            List<SL_View_Filter__c> lst = new List<SL_View_Filter__c>();
            for(SL_View_Filter__c f : filters){
                String obj = '';
                String obj_r = '';
                String field = f.Field__c;
                if(field.contains('.')){ // Handle nested filters
                    String[] strs = field.split('\\.');
                    obj_r = strs[0];
                    obj = obj_r.replace('__r', '__c');
                    field = strs[1];
                    SObject so = filterObj.getSObject(obj_r);
                    if( so != null && so.get(field) != null && so.get(field) != ''){
                        SL_View_Filter__c ff = f.clone(false, true, false, false);
                        ff.put('Field__c', f.Field__c);
                        ff.put('Value__c', so.get(field));
                        lst.add(ff);
                    }
                } else {
                    if(filterObj.get(f.Field__c) != null && filterObj.get(f.Field__c) != ''){
                        SL_View_Filter__c ff = f.clone(false, true, false, false);
                        ff.put('Field__c', f.Field__c);
                        ff.put('Value__c', filterObj.get(f.Field__c));
                        lst.add(ff);
                    }
                }
            }
            if(!lst.isEmpty()){
                String filter = '1';
                for(Integer i=2; i<lst.size()+1; i++){
                    filter = '(' + filter + ')' + ' AND ' + i;
                }
                for(SL_View_Filter__c f: lst){
                    f.putSObject('SL_View__r', new SL_View__c(Advanced_Filter__c = filter));
                }
            }
            return lst;
        }else{
            return super.getViewFilters();
        }
    }
    
    private void refreshFilters(){
        cb_filters = '';
        cb_advFilters = '';
        for(SL_View_Filter__c objFiltersTemplate: filters)
        {
            if(cb_filters != '') {cb_filters += '##';}
            cb_filters = objFiltersTemplate.Type__c + '___' + objFiltersTemplate.Field__c + '___' + objFiltersTemplate.Operator__c + '___' + objFiltersTemplate.Value__c + '___' ;
        }
        cb_advFilters = view.Advanced_Filter__c;
    }
    
    public SL_Mass_Implementation__c getMassEditSettings(){return this.currMainCusSettings;}
    
    public void loadDefaults()
    {              
		if(!hasNoError)
		{
			String clId = ApexPages.currentPage().getParameters().get('clId');
			String qTxt = 'SELECT Id, Name FROM '+parentObjectName+' WHERE Id = \''+clId+'\'';
			for(SObject item: Database.query(qTxt)){ parentObject = item;}
	
			btnGo();
			//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Limit: ' + Limits.getScriptStatements()));
		}
    }
    
    public void loadDefaultsTarget()
    {
    	this.loadDefaults();
    	for(SL_View__c item:[Select RowsCount__c, ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='ManageTargets' limit 1])
    	{
    		pageSize = (integer)item.RowsCount__c;
			pageCount = (membersList.size()-1)/pageSize;
    	}
    }
    
	public String getCurrentUrlEncoded()
	{
		//return EncodingUtil.urlEncode(shortUrl+'?clId=' + parentObject.Id + '&implId=' +this.currMainCusSettings.ID + '&mt=' + getMT(), 'UTF-8');
		
		String urlVal = Apexpages.currentPage().getUrl();
		if(urlVal==null || urlVal=='') return urlVal;
		if(urlVal.indexOf('?')!=-1){ urlVal = urlVal.substring(0,urlVal.indexOf('?'));}
		return EncodingUtil.urlEncode(urlVal+'?clId=' + parentObject.Id + '&implId=' +this.currMainCusSettings.ID + '&mt=' + getMT(), 'UTF-8');
		
	}

	public List<MemberContainerCasted> getConvertedCallLogs()
	{
        List<MemberContainerCasted> res = new List<MemberContainerCasted>();
        Integer first = Math.min(pageNumber*pageSize, membersList.size());
        Integer last = Math.min(pageNumber*pageSize + pageSize, membersList.size());
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'first: ' + first));
        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'last: ' + last));
        for (Integer i=first; i<last; i++)
        {
            MemberContainer member = membersList.get(i);
            member.index = res.size();
            res.add(new MemberContainerCasted(member));
        }
        return res; 
    }
    
    public override SObject getNewTargetObject()
    {
		sObject sObj = null;
		if(targetObjectName!=null)
		{
			sObj = Schema.getGlobalDescribe().get(targetObjectName).newSObject();
			sObj.put(targetObjectParentFieldName, parentObject.Id);
		}
		return sObj;
    }
    
	public override boolean castAndSave(List<SObject> lst)
	{
		boolean retVal = true;
		
		List<SObject> lst2Insert = new List<SObject>();
		List<SObject> lst2Update = new List<SObject>();
		for (SObject item : lst)
		{
			if(item.ID==null) lst2Insert.add(item);
			else lst2Update.add(item);
		}
		
		List<Database.SaveResult> uInsertResults = Database.insert(lst2Insert,false);
		for(Database.SaveResult result:uInsertResults)
		{
			if (!result.isSuccess()){ retVal = false;} 
		}
		
		List<Database.SaveResult> uUpdateResults = Database.update(lst2Update,false);
		for(Database.SaveResult result:uUpdateResults)
		{
			if (!result.isSuccess()){ retVal = false;} 
		}
 
		return retVal;
	}
    
    public class MemberContainerCasted {
        public MemberContainer member {get; set;}
        
        public MemberContainerCasted(MemberContainer member){
            this.member = member;
        }
        
        public SObject getCastedSObject(){
            return (SObject)member.obj;
        }
    }
    
    public void dummyFunction(){}
    
    public void doDelete()
    {

        List<SObject> delLogs = new List<SObject>();
        for (MemberContainer member : membersList){
            if (member.isSelected) delLogs.add(member.obj);
        }
		if (delLogs.size()>0){ Database.delete(delLogs, false);}
        
        refetchMembers();
    }
    
    public void doCusSave()
    {
    	save();
    	refetchMembers();
    }
    
    public Boolean getIsItems(){
    	return !getConvertedCallLogs().isEmpty();
    }
    
    public String getTargetObjName(){
    	return this.currMainCusSettings.targetObjectName__c;
    }
    
    public Pagereference addMultipleItems(){
        Pagereference curpage = new Pagereference(shortUrl);
        Pagereference targetpage = new Pagereference('/apex/SL_LIB16_CompanyListSearch');
        targetpage.getParameters().put('clid', ApexPages.currentPage().getParameters().get('clId'));
        
        if(ApexPages.currentPage().getParameters().get('implId')!=null && ApexPages.currentPage().getParameters().get('implId')!='')
        {
        	targetpage.getParameters().put('implId', ApexPages.currentPage().getParameters().get('implId'));
        }
        else if(ApexPages.currentPage().getParameters().get('ExtId')!=null && ApexPages.currentPage().getParameters().get('ExtId')!='')
        {
        	targetpage.getParameters().put('ExtId', ApexPages.currentPage().getParameters().get('ExtId'));
        }
        targetpage.getParameters().put('mt', getMT());
        targetpage.getParameters().put('retURL', curpage.getUrl());
        return targetpage;
    }
    
    private String getMT(){
    	return (isManageTargets ? '1' : '0');
    }
    
    /**
    * Put a value to SObject by field, if there is an inner object, puts to the inner object.
    * It is assumed that if the innerObj is specified, then it has been already created on the obj.
     */
    private void putToSObject(sObject obj, String field, Object value, String innerObj){
        if(innerObj!=null && innerObj!=''){
            SObject so = obj.getSObject(innerObj);
            so.put(field, value);
            obj.putSObject(innerObj, so);
        } else {
            obj.put(field, value);
        }
    }
    
    public String getObjectLabel(SObject item){
        return '';
    }
    
    
    public PageReference runReport()
    {
		return SL_ReportButton.generateReport(currMainCusSettings.ID, strColumnsAndFiltersTemplate, ApexPages.currentPage().getParameters().get('clId'));
    }
}