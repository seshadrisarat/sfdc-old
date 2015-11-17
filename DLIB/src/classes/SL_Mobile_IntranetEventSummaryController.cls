public with sharing class SL_Mobile_IntranetEventSummaryController extends ComponentControllerBase   {
	
	
	public class InfoResultWrapper {
		public Boolean hasMoreRecords;
		public List<Intranet_Event__c> records; 
		
		public InfoResultWrapper(List<Intranet_Event__c> records, Boolean hasMoreRecords) {
			this.records = records;
			this.hasMoreRecords = hasMoreRecords;
		}
	}

	@RemoteAction
	public static InfoResultWrapper getData(String widgetInstanceName, Integer offset, String departmentId, String chatterTopicId) {
		SL_Mobile_IntranetEventSummary w = (SL_Mobile_IntranetEventSummary)WidgetRepository.getWidgetInstanceById(widgetInstanceName);
		
		w.loadRecords(offset * w.numRecordstodisplay, departmentId, chatterTopicId);
		
		return new InfoResultWrapper( w.loadedItems, w.hasMoreRecords );
	}
	
	
	
	//Function for implementing base class for this Controller.
	public SL_Mobile_IntranetEventSummary getMyImpl() 
	{
		return (SL_Mobile_IntranetEventSummary)CompImpl; 
	} 
	public String getTitle() {
		return ((SL_Mobile_IntranetEventSummary)compImpl).strHeading;
	}
	
	/**
	** build widget configuration json
	**/
	public String getConfigurationJSON() {
		
		SL_Mobile_IntranetEventSummary impl = (SL_Mobile_IntranetEventSummary)compImpl;
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		
		gen.writeFieldName('fieldsData');
  		gen.writeObject(impl.lstFieldWrapper);
  		gen.writeBooleanField('showFieldLabel', impl.showFieldLabel);
  		gen.writeBooleanField('departmentFiltering', impl.departmentFiltering);
  		gen.writeBooleanField('chatterTopicFiltering', impl.chatterTopicFiltering);
  		gen.writeStringField('defaultDepartmentId', impl.deptId == null ? '' : impl.deptId);	
		
		gen.writeEndObject();
		
		return gen.getAsString();
	}

}