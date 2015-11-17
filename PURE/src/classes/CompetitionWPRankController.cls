/**
*		CompetitionWPRankController contains controller method and actions to the CompetitionWPRankPage.
*	
*		Author  :   Wilson Ng
*		Date	:	Jan 30, 2013
*  
*		Revision History:
*			Date	Author			Comments
*
*/
public with sharing class CompetitionWPRankController {
	
	// public variables
	public ID parentId {get; private set;}
	public list<Competition_WP_Rank__c> wpList {get; set;}
	public Competition_WP_Rank__c rankRecord {get; set;}
	public boolean canEdit {get; private set;}
	public boolean isEdit {get; private set;}
		
	// Constructors
	public CompetitionWPRankController(ApexPages.StandardController controller) {
		this.parentId = controller.getId();
	}

	// Methods
	public PageReference init() {
		// determine if user has edit rights
		Id userId = UserInfo.getUserId();
		Id recordId = this.parentId;
		list<UserRecordAccess> checkAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId];
		canEdit = (checkAccess.size()>0 && checkAccess[0].HasEditAccess);
		isEdit = false;
		return null;
	}
	public PageReference refreshList() {
		this.wpList = new list<Competition_WP_Rank__c>();
		this.rankRecord = new Competition_WP_Rank__c();
		
		system.SavePoint pSavepoint = database.setSavepoint();
		try {
			// query all records
			Id recordId = this.parentId;
			system.debug('parent record id: ' + recordId);
			for(Competition_WP_Rank__c cwpr : database.query(generateQuery())) {
				// separate into wpList and rankRecord
				if(cwpr.RecordType.Name == 'WP')
					this.wpList.add(cwpr);
				else
					this.rankRecord = cwpr;
			}
						
			// if wpList does not contain current year record, then create current year wp record
			if(this.canEdit && (this.wpList.size() == 0 || Integer.valueOf(this.wpList[0].Year__c) < system.today().year())) {
				system.debug('Adding new current year WP record');
				Competition_WP_Rank__c newWp = new Competition_WP_Rank__c(RecordType=new RecordType(Name='WP'), Account__c=this.parentId, Year__c=String.valueOf(system.today().year()));
				insert newWp;
				if(this.wpList.size() == 0)
					this.wpList.add(newWp);			// add new entry into empty list
				else
					this.wpList.add(0, newWp);		// add to beginning of list
			}
			
			// if rankRecord does not exist, then create a rank record
			if(this.canEdit && this.rankRecord.Id == null) {
				system.debug('Adding new Rank record');
				Competition_WP_Rank__c newRank = new Competition_WP_Rank__c(RecordType=new RecordType(Name='Rank'), Account__c=this.parentId);
				insert newRank;
				this.rankRecord = newRank;
			}
		}
		catch(Exception ex) {
			database.rollback(pSavepoint);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
		return null;
	}
	private string generateQuery() {
		return 'SELECT RecordType.Name,' + string.join(new list<string>(Schema.SObjectType.Competition_WP_Rank__c.fields.getMap().keySet()), ',') + 
				' FROM Competition_WP_Rank__c WHERE Account__c = :recordId ORDER BY Year__c DESC NULLS LAST';
	}
	
	//
	// edit and save methods
	public PageReference Edit() {
		this.isEdit = true;
		return null;
	}
	public PageReference Save() {
		try {
			// update all records
			list<Competition_WP_Rank__c> updList = new list<Competition_WP_Rank__c>();
			updList.addAll(wpList);
			updList.add(rankRecord);
			update updList;
			
			this.isEdit = false;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
		return null;
	}
	public PageReference Cancel() {
		this.isEdit = false;
		return refreshList();
	}
		
		
	//
	// test method
	@isTest
	static void testThisClass_Controller() {
		// create dummy account
		Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name='Broker'));
		insert acct;
		acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.CompetitionWPRankPage;
		Test.setCurrentPageReference(pageRef);		
		CompetitionWPRankController controller = new CompetitionWPRankController(new ApexPages.StandardController(acct));
		PageReference nextPage = controller.init();

		// refreshlist
		nextPage = controller.refreshList();
		system.assertEquals(false, ApexPages.hasMessages(), 'Error: Refresh List failed: ' + ApexPages.getMessages());
		list<Competition_WP_Rank__c> testList = [select id, Year__c, RecordType.Name FROM Competition_WP_Rank__c where Account__c = :acct.Id order by Year__c desc nulls last];
		system.assertEquals(2, testList.size(), 'Error: Refresh List did not auto generate 2 competition wp rank records.');
		list<Competition_WP_Rank__c> wpList = controller.wpList;
		system.assertEquals(1, wpList.size(), 'Error: WP list should equals 1 record.');
		Competition_WP_Rank__c rankRecord = controller.rankRecord;
		system.assert(rankRecord!=null && rankRecord.Id!=null, 'Error: Rank record should not be null.');
		
		// edit
		nextPage = controller.Edit();
		
		// update fields
		wpList[0].Chubb__c = 123;
		rankRecord.Chubb__c = 234;
		rankRecord.Comments__c = 'test comments update';

		// save
		nextPage = controller.Save();
		system.assertEquals(false, ApexPages.hasMessages(), 'Error: Save failed: ' + ApexPages.getMessages());
		testList = [select id, Year__c, RecordType.Name, Chubb__c, Comments__c FROM Competition_WP_Rank__c where Account__c = :acct.Id order by Year__c desc nulls last];
		system.assertEquals(2, testList.size(), 'Error: There should be only 2 total competition records.');
		system.assert(testList[0].RecordType.Name=='WP' && testList[0].Chubb__c==123, 'Error: WP record did not save properly.');
		system.assert(testList[1].RecordType.Name=='Rank' && testList[1].Chubb__c==234 && testList[1].Comments__c=='test comments update', 'Error: rank record did not save properly.');
		
		// cancel
		nextPage = controller.Cancel();
		
		Test.stopTest();
	}
}