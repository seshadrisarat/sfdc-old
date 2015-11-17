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
private class SL_Test_AgentHomePageController 
{
    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        RecordType objMemberRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member'];
        RecordType objBrokerRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Broker'];
        
        Account objAccount = new Account(Name = 'Test Account', RecordTypeId = objBrokerRecordtype.Id, Billing_Document_Delivery_Method__c = 'Electronic', Broker_Status__c = 'Active', Broker_Id__c = '12345', Date_Of_Appointment__c = Date.today());
        insert objAccount;
        		
        Account objAccount1 = new Account(Name = 'Test Account 1', RecordTypeId = objMemberRecordtype.Id, Billing_Document_Delivery_Method__c = 'Paper',Broker__c = objAccount.Id,Status__c = 'Active');
        insert objAccount1;
        
        //RecentlyViewed objRV = new RecentlyViewed(Id=objAccount1.Id);
        //insert objRV;
        
        List<Policy__c> lstPolicies = new List<Policy__c>{new Policy__c(Member__c = objAccount1.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='12223333333333',IsOverdue__c = true),
														  new Policy__c(Member__c = objAccount1.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c = true, Policy_Number__c='12333333333333')
												  		 };
		insert lstPolicies;							  		 
												  		
		List<Claim__c> lstClaims = new List<Claim__c>{new Claim__c(Member__c = objAccount1.Id, Claim_Number__c = '1234',Claim_Status__c = 'in progress', Portal_Closed_Date__c = date.today(),Final_Closed_Date__c = Date.newInstance(2015, 01, 09 )),
        											   new Claim__c(Member__c = objAccount1.Id, Claim_Number__c = '12345',Claim_Status__c = 'Closed', Portal_Closed_Date__c = Date.newInstance(2014, 01, 09 )),
        											   new Claim__c(Member__c = objAccount1.Id, Claim_Number__c = '12345',Claim_Status__c = 'in subrogation',Portal_Closed_Date__c = Date.newInstance(2015, 01 , 09))      	
        											   };		
        											   
        insert lstClaims;										   								  		
												  		
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = objAccount1.Id),
        											 new Contact(LastName = 'Test Contact 1', AccountId = objAccount.Id)
        											};
        insert lstContact;
        
        Agency_Contact__c objAgencyContact = new Agency_Contact__c(Contact__c = lstContact[0].Id,Agency__c = objAccount.Id,User_Status__c = 'Active');
        insert objAgencyContact;
        
        User objCommunityUser = new User(Alias = 'HPD4', Email='standarduser4@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4@testorg.com' , ContactID = lstContact[0].Id);              
                             
        insert objCommunityUser;
        
        System.runAs(objCommunityUser)
        {
        	PageReference pageRef = Page.BrokerHomePage; 
        	Test.setCurrentPage(pageRef); // Setting current page as AgentHomePage
        	
        	// Setting required parameters in URL
        	ApexPages.currentPage().getParameters().put('fn', 'Test');
        	ApexPages.currentPage().getParameters().put('lnl', 'OR');
        	ApexPages.currentPage().getParameters().put('ln', 'Account');
        	ApexPages.currentPage().getParameters().put('c', 'Wilmette');
        	ApexPages.currentPage().getParameters().put('zcl', 'OR');
        	ApexPages.currentPage().getParameters().put('zc', '60091');
        	ApexPages.currentPage().getParameters().put('s', 'IL');
        	ApexPages.currentPage().getParameters().put('sl', 'OR');
        	ApexPages.currentPage().getParameters().put('pl', 'OR');
        	ApexPages.currentPage().getParameters().put('pnum',lstPolicies[0].Policy_Number__c );
        	ApexPages.currentPage().getParameters().put('p',objAccount1.Id );
        	ApexPages.currentPage().getParameters().put('mids',objAccount1.Id);
        	ApexPages.currentPage().getParameters().put('mId',objAccount1.Id);
        	ApexPages.currentPage().getParameters().put('claimNum',lstClaims[0].Claim_Number__c);
        	
        	ApexPages.currentPage().getParameters().put('sortSearchResTable','MemberSearchResults');
        	ApexPages.currentPage().getParameters().put('sortSearchResColumn','Name');
        	ApexPages.currentPage().getParameters().put('searchResColsortorder','ASC');
        	
        	ApexPages.currentPage().getParameters().put('sortRecViewTable','RecentlyViewedMembers');
        	ApexPages.currentPage().getParameters().put('sortRecViewColumn','Name');
        	ApexPages.currentPage().getParameters().put('sortRecViewColDir','ASC');
        	
        	ApexPages.currentPage().getParameters().put('sortPastDueTable','MembersWithPastDueBalances');
        	ApexPages.currentPage().getParameters().put('sortPastDueColumn','Name');
        	ApexPages.currentPage().getParameters().put('sortPastDueDir','ASC');
        	
        	ApexPages.currentPage().getParameters().put('sortClaimActTable','MembersWithClaimActivity');
        	ApexPages.currentPage().getParameters().put('sortClaimActColumn','Claim_Number__c');
        	ApexPages.currentPage().getParameters().put('sortClaimActColumnDir','ASC');
        	
        	
        	SL_AgentHomePageController objController = new SL_AgentHomePageController();
        	objController.moreMembers = true;
        	objController.moreMemBalances = true;
        	objController.moreClaims = true;
        	
        	objController.pageAction();   
        	objController.getStateList();
        	// Verifying expected results
        	system.assertEquals(objController.lstMemberClaims.size(),1);
        	system.assertEquals(objController.lstMembersWithPastDueBalances.size(),1);
        	system.assertEquals(objController.lstMembersSearched.size(),1);
        	
        	ApexPages.currentPage().getParameters().put('all','true');
        	objController.pageAction();
        	objController.navigateToMember();
        	objController.navigateToClaim();
        	objController.searchMembers(); 
        	
        	objController.strSortTable = 'MemberSearchResults';
        	objController.strSortColumn = 'Name';
        	objController.sortPageSections();
        	
        	objController.strSortTable = 'RecentlyViewedMembers';
        	objController.strSortColumn = 'Name';
        	objController.sortPageSections();
        	
        	objController.strSortTable = 'MembersWithPastDueBalances';
        	objController.strSortColumn = 'Name';
        	objController.sortPageSections();
        	
        	objController.strSortTable = 'MembersWithClaimActivity';
        	objController.strSortColumn = 'Claim_Number__c';
        	objController.sortPageSections();
        	
        	objController.moreParamName = 'moremembers';
        	objController.addMoreParam();
        	system.assertEquals(objController.moreMembers,true);
        	objController.removeMoreParam();
        	system.assertEquals(objController.moreMembers,false);
        	
        	objController.moreParamName = 'morememBalances';
        	objController.addMoreParam();
        	system.assertEquals(objController.moreMemBalances,true);
        	objController.removeMoreParam();
        	
        	objController.moreParamName = 'moreclaim';
        	objController.addMoreParam();
        	system.assertEquals(objController.moreClaims,true);
        	objController.removeMoreParam();
        }
    }
}