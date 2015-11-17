/**
* Test methods are in Test_Multifilter.cls
**/
public without sharing class Multifilter_filter {
	/****************************************
	 * Class for handling a list of filters *
	 ****************************************/
	
	private Integer maxFilters_num = 0;
	
	public String errMsg_p = null;
	public String errMsg {
		get {
			if (errMsg_p == null) {
				errMsg_p = '';
			}
			return errMsg_p;
		}
		set {
			errMsg_p = value;
		}
	}
	
	/* Result filters */
	private String dealResultFilter_p {get;set;}
	public String dealResultFilter {
		get {
			if (dealResultFilter_p == null)
				dealResultFilter_p = '';
			String res = dealResultFilter_p;
			if (dealResultFilter_p != '' && targetResultFilter != '' && acquirorResultFilter != '') {
				res = dealResultFilter_p + ' OR ' + targetResultFilter + ' OR ' + acquirorResultFilter;
			}
			return res;
		}
		set {
			dealResultFilter_p = value;
		}
	}
	private String targetResultFilter_p {get;set;}
	public String targetResultFilter {
		get {
			if (targetResultFilter_p == null)
				targetResultFilter_p = '';
			return targetResultFilter_p;
		}
		set {
			targetResultFilter_p = value;
		}
	}
	private String acquirorResultFilter_p {get;set;}
	public String acquirorResultFilter {
		get {
			if (acquirorResultFilter_p == null)
				acquirorResultFilter_p = '';
			return acquirorResultFilter_p;
		}
		set {
			acquirorResultFilter_p = value;
		}
	}
	public String drpResultFilter_p {get;set;}
	public String drpResultFilter {
		get {
			if (drpResultFilter_p == null)
				drpResultFilter_p = '';
			return drpResultFilter_p;
		}
		set {
			drpResultFilter_p = value;
		}
	}
	public String pbiResultFilter_p {get;set;}
	public String pbiResultFilter {
		get {
			if (pbiResultFilter_p == null)
				pbiResultFilter_p = '';
			return pbiResultFilter_p;
		}
		set {
			pbiResultFilter_p = value;
		}
	}
	
	private String resultFilter_p;
	public String resultFilter {
		get {
			//resultFilter_p = getConditions();
			return resultFilter_p;
		}
		set {
			resultFilter_p = value;
		}
	}
	
	public List<FilterWrapper> filters {get;set;}
	public String Fields {get;set;}
	/* List of select items*/
    public List<SelectOption>  FieldNames {
    	get {
    		List<SelectOption> res = new List<SelectOption>();
    		res.add(new selectOption('Client__r.Name','Deal Company Name'));
    		res.add(new selectOption('Target__c','Deal Target'));
    		res.add(new selectOption('Acquiror__c','Deal Acquiror'));
    		res.add(new selectOption('Company__r.Name','Deal Related Party Company Name'));
    		res.add(new selectOption('Name','Potential Buyer/Investor Name'));

    		return res;
    	}
    }
    public List<SelectOption>  LabelNames { get; set; }
    public List<SelectOption>  Operators  { get; set; }
    public List<SelectOption>  Conditions { get; set; }
    public String valueStr {get;set;}
	
	public Multifilter_filter() { //Constructor
		filters = new List<FilterWrapper>();
		initConditions();
		maxFilters_num = 0;
		add();
	}
	
	/* Generate IDs & reset indexes */
	private void resetIndexes() {
		for( Integer i= 0; i < filters.size(); i++ ) { 
			filters[i].Id = ''+i;
			filters[i].isLast = false;
			filters[i].showDelButton = true;		
		}
		if (filters.size() > 0) {
			filters[filters.size() - 1].isLast = true;
			filters[filters.size() - 1].showDelButton = false;
		}
	}

	public Pagereference add() { // Add new filter line
		//system.debug('*********** Filters ********>>>> '+filters);
		FilterWrapper newFilter = new FilterWrapper();
		errMsg = '';
		if (FieldNames.size() > 0) {
			newFilter.fieldName = FieldNames[0].getValue();
		}
		if (maxFilters_num <= 10) {
			filters.add(newFilter);
			maxFilters_num ++;
		} else {
			errMsg = 'Filters limit exhausted.';
		}
		resetIndexes();
		getConditions();
		//system.debug('*********** Filters ********>>>> '+filters);
		return null;
	}

	public void remove(String p_id) { // Remove filter line
		Integer filterWrapper_forDelete;
		FilterWrapper curFilterWrapper;
		errMsg = '';
		maxFilters_num --;
		for(Integer i = 0; i < filters.size(); i++) {
			curFilterWrapper = filters.get(i);
			if (curFilterWrapper.Id == p_Id)
				filterWrapper_forDelete = i;
		}
		filters.remove(filterWrapper_forDelete);
		resetIndexes();
		getConditions();
	}

	private void initConditions() {
		Conditions = new List<SelectOption>();

		Conditions.add( new SelectOption('AND', 'AND'));
		Conditions.add( new SelectOption('OR', 'OR'));
	}
	
	/* Getting result filters */
	public String getConditions() {
		dealResultFilter = '';
		targetResultFilter = '';
		acquirorResultFilter = '';
		drpResultFilter = '';
		pbiResultFilter = '';
		FilterWrapper curFilterWrapper;
		for(integer i=0; i < filters.size(); i++) {
			if(filters[i].value != null && filters[i].value != '') {
				
				/* Sorting data in different result fields */
				if (dealResultFilter != '') {
					dealResultFilter = '('+dealResultFilter+') '+filters[i-1].condition+' '+compileStatment('Client__r.Name',filters[i]);
				} else {
					dealResultFilter += compileStatment('Client__r.Name',filters[i]);
				}
				if (targetResultFilter != '') {
					targetResultFilter = '('+targetResultFilter+') '+filters[i-1].condition+' '+compileStatment('Target__c',filters[i]);
				} else {
					targetResultFilter += compileStatment('Target__c',filters[i]);
				}
				if (acquirorResultFilter != '') {
					acquirorResultFilter = '('+acquirorResultFilter+') '+filters[i-1].condition+' '+compileStatment('Acquiror__c',filters[i]);
				} else {
					acquirorResultFilter += compileStatment('Acquiror__c',filters[i]);
				}
				if (drpResultFilter != '') {
					drpResultFilter = '('+drpResultFilter+') '+filters[i-1].condition+' '+compileStatment('Company__r.Name',filters[i]);
				} else {
					drpResultFilter += compileStatment('Company__r.Name',filters[i]);
				}
				if (pbiResultFilter != '') {
					pbiResultFilter = '('+pbiResultFilter+') '+filters[i-1].condition+' '+compileStatment('TargetBuyer__r.Name',filters[i]);
				} else {
					pbiResultFilter += compileStatment('TargetBuyer__r.Name',filters[i]);
				}
			}
		}
		return null;
	}
	
	/* Quoting data & compile to normal part of SOQL */
	//private String compileStatment(FilterWrapper curFW) {
	public String compileStatment(String field,FilterWrapper curFW) {
		String result = '';
		if(curFW.operator == 'equals') {
			result = field + ' LIKE ' + Quote(String.escapeSingleQuotes(curFW.value).replace('*','%'));
		}
		if(curFW.operator == 'notEqual') {
			result = field + ' != ' + Quote(String.escapeSingleQuotes(curFW.value).replace('*','%'));
		}
		if(curFW.operator == 'startsWith') {
			result = field + ' LIKE ' + Quote(String.escapeSingleQuotes(curFW.value)+'%');
		}
		if(curFW.operator == 'contains') {
			result = field +  ' LIKE ' + Quote('%' + String.escapeSingleQuotes(curFW.value).replace('*','%') + '%');
			  
		}
		/*if(curFW.operator == 'notContain') {
			result = field +  ' NOT IN ' + '('+Quote(String.escapeSingleQuotes(curFW.value))+')';
		}*/
		
		return result;	
	}
	
	private String Quote(String p_str) { //Quoting data
		p_str = '\'' + p_str +  '\''; 
		return p_str;
	}

	
	public class FilterWrapper {
		public String Id             {get;set;}
		public String fieldName      {get;set;}
		public String operator       {get;set;}
		public String value          {get;set;}
		public String condition      {get;set;}
		public Boolean isLast        {get;set;}
		public Boolean showDelButton {get;set;}
		public Boolean isDateType    {get;set;}
		public FilterWrapper() {
			fieldName = '';
			operator  = '';
			value     = '';
			condition = '';
			isLast    = false;
			showDelButton = false;
			isDateType = false;
		}
		public List<SelectOption> getOperators() {
			List<SelectOption> operators = new List<SelectOption>();
			operators.add( new SelectOption('contains', 'contains'));
			//operators.add( new SelectOption('notContain', 'not contain'));
			operators.add( new SelectOption('equals', 'equals'));
			operators.add( new SelectOption('notEqual', 'not equal'));
			return operators;
		}
	}
}