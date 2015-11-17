/**
* \arg TriggerName    		: SL_RollUpDealTeamMembersToDealHandler
* \arg JIRATicket     		: MOELISSUPP-17,MOELISSUPP-34
* \arg CreatedOn      		: 21/01/2014
* \arg LastModifiedOn       : 25/09/2014
* \arg CreatededBy    		: Pankaj Ganwani
* \arg ModifiedBy     		: Pankaj Ganwani
* \arg Description    		: This class works as handler for trigger SL_RollUpDealTeamMembersToDeal
*/

public with sharing class SL_RollUpDealTeamMembersToDealHandler 
{
    /* Start - Variables */
    /***This variable has been created as per the requirement of MOELISSUPP-34 ***/
    private static final Set<String> setSeniorBankerTitles = !SL_SeniorBankerTitle__c.getAll().isEmpty() ? SL_SeniorBankerTitle__c.getAll().keyset() :  new Set<String>{'Managing Director', 'Senior Advisor', 'Senior Vice President'};
    /* End -  Variables */
    
    /* Start - Constructor*/
    public SL_RollUpDealTeamMembersToDealHandler()
    {
        //Do Nothing
    }
    /* End - Constructor*/
    
    /*!
        * MethodName : onAfterInsert
        * param      : List of inserted Deal Team Members
        * Description: This method is called after insertion of the Deal Team Member.
    */
    public void onAfterInsert(List<Project_Resource__c> lstDealTeamMembers)
    {                                                                       
        //Calling function to perform the creation of a string of all Deal Team Members in list.
        rollupDealTeamMembersToDeal(lstDealTeamMembers);
    }
    
    /*!
        * MethodName : onAfterUpdate
        * param      : map of new and old Deal Team Members.
        * Description: This method is called after updation of the Deal Team Member.
    */
    public void onAfterUpdate(Map<Id,Project_Resource__c> mapOldIdToDealTeamMember,Map<Id,Project_Resource__c> mapNewIdToDealTeamMember)
    {
        List<Project_Resource__c> lstDealTeamMembers = new List<Project_Resource__c>();//List of Deal Team Members where map value differs
        
        //Iterating over mapNewIdToDealTeamMember keyset to compare the values of old map with new map
        for(Id objDealTeamMemberId : mapNewIdToDealTeamMember.keyset())
        {
            //comparing the values of old map with new map
            if(mapOldIdToDealTeamMember.get(objDealTeamMemberId).Banker__c!=mapNewIdToDealTeamMember.get(objDealTeamMemberId).Banker__c
               || mapOldIdToDealTeamMember.get(objDealTeamMemberId).Project__c!=mapNewIdToDealTeamMember.get(objDealTeamMemberId).Project__c
               || mapOldIdToDealTeamMember.get(objDealTeamMemberId).Status__c!=mapNewIdToDealTeamMember.get(objDealTeamMemberId).Status__c)
                {
                    lstDealTeamMembers.add(mapNewIdToDealTeamMember.get(objDealTeamMemberId));
                }
        }                                                                                   
        //Calling function to perform the creation of a string of all Deal Team Members in list.
        rollupDealTeamMembersToDeal(lstDealTeamMembers);
    }
    
    /*!
        * MethodName : onAfterDelete
        * param      : List of deleted Deal Team Members.
        * Description: This method is called after deletion of the Deal Team Member.
    */
    public void onAfterDelete(List<Project_Resource__c> lstDealTeamMembers)
    {                                                                                               
        //Calling function to perform the creation of a string of all Deal Team Members in list.
        rollupDealTeamMembersToDeal(lstDealTeamMembers);
    }
    
    /*!
        * MethodName : rollupDealTeamMembersToDeal
        * param      : List of Deal Team Members
        * Description: This method creates a comma separated string of all the bankers related to Deal Team Members
    */
    private void rollupDealTeamMembersToDeal(List<Project_Resource__c> lstDealTeamMembers)
    {
        Set<Id> setDealIds = new Set<Id>();//Set of Deal Ids.
        List<Ibanking_Project__c> lstDeal = new List<Ibanking_Project__c>();//List of updated Deal records
        /***This map has been created as per the requirement of MOELISSUPP-34 ***/
        Map<Id,DealTeamMemberWrapper> mapDealIdToDealTeamMemberWrapper = new Map<Id,DealTeamMemberWrapper>();//map of Deal Id to corresponding senior bankers and all bankers
        
        //Iterating over map to create a set of all DealIds.
        for(Project_Resource__c objDealTeamMember : lstDealTeamMembers)
                setDealIds.add(objDealTeamMember.Project__c);
            
                
        //Iterating over list of Deal Team Members to create a string of Deal Team in comma separated fashion
        for(Project_Resource__c objDealTeamMember : [SELECT Status__c,Banker__r.Name, Banker__r.Title__c, Project__c FROM Project_Resource__c
                                                     WHERE Status__c='Active' AND Banker__c!=null AND Project__c IN:setDealIds
                                                     ORDER BY Sort_Order__c])
        {
            //Checking if map contains the deal id
            if(!mapDealIdToDealTeamMemberWrapper.containskey(objDealTeamMember.Project__c))
            {
            	String strBankerName = (objDealTeamMember.Banker__r.Name).trim();
                //Abbreviating the banker's name
                strBankerName = strBankerName.substring(0, 1) + '. ' + strBankerName.substring(strBankerName.indexOf(' '), strBankerName.length());
                //putting the values of banker name and senior banker names(if title contains in a set) in the map
                mapDealIdToDealTeamMemberWrapper.put(objDealTeamMember.Project__c,new DealTeamMemberWrapper(strBankerName, objDealTeamMember.Banker__r.Title__c!=null && setSeniorBankerTitles.contains(objDealTeamMember.Banker__r.Title__c) ? strBankerName : null));   
            }
            else
            {
            	String strBankerName = (objDealTeamMember.Banker__r.Name).trim();
                //Abbreviating the banker's name
                strBankerName = strBankerName.substring(0, 1) + '. ' + strBankerName.substring(strBankerName.indexOf(' '), strBankerName.length());
                //fetching the object value corresponding to deal
                DealTeamMemberWrapper objDealTeamMemberWrapper = mapDealIdToDealTeamMemberWrapper.get(objDealTeamMember.Project__c);
                //appending the banker's name with existing value in comma separated format
                objDealTeamMemberWrapper.strBankerName = String.valueOf(objDealTeamMemberWrapper.strBankerName) + ', ' + strBankerName;
                //checking if employee title contains in a set
                if(objDealTeamMember.Banker__r.Title__c!=null && setSeniorBankerTitles.contains(objDealTeamMember.Banker__r.Title__c))
                {
                	objDealTeamMemberWrapper.strSeniorBankerName = objDealTeamMemberWrapper.strSeniorBankerName!=null ? String.valueOf(objDealTeamMemberWrapper.strSeniorBankerName)+', '+ strBankerName: strBankerName;
                }
                //putting the values in map
                mapDealIdToDealTeamMemberWrapper.put(objDealTeamMember.Project__c, objDealTeamMemberWrapper);
            }
        }
        
        //Iterating over Deal object in order to get records where deal id is in set
        for(Ibanking_Project__c objDeal : [SELECT Id,Deal_Team_Members__c FROM Ibanking_Project__c WHERE Id IN:setDealIds])
        {
            if(mapDealIdToDealTeamMemberWrapper.containsKey(objDeal.Id))// Checking if the deal id is in map keyset
                lstDeal.add(new Ibanking_Project__c(Id = objDeal.Id, Deal_Team_Members__c = mapDealIdToDealTeamMemberWrapper.get(objDeal.Id).strBankerName, Senior_Banker_Deal_Team_Member__c = mapDealIdToDealTeamMemberWrapper.get(objDeal.Id).strSeniorBankerName));
            else
                lstDeal.add(new Ibanking_Project__c(Id = objDeal.Id, Deal_Team_Members__c = null, Senior_Banker_Deal_Team_Member__c = null));//Putting null to Deal team members if this is not contained in map
        }
        //Validating the list
        if(!lstDeal.isEmpty())
            update lstDeal;//perform dml
    }
    /***This wrapper class has been created as per the requirement of MOELISSUPP-34 ***/
    /*!
        * ClassName : DealTeamMemberWrapper
        * Description: This wrapper has been used to keep the values of both bankers and senior bankers names
    */
    private class DealTeamMemberWrapper
    {
    	private String strBankerName;//variable to hold the names of all the bankers related to deal
    	private String strSeniorBankerName;//variable to hold the names of all the senior bankers related to deal 
    	
    	//constructor
    	private DealTeamMemberWrapper(String strBankerName, String strSeniorBankerName)
    	{
    		this.strBankerName = strBankerName;
    		this.strSeniorBankerName = strSeniorBankerName;
    	}
    }
}