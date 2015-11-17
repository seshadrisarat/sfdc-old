public with sharing class SL_Mobile_IntranetNotificationController extends ComponentControllerBase {
	
	/* Wrapper Class */
	public class InfoResultWrapper {
		
		public Boolean hasMoreRecords;
		public List<Notification__c> records; 					// List of Notification Object Records
		
		public InfoResultWrapper(List<Notification__c> records, Boolean hasMoreRecords) {
			this.records = records;
			this.hasMoreRecords = hasMoreRecords;
		}
	}

	@RemoteAction
	public static InfoResultWrapper getData(String widgetInstanceName, Integer offset, String departmentId, String chatterTopicId) {
		
		SL_Mobile_IntranetNotification w = (SL_Mobile_IntranetNotification)WidgetRepository.getWidgetInstanceById(widgetInstanceName);
		
		w.loadRecords(offset * w.numRecordstodisplay, departmentId, chatterTopicId);  
		
		return new InfoResultWrapper( w.loadedItems, w.hasMoreRecords );
	}
	
	public String getTitle() {
		return ((SL_Mobile_IntranetNotification)compImpl).strHeading;
	}
	      
	/**
	** build widget configuration json
	**/
	public String getConfigurationJSON() {
		
		SL_Mobile_IntranetNotification impl = (SL_Mobile_IntranetNotification)compImpl;
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		
		gen.writeFieldName('fieldsData');
  		gen.writeObject(impl.lstFieldWrapper);
  		gen.writeBooleanField('showFieldLabel', impl.showFieldLabel);
  		gen.writeBooleanField('DepartmentFiltering', impl.DepartmentFiltering);
  		gen.writeBooleanField('ChatterTopicFiltering', impl.ChatterTopicFiltering);
  		gen.writeStringField('defaultDepartmentId', impl.deptId == null ? '' : impl.deptId);	
		
		gen.writeEndObject();
		
		return gen.getAsString();
	}

}