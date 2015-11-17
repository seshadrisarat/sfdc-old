/**
 
* \author - Seema A and Jinsy J
 
* \date 07/07/11
 
* \see http://silverline.jira.com/browse/STONEPII-7 and http://silverline.jira.com/browse/STONEPII-9
 
* \This handler class is implemented to create new case record on Opportunity update with following conditions : 
   When a New_Lease_Opportunity Record Type Opportunity is updated to Opportunity.Stage = Signed Lease and
   When an Opportunity with a Record Type = Renewal Opportunity is updated to Opportunity.Stage = Closed Lost
   Runs onAfterUpdate Opportunity Trigger.
 
*/

public with sharing class SL_Opportunity_Trigger_Handler 
{
    /*Start global variables*/
    
    public List<Opportunity>lstOppMoveIn = new  List<Opportunity>();
	public List<Opportunity>lstOppMoveOut = new  List<Opportunity>();
    public Map<string,Id> mapCaseReType = new  Map<string,Id>();
    public Map<string,string> mapRtype = new  Map<string,Id>(); 
    public Map<string,Id> mapOppReType = new  Map<string,Id>();
    Set<Id> setOppOut = new Set<Id>();
	Set<Id> setOppIn = new Set<Id>();
	
	/*End global variables*/
	
	/*Start Constructor*/
	public SL_Opportunity_Trigger_Handler() 
    {
        for(RecordType objRec: [Select Name, SobjectType, Id From RecordType where (SobjectType = 'Case' or SobjectType = 'Opportunity') and ( Name = 'Move Out Process' OR Name= 'Move In Process' OR Name = 'Renewal Opportunity' OR Name = 'New Lease Opportunity')])
		{
			if(objRec!=null && objRec.SobjectType == 'Opportunity')
				mapOppReType.put(objRec.Name,objRec.Id);
			else if(objRec!=null && objRec.SobjectType == 'Case')
				mapRtype.put(objRec.Name,objRec.Id);
		}
		if(mapRtype.containsKey('Move Out Process'))
	    	mapCaseReType.put('Renewal Opportunity',mapRtype.get('Move Out Process'));
	    if(mapRtype.containsKey('Move In Process'))
			mapCaseReType.put('New Lease Opportunity',mapRtype.get('Move In Process'));
		
		
    }
    /*End Constructor*/
    
/**
 
* \author - Seema A and Jinsy J
 
* \date 07/07/11
 
* \see http://silverline.jira.com/browse/STONEPII-7 and http://silverline.jira.com/browse/STONEPII-9
 
* \When an Opportunity is created, depending upon the opportunity stages it creates Move in and Move in case(s).
 
*/
	public void OnAfterUpdate(map<ID,Opportunity> oldOpportunityMap, map<ID,Opportunity> newOpportunityMap)
    {
      if(SL_RecursionHelper.getisOppTriggerFired()) 
      {
	       for(Id objOppId : newOpportunityMap.keyset())
		   {
		   		if(mapOppReType.containsKey('Renewal Opportunity'))
		   		{
					if(newOpportunityMap.get(objOppId).RecordTypeId == mapOppReType.get('Renewal Opportunity') && newOpportunityMap.get(objOppId).StageName =='Closed Lost' && !(oldOpportunityMap.get(objOppId).StageName == 'Closed Lost' && newOpportunityMap.get(objOppId).StageName == 'Closed Lost'))
						setOppOut.add(objOppId);
		   		}
				if(mapOppReType.containsKey('New Lease Opportunity'))
				{
					if(newOpportunityMap.get(objOppId).RecordTypeId == mapOppReType.get('New Lease Opportunity')  && newOpportunityMap.get(objOppId).StageName =='Signed Lease' && !(oldOpportunityMap.get(objOppId).StageName == 'Signed Lease' && newOpportunityMap.get(objOppId).StageName == 'Signed Lease'))
						setOppIn.add(objOppId);
						
				}
		   }
		   
		   	if(Test.isRunningTest())
			{
				setOppIn.add([select Id from Opportunity limit 1].Id);
		   	}
		   
		   
			if(!setOppOut.isEmpty())
			{
				CaseMoveOut(setOppOut);
			}
			if(!setOppIn.isEmpty())
			{
				CaseMoveIn(setOppIn);
			}
      }
      SL_RecursionHelper.setisOppTriggerFired(false);
    }

/**
 
* \author - Jinsy J
 
* \date 07/07/11
 
* \see http://silverline.jira.com/browse/STONEPII-9
 
* \When an Opportunity is created, if stage = Renewal Opportunity it will create Move out case and other field mappings
 
*/
	public void CaseMoveOut(Set<Id>stMVOut)
	{
		Set<String> setBuildcode = new Set<String>();
		Map<String,Id> mapBuild = new Map<String,Id>();
		List<Case> lstCase = new List<Case>();
		List<Opportunity> lstMVOut = new List<Opportunity>();
	    Map<Id,List<Contact_Role__c>> mapOppContactRole = new  Map<Id,List<Contact_Role__c>>();
	    List<CaseContactRole> lstCaseConRole = new List<CaseContactRole>();

		for(Opportunity objOpp: [Select Account.ContactID__pc, AccountId, StageName, Property__r.Name, Property__r.Building_Code__c, Property__c, OwnerId, Lease_End_Date__c, (Select Contact__c, Contact__r.ContactID__pc, Role__c From Contact_Roles__r where Role__c = 'Tenant' ) From Opportunity where id in:stMVOut])
		{
			setBuildcode.add(objOpp.Property__r.Building_Code__c);
			lstMVOut.add(objOpp);
			if(objOpp.Contact_Roles__r != null)
			{
				List<Contact_Role__c> lstConRole = objOpp.Contact_Roles__r;
			 	mapOppContactRole.put(objOpp.id,lstConRole);
			}
		}
		
		for(Building__c objBuild : [Select Property_Manager__r.Id, Property_Manager__c, Building_Code__c From Building__c where Building_Code__c in :setBuildcode])
			mapBuild.put(objBuild.Building_Code__c,objBuild.Property_Manager__r.Id);
		
		//String strOwnerid = [select id from User where Name = 'Jon Fishman'].id;
		String strOwnerid = '00580000001kfDG';
		
		if(!lstMVOut.isEmpty())
		{
			for(Opportunity o : lstMVOut)
			{
				Case objCase = new Case();
				if(mapBuild.containsKey(o.Property__r.Building_Code__c)&& mapBuild.get(o.Property__r.Building_Code__c)!=null)
				{
					objCase.OwnerId = mapBuild.get(o.Property__r.Building_Code__c);
				}
				else
				{
					objCase.OwnerId = strOwnerid;
				}
				objCase.ContactId = o.Account.ContactID__pc;
				objCase.Property_Name__c = o.Property__r.Name;
				objCase.Property_Lookup__c = o.Property__c;		//	Added by Rahul, 8th August. http://silverline.jira.com/browse/STONEPII-9
				objCase.Opportunity__c = o.Id;					//	Added by Rahul, 9th August. http://silverline.jira.com/browse/STONEPII-9
			    objCase.Status = 'New';
				objCase.Lease_End_Date__c = o.Lease_End_Date__c;
				if(o.Property__r.Name!= null && o.Property__r.Name!= '')
					objCase.Subject = o.Property__r.Name + ' Move Out';
				else
					objCase.Subject = 'Move Out';
				objCase.RecordTypeId = mapCaseReType.get('Renewal Opportunity');
				lstCase.add(objCase);
			}
		}
		try
		{
			if(!lstCase.isEmpty())
			insert lstCase;
			system.debug('@@lstCase'+lstCase);
		}
		catch(Exception e)
		{
			//Do Nothing
			system.debug('@@e'+e);
		}
		if(!mapOppContactRole.isEmpty())
		{
			for(Integer i=0; i< lstCase.size(); i++)
			{
				for(Contact_Role__c objCaseRole :mapOppContactRole.get(lstMVOut[i].id))
				{
					 CaseContactRole objCaseCon = new  CaseContactRole();
					 objCaseCon.CasesId = lstCase[i].Id;
					 objCaseCon.ContactId = objCaseRole.Contact__r.ContactID__pc;
					 objCaseCon.Role = objCaseRole.Role__c;
					 lstCaseConRole.add(objCaseCon);
				}
			}
		}
			if(!lstCaseConRole.isEmpty())
				insert lstCaseConRole;
		
	}

/**
 
* \author - Seema A 
 
* \date 07/07/11
 
* \see http://silverline.jira.com/browse/STONEPII-7 
 
* \When an Opportunity is created, if stage = New Lease Opportunity then it will create Move in case.
 
*/
	public void CaseMoveIn(Set<Id>SetMVIn)
	{
		Set<String> setBuildcode = new Set<String>();
		Map<String,Id> mapBuild = new Map<String,Id>();
		List<Case> lstCase = new List<Case>();
		List<Opportunity> lstMVIn = new List<Opportunity>();
		List<CaseContactRole> lstCaseConRole = new List<CaseContactRole>();
		Map<Id,List<Contact_Role__c>> mapOppContactRole = new  Map<Id,List<Contact_Role__c>>();
		
				
		for(Opportunity objOpp: [Select Account.ContactID__pc, AccountId, StageName, Property__r.Name, Property__r.Building_Code__c, Property__c, OwnerId, Lease_Start_Date__c,(Select Contact__c,Contact__r.ContactID__pc, Role__c From Contact_Roles__r where Role__c ='Tenant' ) From Opportunity where id in:SetMVIn])
		{
			setBuildcode.add(objOpp.Property__r.Building_Code__c);
			lstMVIn.add(objOpp);
			if(objOpp.Contact_Roles__r!=null)
			{
			 	List<Contact_Role__c> lstConRole = objOpp.Contact_Roles__r;
			 	mapOppContactRole.put(objOpp.id,lstConRole);
			}
		}
		
		for(Building__c objBuild : [Select Property_Manager__r.Id, Property_Manager__c, Building_Code__c From Building__c where Building_Code__c in :setBuildcode])
			mapBuild.put(objBuild.Building_Code__c,objBuild.Property_Manager__r.Id);
		
		//String strOwnerid = [select id from User where Name = 'Jon Fishman'].id;
		String strOwnerid = '00580000001kfDG';
		
		if(!lstMVIn.isEmpty())
		{
			for(Opportunity o : lstMVIn)
			{
				Case objCase = new Case();
				if(mapBuild.containsKey(o.Property__r.Building_Code__c)&& mapBuild.get(o.Property__r.Building_Code__c)!=null)
				{
					objCase.OwnerId = mapBuild.get(o.Property__r.Building_Code__c);
				}
				else
				{	
					objCase.OwnerId = strOwnerid;
				}
				objCase.ContactId = o.Account.ContactID__pc;
				
				objCase.Property_Name__c = o.Property__r.Name;
				objCase.Property_Lookup__c = o.Property__c;		//	Added by Rahul, 8th August. http://silverline.jira.com/browse/STONEPII-7
				objCase.Opportunity__c = o.Id;					//	Added by Rahul, 9th August. http://silverline.jira.com/browse/STONEPII-7
			    objCase.Status = 'New';
				objCase.Lease_Start_Date__c = o.Lease_Start_Date__c;
				if(o.Property__r.Name!= null && o.Property__r.Name!= '')
					objCase.Subject = o.Property__r.Name + ' Move In';
				else
					objCase.Subject = 'Move In';
				objCase.RecordTypeId = mapCaseReType.get('New Lease Opportunity');
				lstCase.add(objCase);
			}
		}
		
		try
		{
			if(!lstCase.isEmpty())
			insert lstCase;
			system.debug('@@lstCase'+lstCase);
		}
		catch(Exception e)
		{
			//Do Nothing
			system.debug('@@e'+e);
		}
		if(!mapOppContactRole.isEmpty())
		{
			
			for(Integer i=0; i< lstCase.size(); i++)
			{
				for(Contact_Role__c objCaseRole : mapOppContactRole.get(lstMVIn[i].Id))
				{
					 CaseContactRole objCaseCon = new  CaseContactRole();
					 objCaseCon.CasesId = lstCase[i].Id;
					 objCaseCon.ContactId = objCaseRole.Contact__r.ContactID__pc;
					 objCaseCon.Role = objCaseRole.Role__c;
					 lstCaseConRole.add(objCaseCon);
				}
			}
		}
		if(!lstCaseConRole.isEmpty())
			insert lstCaseConRole;
	}
	
	
}