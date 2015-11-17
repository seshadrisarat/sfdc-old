public with sharing class SL_Mobile_IntranetDocumentController extends ComponentControllerBase {
	
	/* Wrapper Class */
	public class InfoResultWrapper {
		
		public Boolean hasMoreRecords;
		public List<ContentVersion> records; 					// List of Notification Object Records
		
		public InfoResultWrapper(List<ContentVersion> records, Boolean hasMoreRecords) {
			this.records = records;
			this.hasMoreRecords = hasMoreRecords;
		}
	}

	@RemoteAction
	public static InfoResultWrapper getData(String widgetInstanceName, Integer offset, String strContentName, String departmentId) {

		SL_Mobile_IntranetDocument w = (SL_Mobile_IntranetDocument)WidgetRepository.getWidgetInstanceById(widgetInstanceName);
		
		w.loadRecords(offset * w.numRecordstodisplay, strContentName, departmentId); 
		   
		return new InfoResultWrapper( w.loadedItems, w.hasMoreRecords );
	}
	
	public String getTitle() {
		return ((SL_Mobile_IntranetDocument)compImpl).strHeading;
	}
	      
	/**
	** build widget configuration json
	**/
	public String getConfigurationJSON() {
		
		SL_Mobile_IntranetDocument impl = (SL_Mobile_IntranetDocument)compImpl;
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		
		gen.writeFieldName('fieldsData');
  		gen.writeObject(impl.lstFieldWrapper);
  		gen.writeBooleanField('showFieldLabel', impl.showFieldLabel);
  		gen.writeBooleanField('displayFilterLinks', impl.bDisplayFilterLinks);
  		gen.writeBooleanField('DepartmentFiltering', impl.DepartmentFiltering);
  		gen.writeStringField('defaultDepartmentId', impl.deptId == null ? '' : impl.deptId);	
		
		gen.writeEndObject();
		
		return gen.getAsString();
	}

}