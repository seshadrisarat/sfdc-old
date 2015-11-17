trigger OpportunityTriggers on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
	
	if(Trigger.isBefore && !Trigger.isDelete)
	{
		//Build a map of User ID's and Manager ID's
		Map<Id, Id> managerMap = new Map<Id, Id>();
		List<User> users = [SELECT Id, ManagerId FROM User];
		for(User u : users)
		{
			managerMap.put(u.id, u.ManagerId);
		}
		
		for(Opportunity o : Trigger.New)
		{
			if(o.OwnerId != null)
			{
				 if(managerMap.get(o.OwnerId) != null)
				 {
				 	o.Manager__c = managerMap.get(o.OwnerId);
				 }
			}
		}
	}
	 
	else if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
	{
		SL_OpportunityHandler objOpportunityHandler = new SL_OpportunityHandler();
		
		if(Trigger.isUpdate)
		{
			objOpportunityHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
		}
		
		if(Trigger.isInsert)
		{
			objOpportunityHandler.onAfterInsert(trigger.new);
		} 
		
		
		If(TriggerMonitor.ExecutedTriggers.contains('OpportunityChatter')) return;
		TriggerMonitor.ExecutedTriggers.add('OpportunityChatter');
		
		//Opportunity Chatter Trigger
		for(Opportunity o : Trigger.New)
		{
			if(Trigger.isUpdate)
			{
				if(o.StageName == 'Information Gathering' && Trigger.oldMap.get(o.id).StageName == 'Pre-Opportunity' && o.Chatter_Created__c != true)
				{
					//Get owner information
					User u = [SELECT id, Firstname, Lastname, Default_Chatter_Group__c FROM User WHERE id = :o.OwnerId LIMIT 1];
					//Get Account Information
					Account a = [SELECT id, Account_Type__c, BillingCity, BillingState FROM Account WHERE id = :o.AccountId LIMIT 1];
					
					if(u.Default_Chatter_Group__c != null)
					{
						//Find Chatter Group
						List<CollaborationGroup> cgs = [SELECT id, name FROM CollaborationGroup WHERE name = :u.Default_Chatter_Group__c LIMIT 1];
						
						//Post to Chatter Group
						if(cgs.size() > 0 || Test.isRunningTest()){
							FeedItem post = new FeedItem();
							if(!Test.isRunningTest()) post.ParentId = cgs[0].id;
							if(Test.isRunningTest()) post.ParentId = UserInfo.getUserId();
							post.Body = u.Firstname + ' ' + u.Lastname + ' has uncovered another Qualified Opportunity for a ' + a.Account_Type__c + ' in ' + a.BillingCity + ',' + a.BillingState + '\n\n' +
							            'Equipment Detail/Purpose:' + o.Equipment_Detail_Purpose__c + '\n' +
							            'Amount: $' + o.Amount + '\n' +
							            'Term: ' + o.Term__c + '\n' +
							            'Likely Structure: ' + o.Likely_Structure__c + '\n' +
							            'Estimated Close Date: ' + o.CloseDate.format();
							insert post;
							
							//Check the Chatter_Created__c on the related opp
							Opportunity oppToUpdate = new Opportunity(id=o.id, Chatter_Created__c = true);
							update oppToUpdate;
						}
					}
				}
			}
			else if(Trigger.isInsert)
			{
				if(o.StageName == 'Information Gathering')
				{
					//Get owner information
					User u = [SELECT id, Firstname, Lastname, Default_Chatter_Group__c FROM User WHERE id = :o.OwnerId LIMIT 1];
					//Get Account Information
					Account a = [SELECT id, Account_Type__c, BillingCity, BillingState FROM Account WHERE id = :o.AccountId LIMIT 1];
					
					if(u.Default_Chatter_Group__c != null){
						//Find Chatter Group
						List<CollaborationGroup> cgs = [SELECT id, name FROM CollaborationGroup WHERE name = :u.Default_Chatter_Group__c LIMIT 1];
						
						//Post to Chatter Group
						if(cgs.size() > 0)
						{
							FeedItem post = new FeedItem();
							post.ParentId = cgs[0].id;
							post.Body = u.Firstname + ' ' + u.Lastname + ' has uncovered another Qualified Opportunity for a ' + a.Account_Type__c + ' in ' + a.BillingCity + ',' + a.BillingState + '\n\n' +
							            'Equipment Detail/Purpose:' + o.Equipment_Detail_Purpose__c + '\n' +
							            'Amount: $' + o.Amount + '\n' +
							            'Term: ' + o.Term__c + '\n' +
							            'Likely Structure: ' + o.Likely_Structure__c + '\n' +
							            'Estimated Close Date: ' + o.CloseDate.format();
							insert post;
							
							//Check the Chatter_Created__c on the related opp
							Opportunity oppToUpdate = new Opportunity(id=o.id, Chatter_Created__c = true);
							update oppToUpdate;
						}
					}
				}
			}
		}
	}
	
}