/*
*		NewLocationNeighborhoodOverrideCntrlr is apex controller class for overriding the std New Location/Neighborhood page.  Uses the show photos pages/controller.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 15, 2013
* 
*/
public with sharing class NewLocationNeighborhoodOverrideCntrlr extends ShowImageUploadController {

	public boolean isEditMode { get; private set; }
	private string retUrl;
	private string saveUrl;
	
	public NewLocationNeighborhoodOverrideCntrlr(ApexPages.StandardController controller) {
		super(controller);
		this.isEditMode = true;
	}
	
	public PageReference init2() {
				
		if(this.sobj == null) {
			if(this.sobjId != null) {
	            Id locId = this.sobjId;
	            system.debug('in init2, loc id is ' + locId);
	            string query = 'select ' + generateListOfLocationNeighborhoodFields() + ' From Location_Neighborhood__c where Id=:locId';
	            this.sobj = database.query(query);
			}
			else
				this.sobj = ShowImageUploadController.createObject('Location_Neighborhood__c');
				
            system.debug('in init2, location/neighborhood is ' + this.sobj);
		}
		
		retUrl = ApexPages.currentPage().getParameters().get('retURL');
		saveUrl = ApexPages.currentPage().getParameters().get('saveURL');
		
		return super.init();	// note: the base or super init function must be call after this class initializing items
	}
	
	private string generateListOfLocationNeighborhoodFields() {
		return string.join(new list<string>(Schema.SObjectType.Location_Neighborhood__c.fields.getMap().keySet()), ',').replace('map_coordinates__c,', '');		// fix invalid field
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