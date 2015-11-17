public class DepartmentSpecification implements IVisibilitySpecification {
		
	private String departmentId;
	
	public DepartmentSpecification(String departmentId) {
		this.departmentId = departmentId;
	}
		
	private Boolean satisfiedByGeneric(Boolean forAll, String selection) {
		if(departmentId=='All')
			return !String.isEmpty(selection);
		else if(String.isEmpty(departmentId))
			return String.isEmpty(selection);
		else 
			return (forAll || (!String.isEmpty(selection) && (new Set<String>(selection.split(';'))).contains(departmentId)));
		
	}
		
	/* --Method used for Key Contact widget to handle use case when none is selected in department widget*/
	private Boolean satisfiedByGeneric(Boolean forAll, String selection, Boolean checkWhenNoDept){
		if(departmentId=='All')
			return !String.isEmpty(selection);
		else if(String.isEmpty(departmentId))
			return checkWhenNoDept;
		else 
			return (forAll || (!String.isEmpty(selection) && (new Set<String>(selection.split(';'))).contains(departmentId)));
	}
	
	
	/*----Method called from Key Contact widget*/
	public Boolean satisfiedBy(User candidate, Boolean checkWhenNoDept) {
		return satisfiedByGeneric(candidate.All_Departments__c, candidate.Selected_Department_Ids__c, checkWhenNoDept);
	} 
	
	public Boolean satisfiedBy(SObject candidate) {
		return satisfiedByGeneric(
			(Boolean)candidate.get(candidate instanceOf User ? 'All_Departments__c' : 'For_All_Departments__c'), 
			(String)candidate.get('Selected_Department_Ids__c')
		);
	} 
}