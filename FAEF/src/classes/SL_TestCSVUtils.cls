@isTest
public class SL_TestCSVUtils{
    
  	/**
	* Name		  : testParseCSV
	* Parameters  : None
	* Description : testMethod is validating data supplied in CSV with correct output data after parsing.
	*/
    static testmethod void testParseCSV()
    {
        test.startTest();
        // Validating field containing values
        string csvContent = 'firstname,lastname\nTest,Guy';
        List<List<String>> parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        list<contact> contactList = (list<contact>) SL_CSVUtils.csvTosObject(parsedContent, 'contact');
        system.assertEquals(contactList.size(),1);
        system.assertEquals(contactList[0].firstname,'Test');
        system.assertEquals(contactList[0].lastname,'Guy');
        
        // Validating field containing comma values
        csvContent = 'firstname,lastname\n"Test,Name",Guy';
        parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        contactList = (list<contact>) SL_CSVUtils.csvTosObject(parsedContent, 'contact');
        system.assertEquals(contactList.size(),1);
     	system.assertEquals(contactList[0].firstname,'Test,Name');
       	system.assertEquals(contactList[0].lastname,'Guy');
        
     	// Validating field containing "" value 
     	csvContent = 'firstname,lastname\n"""Test Name""",Guy';  
        parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        contactList = (list<contact>) SL_CSVUtils.csvTosObject(parsedContent, 'contact');
        system.assertEquals(contactList.size(),1);
     	system.assertEquals(contactList[0].firstname,'"Test Name"');
       	system.assertEquals(contactList[0].lastname,'Guy');
        
        // Validating field containing "" value 
        csvContent = 'firstname,lastname\nTest"Name,Guy';  
        parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        contactList = (list<contact>) SL_CSVUtils.csvTosObject(parsedContent, 'contact');
        system.assertEquals(contactList.size(),1);
     	system.assertEquals(contactList[0].firstname,'Test"Name');
       	system.assertEquals(contactList[0].lastname,'Guy');
       	
        csvContent = 'firstname,lastname\nTest"Name,Guy';  
        parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        contactList = (list<contact>) SL_CSVUtils.csvTosObject(parsedContent, 'Test');
        
        csvContent = 'test,lastname\nTest"Name,Guy';  
        parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        contactList = (list<contact>) SL_CSVUtils.csvTosObject(parsedContent, 'contact');
        
        csvContent = 'ActivityDate\n'+Datetime.now();  
        parsedContent = SL_CSVUtils.parseCSV(csvContent,false);
        List<Task> lstTask= (list<Task>) SL_CSVUtils.csvTosObject(parsedContent, 'Task');
        
        test.stoptest();
    } 
    
	/**
	* Name		  : test_SL_UploadEquipment
	* Parameters  : None
	* Description : Method is uploading CSV and verifying whether we are getting correct number of sObject rows or not. 
	*/
    static testmethod void test_SL_UploadEquipment()
    {
	   	Letter_of_Intent__c objOLI = new Letter_of_Intent__c();
    	insert objOLI;
    	
    	Schedule__c objSch = new Schedule__c( Letter_of_Intent__c = objOLI.id);
    	insert objSch;
    	Equipment__c objEquipment = new Equipment__c(Schedule__c=objSch.Id);	
    	insert objEquipment; 
    	Equipment__c objEquipment1 = new Equipment__c(Schedule__c=objSch.Id);	
    	insert objEquipment1; 
    	test.startTest();
    	
		ApexPages.currentPage().getParameters().put('schId',objSch.id);    	
    	SL_UploadEquipment objUpload = new SL_UploadEquipment();
    	//Validating upload 
    	String strCSV = 'Name,Quantity__c,Unit_Price__c,Equipment_Type__c,Acceptance_Date__c,Location_Upload__c,Sale_Leaseback__c,Id\nTest1,23,2000,Mainframes and Servers,12/12/2013,12,true,'+objEquipment.Id+'\n"Test2",40,4000,"Computer-related Services","12-12-2013,15,false,'+objEquipment1.Id ;
    	objUpload.csv = Blob.valueOf(strCSV);
    	objUpload.upload();
    	//Validating sObject rows
    	system.assertEquals(objUpload.equipList.size(), 2); 
    	
    	//Validating save fuctionality
    	objUpload.save();
    	List<Equipment__c> lstEquipment = [select id from Equipment__c where Schedule__c = :objSch.id];
    	system.assertEquals(lstEquipment.size(),2);
    	
    	//Validating back fuctionality
    	objUpload.back();
    	system.assertEquals(objUpload.equipList.size(), 0);
    	objUpload.backToParent();
    	test.stopTest();
    } 
}