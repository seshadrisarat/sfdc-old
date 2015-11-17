public with sharing class SL_SyncContactForHandler {
	public List<DelegateUser> lstSyncDelegates {get;set;}
	public List<SyncObject> AllSyncRecords {get;set;}
	public User curUser;
	public List<String> lstIDs;
	public ID curContactID;
	public Map<ID,Boolean> mapOfSyncs {get;set;}
	public String parentId;
	public String runningUserContactId;
	public SL_SyncContactForHandler() {
		lstSyncDelegates = new List<DelegateUser>();
		curUser = [SELECT ID,NAME FROM USER where ID =: UserInfo.getUserId() limit 1];
		lstIDs = new List<String>();
		parentId = '';
		initializeVars();
		getAsUsers();
		getSyncRecords();
	}
	public void initializeVars()
	{
		AllSyncRecords = new List<SyncObject>();
		mapOfSyncs = new Map<Id,Boolean>();
		parentID = ApexPages.currentPage().getParameters().get('ContactID');
	}
	public void whoContactSync()
	{
		//Temporarirly current user
		Contact userContact = [SELECT ID FROM Contact where Salesforce_User__c =:UserInfo.getUserId() limit 1];
		if(userContact!=null)
			runningUserContactId = userContact.ID;
	}
	public void getAsUsers()
	{
		DelegateUser d = new DelegateUser();
		d.ManagerID = UserInfo.getUserId();
		d.Name = curUser.Name;
		lstIds.add(runningUserContactId);
		lstSyncDelegates.add(d);
		SyncObject syncObj = new SyncObject();
		syncObj.isSynced = false;
		syncobj.contactID = curContactID;
		syncobj.syncerId = runningUserContactId;
		syncobj.syncerName = curUser.Name;
		AllSyncRecords.add(syncobj);
		mapOfSyncs.put(Userinfo.getUserId(),false);
		List<Delegate__c> syncDelegates = [SELECT ID,Manager__c,Manager__r.Name,Manager__r.ContactID FROM Delegate__c WHERE Delegate__c=:UserInfo.getUserId() AND Active__c =:true AND Contact_Sync__c =:true];
		for(Delegate__c del:syncDelegates)
		{
			d = new DelegateUser();
			d.ManagerID = del.Manager__c;
			d.Name = del.Manager__r.Name;
			lstIds.add(del.Manager__r.ContactID);
			lstSyncDelegates.add(d);
			syncObj = new SyncObject();
			syncObj.isSynced = false;
			syncobj.contactID = curContactID;
			syncobj.syncerId = del.Manager__r.ContactID;
			syncobj.syncerName = del.Manager__r.Name;
			AllSyncRecords.add(syncobj);
			mapOfSyncs.put(del.Manager__c,false);
		}
	}
	public void getSyncRecords()
	{
		List<Outlook_Sync__c>  outlookSyncRecords = [SELECT ID,AS_Person__c,AS_Person__r.Name, Contact__c, Contact__r.Name FROM Outlook_Sync__c where AS_Person__c in:lstIDs AND Contact__c=:parentId];
		System.debug('syncs'+outlookSyncRecords);
		System.debug('parent'+parentid);
		System.debug('ids'+lstIds);

		for(Outlook_Sync__c syncRecord:outlookSyncRecords)
		{
			if(mapOfSyncs.get(syncRecord.AS_Person__c)!=null)
			{
				System.debug(mapOfSyncs);
				mapOfSyncs.put(syncRecord.AS_Person__c,true);
			}
		}
		for(SyncObject s:AllSyncRecords)
		{
			if(mapOfSyncs.get(s.syncerId)==true)
			{
				System.debug('true');
				s.isSynced=true;
			}
		}
	}
	public PageReference submitSyncs()
	{
		return null;
	}
	public class SyncObject
    {
    	public ID syncID {get;set;}
    	public String syncerId {get;set;}
    	public String syncerName {get;set;}
        public Boolean isSynced {get;set;}
        public String contactName {get;set;}
        public ID contactID {get;set;}
        public String email {get;set;}
        public String accountName {get;set;}
        public ID accountID;
        public String type {get;set;}
        public SyncObject()
        {
            isSynced=false;
	        contactName='';
	        email='';
	        accountName='';
	        type = '';
	        syncerId = '';
	        syncerName = '';
        }
    }
	public class DelegateUser
    {
    	public String ManagerID {get;set;}
    	public String Name {get;set;}
    	
        public DelegateUser()
        {
           ManagerID = '';
           Name = '';
        }
    }
}