trigger LookupContactOwner on Outlook_Contact__c (before insert,before update) 
{
	Map<String,Id> mUsers=new Map<String,Id>();
	List<Outlook_Contact__c> lOCs=new List<Outlook_Contact__c>();
	
	
	for(Outlook_Contact__c oc : trigger.new)
	{
		mUsers.put(oc.Contact_Owner_Email__c.toLowerCase(),null);
	}
	
	List<User> lU=[SELECT Id, Username, Name FROM User WHERE Username IN :mUsers.keySet() ];
	
	for(User u: lU)
	{
		mUsers.put(u.Username.toLowerCase(),u.id);
	}
	
	for(Outlook_Contact__c oc : trigger.new)
	{
		oc.Contact_Owner__c=mUsers.get(oc.Contact_Owner_Email__c.toLowerCase());
	}

}