public class ChatterItemProcessor 
{
	List<RecordType> lTypes=null;
	Map<String,Id> mRecordTypes=new Map<String,Id>();
	
	public ChatterItemProcessor()
	{
		lTypes=[Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType WHERE SObjectType='Account' AND Name IN ('Company','G2K Historical Company')];

		for(RecordType r : lTypes)
		{
			mRecordTypes.put(r.name,r.Id);
		}	
	}
	
	public void processGAPSOwnership(List<FeedItem> items)
	{
		String strAccountPrefix=Account.sObjectType.getDescribe().getKeyPrefix();
		String strDealPrefix=Deal__c.sObjectType.getDescribe().getKeyPrefix();
		Map<Id,User> mUsers=new Map<Id,User>();
		Map<Id,Account> mAccounts=new Map<Id,Account>();
		Map<Id,Deal__c> mDeals=new Map<Id,Deal__c>();
		
		for(FeedItem f : items)
		{
			mUsers.put(f.createdById,null);
			String strID=f.parentId;
			
			if(strID.startsWith(strAccountPrefix))
				mAccounts.put(f.parentId,null);
			else if(strID.startsWith(strDealPrefix))
				mDeals.put(f.parentId,null);
		}
				
		for(Account a : [SELECT Id, Name, OwnerId, Owner.Name FROM Account WHERE Id IN :mAccounts.keySet()])
		{
			mAccounts.put(a.Id,a);
		}
		
		for(Deal__c d : [SELECT Id, Name, OwnerId, Owner.Name FROM Deal__c WHERE Id IN :mDeals.keySet()])
		{
			mDeals.put(d.Id,d);
		}		
		
		for(User u : [SELECT Id, Name FROM User WHERE Id IN :mUsers.keySet()])
		{
			mUsers.put(u.Id,u);
		}
		
		List<FeedItem> lFeedUpdates=new List<FeedItem>();
		
		for(FeedItem f : items)
		{
			User u=mUsers.get(f.createdById);
			String strName='';
			String strOwnerName='';
			String strOwnerID='';
			String strID=f.parentId;
			
			if(strID.startsWith(strAccountPrefix))
			{
				Account a=mAccounts.get(f.parentId);
				strName=a.name;
				strOwnerName=a.Owner.Name;
				strOwnerID=a.OwnerId;
				mAccounts.put(f.parentId,new Account(Id=f.parentId,OwnerId=f.createdById,RecordTypeId=mRecordTypes.get('Company')));
			}
			else if(strID.startsWith(strDealPrefix))
			{
				Deal__c d=mDeals.get(f.parentId);
				strName=d.name;
				strOwnerName=d.Owner.Name;
				strOwnerID=d.OwnerId;
				mDeals.put(f.parentId,new Deal__c(Id=f.parentId,OwnerId=f.createdById));				
			}
			
			lFeedUpdates.add(new FeedItem(parentId=f.parentId, createdById=f.createdById, Type='TextPost', Body='Ownership of '+strName+' assigned from @'+strOwnerName+' to @'+u.Name ));
			lFeedUpdates.add(new FeedItem(parentId=strOwnerID, createdById=f.createdById, Type='TextPost', Body='Ownership of '+strName+' assigned from @'+strOwnerName+' to @'+u.Name ));
		}
		
		if(lFeedUpdates.size()>0)
		{
			if(mAccounts.size()>0)
				update mAccounts.values();
				
			if(mDeals.size()>0)
				update mDeals.values();
				
			insert lFeedUpdates;
		}
		
	}
	
	public void processStatusNotes(List<FeedItem> items)
	{
		GAPSMailHandler geh=new GAPSMailHandler();
		Set<Id> sUIds=new Set<Id>();
		Map<Id,User> mUs=new Map<Id,User>();
		
		for(FeedItem fi : items)
		{
			sUIds.add(fi.createdByID);
		}
		
		List<User> lUs=[SELECT Id,Name,email,Group_Name__c FROM User WHERE Id IN :sUIds];
		
		for(User u : lUs)
		{
			mUs.put(u.Id,u);
		}
		
		for(FeedItem fi : items)
		{
			geh.setStatusNote(mUs.get(fi.createdById), new Account(id=fi.ParentId), fi.Body,false);
		}
	}
	
	public void processResearchTrackerApprovals(List<FeedItem> items,String strStatus)
	{		
		Map<Id,Id> mProjects=new Map<Id,Id>();
		
        for(FeedItem f : items)
        {
        	mProjects.put(f.parentId,f.createdById);
        }
        
        List<Project__c> lP=[SELECT Id, OwnerId,Owner.Name, Status__c FROM Project__c WHERE OwnerId IN :mProjects.values() AND  Id IN :mProjects.keySet()];
        
        for(Project__c p : lP)
        {
        	p.Status__c = strStatus;
        }
        
        if(lP.size()>0)
        	update lP;
	}
	
	public void processTeamTaskStatuses(List<FeedItem> items,String strStatus)
	{
		List<Id> lTasks=new List<Id>();
		
		for(FeedItem f : items)
		{
			lTasks.add(f.parentId);
		}
		
		List<Task__c> lT=[SELECT Id, OwnerId,Owner.Name, Status__c FROM Task__c WHERE Id IN :lTasks];
        
        for(Task__c t : lT)
        {
        	t.Status__c = strStatus;
        }
        
        if(lT.size()>0)
        	update lT;		
	}
}