/**
* \arg ClassName      : SL_Company_List_Member_Handler
* \arg CreatedOn      : 8/30/2013
* \arg LastModifiedOn : 10/Feb/2015
* \arg ModifiedBy     : Sandeep
* \arg Description    : This is handler class for Company list member
*/

public class SL_Company_List_Member_Handler 
{
	/* Start - Constructor*/
	public SL_Company_List_Member_Handler()
	{
		/* Do nothing */ 
	}
     /* End - Constructor*/
    
    /*!
        * MethodName : onBeforeInsert
        * param      : List of inserted Company List Members
        * Description: This method is called before insertion of the company list member.
    */ 
	public void onBeforeInsert(List<Company_List_Member__c> lstCLMs)
	{           
        // Get a list of Company List Ids
        Set<Id> setCLIds = new Set<Id>();
        for(Company_List_Member__c clm:lstCLMs)
        {
            setCLIds.add(clm.Company_List__c);
        }
        
        // Query all the Banker Ids for all the Company Lists.
        Map<Id,Company_List__c> mapCLId_CL = new Map<Id,Company_List__c>([SELECT Id,Banker_Name__c FROM Company_List__c WHERE Id IN:setCLIds]);
       
        // Set the CLM Banker fields based on the CL Banker field.
        for(Company_List_Member__c clm :lstCLMs)
        {
            clm.Banker__c = mapCLId_CL.get(clm.Company_List__c).Banker_Name__c;
        }
    }
    
    // Start - Sandeep
    
    /*!
        * MethodName : onAfterInsert
        * param      : List of inserted Company List Members
        * Description: This method is called after insertion of the Company List Member.
    */
    public void onAfterInsert(List<Company_List_Member__c> lstCompanyListMemberMembers)
    {                                                                       
        /* Calling function to perform the creation of a string of all Company List Members in list. */
        rollupCompanyListMemberToCompany(lstCompanyListMemberMembers, null);
    }
    
     /*!
        * MethodName : onAfterUpdate
        * param      : map of new and old Company List Members.
        * Description: This method is called after updation of the Company List Member.
    */
    public void onAfterUpdate(Map<Id,Company_List_Member__c> mapOldIdToCompanyListMember,Map<Id,Company_List_Member__c> mapNewIdToCompanyListMember)
    {
    	List<Company_List_Member__c> lstCompanyListMember = new List<Company_List_Member__c>();
    	List<Company_List_Member__c> lstOldCompanyListMember = new List<Company_List_Member__c>();
    	
    	for(Id objCLM : mapNewIdToCompanyListMember.keyset())
    	{
    			lstCompanyListMember.add(mapNewIdToCompanyListMember.get(objCLM));	
    	}
    	
    	for(Id objCLM : mapOldIdToCompanyListMember.keyset())
    	{
    			lstOldCompanyListMember .add(mapOldIdToCompanyListMember.get(objCLM));	
    	}
    	rollupCompanyListMemberToCompany(lstCompanyListMember, lstOldCompanyListMember);	
    }
    
    /*!
        * MethodName : onAfterDelete
        * param      : List of deleted  Company List Members.
        * Description: This method is called after deletion of the Company List Member.
    */
    public void onAfterDelete(List<Company_List_Member__c> lstCompanyListMembers)
    {    
        /* Calling function to perform the creation of a string of all Company List Members in list.*/ 
       rollupCompanyListMemberToCompany(lstCompanyListMembers,null);
    }
    
    /*!
        * MethodName : onAfterUnDelete
        * param      : List of undeleted Company List Members.
        * Description: This method is called after undelete of the Company List Member.
    */
    public void onAfterUnDelete(List<Company_List_Member__c> lstCompanyListMembers)
    {
    	rollupCompanyListMemberToCompany(lstCompanyListMembers, null);
    }
    
    /*!
        * MethodName : rollupCompanyListMemberToCompany
        * param      : List of Company List Members
        * Description: This method creates a comma separated string of all the bankers related to Company List Members
    */
    private void rollupCompanyListMemberToCompany(List<Company_List_Member__c> lstCompanyListMembers, List<Company_List_Member__c> lstOldCompanyListMembers)
    {
    	Set<Id> setAccountIds = new Set<Id>();	
        List<Account> lstAccountToUpdate = new List<Account>();	
    	Map<Id, String> mapAccocuntIdToLstCLMName = new Map<Id,String>();
    	
    	/* Iterating over the new list to get set of all new Accounts. */
        for(Company_List_Member__c objCompanyListMember : lstCompanyListMembers)
                setAccountIds.add(objCompanyListMember.Company__c);
        
        /* Iterating over the old list to get set of all new Accounts. */
        if(lstOldCompanyListMembers != null)
        {
	        for(Company_List_Member__c objCompanyListMember : lstOldCompanyListMembers)
				setAccountIds.add(objCompanyListMember.Company__c);
        }
        
    	/* Iterating over list of Deal Team Members to create a string of Deal Team in comma separated fashion */ 
        for(Company_List_Member__c objCLMember : [SELECT Company_List_Type__c, Company_List_Status__c, Company_Category__c, Company__c,
        													   Banker__r.First_Name__c, Banker__r.Last_Name__c , Banker__r.Title__c 
        										    FROM Company_List_Member__c 
                                                   WHERE Company_List_Type__c='Coverage List' 
                                             	     AND Company_List_Status__c = 'Active'
                                             	     AND Company_Category__c = '6 - Private Funds Advisory' 
                                             	     AND Company__c IN: setAccountIds ORDER By Banker__r.Title__c, Banker__r.Last_Name__c])
        {
			if(!mapAccocuntIdToLstCLMName.containskey(objCLMember.Company__c))
			{
				if(objCLMember.Banker__r.Last_Name__c != null && objCLMember.Banker__r.Last_Name__c != '' && objCLMember.Banker__r.First_Name__c != null && objCLMember.Banker__r.First_Name__c != '')
					mapAccocuntIdToLstCLMName.put(objCLMember.Company__c, objCLMember.Banker__r.First_Name__c.trim().substring(0, 1) + '. ' + objCLMember.Banker__r.Last_Name__c);
				else if(objCLMember.Banker__r.Last_Name__c != null)
        			mapAccocuntIdToLstCLMName.put(objCLMember.Company__c, (objCLMember.Banker__r.First_Name__c !=null && objCLMember.Banker__r.First_Name__c != '') ? objCLMember.Banker__r.First_Name__c.trim().substring(0, 1) + '. ' + objCLMember.Banker__r.Last_Name__c : objCLMember.Banker__r.Last_Name__c);
        		else if(objCLMember.Banker__r.First_Name__c != null && objCLMember.Banker__r.First_Name__c != '')
        			mapAccocuntIdToLstCLMName.put(objCLMember.Company__c, objCLMember.Banker__r.First_Name__c.trim().substring(0, 1)+' ');
			}
        	else
        	{
        		if(objCLMember.Banker__r.Last_Name__c != null && objCLMember.Banker__r.Last_Name__c != '' && objCLMember.Banker__r.First_Name__c != null && objCLMember.Banker__r.First_Name__c != '')
        			mapAccocuntIdToLstCLMName.put(objCLMember.Company__c, mapAccocuntIdToLstCLMName.get(objCLMember.Company__c) + ', ' + objCLMember.Banker__r.First_Name__c.trim().substring(0, 1) + '. ' + objCLMember.Banker__r.Last_Name__c);
        		else if(objCLMember.Banker__r.Last_Name__c != null && objCLMember.Banker__r.Last_Name__c != '')
					mapAccocuntIdToLstCLMName.put(objCLMember.Company__c, mapAccocuntIdToLstCLMName.get(objCLMember.Company__c) + ', ' + 
											  ((objCLMember.Banker__r.First_Name__c != null && objCLMember.Banker__r.First_Name__c != '')  ? objCLMember.Banker__r.First_Name__c.trim().substring(0, 1) + '. ' + objCLMember.Banker__r.Last_Name__c : objCLMember.Banker__r.Last_Name__c));
				else if(objCLMember.Banker__r.First_Name__c != null && objCLMember.Banker__r.First_Name__c != '')
					mapAccocuntIdToLstCLMName.put(objCLMember.Company__c, mapAccocuntIdToLstCLMName.get(objCLMember.Company__c)+ ', ' + objCLMember.Banker__r.First_Name__c.trim().substring(0, 1)+' ');
        	}								  
        }
    	
    	/* Iterating over the set of account Ids */
        for(Id objAccountId : setAccountIds)
        {
        	if(mapAccocuntIdToLstCLMName.containskey(objAccountId))
        		lstAccountToUpdate.add(new Account(Id = objAccountId, PFA_Coverage__c = String.valueOf(mapAccocuntIdToLstCLMName.get(objAccountId))));
        	else
        		lstAccountToUpdate.add(new Account(Id = objAccountId, PFA_Coverage__c = null)); 
        }
        
        if(!lstAccountToUpdate.isEmpty())
            update lstAccountToUpdate;
    }
    // End - Sandeep
}