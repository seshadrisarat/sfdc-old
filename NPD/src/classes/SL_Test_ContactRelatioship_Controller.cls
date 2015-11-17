@isTest
private class SL_Test_ContactRelatioship_Controller {
	
	private static final Id PRACTICE_ACCOUNT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Account').getRecordTypeId();
    
    /*
       * MethodName : contactRelationship_Account
       * Param 		: -
       * Description: Test class for testing Account's ContactRelationship Page
    */
    
	@isTest static void contactRelationship_Account() 
	{
		List<Account> lstAccountToInsert = new List<Account>{
				new Account(Name='Test Account' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PRACTICE_ACCOUNT_ID),
				new Account(Name='Test Account Parent 1' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PRACTICE_ACCOUNT_ID)
		};

		insert lstAccountToInsert;

		lstAccountToInsert[0].Company_Account__c =  lstAccountToInsert[1].Id;
		update lstAccountToInsert[0];

		List<Contact> lstContact = new List<Contact>{
            new Contact (LastName = 'Contact-01-RelationshipTest', AccountId = lstAccountToInsert[1].Id),
            new Contact (LastName = 'Contact-02-RelationshipTest', AccountId = lstAccountToInsert[1].Id),
            new Contact (LastName = 'Contact-03-RelationshipTest', AccountId = lstAccountToInsert[1].Id),
            new Contact (LastName = 'Contact-04-RelationshipTest', AccountId = lstAccountToInsert[1].Id)
        };
        insert lstContact;
		
		PageReference currPage = Page.SL_ContactRelationshipsAccount;
		currPage.getParameters().put('id' , lstAccountToInsert[0].Id);
		Test.setCurrentPage(currPage);
                
        Test.startTest();
            
             /* Adding all Contacts to create Contact Relationships - Start */
            
            SL_ContactRelationshipsCtrl objController = new SL_ContactRelationshipsCtrl();
            String strFinalStrBuild = '';  
            /*objController.rightOptionsHidden */
            for(SelectOption objOptions : objController.leftOptions)
            {
                strFinalStrBuild += EncodingUtil.urlEncode(objOptions.getValue() , 'UTF-8') + '&' + EncodingUtil.urlEncode(objOptions.getLabel(), 'UTF-8') + '&';
            }
            strFinalStrBuild = strFinalStrBuild.substring(0 , strFinalStrBuild.length() - 1);
            objController.rightOptionsHidden = strFinalStrBuild;
            objController.enableSaveButton();
            objController.save();
            
            /* Adding all Contacts to create Contact Relationships - End*/
            
            /* Remove some Contacts to delete and test duplicate Contact Relationships - Start */
            
            SL_ContactRelationshipsCtrl objController_reInitialize = new SL_ContactRelationshipsCtrl();
            String strFinalBuid_reInit = '';  
            Boolean isSkip = true;
            for(SelectOption objOptions : objController.leftOptions)
            {
                if(isSkip)
                    strFinalBuid_reInit += EncodingUtil.urlEncode(objOptions.getValue() , 'UTF-8') + '&' + EncodingUtil.urlEncode(objOptions.getLabel(), 'UTF-8') + '&';
                isSkip = false;    
            }
            strFinalBuid_reInit = strFinalBuid_reInit.substring(0 , strFinalBuid_reInit.length() - 1);
            objController_reInitialize.rightOptionsHidden = strFinalBuid_reInit;
            objController_reInitialize.enableSaveButton();
            objController_reInitialize.save();
            
            /* Remove some Contacts to delete and test duplicate Contact Relationships - End */
		
		Test.stopTest();
    }	
    
    /*
       * MethodName : contactRelationship_Contact
       * Param 		: -
       * Description: Test class for testing Contact's ContactRelationship Page
    */
    
    @isTest static void contactRelationship_Contact() 
	{
	    Account objAcc = new Account(Name='Test Account 1' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PRACTICE_ACCOUNT_ID);
        insert objAcc;
	    
		List<Account> lstAccountToInsert = new List<Account>{
				new Account(Name='Test Account 2' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PRACTICE_ACCOUNT_ID , Company_Account__c = objAcc.Id),
				new Account(Name='Test Account 3' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PRACTICE_ACCOUNT_ID , Company_Account__c = objAcc.Id),
                new Account(Name='Test Account 4' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PRACTICE_ACCOUNT_ID , Company_Account__c = objAcc.Id)
		};

		insert lstAccountToInsert;

		lstAccountToInsert[0].Company_Account__c =  lstAccountToInsert[1].Id;
		update lstAccountToInsert[0];

		List<Contact> lstContact = new List<Contact>{
            new Contact (LastName = 'Contact-01-RelationshipTest', AccountId = objAcc.Id)
        };
        insert lstContact;
		
		PageReference currPage = Page.SL_ContactRelationshipsContact;
		currPage.getParameters().put('id' , lstContact[0].Id);
		Test.setCurrentPage(currPage);
                
        Test.startTest();
            
            /*Adding all Accounts to create Contact Relationships - Start*/
            
            SL_ContactRelationshipsCtrl objController = new SL_ContactRelationshipsCtrl();
            String strFinalStrBuild = '';  
            for(SelectOption objOptions : objController.leftOptions)
            {
                strFinalStrBuild += EncodingUtil.urlEncode(objOptions.getValue() , 'UTF-8') + '&' + EncodingUtil.urlEncode(objOptions.getLabel(), 'UTF-8') + '&';
            }
            strFinalStrBuild = strFinalStrBuild.substring(0 , strFinalStrBuild.length() - 1);
            objController.rightOptionsHidden = strFinalStrBuild;
            objController.enableSaveButton();
            objController.save();
            
            /*Adding all Accounts to create Contact Relationships - End*/
            
            /* Remove some Accounts to delete and test duplicate Contact Relationships - Start */
            
            SL_ContactRelationshipsCtrl objController_reInitialize = new SL_ContactRelationshipsCtrl();
            String strFinalBuid_reInit = '';  
            Boolean isSkip = true;
            for(SelectOption objOptions : objController.leftOptions)
            {
                if(isSkip)
                    strFinalBuid_reInit += EncodingUtil.urlEncode(objOptions.getValue() , 'UTF-8') + '&' + EncodingUtil.urlEncode(objOptions.getLabel(), 'UTF-8') + '&';
                isSkip = false;    
            }
            strFinalBuid_reInit = strFinalBuid_reInit.substring(0 , strFinalBuid_reInit.length() - 1);
            objController_reInitialize.rightOptionsHidden = strFinalBuid_reInit;
            objController_reInitialize.enableSaveButton();
            objController_reInitialize.save();
            
            /* Remove some Accounts to delete and test duplicate Contact Relationships - End */
            
		Test.stopTest();
    }	
}