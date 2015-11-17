/**
* Test methods are in Test_Multifilter.cls
**/
public with sharing class Multifilter_controller {
	
	public String columnUnselectedString       {get;set;}
	public String columnSelectedString         {get;set;}
	public String columnSelectedString_forSave {get;set;}

	public String orderForTableData            {get;set;}
	
	public Boolean showEditColumnsWindow {get;set;}
	
	public Multifilter_filter user_filters { get; set; } 
	
	public String curTouchId {get;set;}
	
	private List<Schema.DisplayType> columnFieldTypes;

	public String unselectedColumnLabelsStr {get;set;}
	public String unselectedColumnNamesStr {get;set;}
	public String selectedColumnLabelsStr {get;set;}
	public String selectedColumnNamesStr {get;set;}
	
	public List<MyRowClass> curUnexistingColumnData {get;set;}
	public List<MyRowClass> curExistingColumnData   {get;set;}
	
	
	public Multifilter_controller() {
		curTouchId = ApexPages.currentPage().getParameters().get('touchId'); 
		
		user_filters  = new Multifilter_filter();
	}

	// ==================================================================
	public Pagereference removeFilter() {
		String fidx = ApexPages.currentPage().getParameters().get('fidx');
		try {
			user_filters.remove( fidx );
		} catch(Exception e) {
			//message(e.getMessage());
		}
		return null;
	}
	
	public Pagereference addFilter() {
		user_filters.add();
		return null;	
	}
	
	public class MyRowClass {
		public String Id            {get;set;}
		public Boolean checkboxBool {get;set;}
		public List<String> rowList {get;set;}
		public String status        {get;set;}
		public MyRowClass() {
			checkboxBool = false;
		}
	}
}