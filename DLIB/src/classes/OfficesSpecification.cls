public class OfficesSpecification implements IVisibilitySpecification {		
	private Set<String> allowedOffices;
	
	public OfficesSpecification(Set<String> allowedOffices) {
		this.allowedOffices = allowedOffices != null ? allowedOffices : new Set<String>(); 
	}
	
	private Boolean satisfiedByGeneric(String selection) {
		return ( !String.isEmpty(selection) && (new Set<String>(allowedOffices)).removeAll(selection.split(';')) );
	}

	public Boolean satisfiedBy(ContentVersion candidate) {
		return satisfiedByGeneric(candidate.Selected_Offices_Ids__c);		
	}
	
	public Boolean satisfiedBy(Intranet_Event__c candidate) {
		return satisfiedByGeneric(candidate.Selected_Offices_Ids__c);		
	}
	
	public Boolean satisfiedBy(Intranet_App__c candidate) {
		return satisfiedByGeneric(candidate.Selected_Office_Ids__c);		
	}

	public Boolean satisfiedBy(User candidate) {
		return satisfiedByGeneric(candidate.Selected_Offices_Ids__c);		
	}
	
	public Boolean satisfiedBy(SObject candidate) {
		return satisfiedByGeneric((String)candidate.get('Selected_Offices_Ids__c'));		
	}
}