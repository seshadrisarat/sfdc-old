public with sharing class SL_ExperimentalWidgetConroller extends ComponentControllerBase   {
	
	class InfoResultWrapper {
		public Boolean hasMoreRecords;
		public List<SObject> records; 
		
		public InfoResultWrapper(List<SObject> records, Boolean hasMoreRecords) {
			this.records = records;
			this.hasMoreRecords = hasMoreRecords;
		}
	}

	@RemoteAction
	public static InfoResultWrapper getData(String widgetInstanceName, Integer offset, String departmentId, String chatterTopicId) {		
		SL_ExperimentalWidget w = (SL_ExperimentalWidget)WidgetRepository.getWidgetInstanceById(widgetInstanceName);
		
		w.loadRecords(offset * w.numRecordstodisplay, departmentId, chatterTopicId);
		
		return new InfoResultWrapper( w.loadedItems, w.hasMoreRecords );
	}
	
	public String getTitle() {
		return ((SL_ExperimentalWidget)compImpl).strHeading;
	}
	
	/**
	** build widget configuration json
	**/
	public String getConfigurationJSON() {
		
		SL_ExperimentalWidget impl = (SL_ExperimentalWidget)compImpl;
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		
		gen.writeFieldName('fieldsData');
  		gen.writeObject(impl.lstFieldWrapper);
  		gen.writeBooleanField('showFieldLabel', impl.showFieldLabel);
  		gen.writeBooleanField('IsRespectToDepartmentVisibilityRules', impl.IsRespectToDepartmentVisibilityRules);
  		gen.writeBooleanField('IsRespectToChatterTopicVisibilityRules', impl.IsRespectToChatterTopicVisibilityRules);
  		gen.writeStringField('sObjectName', impl.sObjectName);
  		gen.writeStringField('defaultDepartmentId', impl.deptId == null ? '' : impl.deptId);	
		
		gen.writeEndObject();
		
		return gen.getAsString();
	}
}