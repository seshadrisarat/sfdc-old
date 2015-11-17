public with sharing class SL_IntranetCustomizableComponent 
{
	public String logoURL {get; set;}
	
	public SL_IntranetCustomizableComponent()
	{
		logoURL = '';
		
		for(SL_CustomizableComponent__c objCC : [SELECT Updated_Static_Resource_Name__c, Logo__c 
														FROM SL_CustomizableComponent__c 
														WHERE Default__c = false limit 1])
		{
			if(objCC.Logo__c != null && objCC.Logo__c != '')
				logoURL = '/servlet/servlet.ImageServer?id=' + objCC.Logo__c + '&oid=' + UserInfo.getOrganizationId();	
		}
	}

}