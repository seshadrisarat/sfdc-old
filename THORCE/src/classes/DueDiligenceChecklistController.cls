/**
*		DueDiligenceChecklistController contains controller method and actions to the DueDiligenceChecklistPage.
*	
*		Author  :   Wilson Ng
*		Date	:	Sept 17, 2012
*  
*		Revision History:
*			Date	Author			Comments
*
*/
public with sharing class DueDiligenceChecklistController {
	
	// static variables
	public static string DUE_DILIGENCE_PREFIX	= 'Due_Diligence_';
	public static string DUE_DILIGENCE_TEMPLATE	= 'Due_Diligence_Checklist_Template__c';
	
	// public variables
	public ID parentId {get; private set;}
	public string parentName {get; private set;}
	public list<ListnameWrapper> listNames {get; private set;}
	public list<DueDiligenceChecklistWrapper> dueDiligenceList {get; set;}
	public map<String, list<DueDiligenceChecklistWrapper>> dueDiligenceMap {get; set;}
	public boolean queryPerformed {get; private set;}
	public boolean isEditAll {get; set;}
	public boolean isAddNewTemplate {get; set;}
	public boolean isAddNewItem {get; set;}
	public boolean canEdit {get; set;}
	public boolean asPrintableView { get; private set; }
	
	// configurable fields passed as variable parameters to the apex:component
	public string parentSObjectName { get; set; }
	public string sObjectName { get; set; }
	public string lookupField { get; set; }
	public string editFields { get; set; }
	public string groupingField { get; set; }
	public string sortingField { get; set; }
	public list<String> availableEditFields {
		get {
			return editFields.replaceAll('\\s', '').split(',');
		}
	}
	public list<String> allFields {
		get {
			list<string> mlst = new list<string>();
			set<string> mset = new set<string>();		// unique list
			if(string.isNotEmpty(groupingField)) {
				mlst.add(groupingField); mset.add(groupingField);
			}
			for(string s : editFields.replaceAll('\\s', '').split(',')) {
				if(!mset.contains(s)) {
					mlst.add(s);  mset.add(s);
				}
			}
			return mlst;
		}
	}
	public boolean isDueDiligence {
		get {
			return (sObjectName!=null && sObjectName.startsWith(DUE_DILIGENCE_PREFIX));
		}
	}
	
	// private variables
	private integer rowNumber;
	
	// Constructors
	public DueDiligenceChecklistController(ApexPages.StandardController controller) {
		this();
	}
	public DueDiligenceChecklistController() {

		// get input parameters
		// get isedit parameter
		this.isEditAll = (ApexPages.currentPage().getParameters().get('isedit') != null);
		// must assume this is always coming from the Parent's related list
	   	this.parentId = ApexPages.currentPage().getParameters().get('id');
	   	
	   	// default values for internal variables
	   	this.asPrintableView = false;
		this.queryPerformed = false;
		this.isAddNewItem = false;
		this.isAddNewTemplate = false;
		
		// if pdf, execute query list
		if(ApexPages.currentPage().getParameters().get('print') != null) {
			this.asPrintableView = true;
			// TODO - ugly hack here to support printable view mode.   not sure how to fix this properly.
			sObjectName = 'Due_Diligence_Checklist__c';
			parentSObjectName = 'Deal__c';
			lookupField = 'Deal__c';
			editFields = 'Name, Status__c, Due_Date__c, Assigned_To__c, Date_Assigned__c, Email_Notify__c, Comments__c, Sort_Order__c';
			groupingField = 'List_Name__c';
			sortingField = 'Sort_Order__c';
			refreshList();
		}
	}
	
	private string join(set<string> stringlist, string delimiter) {
		string retString = '';
		for(string s : stringlist)
			retString += (retString!=''?delimiter:'') + s;
		return retString;
	}
	
	
	// Methods
	public PageReference refreshList() {
		// retrieve sticky sections from existing cookie value
		Cookie sticky = ApexPages.currentPage().getCookies().get('sticky');
		string tempstring = (sticky != null ? sticky.getValue() : '');
		set<string> stickyNames = new set<string>(tempstring.split(','));
		
		// get parent sobject record name
		if(string.isNotEmpty(parentSObjectName)) {  		
		   	try {
			   	string parentQuery = 'select Name from ' + parentSObjectName + ' where id=:parentId';
			   	sObject sobj = database.query(parentQuery);
				parentName = (String)sobj.get('Name');
		   	}
		   	catch(Exception ex) {
		   		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to query parent object: ' + ex.getMessage()));
		   	}
	   	}
	   	
	   	// query all child records
		set<string> listOfFields = new set<string>();
		listOfFields.add('Id');
		listOfFields.add(lookupField);
		string sortPhrase = '';
		if(string.isNotEmpty(groupingField)) {
			sortPhrase = 'order by ' + groupingField + ' ASC';
			listOfFields.add(groupingField);
		}
		if(string.isNotEmpty(sortingField)) {
			sortPhrase += (string.isEmpty(sortPhrase)?'order by ':', ') + sortingField + ' ASC';
			listOfFields.add(sortingField);
		}
		sortPhrase += (string.isNotEmpty(sortPhrase)?' NULLS LAST':'');
		listOfFields.addAll(availableEditFields);
		string soqlQuery = string.format('select {2} from {0} where {1} = :parentId {3}', 
								new list<string> {sObjectName, lookupField, join(listOfFields, ','), sortPhrase});
		system.debug('soqlQuery: ' + soqlQuery);
		// unique list of dd ids
		list<id> ddIds = new list<id>();
		listNames = new list<ListnameWrapper>();
		dueDiligenceList = new list<DueDiligenceChecklistWrapper>();
		dueDiligenceMap = new map<String, list<DueDiligenceChecklistWrapper>>();
		rowNumber = 0;
		for(SObject ddc : Database.query(soqlQuery)) {
			string groupvalue = (string.isNotEmpty(groupingField)?(string)ddc.get(groupingField):'');
			if(!dueDiligenceMap.containsKey(groupvalue)) {
				dueDiligenceMap.put(groupvalue, new list<DueDiligenceChecklistWrapper>());
				listNames.add(new ListnameWrapper(groupvalue, stickyNames.contains(groupvalue)));
			}
			DueDiligenceChecklistWrapper itm = new DueDiligenceChecklistWrapper(rowNumber++, ddc);
			dueDiligenceList.add(itm);
			dueDiligenceMap.get(groupvalue).add(itm);
			ddIds.add(ddc.Id);
		}
		
		// attachments support here
		// query attachment object, order by parent ids
		for(Attachment att : [select Id, Name, ParentId from Attachment where ParentId in :ddIds order by CreatedDate asc])
			findOne(dueDiligenceList, att.ParentId).addAttachment(att.Id, att.Name);
		
		queryPerformed = true;
		
		// code to make sure that one item is editable
		if(dueDiligenceList.size() > 0) {
			Id recId = dueDiligenceList[0].record.Id;
			list<UserRecordAccess> accList = [select RecordId, HasEditAccess from UserRecordAccess where UserId = :userInfo.getUserId() and RecordId = :recId];
			if(accList==null || accList.size()==0 || !accList[0].HasEditAccess) {
				// throw an exception
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You don\'t have the proper access to create or edit '+sObjectName+' Items.'));
			}
		}
		return null;
	}
	
	//
	// creates sobject instance
	static sObject createObject(String typeName) {
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
		if (targetType == null) {
			// throw an exception
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to describe sobject: '+typeName));
		}
		// Instantiate an sObject with the type passed in as an argument at run time.
		return targetType.newSObject();
	}
	
	//
	// add new template methods
	public list<DueDiligenceChecklistTemplateWrapper> newTemplateItems { get; set;}
	public PageReference addNewTemplate() {
		// query list of all list_names with their corresponding number of items count
		this.newTemplateItems = new list<DueDiligenceChecklistTemplateWrapper>();
		// use generic sobject i.e. dynamic soql
		string query = 'select List_Name__c, count(Name) cnt from Due_Diligence_Checklist_Template__c group by List_Name__c';
		for(AggregateResult ar : database.query(query))
			this.newTemplateItems.add(new DueDiligenceChecklistTemplateWrapper(String.valueOf(ar.get('List_Name__c')), Integer.valueOf(ar.get('cnt'))));
		this.isAddNewTemplate = true;
		return null;
	}
	public PageReference saveNewTemplate() {		
		list<String> selectedListNames = new list<String>();
		for(DueDiligenceChecklistTemplateWrapper ddctw : newTemplateItems)
			if(ddctw.IsChecked)
				selectedListNames.add(ddctw.ListName);
		if(selectedListNames.size() > 0) {
			list<sObject> insList = new list<sObject>();
			// query all records
			// list object generic, i.e. dynamic soql
			string query = 'select List_Name__c, Name, Comments__c, Sort_Order__c from Due_Diligence_Checklist_Template__c where List_Name__c in :selectedListNames';
			for(sObject ddct : database.query(query)) {
				// check to see if same due diligence checklist item already exists (using listname + name).  if yes, don't add
				if(findOne(dueDiligenceList, (string)ddct.get('List_Name__c'), (string)ddct.get('Name')) != null)
					continue;
				// create new one
				sObject ddcw = createObject(sObjectName);
				ddcw.put(lookupField, this.parentId);
				ddcw.put('List_Name__c', ddct.get('List_Name__c'));
				ddcw.put('Name', ddct.get('Name'));
				ddcw.put('Comments__c', ddct.get('Comments__c'));
				ddcw.put('Sort_Order__c', ddct.get('Sort_Order__c'));
				ddcw.put('Status__c', 'Created');
				DueDiligenceChecklistWrapper newItem = new DueDiligenceChecklistWrapper(rowNumber++, ddcw, this.isEditAll);
				if(!this.isEditAll)
					insList.add(newItem.record);		// insert dml only during non-Edit All mode
				addToMap(newItem);
			}
			if(insList.size() > 0)		
				insert insList;
		}
		return cancelNewTemplate();
	}
	public PageReference cancelNewTemplate() {
		this.isAddNewTemplate = false;
		this.newTemplateItems = null;
		return null;
	}
	
	
	//
	// add new item methods
	public list<DueDiligenceChecklistWrapper> newItems { get; set;}
	public DueDiligenceChecklistWrapper newItem { get; set; }
	public PageReference addNewItem() {
		sObject newRecord = createObject(sObjectName);
		newRecord.put(lookupField, this.parentId);		// populate lookup value
		newItem = new DueDiligenceChecklistWrapper(rowNumber++, newRecord, this.isEditAll);
		newItems = new list<DueDiligenceChecklistWrapper> { newItem };
		this.isAddNewItem = true;
		return null;
	}
	public PageReference saveNewItem() {
		if(!this.isEditAll)
			insert newItem.record;
		//TODO - check error?
		addToMap(newItem);
		return cancelNewItem();
	}
	public PageReference cancelNewItem() {
		this.isAddNewItem = false;
		this.newItem = null;
		this.newItems = null;
		return null;
	}
	private void addToMap(DueDiligenceChecklistWrapper ddcw) {
		dueDiligenceList.add(ddcw);
		string groupvalue = (string.isNotEmpty(groupingField)?(string)ddcw.record.get(groupingField):'');
		if(!dueDiligenceMap.containsKey(groupvalue)) {
			dueDiligenceMap.put(groupvalue, new list<DueDiligenceChecklistWrapper>());
			listNames.add(new ListnameWrapper(groupvalue, false));
		}
		dueDiligenceMap.get(groupvalue).add(ddcw);
	}
	
	//
	// edit all methods
	public PageReference saveAll() {
		list<sObject> insList = new list<sObject>();
		list<sObject> updList = new list<sObject>();
		list<sObject> delList = new list<sObject>();
		for(DueDiligenceChecklistWrapper ddcw : dueDiligenceList) {
			if(ddcw.isDeleted)
				delList.add(ddcw.record);
			else if(ddcw.isInserted)
				insList.add(ddcw.record);
			else
				updList.add(ddcw.record);
		}
		if(insList.size() > 0)
			insert insList;
		if(updList.size() > 0)
			update updList;
		if(delList.size() > 0)
			delete delList;
		
		if(this.isEditAll)
			return new PageReference('/' + this.parentId);		// go back to detail page
		else
			return refreshList();				// undo all changes by refreshing the list
	}
	public PageReference cancel() {
		return new PageReference('/' + this.parentId);		// go back to detail page
	}
	public string getEditAllPageURL() {
		string url = ApexPages.currentPage().getUrl();
		if(url.indexOf('?') != -1)
			url = url.substring(0, url.indexOf('?'));
		PageReference editPage = new PageReference(url);
		editPage.getParameters().put('id', this.parentId);
		editPage.getParameters().put('isedit', '1');
		return editPage.getUrl();
	}
	public string getDeleteReturnUrl() {
		if(this.isEditAll)
			return getEditAllPageURL();
		else
			return EncodingUtil.urlEncode('/' + this.parentId, 'UTF-8');
	}

	//
	// one item methods
	public integer oneItem { get; set; }
	public PageReference editOne() {
		DueDiligenceChecklistWrapper oneChecklistItem = findOne(dueDiligenceList, oneItem);
		if(oneChecklistItem != null)
			oneChecklistItem.isEdit = true;
		return null;
	}
	public PageReference saveOne() {	
		DueDiligenceChecklistWrapper oneChecklistItem = findOne(dueDiligenceList, oneItem);
		if(oneCheckListItem != null) {
			update oneChecklistItem.record;
			oneChecklistItem.isEdit = false;
		}
		return null;	   
	}
	public PageReference closeOne() {
		DueDiligenceChecklistWrapper oneChecklistItem = findOne(dueDiligenceList, oneItem);
		if(oneCheckListItem != null) {
			oneChecklistItem.record.put(sObjectName=='Task'?'Status':'Status__c', 'Completed');		// assumed the Completed status is available for usage

			if(!this.isEditAll)					// if edit all mode, commit only when user clicks on Save All button
				update oneChecklistItem.record;
			oneChecklistItem.isEdit = false;
		}
		return null;
	}
	public PageReference deleteOne() {	
		DueDiligenceChecklistWrapper oneChecklistItem = findOne(dueDiligenceList, oneItem);
		if(oneCheckListItem != null) {
			if(!this.isEditAll)					// if edit all mode, commit only when user clicks on Save All button
				delete oneChecklistItem.record;
			oneChecklistItem.isDeleted = true;
			oneChecklistItem.isEdit = false;
			oneChecklistItem.isRendered = false;
		}
		return null;	   
	}
	private DueDiligenceChecklistWrapper findOne(list<DueDiligenceChecklistWrapper> mylist, integer rowNum) {
		for(DueDiligenceChecklistWrapper ddcw : mylist)
			if(ddcw.rowNum == rowNum)
				return ddcw;
		return null;
	}
	private DueDiligenceChecklistWrapper findOne(list<DueDiligenceChecklistWrapper> mylist, id recId) {
		for(DueDiligenceChecklistWrapper ddcw : mylist)
			if(ddcw.record.Id == recId)
				return ddcw;
		return null;
	}
	private DueDiligenceChecklistWrapper findOne(list<DueDiligenceChecklistWrapper> mylist, string listname, string itemname) {
		for(DueDiligenceChecklistWrapper ddcw : mylist)
			if(!ddcw.isDeleted && (string)ddcw.record.get('List_Name__c') == listname && (string)ddcw.record.get('Name') == itemname)
				return ddcw;
		return null;
	}
	
	//
	// methods for deleting entire lists
	public string deleteListname {get; set;}
	public PageReference deleteList() {
		if(string.isNotEmpty(deleteListname)){
			// delete due diligence records where listname = deleteListname
			list<sObject> delList = new list<sObject>();
			for(DueDiligenceChecklistWrapper ddcw : dueDiligenceList)
				if((String)ddcw.record.get('List_Name__c') == deleteListname && !ddcw.isDeleted)
					delList.add(ddcw.record);
			delete delList;
			
			return refreshList();				// refresh the list
		}
		return null;
	}
	
	//
	// methods for sticky sections
	public string stickySectionsIndicator {get; set;}		// values = show or hide
	public string stickySectionsNums { get; set; }
	public PageReference stickySections() {
		system.debug('in stickySections, ind: ' + stickySectionsIndicator + ', sec nums: ' + stickySectionsNums);
		// retrieve existing cookie value
		Cookie sticky = ApexPages.currentPage().getCookies().get('sticky');
		string tempstring = (sticky != null ? sticky.getValue() : '');
		set<string> stickyNames = new set<string>(tempstring.split(','));
		
		// process new ones
		for(string s : stickySectionsNums.split(',')) {
			if(string.isNotBlank(s)) {
				integer i = Integer.valueOf(s);
				if(i < this.listNames.size()) {
					string item = this.listNames.get(i).listName;
					if(stickySectionsIndicator == 'show') {
						stickyNames.remove(item);
						this.listNames.get(i).stickyHide = false;
					}
					else {
						stickyNames.add(item);
						this.listNames.get(i).stickyHide = true;
					}
				}
			}
		}

		// Set the new cookie for the page
		string newstickyvalue = string.join(new list<string>(stickyNames),',');
		system.debug('newstickyvalue: ' + newstickyvalue);
		sticky = new Cookie('sticky', newstickyvalue, null, (60 * 60 * 24 * 30), false);		// 30 days
		ApexPages.currentPage().setCookies(new Cookie[]{sticky});
		
		return null;
	}
	
	//
	// file upload attachment methods
	public Attachment att {get; set;}
	public string oneItemName { get; private set;}
	public PageReference addAttachment() {
		DueDiligenceChecklistWrapper oneChecklistItem = findOne(dueDiligenceList, oneItem);
		if(oneChecklistItem != null) {
			this.att = new Attachment();
			oneItemName = (string)oneChecklistItem.record.get('Name');
		}
		return null;
	}
	public PageReference saveAttachment() {
		DueDiligenceChecklistWrapper oneChecklistItem = findOne(dueDiligenceList, oneItem);
		if(oneChecklistItem != null && string.isNotEmpty(this.att.Name)) {
			this.att.ParentId = oneChecklistItem.record.Id;
			insert this.att;
			oneChecklistItem.addAttachment(this.att.Id, this.att.Name);
			this.att = new Attachment();
		}
		return null;
	}
	public PageReference cancelAttachment() {
		this.att = null;
		return null;
	}
	
	public PageReference printMe() {
		//this.asPDF = true;
		/*string url = ApexPages.currentPage().getUrl();
		if(url.indexOf('?') != -1)
			url = url.substring(0, url.indexOf('?'));
		PageReference editPage = new PageReference(url);
		editPage.getParameters().put('id', this.parentId);
		editPage.getParameters().put('isedit', '1');
		return editPage.getUrl();*/
		//return null;
		PageReference nextPage = ApexPages.currentPage();
		nextPage.getParameters().put('print', '1');
		return nextPage;
	}
	
	//
	// wrapper class
	public class ListnameWrapper {
		public string listName { get; private set; }
		public boolean stickyHide { get; set; }
		public string display {	get { return (stickyHide ? 'none' : 'inline'); } }
		public string notdisplay { get { return (!stickyHide ? 'none' : 'inline'); } }
		public ListnameWrapper(string name, boolean hide) {
			this.listName = name;
			this.stickyHide = hide;
		}
	}
	
	//
	// wrapper class
	public class DueDiligenceChecklistWrapper {
		public SObject record { get; set; }
		public integer rowNum { get; private set; }
		public string[] attachments { get; set; }
		public boolean isEdit { get; set; }
		public boolean isRendered { get; set; }
		public boolean isDeleted { get; set; }
		public boolean isInserted { get; set; }
		public boolean isClosed {
			get {
				string val;
				try {
					val = (string)record.get('Status__c');		// TODO - not sure if this should be hard-coded like this...what other solution can we do to close items?
				} catch (Exception ex) {
					try {
						val = (string)record.get('Status');
					} catch (Exception ex2) {
						val = '';
					}
				}
				return (val=='Completed');
			}
		}
		public boolean hasAttachments { get { return attachments.size()>0; } }

		public DueDiligenceChecklistWrapper(integer rn, SObject sobj) {
			this(rn, sobj, false);
		}
		public DueDiligenceChecklistWrapper(integer rn, SObject sobj, boolean isIns) {
			record = sobj;
			rowNum = rn;
			isInserted = isIns;
			isEdit = false;
			isRendered = true;
			isDeleted = false;
			attachments = new list<string>();
		}
		public void addAttachment(id attid, string attname) { attachments.add(attid+attname); }
	}
	
	//
	// wrapper class
	public class DueDiligenceChecklistTemplateWrapper {
		public String listName { get; set; }
		public integer cnt { get; set; }
		public boolean isChecked { get; set; }
		
		public DueDiligenceChecklistTemplateWrapper(string listName, integer cnt) {
			this.listName = listName;
			this.cnt = cnt;
			this.isChecked = false;
		}
	}
	
		
	//
	// test method for due diligence-specific test scenarios
	// NOTE: You will need to update this testmethod depending on the Parent SObject
	@isTest
	public static void testThisClass_DueDiligence() {
		
		//NOTE: Update these 2 fields if parent object is NOT Account
		string parentObject = 'Deal__c';
		string parentLookupField = 'Deal__c';
		string dueDiligenceObject = 'Due_Diligence_Checklist__c';		// update only if you changed the name of the due diligence checklist object
		
		// insert test data
		sObject acct = createObject(parentObject);
		acct.put('Name', 'testparent');
		insert acct;
		list<sObject> sobjList = new list<sObject>();
		for(integer i=0; i<4; i++) {
			sObject sobj = createObject(dueDiligenceObject);
			sobj.put(parentLookupField, acct.Id);
			sobj.put('List_Name__c', 'list'+(Math.mod(i,3)));
			sobj.put('Name', 'item'+i);
			sobj.put('Comments__c', 'comment item'+i);
			sobj.put('Sort_Order__c', i);
			sobjList.add(sobj);
		}
		insert sobjList;
		
		// add attachments
		list<Attachment> attList = new list<Attachment>();
		for(integer i=0; i<4; i++)
			attList.add(new Attachment(parentId = sobjList[i].Id, Name='test attach'+i, Body=Blob.valueOf('testabc')));
		insert attList;
		
		// add test due diligence template data
		list<sObject> templateList = new list<sObject>();
		for(integer i=0; i<10; i++) {
			sObject templ = createObject('Due_Diligence_Checklist_Template__c');
			templ.put('List_Name__c', 'list'+(Math.mod(i,3)));
			templ.put('Name', 'template item'+i);
			templ.put('Comments__c', 'comment item'+i);
			templ.put('Sort_Order__c', i);
			templateList.add(templ);
		}
		insert templateList;
		
		Test.startTest();
		
		// create new controller instance
		PageReference pageRef = Page.DueDiligenceChecklistPage;
		pageRef.getParameters().put('id', acct.Id);
		Test.setCurrentPageReference(pageRef);
		DueDiligenceChecklistController controller = new DueDiligenceChecklistController(new ApexPages.StandardController(acct));
		
		// set the config parameters
		controller.parentSObjectName = parentObject;
		controller.sObjectName = dueDiligenceObject;
		controller.lookupField = parentLookupField;
		controller.editFields = 'Name, Status__c, Due_Date__c, Assigned_To__c, Date_Assigned__c, Comments__c, Sort_Order__c';
		controller.groupingField = 'List_Name__c';
		controller.sortingField = 'Sort_Order__c';
		
		// call initialization method
		pageRef = controller.refreshList();
		
		// test getter methods
		list<String> strList = controller.availableEditFields;
		strList = controller.allFields;
		boolean bool = controller.isDueDiligence;
		
		// test internal list of entries
		list<DueDiligenceChecklistWrapper> ddList = controller.DueDiligenceList;
		system.assertEquals(4, ddList.size(), 'Error: Controller did not return correct number of item entries.');
		list<ListnameWrapper> nameList = controller.listNames;
		system.assertEquals(3, nameList.size(), 'Error: Controller did not return correct number of groupings.');
		map<String, list<DueDiligenceChecklistWrapper>> ddMap = controller.dueDiligenceMap;
		
		//
		// test one item methods
		controller.oneItem = 0;
		pageRef = controller.editOne();
		// update one item details
		ddList[0].record.put('Due_Date__c', system.today()+10);
		ddList[0].record.put('Comments__c', 'updated comments');
		pageRef = controller.saveOne();
		system.assert(ApexPages.hasMessages()==false, 'Error: Save one failed: ' + ApexPages.getMessages());
		Id recId = ddList[0].record.Id;
		sObject testSobj = database.query('select Id, Due_Date__c, Comments__c from '+dueDiligenceObject+' where Id=:recId');
		system.assertEquals(system.today()+10, testSobj.get('Due_Date__c'), 'Error: Save one item did not properly update the item record.');
		bool = ddList[0].isClosed;
		pageRef = controller.closeOne();
		system.assert(ApexPages.hasMessages()==false, 'Error: Close one row failed: ' + ApexPages.getMessages());
		testSobj = database.query('select Id, Status__c from '+dueDiligenceObject+' where Id=:recId');
		system.assertEquals('Completed', testSobj.get('Status__c'), 'Error: Close one item did not properly update the item record status value.');
		bool = ddList[0].isClosed;
		pageRef = controller.deleteOne();
		system.assert(ApexPages.hasMessages()==false, 'Error: Delete one row failed: ' + ApexPages.getMessages());
		
		//
		// test add new item methods
		pageRef = controller.addNewItem();
		DueDiligenceChecklistWrapper item = controller.newItem;
		string nameStr = 'testnewitem';
		item.record.put('Name', nameStr);
		item.record.put('Due_Date__c', system.today()+1);
		pageRef = controller.saveNewItem();
		system.assert(ApexPages.hasMessages()==false, 'Error: Save new row failed: ' + ApexPages.getMessages());
		testSobj = database.query('select Id, Name, Due_Date__c, '+parentLookupField+' from '+dueDiligenceObject+' where Name=:nameStr limit 1');
		system.assertEquals(acct.Id, testSobj.get(parentLookupField), 'Error: Save new item did not associate to parent record.');
		system.assertEquals(system.today()+1, testSobj.get('Due_Date__c'), 'Error: Save new item did not properly insert the new item record.');
		
		//
		// NOTE: for due diligence scenario only
		// test add new template logics
		pageRef = controller.addNewTemplate();
		list<DueDiligenceChecklistTemplateWrapper> templateItems = controller.newTemplateItems;
		// check all template items
		for(DueDiligenceChecklistTemplateWrapper it : templateItems)
			it.isChecked = true;
		// save
		pageRef = controller.saveNewTemplate();
		system.assert(ApexPages.hasMessages()==false, 'Error: Save new template rows failed: ' + ApexPages.getMessages());
		
		//
		// test edit all methods
		pageRef = Page.DueDiligenceChecklistPage;
		pageRef.getParameters().put('id', acct.Id);
		pageRef.getParameters().put('isedit', '1');
		Test.setCurrentPageReference(pageRef);
		// new controller instance for isedit=1
		controller = new DueDiligenceChecklistController(new ApexPages.StandardController(acct));
		// set the config parameters
		controller.parentSObjectName = parentObject;
		controller.sObjectName = dueDiligenceObject;
		controller.lookupField = parentLookupField;
		controller.editFields = 'Name, Status__c, Due_Date__c, Assigned_To__c, Date_Assigned__c, Comments__c, Sort_Order__c';
		controller.groupingField = 'List_Name__c';
		controller.sortingField = 'Sort_Order__c';
		// refreshlist
		pageRef = controller.refreshList();
		ddList = controller.DueDiligenceList;
		
		// insert some data
		pageRef = controller.addNewItem();
		item = controller.newItem;
		item.record.put('List_Name__c', 'list0');
		item.record.put('Name', 'testnewitem');
		item.record.put('Due_Date__c', system.today()+1);
		pageRef = controller.saveNewItem();
		
		// update some data
		controller.oneItem = 0;
		pageRef = controller.closeOne();
		
		// delete some data
		controller.oneItem = 1;
		pageRef = controller.deleteOne();
		
		// save
		pageRef = controller.saveAll();
		system.assert(ApexPages.hasMessages()==false, 'Error: Save all rows failed: ' + ApexPages.getMessages());
		pageRef = controller.cancel();
		string str = controller.getEditAllPageURL();
		str = controller.getDeleteReturnUrl();
	
		// delete entire lists	
		controller.deleteListname = 'list0';
		controller.deleteList();
		
		// sticky sections
		controller.stickySectionsNums = '0,1';
		controller.stickySectionsIndicator = 'hide';
		controller.stickySections();
		controller.stickySectionsIndicator = 'show';
		controller.stickySections();
	
		// add attachment
		controller.oneItemName = controller.dueDiligenceList[0].record.Id;
		controller.addAttachment();
		controller.att.Name = 'test add attachment';
		controller.att.Body = Blob.valueOf('test attachment');
		controller.saveAttachment();
		controller.cancelAttachment();	
	
		Test.stopTest();
	}
	
	
	@isTest
	public static void testThisClass_DueDiligence_Print() {
		
		//NOTE: Update these 2 fields if parent object is NOT Account
		string parentObject = 'Deal__c';
		string parentLookupField = 'Deal__c';
		string dueDiligenceObject = 'Due_Diligence_Checklist__c';		// update only if you changed the name of the due diligence checklist object
		
		// insert test data
		sObject acct = createObject(parentObject);
		acct.put('Name', 'testparent');
		insert acct;
		list<sObject> sobjList = new list<sObject>();
		for(integer i=0; i<4; i++) {
			sObject sobj = createObject(dueDiligenceObject);
			sobj.put(parentLookupField, acct.Id);
			sobj.put('List_Name__c', 'list'+(Math.mod(i,3)));
			sobj.put('Name', 'item'+i);
			sobj.put('Comments__c', 'comment item'+i);
			sobj.put('Sort_Order__c', i);
			sobjList.add(sobj);
		}
		insert sobjList;
		
		Test.startTest();
		
		// create new controller instance
		PageReference pageRef = Page.DueDiligenceChecklistPage;
		pageRef.getParameters().put('id', acct.Id);
		pageRef.getParameters().put('print', '1');		// test print
		Test.setCurrentPageReference(pageRef);
		DueDiligenceChecklistController controller = new DueDiligenceChecklistController(new ApexPages.StandardController(acct));
		
		// set the config parameters
		controller.parentSObjectName = parentObject;
		controller.sObjectName = dueDiligenceObject;
		controller.lookupField = parentLookupField;
		controller.editFields = 'Name, Status__c, Due_Date__c, Assigned_To__c, Date_Assigned__c, Comments__c, Sort_Order__c';
		controller.groupingField = 'List_Name__c';
		controller.sortingField = 'Sort_Order__c';
		
		// call initialization method
		pageRef = controller.refreshList();
		
		controller.printMe();
		
		Test.stopTest();
	}
	
}