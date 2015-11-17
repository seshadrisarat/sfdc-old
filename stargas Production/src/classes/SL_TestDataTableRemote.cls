/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_TestDataTableRemote {
	
	private static Account objAcc;
	private static Opportunity objOpp;
	private static Territory__c objTerritory;
	private static Division__c objDivision;
	private static String strOilRecTypeOpportunity = '';
	private static String strOilRecTypePriceTable = '';
	private static String strPropaneRecTypePriceTable = '';
	private static String strPropaneRecTypeOpportunity = '';
	
	//Test code SL_DataTables_Remote controller
    static testMethod void TestDataTableRemote() 
    {
			
		Test.startTest();
		createTestData();
		ApexPages.StandardController controller = new ApexPages.StandardController(objOpp);
		SL_DataTables_Remote dataTableRemote = new SL_DataTables_Remote(controller);  
		SL_DataTables_Remote objdataTableRemote = new SL_DataTables_Remote();  			
		SL_DataTables_Remote.getFieldSetFields('Oil_Rec_Fieldset', 'Price_Table__c');
		Test.stopTest();
    }
    
	//Testing SL_DataTableRowsJSONController controller for Oil record type
    static testMethod void TestDataTableRowsJSONController() 
    {
    	Test.startTest();
    	createTestData();
    	
    	Price_Table__c objPT = new Price_Table__c(RecordTypeId= strPropaneRecTypePriceTable);
    	insert objPT;
    	
    	System.currentPageReference().getParameters().put('sObjectName',''+'Price_Table__c');
		System.currentPageReference().getParameters().put('fieldSetName','Oil_Rec_Fieldset');
		System.currentPageReference().getParameters().put('filter',' where RecordType.Name = \'Oil\'');
		
    	Sl_DataTableRowsJsonController objJSON = new Sl_DataTableRowsJsonController();
    	
    	Test.stopTest();
    }
    //Testing SL_DataTableRowsJSONController controller for Oil record type
    static testMethod void TestDataTableRowsJSONControllerSameRecType() 
    {
    	Test.startTest();
    	createTestData();
    	
    	Price_Table__c objPT = new Price_Table__c(RecordTypeId= strOilRecTypePriceTable, Division_Group__c = '1');
    	insert objPT;
    	
    	System.currentPageReference().getParameters().put('sObjectName',''+'Price_Table__c');
		System.currentPageReference().getParameters().put('fieldSetName','Oil_Rec_Fieldset');
		System.currentPageReference().getParameters().put('filter',' where RecordType.Name = \'Oil\'');
		System.currentPageReference().getParameters().put('divisiongroup','1');
		
    	Sl_DataTableRowsJsonController objJSON = new Sl_DataTableRowsJsonController();
    	
    	Test.stopTest();
    }
    
    //Testing SL_DataTableRowsJSONController controller for Propane record type
    static testMethod void TestDataTableRowsJSONControllerPropaneRecType() 
    {
    	Test.startTest();
    	createTestData();
    	objOpp.RecordTypeId = 	strPropaneRecTypeOpportunity;
		update objOpp;
    	Price_Table__c objPT = new Price_Table__c(RecordTypeId= strPropaneRecTypePriceTable,  Tank_Type__c = 'test', Division_Name__c= objDivision.Id);
    	insert objPT;
    	
    	System.currentPageReference().getParameters().put('sObjectName',''+'Price_Table__c');
		System.currentPageReference().getParameters().put('fieldSetName','Propane_Rec_Fieldset');
		System.currentPageReference().getParameters().put('filter',' where RecordType.Name = \'Propane\'');
		System.currentPageReference().getParameters().put('tanktype',''+'test');
		System.currentPageReference().getParameters().put('division',objDivision.Id);
		
    	Sl_DataTableRowsJsonController objJSON = new Sl_DataTableRowsJsonController();
    	
    	Test.stopTest();
    }
    
    //Creating test data
    private static void createTestData()
    {
    	DivOilPriceGrp__c objDivOilPriceGrp1 = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp1;
    	
    	objDivision = new Division__c(Division_Oil_Pricing_Group__c = '1');
	    insert objDivision;
	    
	    objTerritory = new Territory__c(Division__c = objDivision.Id);
	    insert objTerritory;
    	
    	objAcc = new Account(LastName='TestAcc', Territory__c = objTerritory.Id);
	    insert objAcc;
	   
		for(RecordType objRecordType : [SELECT Id, sObjectType, Name FROM RecordType WHERE (sObjectType = 'Opportunity' OR sObjectType = 'Price_Table__c') AND isActive = TRUE])
			if(objRecordType.sObjectType == 'Opportunity' && objRecordType.Name == 'Oil')
				strOilRecTypeOpportunity = objRecordType.Id;
			else if(objRecordType.sObjectType == 'Price_Table__c' && objRecordType.Name == 'Oil')
				strOilRecTypePriceTable = objRecordType.Id;
			else if(objRecordType.sObjectType == 'Price_Table__c' && objRecordType.Name == 'Propane')
				strPropaneRecTypePriceTable = objRecordType.Id;
			else if(objRecordType.sObjectType == 'Opportunity' && objRecordType.Name == 'Propane')
				strPropaneRecTypeOpportunity = objRecordType.Id;
	
		objOpp = new Opportunity(Name='TestOppt', CloseDate=Date.today(), StageName='Open', Tank_Type__c = 'test',
		 AccountId =objAcc.Id, RecordTypeId= strOilRecTypeOpportunity ,Territory__c = objTerritory.Id, HHAU__c = 'Email');
		insert objOpp;
    	
    }
}