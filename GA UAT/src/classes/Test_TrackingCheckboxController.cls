@isTest(SeeAllData=false)
private class Test_TrackingCheckboxController 
{
    static testMethod void Test_TrackingCheckbox() 
    {
    	 List<RecordType> lstRDOtherAcc =  [ Select Name, Id, DeveloperName 
    	 									 From RecordType 
                    						 where sObjectType='Account' and 
                    						 DeveloperName='Other' limit 1];
    	List<CustomTrackingLinks__c> lstCTLinks = new List<CustomTrackingLinks__c>();
    	
    	CustomTrackingLinks__c objCTLinkForPearl = new CustomTrackingLinks__c(	Name ='Test Pearl',
    																			Checked_Symbol__c = '&#9745;' ,
																		    	Checked_Symbol_Color__c = 'red' ,
																		    	Is_Reversed__c = false,
																		    	Label_Checked__c = 'Pearl Checked',
																		    	Label_Unchecked__c = 'Pearl Unchecked',
																		    	Target_Field__c = 'Pearl_Tracking__c',
																		    	Target_Object__c = 'Account',
																		    	Unchecked_Symbol__c = '&#9746;',
																		    	Unchecked_Symbol_Color__c = 'Green');
		lstCTLinks.add(objCTLinkForPearl);
    	
    	CustomTrackingLinks__c objCTLinkForHard = new CustomTrackingLinks__c(	Name = 'Test Hard',
    																			Checked_Symbol__c = '&#10004;',
																		    	Checked_Symbol_Color__c = 'blue' ,
																		    	Is_Reversed__c = true ,
																		    	Label_Checked__c = 'Hard Checked',
																		    	Label_Unchecked__c = 'Hard Check',
																		    	Target_Field__c = 'Hard_To_Crack_Tracking__c',
																		    	Target_Object__c = 'Account',
																		    	Unchecked_Symbol__c = '',
																		    	Unchecked_Symbol_Color__c = '');
		lstCTLinks.add(objCTLinkForHard);
    	
    	CustomTrackingLinks__c objCTLinkForDiscuss = new CustomTrackingLinks__c(	Name = 'Test Discuss',
	    																			Checked_Symbol__c = '&#10004;',
																			    	Checked_Symbol_Color__c = 'blue' ,
																			    	Is_Reversed__c = true ,
																			    	Label_Checked__c = 'Hard Checked',
																			    	Label_Unchecked__c = 'Hard Check',
																			    	Target_Field__c = 'Discuss',
																			    	Target_Object__c = 'Account',
																			    	Unchecked_Symbol__c = '&#9746;',
																			    	Unchecked_Symbol_Color__c = 'brown');
		lstCTLinks.add(objCTLinkForDiscuss);
    	
    	insert lstCTLinks;
    	
    	CustomTrackingLayout__c objCTLayoutLeft = new CustomTrackingLayout__c(Name = 'Layout left',Layout_Left__c = 'Test Hard; Test Discuss ', Layout_Right__c ='Test Pearl; Test Discuss' );
    	
    	insert objCTLayoutLeft;
    	
    	CustomTrackingPages__c objCTPages = new CustomTrackingPages__c(Custom_Tracking_Layout__c = 'Layout left');
		insert objCTPages;
    	
    	
    	Account objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
    	Apexpages.StandardController ctrlForAccount = new Apexpages.StandardController(objAccount);
        TrackingCheckboxController objTrackingChkbox = new TrackingCheckboxController(ctrlForAccount);
        
        objTrackingChkbox.strSelectdCTLink = 'Test Pearl';
        
        objTrackingChkbox.rightPageAction();
        objTrackingChkbox.leftPageAction();
        objTrackingChkbox.processCustomSettingrecords();
    }
}