trigger FollowTeamTask on Task__c (after insert, after update) 
{
	Map<Id,Id> mExisting=new Map<Id,Id>();
	Map<Id,EntitySubscription> mNewSubs=new Map<Id,EntitySubscription>();
	
	String strQueuePrefix='00G';//QueueSobject.sObjectType.getDescribe().getKeyPrefix();
	
	for(Task__c t : trigger.new)
	{
		String strId=t.OwnerId;
		
		if(!strID.StartsWith(strQueuePrefix))
		{
			mExisting.put(t.id,t.ownerId);
			mNewSubs.put(t.id,new EntitySubscription(parentId=t.id,subscriberid=t.OwnerId));
		}
	}
	
	List<EntitySubscription> lExisting=[select Id, ParentId, SubscriberId, CreatedById, CreatedDate, IsDeleted from EntitySubscription where parentid in :mExisting.keySet() AND SubscriberId IN :mExisting.values()];

	for(EntitySubscription e : lExisting)
	{
		EntitySubscription enew=mNewSubs.get(e.ParentId);
		
		if(e.SubscriberID==enew.subscriberId)
			mNewSubs.remove(e.ParentId);
	}
	
	if(mNewSubs.size()>0)
		insert mNewSubs.values();
}