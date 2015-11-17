/*
*		PropertyShowPhotosController is apex controller class for displaying and uploading Property Photos to/from public Document folder called 'Property Images'.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 10, 2013
* 
*/
public with sharing virtual class PropertyShowPhotosController extends ShowImageUploadController {
 
		
	public PropertyShowPhotosController(ApexPages.StandardController controller) {
		super(controller);
		
		// override these values
		this.sobjType = 'Property__c';
		this.imageOrder = new list<string> { 'PP', 'FP', 'RM' };
		this.documentFieldMap = new map<string, DocumentIdField> { 
		'PP' => new DocumentIdField('PP', 'Property Photo', 'Property_Photo_Document_Id__c'), 
		'FP' => new DocumentIdField('FP', 'Floor Plan', 'Floorplan_Image_Document_Id__c'),
		'RM' => new DocumentIdField('RM', 'Retail Map', 'Retailmap_Image_Document_Id__c') };
		
		this.MyController = this;
	}
	
	//
	// test methods
	@isTest
	static void Test_ThisController() {
		
		// create dummy data
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='TestLocation');
		insert loc;
    	Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id);
		insert prop;
    	
    	Test.startTest();
    	
    	PageReference testPageReference = Page.PropertyShowPhotosPage;
		Test.setCurrentPage(testPageReference);
    	PropertyShowPhotosController controller = new PropertyShowPhotosController(new ApexPages.StandardController(prop));
    	controller.init(); 
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller initiatizing code failed - ' + ApexPages.getMessages());
    	
    	controller.getImageLocations();
    	
		// test each imagelocation and save
    	controller.uploadDoc = ShowImageUploadController.createTestDocument();
    	controller.imageLocation = 'PP';	// property photo
    	controller.saveDocument();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller save document failed for property photo - ' + ApexPages.getMessages());
		
		controller.uploadDoc = ShowImageUploadController.createTestDocument();
    	controller.imageLocation = 'FP';	// floor plan
    	controller.saveDocument();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller save document failed for floor plan - ' + ApexPages.getMessages());
    	
    	controller.uploadDoc = ShowImageUploadController.createTestDocument();
    	controller.imageLocation = 'RM';	// retail map
    	controller.saveDocument();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller save document failed retail map - ' + ApexPages.getMessages());
		
		// test update
		controller.uploadDoc = ShowImageUploadController.createTestDocument();
    	controller.imageLocation = 'PP';	// property photo
    	controller.saveDocument();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller save document failed for property photo update - ' + ApexPages.getMessages());
		
		// assert property fields
		list<Property__c> testProp = [select id, name, Property_Photo_Document_Id__c, Floorplan_Image_Document_Id__c, Retailmap_Image_Document_Id__c from Property__c where id = :prop.Id];
		system.assertEquals(1, testProp.size(), 'Error: Unable to retrieve back property record for field validations.');
		system.assertNotEquals(null, testProp[0].Property_Photo_Document_Id__c, 'Error: property photo document id value was not set on the property record.');
		system.assertNotEquals(null, testProp[0].Floorplan_Image_Document_Id__c, 'Error: floor plan document id value was not set on the property record.');
		system.assertNotEquals(null, testProp[0].Retailmap_Image_Document_Id__c, 'Error: retail map document id value was not set on the property record.');
		
		// test delete
		controller.deleteImageLocation = 'PP';
		controller.deleteImage();
    	system.assertEquals(false, controller.hasMessages, 'Error: Controller delete document failed for property photo delete - ' + ApexPages.getMessages());
		
		Test.stopTest();
	}

}