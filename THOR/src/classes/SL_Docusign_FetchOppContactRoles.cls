global class SL_Docusign_FetchOppContactRoles 
{
	webservice static List<Contact_Role__c> fetchContactRoles(String OpportunityId)
	{
		List<Contact_Role__c> lstContactRoles = [Select FirstName__c, LastName__c, Email__c from Contact_Role__c where Opportunity__c=: OpportunityId];
		if(lstContactRoles !=null)
			return lstContactRoles;
		return null;
	}
}