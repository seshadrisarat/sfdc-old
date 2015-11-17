/*
*		ShowImageUploadController is base apex controller class for displaying and uploading images to/from public Document folder called 'Property Images'.
*		Sobject is Location_Neighborhood__c. 
*
*		Author	:	Wilson Ng 
*		Date	:	January 16, 2013
* 
*/
public with sharing virtual class ShowImageUploadController {
 
	static string FOLDER_NAME				= 'Property_Images';
	static string DOCUMENT_URL				= '/servlet/servlet.ImageServer?oid='+UserInfo.getOrganizationId()+'&id=';

	public sObject sobj { get; protected set; }
	public Id sobjId { get; protected set; }
	public Id folderId { get; protected set; }
	public string sobjType { get; protected set; }
	public list<string> imageOrder { get; protected set; }
	public map<string, DocumentIdField> documentFieldMap { get; protected set; }
	public Document uploadDoc { get; set; }
	public ShowImageUploadController MyController { get; set; }
	public boolean hasMessages { get { return ApexPages.hasMessages(); } }
	
	// upload image selector type
	public string imageLocation { get; set; }
	public List<SelectOption> getImageLocations() {
		List<SelectOption> options = new List<SelectOption>();
		for(string imgloc : imageOrder) {
			DocumentIdField dif = documentFieldMap.get(imgloc);
			options.add(new SelectOption(dif.abbrev, dif.label));
		}
		return options;
	}
	
	public ShowImageUploadController(ApexPages.StandardController controller) {
		this.sobjId = controller.getId();
		
		// specify the image document fields in sobject
		this.sobjType = 'Location_Neighborhood__c';
		this.imageOrder = new list<string> { 'RM' };
		this.documentFieldMap = new map<string, DocumentIdField> { 
		'RM' => new DocumentIdField('RM', 'Retail Map', 'Retailmap_Image_Document_Id__c') };
		
		this.MyController = this;
	}
	
	public PageReference init() {
		
		// retrieve folder id
		Folder[] folderList = [select Id, Name from Folder where DeveloperName = :FOLDER_NAME limit 1];
		if(folderList.size() == 0)
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to find public Property Images folder.  Please contact your system administrator.'));
		else
			this.folderId = folderList[0].Id;
			
		// retrieve sobject details
		if(this.sobj == null) {
			string sobjId = this.sobjId;
			string query = string.format('select Id, Name, {1} from {0} where Id = :sobjId', new list<string> { this.sobjType, getFieldNames() } );
			this.sobj = (this.sobjId != null ? database.query(query) : createObject(this.sobjType));
			system.debug('in init, sobject is ' + this.sobj);
		}
		
		// retrieve existing document details
		list<Id> docIds = new list<Id>();
		for(DocumentIdField dif : this.documentFieldMap.values()) {
			if(this.sobj.get(dif.fldName) != null) {
				dif.docId = (Id)this.sobj.get(dif.fldName);
				docIds.add(dif.docId);
			}
		}
		for(Document doc : [select Id, Name, Type from Document where Id in :docIds] ) {
			for(DocumentIdField dif : this.documentFieldMap.values()) {
				if(dif.docId == doc.Id) {
					dif.docName = doc.Name;
					dif.imgType = doc.Type;
				}
			}
		}

		// reconcile invalid document ids, ie. if someone manually deleted the document from the org.
		for(DocumentIdField dif : this.documentFieldMap.values()) {
			if(dif.docId != null && dif.docName == null) {
				dif.docId = null;
				this.sobj.put(dif.fldName, null);		// blank out the sobject field
			}
		}
		
		if(this.imageOrder.size() == 1)
			this.imageLocation = this.imageOrder[0];	// if only one option, select it as default

		// instantiate new document photo for uploading
		this.uploadDoc = new Document();
			
		return null;
	}
	
	private string getFieldNames() {
		list<string> strarr = new list<string>();
		for(DocumentIdField dif : this.documentFieldMap.values())
			strarr.add(dif.fldName);
		return string.join(strarr, ',');
	}
	
	public PageReference saveDocument() {
		// clear view state of uploadDoc document...btw, transient keyword did not work for this purpose
		Document tempdoc = this.uploadDoc;
		this.uploadDoc = new Document();
		Document newdoc;
		
		try {
			DocumentIdField dif = this.documentFieldMap.get(imageLocation);
			newdoc = (this.sobj.get(dif.fldName) != null) ? new Document(Id=(Id)this.sobj.get(dif.fldName)) : tempDoc;
			// populate document fields
			newdoc.IsPublic = true;
			newdoc.FolderId = this.folderId;
			// update existing document record
			newdoc.Name = tempdoc.Name;
			newdoc.Body = tempdoc.Body;
			newdoc.ContentType = tempdoc.ContentType;
			//newdoc.Type = tempdoc.Type;  // bug - this does not populate value
			string[] spl = tempdoc.ContentType.split('/');
			newdoc.Type = spl[spl.size()-1];
			
			if(newdoc.Id != null) {
				// update existing photo
				update newdoc;
			}
			else {
				// insert new document record
				insert newdoc;
				// update sobject document id value
				this.sobj.put(dif.fldName, newdoc.Id);
				if(this.sobj.Id != null)
					update this.sobj;
			}
			return init();
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + ex.getMessage()));
			return null;
		}
	}
	
	public string deleteImageLocation { get; set; }
	public PageReference deleteImage() {
		try {
			DocumentIdField dif = this.documentFieldMap.get(deleteImageLocation);
			
			// update sobject field
			this.sobj.put(dif.fldName, null);
			update this.sobj;
			
			// delete actual document record
			delete new Document(Id=dif.docId);
			
			// clear state
			dif.docId = null;
			dif.docName = null;
			dif.imgType = null;
		}
		catch(Exception ex) {
			// ignore and continue
		}
		return null;
	}
	
	//
    // creates sobject instance
    public static sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
            throw new ShowImageUploadException('Unable to describe sobject: '+typeName);
        }
        // Instantiate an sObject with the type passed in as an argument at run time.
        return targetType.newSObject();
    }
	
	public class DocumentIdField {
		public string abbrev { get; set; }
		public string label { get; set; }
		public string fldName { get; set; }
		public string docName { get; set; }
		public Id docId { get; set; }
		public string imgType { get; set; }
		public string docUrl { get { return (docId!=null ? ShowImageUploadController.DOCUMENT_URL+docId : ''); } } 
		public boolean isImage { get { return (imgType=='bmp'||imgType=='gif'||imgType=='jpeg'||imgType=='jpg'||imgType=='png'||imgType=='tiff'); } }
		public DocumentIdField(string abb, string lb, string fd) {
			this.abbrev = abb;
			this.label = lb;
			this.fldName = fd;
		}
	}
	
	public class ShowImageUploadException extends Exception { }

	//
	// test methods
	@isTest
	static void Test_ThisController() {
		
		// create dummy data
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='TestLocation');
		insert loc;
    	
    	Test.startTest();
    	
		PageReference testPageReference = Page.LocationNeighborhoodShowImageUploadPage;
		Test.setCurrentPage(testPageReference);
    	ShowImageUploadController controller = new ShowImageUploadController(new ApexPages.StandardController(loc));
    	controller.init(); 
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller initiatizing code failed - ' + ApexPages.getMessages());
    	
    	controller.getImageLocations();
    	
		// test imagelocation and save
    	controller.uploadDoc = createTestDocument();
    	controller.imageLocation = 'RM';	// retail map
    	controller.saveDocument();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller save document failed retail map - ' + ApexPages.getMessages());
		
		// test update
		controller.uploadDoc = createTestDocument();
    	controller.imageLocation = 'RM';	// retail map
    	controller.saveDocument();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller save document failed for retail map update - ' + ApexPages.getMessages());
		
		// assert location neighborhood fields
		list<Location_Neighborhood__c> testLoc = [select id, name, Retailmap_Image_Document_Id__c from Location_Neighborhood__c where id = :loc.Id];
		system.assertEquals(1, testLoc.size(), 'Error: Unable to retrieve back location neighborhood record for field validations.');
		system.assertNotEquals(null, testLoc[0].Retailmap_Image_Document_Id__c, 'Error: retail map document id value was not set on the location neighborhood record.');
		
		// test delete
		controller.deleteImageLocation = 'RM';
		controller.deleteImage();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller delete document failed for retail map delete - ' + ApexPages.getMessages());
		
		Test.stopTest();
	}
	public static Document createTestDocument() { return new Document(Name='test name', Body=Blob.valueOf('test body'), ContentType='text/plain', Type='txt'); }
	
	@isTest
	static void Test_ThisController_ErrorConditions() {
		
		// create dummy data
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='TestLocation');
		insert loc;
    	
    	Test.startTest();
    	
    	PageReference testPageReference = Page.LocationNeighborhoodShowImageUploadPage;
		Test.setCurrentPage(testPageReference);
    	ShowImageUploadController controller = new ShowImageUploadController(new ApexPages.StandardController(loc));
    	controller.init(); 

    	// test upload and save failure
    	controller.uploadDoc = createTestDocument();
    	controller.uploadDoc.Name = null;	//name is required field
    	controller.imageLocation = 'RM';
    	controller.saveDocument();
    	system.assertEquals(true, controller.hasMessages, 'Error: Controller save document did not fail for missing document name');
		
		// invalid/missing folder
    	FOLDER_NAME = 'invalidfoldername';
    	controller.init(); 
    	system.assertEquals(true, controller.hasMessages, 'Error: Controller initiatizing code did not fail for invalid folder name');
    	
		Test.stopTest();
	}
}