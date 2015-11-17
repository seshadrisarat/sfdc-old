/*
	Author: Prishlyak Vladimir
	Main task: https://silverline.jira.com/browse/LIB-62
	Description:  Company List Management
*/
public abstract class SL_LIB16_MassEdit {
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
	public List<SelectOption> pageSizeValues {get; set;}
	public boolean inEditColumns {get; set;}
	public List<String> fieldNames {get; set;}
	public List<String> fieldNamesNotColumns {get; set;}
	public List<String> fieldNamesNotNulls {get; set;}
	public List<ColumnInfo> columns {get; set;}
	public String selectedColumnsCallback {get; set;}
	public String targetObjectName, targetObjectParentFieldName;
	public final String customSettingName {get; set;}
	public Integer customSettingCount {get; set;}
	public Set<String> shownColumnNames {get; set;}
	public boolean isViewState {get; set;}
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
	public SL_LIB16_MassEdit(){
		isDebug = false;
		inEditColumns = false;
		pageSizeValues = new List<SelectOption>();
		pageSizeValues.add(new SelectOption('10', '10'));
		pageSizeValues.add(new SelectOption('20', '20'));
		pageSizeValues.add(new SelectOption('30', '30'));
		pageSizeValues.add(new SelectOption('50', '50'));
		pageSizeValues.add(new SelectOption('100', '100'));
		pageSize = 50;
		pageNumber = 0;
		sortExpression = 'Name';
		sortDirection = 'ASC';
		customSettingCount = 10;
		filterCompiler = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler ();
		membersList = new List<MemberContainer>();
		fieldNamesNotColumns = new List<String>();
		fieldNamesNotNulls = new List<String>();
		fieldsAsPicklists = new Set<String>();
		fieldsFilterIgnored = new Set<String>();
		cb_quickFilters = new List<QuickFilter>();
	}
	
	
	
	/** just fill describe info about target object */
	public void fillDescribe(){
		fillDescribe(targetObjectName);
		sobjectFields = sobjectFieldsAll.get(targetObjectName);
	}
	
	
	
	private Schema.DescribeSObjectResult fillDescribe(String objName){
		if (sobjectFieldsAll==null) sobjectFieldsAll = new Map<String, Map<String, Schema.SObjectField>>();
		if (sobjectDescribesAll==null) sobjectDescribesAll = new Map<String, Schema.DescribeSObjectResult>();
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Filling Describe : ' + objName));
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
		try {
			objDescr = sobjectDescribesAll.get(objName);
		}
		catch (exception e) {objDescr = null;}
		if (objDescr==null) objDescr = fillDescribe(objName);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, objName + ' fields : '+sobjectFieldsAll.get(objName)));
		system.debug('objName = '+objName);
		system.debug('sobjectFieldsAll.get(objName) = '+sobjectFieldsAll.get(objName));
		system.debug('fieldName = '+fieldName);
		system.debug('fieldName.indexOf(.) = '+fieldName.indexOf('.'));
		system.debug('sobjectFieldsAll.get(objName).get(fieldName) = '+sobjectFieldsAll.get(objName).get(fieldName));
		if (fieldName.indexOf('.')<0) return sobjectFieldsAll.get(objName).get(fieldName).getDescribe();
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'rel : '+objName + ' -> ' + fieldName));
		String relName = fieldName.substring(0, fieldName.indexOf('.'));
		for (Schema.SObjectField f : objDescr.fields.getMap().values()){
			String path = (fullPath.length()==0) ? ''+f : fullPath + '.' + f;
			if (fieldDescribes.containsKey(path)){
				if (fieldDescribes.get(path).getRelationshipName().toLowerCase().trim()==relName.toLowerCase().trim()) {
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, path + '  ==> ' + fieldDescribes.get(path).getRelationshipName() + ' ?= ' + relName + ' == ' + (fieldDescribes.get(path).getRelationshipName().toLowerCase().trim()==relName.toLowerCase().trim())));
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'found : '+fieldDescribes.get(path).getName()));
					objName = '' + fieldDescribes.get(path).getReferenceTo().get(0);
					break;
				}
			} else {
				
			}
		}		
		
		fieldName = fieldName.substring(fieldName.indexOf('.')+1);
		system.debug(objName + '( ' + relName + ' ) -> ' + fieldName);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, objName + '( ' + relName + ' ) -> ' + fieldName));
		return getFieldDescribe(objName, fieldName, (fullPath.length()==0) ? relName : fullPath + '.' + relName);
	}
	
	
	
	/*private Schema.SObjectField getFieldByPath(String field) {
		String curSOName = targetObjectName;
		while (field.indexOf('.') >= 0) {
			String fieldSub = field.substring(0, field.indexOf('.'));
			field = field.substring(field.indexOf('.')+1);
			Schema.DescribeSObjectResult R = sobjectDescribesAll.get(curSOName);
			if (R==null) R = fillDescribe(curSOName);
			List<Schema.ChildRelationship> C = R.getChildRelationships();
			for (Schema.Childrelationship cr : C) {
				if (cr.getRelationshipName()==fieldSub) {
					Map<String, Schema.Sobjectfield> allFields = sobjectFieldsAll.get(curSOName);
					Schema.Sobjectfield curField = cr.getField();
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '' + curField));
					curSOName = curField.getDescribe().getReferenceTo().get(0).getDescribe().getName();
				}  
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, curSOName + ' :: ' + field));
		}
		return sobjectFieldsAll.get(curSOName).get(field);
	}*/
	
	
	
	/** Updates column labels from describes */
	protected void refetchColumnHeaders(){
		if (sobjectFields==null) fillDescribe();
		for (String field : fieldNamesNotColumns){
			Schema.DescribeFieldResult fr = getFieldDescribe(field);
		}
		for (ColumnInfo col : columns){
			try {
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, col.Name));
				//Schema.Sobjectfield f = getFieldByPath(col.Name);
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, col.Name + ' :: ' + f));
				Schema.DescribeFieldResult fr = getFieldDescribe(col.Name);
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, col.Name + ' :: ' + fr));
				col.label = fr.getLabel();
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, col.Name + ' :: ' + col.label));
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '' + fieldDescribes));
				return;
			}
		}
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
	
	
	
	/** Selects all target objects and creates back-up data structure */
	public void refetchMembers(){
		hasQueryErrors = false;
		if (sobjectFields==null) fillDescribe();
		String query = getCompiledQuery();
		system.debug('getCompiledQuery()---------------------/'+query);
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Query: ' + query));
		List<SObject> fobjects;
		try{
			fobjects = Database.query(query);
			//inEditColumns = true;
		}
		catch (Exception e){
			hasQueryErrors = true;
			inEditColumns = true;
			ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.ERROR, 'Error: invalid search filter values format or filter lookup value not found or invalid Advanced filter.'));
			return;
		}
		membersList = new List<MemberContainer>();
		for (SObject so : fobjects)
			membersList.add(new MemberContainer(so));
		pageCount = (membersList.size()-1)/pageSize;
		pageNumber = 0;
		membersListBackup = new Map<Id, SObject>();
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Limit: ' + Limits.getScriptStatements()));
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
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'shownColumnNames: ' + shownColumnNames));
	} 
	
	
	
	public String getCompiledQuery(){
		if (fieldNames==null){
			Set<String> fn = new Set<String>();
			for (ColumnInfo col : columns){
				fn.add(col.name);
				fn.add(col.sortExpression);
			}
			fieldNames = new List<String>(fn);
		}
		String res = 'SELECT Id';
		for (String field : fieldNamesNotColumns){
			res += ', ' + field;
		}
		for (String field : fieldNames){
			if (!new Set<String>(fieldNamesNotColumns).contains(field))
				res += ', ' + field;
		}
		res += ' FROM ' + targetObjectName;
		res += ' WHERE ' + targetObjectParentFieldName + '=\'' + parentObject.Id + '\' ';
		for (String field : fieldNamesNotNulls){
			res += ' AND ' + field + '!=null ';
		}
		if (cb_advFilters!=null && cb_advFilters.trim().length()!=0){
			filterCompiler.Initialize(cb_filters, cb_advFilters, targetObjectName);
			filterCompiler.targetObject = this.targetObjectName;
			filterCompiler.recordId = this.parentObject.Id;
			String soql = filterCompiler.SOQL;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'soql: ' + soql));
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
		res += ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' ';
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query: ' + res));
		//res += ' LIMIT 980';
		return res;
	}
	
	/*
	returns "true" if value1 is BEFORE in resulting list than value2
	TODO:
	1. Compare Objects, not Strings
	*/
	public boolean compareField(String value1, String value2){
		system.debug('---------------------------- compare: ' + value1 + ' ' + value2);
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
			p.value = getField(p.member.obj, sortExpression);
			mems.add(p);
		}
		system.debug('================================ mems: ' + mems);
		sortMems(0, mems.size()-1);
		for (integer i=0; i<mems.size(); i++){
			membersList[i] = mems[i].member;
		}
		//refetchMembers();
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Limit: ' + Limits.getScriptStatements()));
	}
	
	
	
	private class Pair{
		public MemberContainer member {get; set;}
		public String value {get; set;}
	}
	
	
	
	private List<Pair> mems {get; set;}
	public void sortMems(integer l, integer r){
		system.debug('----------------------- inside: ' + l + ' ' + r);
		integer i = l;
		integer j = r;
		system.debug(i);
		system.debug(j);
		system.debug(mems.size());
		if (mems.size()<= (i+j)/2+1) return;
		String p = mems[(i+j)/2+1].value;
		do {
			system.debug('-----------------------ij: ' + i + ' ' + j);
			while (compareField(mems[i].value, p)) i++;
			while (compareField(p, mems[j].value)) j--;
			system.debug('-----------------------ij2: ' + i + ' ' + j);
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
	
	
	
	public String pageNumberString {get; set;}
	public void doSavePageNumber() {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'pageNumberString: ' + pageNumberString));
		pageNumber = Integer.valueOf(pageNumberString);
		voidAction();
	}
	
	
	
	public void voidAction()
	{
		pageCount = (membersList.size()-1)/pageSize;
		if (pageNumber >= pageCount) pageNumber = (integer)pageCount;
		if (pageNumber < 0) pageNumber = 0;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'pageNumber: ' + pageNumber));
	}
	
	
	
	public void doSavePageSize(){
		if (pageSize>0 && pageSize<=100) {
			pageCount = (membersList.size()-1)/pageSize;
			Mass_Edit_Columns__c colSetting = Mass_Edit_Columns__c.getValues(UserInfo.getUserId());
			if (colSetting == null) {
				colSetting = new Mass_Edit_Columns__c(SetupOwnerId=UserInfo.getUserId());
			}
			colSetting.put(customSettingName + '_RowsCount__c', pageSize);
			Database.upsert(colSetting);
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
		//try{
			return castAndSave(updMembers);
			//if (updMembers.size()>0) upsert updMembers;
		//} catch (Exception e){
			//return false;
		//}
		return true;
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
	
	
	
	public virtual class ColumnInfo{
		public String name {get; set;}
		public String label {get; set;}
		public String sortExpression {get; set;}
		public Boolean show {get; set;}
		public Boolean allowMultiedit {get; set;}
		public Integer showOrder {get; set;}
		
		public ColumnInfo(String name, String sortE, String label, Boolean show){
			this.name = name;
			this.sortExpression = sortE;
			this.label = label;
			this.show = show;
			this.allowMultiedit = true;
		}
		
		public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti){
			this.name = name;
			this.sortExpression = sortE;
			this.label = label;
			this.show = show;
			this.allowMultiedit = allowMulti;
		}
		
		public Boolean getIsEmpty(){
			return (label==null || label.trim().length()==0);
		}
	}
	
	
	
	public List<ColumnInfo> getColumnsShown(){
		List<ColumnInfo> res = new List<ColumnInfo>();
		for (ColumnInfo info : columns){
			if (info.show) res.add(info);
		}
		return res;
	}
	
	
	
	public List<SelectOption> getUnselectedColumns(){
		List<SelectOption> res = new List<SelectOption>();
		for (ColumnInfo info : columns){
			if (!info.show) res.add(new SelectOption(info.name, info.label));
		}
		return res;
	}
	
	
	
	public List<SelectOption> getSelectColumns(){
		List<SelectOption> res = new List<SelectOption>();
		for (ColumnInfo info : columns){
			if (info.show) res.add(new SelectOption(info.name, info.label));
		}
		return res;
	}
	
	
	
	public List<SelectOption> getSelectColumnsOrdered(){
		List<SelectOption> res = new List<SelectOption>();
		for (ColumnInfo info : getColumnsShownOrdered()){
			if (info.show) res.add(new SelectOption(info.name, info.label));
		}
		return res;
	}
	
	
	
	public void saveColumns(String scolumns){
		shownColumnNames = new Set<String>();
		List<String> colsLst = scolumns.split(';');
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
		/*for (integer i=colsLst.size()-1; i>=0; i--){
			String cn = colsLst[i];
			for (integer j=0; j<columns.size(); j++){
				if (columns[j].name == cn){
					ColumnInfo info = columns[j];
					columns.remove(j);
					columns.add(0, info);
				}
			}
		}*/
		saveColumnOrder();
	}
	
	
	
	public void saveSelectedColumns(){
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'selectedColumnsCallback : ' + selectedColumnsCallback));
		saveColumns(selectedColumnsCallback);
	}
	
	
	
	public void loadColumnOrder(){
		Mass_Edit_Columns__c colSetting = Mass_Edit_Columns__c.getInstance(UserInfo.getUserId());
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'colSetting: ' + colSetting));
		String cols = '';
		if (colSetting!=null) {
			for (integer i=0; i<customSettingCount; i++){
				try {
					String fields = (String)colSetting.get(customSettingName + '_' + i + '__c');
					if (fields!=null && fields.trim().length()>0) cols += ';' + fields;
				} catch (Exception e) {
					ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'exception: ' + e.getMessage()));
				}
			}
			if (colSetting.get(customSettingName + '_RowsCount__c')==null){
				colSetting.put(customSettingName + '_RowsCount__c', 50);
			}
			pageSize = Math.round((Double)colSetting.get(customSettingName + '_RowsCount__c'));
			pageCount = (membersList.size()-1)/pageSize;
			ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'fcolumns: ' + cols));
		}
		if (cols.length()>0) cols = cols.substring(1);
		else {
			ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Filling default columns'));
			for (ColumnInfo info : columns) {
				if (info.show) cols += ';' + info.name;
			}
			if (cols.length()>0) cols = cols.substring(1);			
		}
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'columns: ' + cols));
		selectedColumnsCallback = cols;
		saveSelectedColumns();
	}
	
	
	
	private List<ColumnInfo> getColumnsShownOrdered(){
		List<ColumnInfo> res = new List<ColumnInfo>();
		List<ColumnInfo> shown = new List<ColumnInfo>();
		System.debug('@@@@@@@@@@@@@@@@@@In here columns= '+columns);
		for (ColumnInfo info : columns) {
			if (info.show) {
				shown.add(info);
			}
		}
		while (res.size()!=shown.size()){
			for (ColumnInfo info : shown) {
				if (info.showOrder==res.size()) res.add(info);
			}
		}
		return res;		
	}
	
	
	
	public void saveColumnOrder(){
		Mass_Edit_Columns__c colSetting = Mass_Edit_Columns__c.getValues(UserInfo.getUserId());
		if (colSetting == null) {
			colSetting = new Mass_Edit_Columns__c(SetupOwnerId=UserInfo.getUserId());
		}
		for (integer i=0; i<customSettingCount; i++){
			try {
				colSetting.put(customSettingName + '_' + i + '__c', null);
			} catch (Exception e) {
				ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'exception: ' + e.getMessage()));
			}
		}
		integer curField = 0;
		String cols = '';
		for (ColumnInfo info : getColumnsShownOrdered()) {
			if (info.show) {
				if ((cols + ';' + info.name).length()-1>255) {
					try {
						colSetting.put(customSettingName + '_' + curField + '__c', cols.substring(1));
					} catch (Exception e) {
						ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'exception: ' + e.getMessage()));
					}
					curField++;
					cols = '';
				}
				cols += ';' + info.name;
			}
		}
		if (cols.length()>0) {
			try {
				colSetting.put(customSettingName + '_' + curField + '__c', cols.substring(1));
			} catch (Exception e) {
				ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'exception: ' + e.getMessage()));
			}
		}
		//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'colSetting: ' + colSetting));
		Database.upsert(colSetting); 
		//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'colSetting: ' + colSetting));
	} 
	
	
	
	public List<PermutationInfo> getColumnPermutation() {
		system.debug('=========================================== getColumnPermutation');
		List<PermutationInfo> res = new List<PermutationInfo>();
		List<Integer> perm = new List<Integer>();
		List<Integer> cperm = new List<Integer>();
		for (ColumnInfo info : columns) {
			if (info.show) {
				perm.add(-1);
			}
		}
		for (ColumnInfo info : columns) {
			if (info.show) {
				perm[info.showOrder] = cperm.size();
				cperm.add(cperm.size());
			}
		}
		Integer curPos = isEqual(perm, cperm); 
		integer msgCount = 0;
		while (curPos>=0){
			Integer cv = cperm[curPos];
			res.add(new PermutationInfo(curPos, cperm.size()-1));
			cperm.remove(curPos);
			cperm.add(cv);
			//system.debug(msgCount++ + 'curPos: ' + curPos);
			//system.debug(msgCount++ + 'cperm: ' + cperm);
			//system.debug(msgCount++ + 'perm: ' + perm);
			//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, msgCount++ + 'curPos: ' + curPos));
			//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, msgCount++ + 'cperm: ' + cperm));
			//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, msgCount++ + 'perm: ' + perm));
			curPos = isEqual(perm, cperm);
		}
		return res;
	}
	
	private Integer isEqual(List<Integer> a1, List<Integer> a2) {
		if (a1==null && a2==null) return -1;
		if (a1==null || a2==null) return -1000;
		if (a1.size()!=a2.size()) return -1000;
		for (Integer i=0; i<a1.size(); i++) 
			if (a1[i]!=a2[i]) return i;
		return -1;
	} 
	
	/*private Integer findPos(List<Integer> a, Integer val) {
		if (a==null) return -1;
		for (Integer i=0; i<a.size(); i++) 
			if (a[i]==val) return i;
		return -1;
	}*/
	
	public class PermutationInfo{
		public Integer iFrom {get; set;}
		public integer iTo {get; set;}
		public PermutationInfo(integer i1, integer i2){
			this.iFrom = i1;
			this.iTO = i2;
		}
	}
	
	
	
	public void saveColumnsFilters(){
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'cb_columns: ' + cb_columns));
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'cb_filters: ' + cb_filters));
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'cb_afilters: ' + cb_advfilters));
		
		saveColumns(cb_columns);
		//saveFilters(cb_advFilters, cb_Filters);
		
		refetchMembers();
	}
	
	
	
	public String getFiltersJSON(){
		String res = '';
		for (SL_LIB16_FilterSOQLCompiler.FilterSet filter : filterCompiler.m_filter_set){
			res += ', { name: "' + filter.Field + '", operator: "' + filter.Operator + '", value: "' + filter.Value + '"}';
		}
		if (res.length()>0) res = res.substring(1);
		return '[' + res + ']';
	}
	
	
	
	public static Map<String, String> operatorLabels = new Map<String, String>{
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
		for (SL_LIB16_FilterSOQLCompiler.FilterSet filter : filterCompiler.m_filter_set){
			res += ', ' + getFieldDescribe(filter.Field).getLabel() + ' ' + operatorLabels.get(filter.Operator) + ' ' + filter.Value;
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
		public String  Name         		{get;set;}
        public String  Value        		{get;set;}
        public String  FieldType    	   	{get;set;} 
        public List<String> picklistValues  {get;set;}
        public String Prefix 				{get;set;}
        
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
	
	
	
	public Pagereference EventHandler() {
		if(event == 'load') {
			eventActionLoad();
		}
		return null;	
	} 

	protected void eventActionLoad() {
		Schema.DescribeSObjectResult objDescr = fillDescribe(target);
		Map<String, Schema.SObjectField> fieldsMap = sobjectFieldsAll.get(target);
		if (picklistName==null || picklistName.trim().length()==0){
			List<FieldJSONObject> res = new List<FieldJSONObject>();
			for (Schema.SObjectField field : fieldsMap.values()){
				DescribeFieldResult fd = field.getDescribe();
				FieldJSONObject item = new FieldJSONObject(
						fd.getName(), 
						fd.getLabel(), 
						fd.getType().name()
				);
				//if (item.FieldType == 'ID') item.FieldType = 'REFERENCE';
				if (item.FieldType == 'REFERENCE') {
					if (fd.getName()=='recordtypeid' || fieldsAsPicklists.contains(fd.getName())){
						item.FieldType = 'PICKLIST';
					} else {
						List<Schema.sObjectType> refereced_to_list = fd.getReferenceTo();
						if(!refereced_to_list.isEmpty()) {
							item.Prefix = refereced_to_list.get(0).getDescribe().getKeyPrefix();
						}
					}
				} 
				if (!fieldsFilterIgnored.contains(fd.getName()))
					res.add(item);
			}
			List<FieldJSONObject> sres = new List<FieldJSONObject>();
        	while (res.size()>0){
	        	FieldJSONObject mo = res.get(0);
    	    	res.remove(0);
        		integer i = 0;
        		while (i<res.size()){
        			if (res.get(i).Value < mo.Value){
        				res.add(mo);
	        			mo = res.get(i);
    	    			res.remove(i);
        			} else i++;
        		}
        		sres.add(mo);
        	}
			JSONResponse = getJsonFromFieldsList(sres);
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
	
	public class LookUpPickListValue
	{
		public String  ID   {get;set;}
        public String  Value {get;set;}
        
        public LookUpPickListValue(String inID, String inValue) {
        	ID = inID;
        	Value = inValue;
        }
	}
	
	public abstract List<LookUpPickListValue> getCustomPicklistValues(String parentId, String picklistName);
	
	public List<LookUpPickListValue> getLCPickListValue()
	{
		List<LookUpPickListValue> returnList = new List<LookUpPickListValue>();
		integer ccounter = 0;
		try { 
			if (picklistName=='recordtypeid'){
				String so = target;
				List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
				for (RecordType rt : rtLst){
					//if (rt.Name.indexOf('Investment ')>=0) continue;
					returnList.add(new LookUpPickListValue(''+ccounter,String.escapeSingleQuotes(rt.Name)));
					ccounter++;
				}
			} else
			if (fieldsAsPicklists.contains(picklistName)) {
				returnList = getCustomPicklistValues(recordId, picklistName);
			}
			else {
				Schema.DescribeSObjectResult objDescr = fillDescribe(target);
				Map<String, Schema.SObjectField> fieldsMap = sobjectFieldsAll.get(target);
				List<Schema.PicklistEntry> picklist_list = fieldsMap.get(picklistName).getDescribe().getPicklistValues();
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
	
	protected String getJsonFromFieldsList(List<FieldJSONObject> p_fields_list) {
		String result = '';
		for(Integer i = 0; i < p_fields_list.size(); i++) {
			result += p_fields_list[i].Json;
			if(i != p_fields_list.size()-1) {
				result += ', ';
			}
		}
		return '{"fields" : [' + result + ']}';
	}
	
	
	
	public String getCurrentUrlEncoded() {
		return EncodingUtil.urlEncode('/apex/SL_LIB16_MassEdit_CallLog?justView=true&view=false&pId=' + parentObject.Id, 'UTF-8');
	}
	
	
	
	
	public class QuickFilter {
		public String soql {get; set;}
		public String text {get; set;}
		
		public QuickFilter() {
			
		}
		
		public QuickFilter(String soql, String text) {
			this.soql = soql;
			this.text = text;
		}
	}
	
	
	
	public class MethodNotDefinedException extends Exception{}
}