public with sharing class SL_UtilityWrappers {
	
	public class FieldSetDescribe
	{
		public String fieldAPIName	{	get;set;	}//<! Field API Name.
		public String fieldLabel	{	get;set;	}//<! Field label.
		public String fieldType		{	get;set;	}
		public Boolean isFilter		{	get;set;	}	//To check field is filterable
		
		
		/* Start Constructor of Inner class*/
		public FieldSetDescribe(String fieldAPIName, String fieldLabel, String fieldType)
		{
			this.fieldAPIName = fieldAPIName;
			this.fieldLabel = fieldLabel;
			this.fieldType = fieldType;
		}
		/* End */
		
		//*#*
		//constructor for maintaing isFilterable field
		public FieldSetDescribe(String fieldAPIName, String fieldLabel, String fieldType, Boolean isFilter)
		{
			this.fieldAPIName = fieldAPIName;
			this.fieldLabel = fieldLabel;
			this.fieldType = fieldType;
			this.isFilter = isFilter;
		}
		
	}
	
	public class FieldSetResults
	{
		public String strQuery = '';
		public List<FieldSetDescribe> lstFieldWrapper = new List<FieldSetDescribe>();
		
		public FieldSetResults(String prmQuery, List<FieldSetDescribe> prmFieldWrapper)
		{
			strQuery = prmQuery;
			lstFieldWrapper = prmFieldWrapper;
		}
	}
}