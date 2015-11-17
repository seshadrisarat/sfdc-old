public with sharing class SL_ctrl_VendorScheduleDetail {

	public Schedule__c schedule {get;set;}
	
	public SL_ctrl_VendorScheduleDetail() {
		this.schedule = getSchedule();
	}

	private List<Schema.FieldSetMember> getDetailFields() {
        return SObjectType.Schedule__c.FieldSets.FAEF_Vendor_Schedule_Detail.getFields();
    }

    private List<Schema.FieldSetMember> getEconomicsFields() {
    	return SObjectType.Schedule__c.FieldSets.FAEF_Vendor_Schedule_Economics.getFields();
    }

	private Schedule__c getSchedule(){
		String scheduleId = ApexPages.currentPage().getParameters().get('scheduleId');

		String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getDetailFields()) {
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : this.getEconomicsFields()){
        	query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Schedule__c WHERE Id =: scheduleId';
        return Database.query(query);
	}

}