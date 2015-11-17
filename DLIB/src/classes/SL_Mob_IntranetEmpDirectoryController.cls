public with sharing class SL_Mob_IntranetEmpDirectoryController extends ComponentControllerBase {
	
	
	public class InfoResultWrapper {
		public Boolean hasMoreRecords;
		public List<User> records; 
		
		public InfoResultWrapper(List<User> records, Boolean hasMoreRecords) {
			this.records = records;
			this.hasMoreRecords = hasMoreRecords;
		}
	}

	@RemoteAction
	public static InfoResultWrapper getData(String widgetInstanceName, Integer offset, String departmentId, String chatterTopicId) {
		SL_Mobile_IntranetEmployeeDirectory w = (SL_Mobile_IntranetEmployeeDirectory)WidgetRepository.getWidgetInstanceById(widgetInstanceName);
		
		w.loadRecords(offset * w.numRecordstodisplay, departmentId, chatterTopicId);
		
		return new InfoResultWrapper( w.loadedItems, w.hasMoreRecords );
	}
	
	
	
	//Function for implementing base class for this Controller.
	public SL_Mobile_IntranetEmployeeDirectory getMyImpl() 
	{
		return (SL_Mobile_IntranetEmployeeDirectory)CompImpl; 
	} 
	public String getTitle() {
		return ((SL_Mobile_IntranetEmployeeDirectory)compImpl).strHeading;
	}
	
	/**
	** build widget configuration json
	**/
	public String getConfigurationJSON() {
		
		SL_Mobile_IntranetEmployeeDirectory impl = (SL_Mobile_IntranetEmployeeDirectory)compImpl;
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		
		gen.writeFieldName('fieldsData');
  		gen.writeObject(impl.lstFieldWrapper);
  		gen.writeBooleanField('showFieldLabel', impl.showFieldLabel);
  		gen.writeBooleanField('departmentfiltering', impl.departmentFiltering);
  		gen.writeStringField('defaultDepartmentId', impl.deptId == null ? '' : impl.deptId);	
		
		gen.writeEndObject();
		
		return gen.getAsString();
	}

}