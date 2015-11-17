public with sharing class SL_ContactSyncController {
	public List<SyncObject> AllSyncRecords {get;set;}
	public Map<String,String> mapSyncObjects;
	public Map<ID,Boolean> mapOfSyncs {get;set;}
	public List<DelegateUser> lstSyncDelegates {get;set;}
	public String parentID;
	public ID companyID;
	public Set<ID> allContactIDs;
	public ID amsecID;
	public String runningUserContactId;
	public String currentSelectedUser {get;set;}
	public User curUser;
	public String DealorAccount;
	public SL_ContactSyncController() {
		
		initializeVars();
		parentID = '';
		DealorAccount ='';
		currentSelectedUser = UserInfo.getUserId();
		curUser = [SELECT ID,NAME FROM USER where ID =: UserInfo.getUserId() limit 1];
		lstSyncDelegates = new List<DelegateUser>();
		getAsUsers();
		whoContactSync();
		getAmericanSecuritiesCompanyID();
		getImportantIDs();
		getCompanyContacts();
		getWGContacts();
		getSyncRecords();
	}
	public void initializeVars()
	{
		AllSyncRecords = new List<SyncObject>();
		allContactIDs = new Set<ID>();
		mapOfSyncs = new Map<Id,Boolean>();
		mapSyncObjects = new MAp<String,String>();
	}
	public void whoContactSync()
	{
		//Temporarirly current user
		Contact userContact = [SELECT ID FROM Contact where Salesforce_User__c =:currentSelectedUser limit 1];
		if(userContact!=null)
			runningUserContactId = userContact.ID;
	}

	public void getAsUsers()
	{
		DelegateUser d = new DelegateUser();
		d.ManagerID = UserInfo.getUserId();
		d.Name = curUser.Name;
		lstSyncDelegates.add(d);
		List<Delegate__c> syncDelegates = [SELECT ID,Manager__c,Manager__r.Name FROM Delegate__c WHERE Delegate__c=:UserInfo.getUserId() AND Active__c =:true AND Contact_Sync__c =:true];
		for(Delegate__c del:syncDelegates)
		{
			d = new DelegateUser();
			d.ManagerID = del.Manager__c;
			d.Name = del.Manager__r.Name;
			lstSyncDelegates.add(d);
		}
	}

	public PageReference delegateChanged()
	{
		initializeVars();
		whoContactSync();
		getCompanyContacts();
		getWGContacts();
		getSyncRecords();
		return null;
	}
	public void getImportantIDs()
	{
		parentID = ApexPages.currentPage().getParameters().get('DealID');
		if(parentID!=null)
		{
			Deal__c tempDeal = [Select ID,Salesforce_Company__c from Deal__c where ID =: parentId limit 1];
			if(tempDeal!=null)
			{
				DealorAccount = 'Deal';
				companyID=tempDeal.Salesforce_Company__c;
			}
		}
		else
		{
			parentID = ApexPages.currentPage().getParameters().get('AccountID');
			if(parentID!=null)
			{
				DealorAccount = 'Account';
				companyID=parentID;
			}
		}
	}
	public void getAmericanSecuritiesCompanyID()
	{
		Account amsecCompany = [SELECT ID FROM Account where Name='American Securities LLC' limit 1];
		if(amsecCompany!=null)
		{	
			amsecID = amsecCompany.ID;
		}
	}

	public PageReference submitSyncs()
	{
		System.debug('saving');
		List<ID> deleteSyncs = new List<ID>();
		List<Outlook_Sync__c> insertSyncs = new List<Outlook_Sync__c>();
		for(SyncObject syncRec:AllSyncRecords)
		{
			System.debug('new'+mapOfSyncs.get(syncRec.contactID));
			if(syncRec.isSynced!=mapOfSyncs.get(syncRec.contactID))
			{
				//Has been synced. Create record
				if(syncRec.isSynced==true)
				{
					Outlook_Sync__c newSync = new Outlook_Sync__c();
					newSync.Contact__c = syncRec.contactID;
					newSync.Account__c = syncRec.accountID;
					newSync.AS_Person__c = runningUserContactId;
					insertSyncs.add(newSync);
				}
				//Has been unsynced, delete record
				else
				{
					deleteSyncs.add(mapSyncObjects.get(syncRec.contactID));
				}
			}
		}
		if(deleteSyncs.size()>0)
		{
			delete [SELECT ID FROM Outlook_Sync__c WHERE ID in:deleteSyncs];
		}
		if(insertSyncs.size()>0)
		{
			insert insertSyncs;
		}
		return null;
	}

	public void getCompanyContacts()
	{
		List<Contact> companyContacts = [SELECT ID,Name,Email,Account.Name,AccountID FROM Contact WHERE AccountID =:companyId AND ID NOT in:allContactIDs];
		for(Contact compContact:companyContacts)
		{
			SyncObject syncObj = new SyncObject();
			syncObj.isSynced = false;
			syncobj.contactName = compContact.Name;
			syncobj.contactID = compContact.ID;
			syncobj.email = compContact.Email;
			syncobj.accountName = compContact.Account.Name;
			syncObj.accountID = compContact.AccountId;
			syncobj.syncID = compContact.ID;
			syncobj.type = 'Company Contact';
			AllSyncRecords.add(syncobj);
			mapOfSyncs.put(compContact.ID,false);
			allContactIDs.add(compContact.ID);
		}
	}

	public void getWGContacts()
	{
		List<External_Working_Group_Member__c> allWGMembers = new List<External_Working_Group_Member__c>();
		if(DealorAccount=='Deal')
			allWGMembers = [SELECT ID,Contact__r.Name,Contact__r.Email,Contact__r.Company_Name__c,Contact__r.AccountID FROM External_Working_Group_Member__c WHERE Deal__c=:parentID AND Contact__r.AccountID!=:amsecID AND Contact__c NOT in:allContactIDs];
		else if(DealorAccount=='Account')
			allWGMembers = [SELECT ID,Contact__r.Name,Contact__r.Email,Contact__r.Company_Name__c,Contact__r.AccountID FROM External_Working_Group_Member__c WHERE Company__c=:parentID AND Contact__r.AccountID!=:amsecID AND Contact__c NOT in:allContactIDs];

		for(External_Working_Group_Member__c wgMemb:allWGMembers)
		{
			SyncObject syncObj = new SyncObject();
			syncObj.isSynced = false;
			syncobj.contactName = wgMemb.Contact__r.Name;
			syncobj.contactID = wgMemb.Contact__c;
			syncobj.email = wgMemb.Contact__r.Email;
			syncobj.accountName = wgMemb.Contact__r.Company_Name__c;
			syncobj.accountID = wgMemb.Contact__r.AccountID;
			syncobj.syncID = wgMemb.ID;
			syncobj.type = 'Working Group Member';
			AllSyncRecords.add(syncobj);
			mapOfSyncs.put(wgMemb.Contact__c,false);
			allContactIDs.add(wgMemb.Contact__c);
		}
	}

	public void getSyncRecords()
	{
		List<Outlook_Sync__c>  outlookSyncRecords = [SELECT ID,Account__c, Account__r.Name, AS_Person__c, Contact__c, Contact__r.Name, Contact__r.Email FROM Outlook_Sync__c where AS_Person__c=:runningUserContactId];

		for(Outlook_Sync__c syncRecord:outlookSyncRecords)
		{
			if(mapOfSyncs.get(syncRecord.Contact__c)!=null)
			{
				//SyncObject syncObj = mapSyncObjects.get(syncRecord.syncRecord.Contact__c);
				//syncObj.isSynced = true;
				mapOfSyncs.put(syncRecord.Contact__c,true);
				mapSyncObjects.put(syncRecord.Contact__c,syncRecord.ID);
			}
			//SyncObject syncObj = new SyncObject();
			//syncObj.isSynced = true;
			//syncobj.contactName = syncRecord.Contact__r.Name;
			//syncobj.contactID = syncRecord.Contact__c;
			//syncobj.email = syncRecord.Contact__r.Email;
			//syncobj.accountName = syncRecord.Account__r.Name;
			//syncobj.accountID = syncRecord.Account__c;
			//syncobj.syncID = syncRecord.ID;
			//syncobj.type = 'Outlook Sync';
			//AllSyncRecords.add(syncobj);
			//mapOfSyncsOld.put(syncRecord.ID,true);
			//allContactIDs.add(syncRecord.Contact__c);
		}
		for(SyncObject s:AllSyncRecords)
		{
			if(mapOfSyncs.get(s.contactID)==true)
			{
				s.isSynced=true;
			}
		}
	}
	public class SyncObject
    {
    	public ID syncID {get;set;}
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