/*
*		NewPropertyOverrideController is apex controller class for overriding the std New Property page.  Uses the property show photos pages/controller.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 15, 2013
* 
*/
public with sharing class NewPropertyOverrideController extends PropertyShowPhotosController {

	public boolean isEditMode { get; private set; }
	private string retUrl;
	private string saveUrl;
	
	public NewPropertyOverrideController(ApexPages.StandardController controller) {
		super(controller);
		this.isEditMode = true;
	}
	
	public PageReference init2() {
				
		if(this.sobj == null) {
			if(this.sobjId != null) {
	            Id propId = this.sobjId;
	            system.debug('in init2, prop id is ' + propId);
	            string query = 'select ' + generateListOfPropertyFields() + ' From Property__c where Id=:propId';
	            this.sobj = database.query(query);
			}
			else
				this.sobj = ShowImageUploadController.createObject('Property__c');
				
            system.debug('in init2, property is ' + this.sobj);
		}
		
		retUrl = ApexPages.currentPage().getParameters().get('retURL');
		saveUrl = ApexPages.currentPage().getParameters().get('saveURL');
		
		return super.init();	// note: the base or super init function must be call after this class initializing items
	}
	
	private string generateListOfPropertyFields() {
		return string.join(new list<string>(Schema.SObjectType.Property__c.fields.getMap().keySet()), ',').replace('map_coordinates__c,', '');		// fix invalid field
    }
    
	public PageReference editMe() {
		// not implemented at this time
		return null;
	}
	
	public PageReference saveMe() {
		try {
			if(this.sobj.Id == null)
				insert this.sobj;
			else
				update this.sobj;

			return returnPage(true);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + ex.getMessage()));
		}
		return null;
	}
	
	public PageReference cancelMe() {
		return returnPage(false);
	}
	
	private PageReference returnPage(boolean success) {
		return new PageReference(success&&saveUrl!=null ? saveUrl : !success&&retUrl!=null ? retUrl : this.sobj.Id!=null ? '/'+this.sobj.Id : '/home/home.jsp');
	}
	
	//
	// TODO - test methods
	@isTest
	static void Test_thisController() {
	}
}