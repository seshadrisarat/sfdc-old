@isTest
public class SL_Util_Test {

	public static void createCustomSettings(Id unlockedRT, Id lockedRT){
		Approval_Record_Types__c cs_Locked = new Approval_Record_Types__c(Name='Locked', RecordTypeId__c=lockedRT);
		Approval_Record_Types__c cs_Unlocked = new Approval_Record_Types__c(Name='Unlocked', RecordTypeId__c=lockedRT);
		insert new List<Approval_Record_Types__c>{cs_Unlocked, cs_Locked};
	}
	
	public static Credit_Requests__c createCreditRequest(){
		// Test data, credit requests require a funding source which require a letter of intent
		Letter_of_Intent__c loi = new Letter_of_Intent__c();
		insert loi;

		Funding_Source__c fundingSource = new Funding_Source__c(Letter_of_Intent__c = loi.id);
		insert fundingSource;

		Id unlockedRT = Schema.SObjectType.Credit_Requests__c.getRecordTypeInfosByName().get('Unlocked').getRecordTypeId();

		Credit_Requests__c cr = new Credit_Requests__c(Name = 'test', 
														Funding_Source__c = fundingSource.id, 
														Amount__c = 100.00, 
														Credit_Expiration_Date__c = Date.newInstance(2014, 3, 31),
														Requester__c = 'testRequester',
														Requester_Name__c = 'Tester Name',
														Previous_Status__c = 'testPreviousStatus', 
														Status__c = 'testStatus',
														RecordTypeId = unlockedRT,
														Credit_Last_In_Timestamp__c = Datetime.newInstance(Date.newInstance(1900, 1, 1), Time.newInstance(1, 1, 1, 1)));
		insert cr;
		return cr;
	}

	public static User createUser(String lastName, String profileName, Boolean approver){
		Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];

		User tester = new User(Alias = 'standt', Email=(lastName + '@testorg.com'), 
			      EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
			      LocaleSidKey='en_US', ProfileId = p.Id, 
			      TimeZoneSidKey='America/Los_Angeles', UserName=(lastName +'@testorg.com'));
		insert tester;

		if(approver){
			GroupMember gm = new GroupMember(UserOrGroupId = tester.id);
			Group g = [SELECT Id FROM Group WHERE DeveloperName = 'Credit_Preparers' AND Type = 'Queue'];
			gm.GroupId = g.id;
			insert gm;
		}

		return tester;
	}     
}