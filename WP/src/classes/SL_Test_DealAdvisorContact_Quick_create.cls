@isTest(SeeAllData=true)
public with sharing class SL_Test_DealAdvisorContact_Quick_create 
{
	
	static testMethod void SL_Test_ctrl_DealAdvisorContact_Quick_create() 
     {
     	
     	   Account testAccount = new Account( Name='Test Account 001');
           insert testAccount;
           
           RecordType objRecordType = [SELECT ID,Name,SobjectType,DeveloperName  FROM RecordType WHERE SobjectType = 'Contact' and DeveloperName = 'Contact'];
           
           system.debug('===========objRecordType================' + objRecordType);
           
            RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
//           Contact objContact = new Contact(LastName = 'Testcontact-00',RecordTypeID = objRecordType.Id);
           Contact objContact = new Contact(LastName = 'Testcontact-00',RecordTypeId = ContRecTypeId.Id,  User_ID__c = UserInfo.getUserId());
           insert objContact;
           
           Contact objContact1 = new Contact(LastName = 'Testcontact-000',RecordTypeID = objRecordType.Id);
           insert objContact1;
           
      
           system.assert(objContact.Id != null);
       
     	   Deal__c testDeal = new Deal__c( Name = 'Test Deal 001' , Company__c = testAccount.Id, WP_Investment__c = 10, WP_Ownership__c = 10 , 
     									  Description__c = 'TestDescription', ISOPENSTAGE__c = 1 , Stage__c = 'Early-Prospect' , Is_Energy_Opportunity__c = 'No' ); 
           insert testDeal;
          
           ApexPages.currentPage().getParameters().put('did',testDeal.id);
          
           Deal_Advisor_Contact__c objDealAdvisorContact1 = new Deal_Advisor_Contact__c (Deal__c = testDeal.Id); 
           insert objDealAdvisorContact1;
         
     	   SL_ctrl_DealAdvisorContact_Quick_Create objDealAdvisorContact = new SL_ctrl_DealAdvisorContact_Quick_Create();
     	   SL_ctrl_DealAdvisorContact_Quick_Create.DealAdvisorContact objInner = new SL_ctrl_DealAdvisorContact_Quick_Create.DealAdvisorContact(objDealAdvisorContact1, false);
     	   
     	   
     	   objDealAdvisorContact.searchContact();
		   objDealAdvisorContact.searchContactText = 'Testcontact-00';
		    objDealAdvisorContact.setContactToSelected();
		   	Id [] fixedSearchResults= new Id[2];
	        fixedSearchResults[0] = objContact.Id;
	        fixedSearchResults[1] = objContact1.Id;
	        
	        Test.setFixedSearchResults(fixedSearchResults);
        	objDealAdvisorContact.searchContact();
        
     	   objDealAdvisorContact.addDealAdvisorContact();  
     	   //objDealAdvisorContact.del();
           objDealAdvisorContact.addDealAdvisorContact();   
           objInner.isSelected = true; 
           objDealAdvisorContact.listNewDealAdvisorContacts.add(objInner);
           objDealAdvisorContact.goToSearchContact();
           
           objDealAdvisorContact.searchContact();
           
           objDealAdvisorContact.setContactToSelected();
           objDealAdvisorContact.backAdvCont();
           objDealAdvisorContact.addDealAdvisorContact();   
           objInner.isSelected = true;
           objDealAdvisorContact.save(); 
           objDealAdvisorContact.goToSearchContact();
           objDealAdvisorContact.searchContact();
           objDealAdvisorContact.newContact();
           objDealAdvisorContact.newContact.LastName = 'Test Contact';
           objDealAdvisorContact.backContact();
           system.assert( objDealAdvisorContact.newContact.id == null);
           objDealAdvisorContact.goToSearchContact();
           objDealAdvisorContact.newContact();
           objDealAdvisorContact.newContact.LastName = 'Test Contact1';
           objDealAdvisorContact.saveContact();
           objDealAdvisorContact.save();
           objDealAdvisorContact.getJSONDealTeamIDs();
           objDealAdvisorContact.getJSONResponse();
           objDealAdvisorContact.del();
     }
     
     
     static testMethod void SL_Test_ctrl_DealAdvisorContact_Quick_create1()
     {
     	/*SL_ctrl_DealAdvisorContact_Quick_Create objDealAdvisorContact = new SL_ctrl_DealAdvisorContact_Quick_Create();
     	
     	Account testAccount = new Account( Name='Test Account 001');
       insert testAccount;
       
       RecordType objRecordType = [SELECT ID,Name,SobjectType,DeveloperName  FROM RecordType WHERE SobjectType = 'Contact' and DeveloperName = 'Contact'];
       
       system.debug('===========objRecordType================' + objRecordType);
       
       //Contact objTestContact = new Contact();
       //objTestContact = [Select Id, Name, RecordType.DeveloperName from Contact Where RecordType.DeveloperName =: 'Contact' LIMIT 1];
       //system.debug('=====objTestContact========'+objTestContact);
       
       Contact objContact = new Contact(LastName = 'Steven',RecordTypeID = objRecordType.Id);
       insert objContact;
       system.assert(objContact.Id != null);
       
       Contact objContact1 = new Contact(LastName = 'Ste', RecordTypeID = objRecordType.Id);
       insert objContact1;
       system.assert(objContact1.Id != null);
   
 	   Deal__c testDeal = new Deal__c( Name = 'Test Deal 001' , Company__c = testAccount.Id, WP_Investment__c = 10, WP_Ownership__c = 10 , 
 									  Description__c = 'TestDescription', ISOPENSTAGE__c = 1 , Stage__c = 'Early - Prospect' ); 
       insert testDeal;
      
       ApexPages.currentPage().getParameters().put('did',testDeal.id);
       
     
 	   
 	   objDealAdvisorContact.searchContactText = 'S';
 	   
 	   objDealAdvisorContact.searchContact();*/
     }

}