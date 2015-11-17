public with sharing class AnnualGoalsTriggerHandler
{
	public final static string CONFLICT_ERROR_MESSAGE1 = 'Mutilple records cannot be set for {0} for {1}.';
	public final static string CONFLICT_ERROR_MESSAGE2 = 'A record already exists for {0} for {1}.';
	
    public static void onBeforeInsert(List<AnnualGoals__c> newRecords)
    {
    	Boolean valid = validate(newRecords);
       	
       	if(valid)
       	{
       		updateName(newRecords);
       	}
    }
    
    public static void onBeforeUpdate(Map<ID, AnnualGoals__c> newRecordMap, Map<ID, AnnualGoals__c> oldRecordMap)
    {
        Boolean valid = validate(newRecordMap.values());
        
       	if(valid)
       	{
       		updateName(newRecordMap.values());
       	}
    }
        
    public static void onAfterUndelete(Map<ID, AnnualGoals__c> newRecordMap)
    {
    	validate(newRecordMap.values());
    }    
    
    private static void updateName(List<AnnualGoals__c> newRecords)
    {
    	Set<ID> userIds = new Set<ID>();
    	Map<ID, User> users = null;
    	
    	for(AnnualGoals__c ag :newRecords)
    	{
    		if(ag.User__c != null)
    		{
    			userIds.add(ag.User__c);
    		}
    	}
    	
    	if(userIds.size() > 0)
    	{
	    	users = new Map<ID, User>([SELECT ID, Name FROM User WHERE ID in :userIds]);
	    	
	    	for(AnnualGoals__c ag :newRecords)
	    	{
	    		if(ag.User__c != null)
	    		{
		    		string name = ag.Year__c + ' - ' + users.get(ag.User__c).Name;
		    		
		    		if(ag.Name != name)
		    		{
		    			ag.Name = name;
		    		}
	    		}
	    	}
    	}
    }
    
    private static Boolean validate(List<AnnualGoals__c> newRecords)
    {
    	//TODO:  Create test user, add smart factory
    	Boolean valid = true;
    	Set<ID> userIds = new Set<ID>();
    	List<AnnualGoals__c> goals = null;
    	Map<ID, List<AnnualGoals__c>> userGoals = new Map<ID, List<AnnualGoals__c>>();
    	Set<String> newUserYears = new Set<String>(); 
    	
    	for(AnnualGoals__c ag :newRecords)
    	{
    		if(ag.User__c != null)
    		{
    			userIds.add(ag.User__c);
    		}
    	}
    	
    	if(userIds.size() > 0)
    	{
	    	goals = [SELECT ID, Year__c, User__c, User__r.Name FROM AnnualGoals__c WHERE User__c in :userIds];
	    	
	    	for(AnnualGoals__c ag :goals)
	    	{
	    		if(ag.User__c != null)
	    		{
		    		List<AnnualGoals__c> goalYears = null;
		    		
		    		if(userGoals.containsKey(ag.User__c))
		    		{
		    			goalYears = userGoals.get(ag.User__c);
		    		}
		    		else
		    		{
		    			goalYears = new List<AnnualGoals__c>();
		    		}
		    		
		    		goalYears.add(ag);
		    		
		    		userGoals.put(ag.User__c, goalYears);
	    		}
	    	}
	    	
	    	for(AnnualGoals__c ag :newRecords)
	    	{
	    		List<AnnualGoals__c> goalYears = null;
	    			
	    		if(ag.User__c != null)
	    		{
	    			goalYears = userGoals.get(ag.User__c);
	    			
	    			//Verify multiple records are not added/updated for the same User/Year combo
	    			if(newUserYears.contains(ag.User__c + '--' + ag.Year__c))
	    			{
	    				valid = false;
	    				
	    				ag.addError(CONFLICT_ERROR_MESSAGE1.replace('{0}', goalYears != null ? goalYears[0].User__r.Name : ag.User__c).replace('{1}', ag.Year__c));
	    				
	    				break;
	    			}
	    			else
	    			{
	    				newUserYears.add(ag.User__c + '--' + ag.Year__c);
	    			}
	    			
	    			if(goalYears != null)
	    			{
		    			//Verify record does not exist for User/Year combo
		    			for(AnnualGoals__c ug :goalYears)
		    			{
		    				if(ug.Year__c == ag.Year__c && ug.Id != ag.Id)
		    				{
		    					valid = false;
		    					
		    					ag.addError(CONFLICT_ERROR_MESSAGE2.replace('{0}', ug.User__r.Name).replace('{1}', ag.Year__c));
		    				}
		    			}
	    			}
	    		}
	    	}
    	}
    	
    	return valid;
    }
    
}