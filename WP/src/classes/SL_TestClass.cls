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
private class SL_TestClass 
{

    static testMethod void test_SL_createAListController() 
    {
    	
    	Company_List__c objList = new Company_List__c(Name = 'test');
    	insert objList;
    	
    	ApexPages.StandardController sc = new ApexPages.standardController(objList);
    	
        SL_createAListController obj = new SL_createAListController(sc);
        
        Group objGroup = new Group();
        objGroup = [Select Id, Email, DeveloperName from Group  ORDER BY DeveloperName LIMIT 1];
       	
       	Group objGroup1 = new Group();
       	objGroup1.Name = 'NewTestGroup';
       	objGroup1.DeveloperName = 'NewTestGroup';
       	insert objGroup1;
		       	
        obj.lstUserOrGroup_Output.add(new SelectOption(objGroup.Id, 'Public Group : ' + objGroup.DeveloperName));
        obj.lstUserOrGroup_Input.add(new SelectOption(objGroup.Id, 'Public Group : ' + objGroup.DeveloperName));
        obj.strUserOrGroup = 'PG : ' + objGroup.DeveloperName;
        
        User objUser = [Select Id from User limit 1];
        User objUser1 = [Select Id from User Where Id !=: UserInfo.getUserId() AND isActive = true limit 1];
        
        Company_List__c objList22 = new Company_List__c(Name = 'test',OwnerId = objUser1.Id);
    	//insert objList22;
    	
        
        obj.strSecurityAccessLevel = 'Read';
        obj.strUserOrGroup = 'User';
        obj.strUserOrGroups = objGroup.Id;
        obj.fetchCurrentUserOrGroupPicklistValues();
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
       	obj.checkUserPermissions();
       	  
        obj.strUserOrGroup = 'User';
        obj.strSecurityAccessLevel = 'None';
        obj.strUserOrGroups = 'PG<>'+objGroup.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strUserOrGroup = 'User';
        obj.strSecurityAccessLevel = 'None';
        obj.strUserOrGroups = objGroup.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strUserOrGroup = 'Firm';
        obj.strSecurityAccessLevel = 'None';
        obj.strUserOrGroups = objGroup.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strUserOrGroup = 'Firm';
        obj.strSecurityAccessLevel = 'Read';
        obj.strUserOrGroups = objGroup.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strUserOrGroup = 'Firm';
        obj.strSecurityAccessLevel = 'Read/Write';
        obj.strUserOrGroups = objGroup.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strUserOrGroup = 'User';
        obj.strSecurityAccessLevel = 'None';
        obj.strUserOrGroups = 'GroupAndUser';
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strSecurityAccessLevel = 'Read/Write';
        obj.strUserOrGroup = 'User';
        obj.strUserOrGroups = 'GroupAndUser';
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strSecurityAccessLevel = 'Read/Write';
        obj.strUserOrGroup = 'Group';
        obj.strUserOrGroups = objUser.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
        obj.strSecurityAccessLevel = 'Read/Write';
        obj.strUserOrGroup = 'Group';
        obj.strUserOrGroups = objUser1.Id;
        obj.fetchUserOrTGroupPicklistValues();
        obj.btnSave();
        obj.btnCancel();
        
       	obj.getSelectedItems();
       	obj.getunselectedItems();
       	           
        Company_List__c objList2 = new Company_List__c(Name = 'Test1');
        
        ApexPages.StandardController stc = new ApexPages.standardController(objList2);
		SL_createAListController obj1 = new SL_createAListController(stc);
		
		
		obj1.strSecurityAccessLevel = 'Read';
		obj1.strUserOrGroup = 'Group';
		obj1.strUserOrGroups ='objGroup1.DeveloperName;objGroup.DeveloperName;';
        obj1.fetchUserOrTGroupPicklistValues();
        
        obj1.btnSave();
        obj1.btnCancel();
        
        obj1.strSecurityAccessLevel = 'Read/Write';
        obj1.strUserOrGroup = 'User';
        obj1.strUserOrGroups = 'objGroup1.DeveloperName;objGroup.DeveloperName;';
        obj1.fetchUserOrTGroupPicklistValues();
        obj1.btnSave();
        obj1.btnCancel();
        
        obj1.strSecurityAccessLevel = 'Read/Write';
        obj1.strUserOrGroup = 'Firm';
        obj1.strUserOrGroups = 'GroupAndUser';
        obj1.fetchUserOrTGroupPicklistValues();
        obj1.btnSave();
        obj1.btnCancel();
        
        obj1.strSecurityAccessLevel = 'Read';
        obj1.strUserOrGroup = 'User';
        obj1.strUserOrGroups = 'GroupAndUser';
        obj1.fetchUserOrTGroupPicklistValues();
        obj1.btnSave();
        obj1.btnCancel();
        
        obj1.strSecurityAccessLevel = 'Read/Write';
        obj1.strUserOrGroup = 'Group';
        obj1.strUserOrGroups = 'GroupAndUser';
        obj1.fetchUserOrTGroupPicklistValues();
        obj1.btnSave();
        obj1.btnCancel();
        
        obj1.fetchUserOrTGroupPicklistValues();
        
    }
    
/*    static testMethod void test_SL_TickSheetProperty_Handler() 
    {
    	
    	RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];
        
        // Create dummy account
        Account testAccount   = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
    	
    	
    	RecordType objRecordType = new RecordType();
    	objRecordType = [Select r.SobjectType, r.Id From RecordType r where r.SobjectType = 'Contact' LIMIT 1];
    	 Contact testContact = new Contact(
          AccountId = testAccount.Id
          ,Geography__c = 'Asia'
          ,Industry__c = 'Software'
         ,RecordTypeId = objRecordType.Id 
         ,LastName = 'Test Contact Name 2'
        );
        insert testContact;
        
        
        Contact testContact1 = new Contact(
          AccountId = testAccount.Id
          ,Industry__c = 'Software'
         ,RecordTypeId = objRecordType.Id 
         ,LastName = 'Test Contact Name 2'
        );
        insert testContact1;
        
        Ticksheet_Property__c objTicksheet = new Ticksheet_Property__c();
        objTicksheet.Save_Location__c = 'Geography__c';
        objTicksheet.Name = 'Test';
        insert objTicksheet;
        
        Ticksheet_Property__c objTicksheet1 = new Ticksheet_Property__c();
    	objTicksheet1 = [select Save_Location__c, Name, Id from Ticksheet_Property__c where Id =: objTicksheet.Id];
    	objTicksheet1.Save_Location__c = 'Industry__c';
    	objTicksheet1.Id = objTicksheet.Id;
    	update objTicksheet1;
    }*/
    
   //This class is use to cover the test coverage of Sl_AddCompanyContactList
    static testMethod void test_SL_ShowListsNameWithHyperlink() 
    {
    	Contact sObjContact = new Contact();
    	Account sObjAccount = new Account(Name='Test');
    	insert sObjAccount;
    	ApexPages.StandardController objStandardController1 = new ApexPages.standardController(sObjAccount);
     	SL_ShowListsNameWithHyperlink objController1 = new SL_ShowListsNameWithHyperlink(objStandardController1);
    	
    	
    	
    	Company_List__c sObjCompanyList = new Company_List__c(Name='Test');
    	insert sObjCompanyList;
    	
    	Company_List_Member__c sObjCLM = new Company_List_Member__c();
    	sObjCLM.Company__c = sObjAccount.Id;
    	sObjCLM.Company_List__c = sObjCompanyList.Id;
    	insert sObjCLM;
    	Apexpages.currentPage().getParameters().put('id', sObjAccount.Id);
    	ApexPages.StandardController objStandardController = new ApexPages.standardController(sObjAccount);
     	SL_ShowListsNameWithHyperlink objController = new SL_ShowListsNameWithHyperlink(objStandardController);
     	Apexpages.currentPage().getParameters().put('id', sObjAccount.Id);
    	
    }
    
    //This class is use to cover the test coverage of Sl_AddCompanyContactList
    static testMethod void test_SL_AddCompanyContactList() 
    {
    	
    	
    	
    	Company_List__c sObjCompanyList = new Company_List__c(Name='Test');
    	sObjCompanyList.Show_in_Quick_Add__c = true;
    	insert sObjCompanyList;
    	Company_List__c sObjCompanyList11 = new Company_List__c(Name='Test1');
    	sObjCompanyList11.Show_in_Quick_Add__c = true;
    	insert sObjCompanyList11;
    	Company_List__c sObjCompanyList2 = new Company_List__c(Name='Test12');
    	sObjCompanyList2.Show_in_Quick_Add__c = true;
    	insert sObjCompanyList2;
    	
    	SL_AddCompanyContactList sObjSL_AddCompanyContactList = new SL_AddCompanyContactList();
    	SL_AddCompanyContactList.WrapperClassToBindCheckBox sObjInnerClass = new SL_AddCompanyContactList.WrapperClassToBindCheckBox(sObjCompanyList, false);
    	
    	Account sObjAccount = new Account(Name='Test');
    	insert sObjAccount;
    	
    	Account sObjAcc = new Account(Name='Test2');
    	insert sObjAcc;
    	
    	Contact sObjcontact = new Contact();
    	sObjcontact.LastName = 'test1';
    	insert sObjcontact;
    	Apexpages.currentPage().getParameters().put('id', sObjcontact.Id);
    	
    	String Ids = Apexpages.currentPage().getParameters().get('id');
    	List<Company_List__c> lstCL = new List<Company_List__c>();
    	
    	Company_List__c sObjCompanyList1 = new Company_List__c(Name='Test1');
    	sObjCompanyList1.OwnerId = Userinfo.getUserId();
    	insert sObjCompanyList1;
    	
    	Company_List__c sObjCompanyList12 = new Company_List__c(Name='Test11');
    	sObjCompanyList12.OwnerId = Userinfo.getUserId();
    	lstCL.add(sObjCompanyList12);
    	
    	
    	Company_List__c sObjCompanyList111 = new Company_List__c(Name='Test111');
    	sObjCompanyList111.OwnerId = Userinfo.getUserId();
    	lstCL.add(sObjCompanyList111);
    	
    	insert lstCL;
    	
    	
    	Company_List_Member__c sObjCLM = new Company_List_Member__c();
    	sObjCLM.Contact__c = Apexpages.currentPage().getParameters().get('id');
    	sObjCLM.Company_List__c = sObjCompanyList.Id;
    	insert sObjCLM;
    	
    	Company_List_Member__c sObjCLM2 = new Company_List_Member__c();
    	//sObjCLM2.Company__c = sObjAcc.Id;
        sObjCLM2.Company__c = sObjAcc.Id;
    	sObjCLM2.Company_List__c = sObjCompanyList11.Id;
    	insert sObjCLM2;
    	
    	Company_List_Member__c sObjCLM1 = new Company_List_Member__c();
    	sObjCLM1.Contact__c = sObjcontact.Id;
    	sObjCLM1.Company_List__c = sObjCompanyList.Id;
    	insert sObjCLM1;
    	
    	sObjSL_AddCompanyContactList.isHeaderSelected = true;
    	
    	sObjInnerClass.isChecked = true;
    	
    	sObjSL_AddCompanyContactList.createCompanyListMembers();
    	sObjInnerClass.isChecked = false;
    	sObjSL_AddCompanyContactList.isHeaderSelected = false;
    	sObjSL_AddCompanyContactList.createCompanyListMembers();
    	sObjSL_AddCompanyContactList.FirstPage = 1;
    	sObjSL_AddCompanyContactList.page = 1;
    	sObjSL_AddCompanyContactList.TotalRows = 12;
    	sObjSL_AddCompanyContactList.PageSize = 5;
    	sObjSL_AddCompanyContactList.LastPage = 4;
    	sObjSL_AddCompanyContactList.page = 0;
    	sObjSL_AddCompanyContactList.goToPage();
    	
    	sObjSL_AddCompanyContactList.firstPage();
    	sObjSL_AddCompanyContactList.lastPage();
    	sObjSL_AddCompanyContactList.nextPage();
    	sObjSL_AddCompanyContactList.previousPage();
    	//Apexpages.currentPage().getParameters().put('id', sObjcontact.Id);
    	sObjSL_AddCompanyContactList.isHeaderSelected = true;
    	sObjInnerClass.isChecked = true;
    	sObjSL_AddCompanyContactList.createCompanyListMembers();
    	
    }
   
}