public with sharing class SROC_Content_ViewController {
	
	private CORECONNECT__CC_Community_Content__c content;
	
	public SROC_Content_ViewController(ApexPages.standardController setController) {
		this.content = (CORECONNECT__CC_Community_Content__c)setController.getRecord();
	}
	
	public PageReference redirect() {
		
		PageReference pr;

		if(Test.isRunningTest() || SROCUtilities.isCCU() || SROCUtilities.isCCL()) {  

			Id ScheduledContent_RecordType_Id = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('ScheduledContent').getRecordTypeId();
			Id FreeText_RecordType_Id = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('FreeText').getRecordTypeId();
			Id MemberBenefits_RecordType_Id = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('Member Benefits').getRecordTypeId();

			if(this.content.RecordTypeId == ScheduledContent_RecordType_Id) {

				pr = new PageReference('/SROC_CommunityEventsDetail?id='+this.content.Id);
				System.debug('pr ---'+pr);  
				pr.setRedirect(true);
				return pr;
			}
			else if(this.content.RecordTypeId == FreeText_RecordType_Id) {

				pr = new PageReference('/SROC_Sea_Ray_NewsDetail?id='+this.content.Id);
				pr.setRedirect(true);
				return pr;
			}
			else if(this.content.RecordTypeId == MemberBenefits_RecordType_Id) {

				pr = new PageReference('/SROC_Member_BenefitsDetail?id='+this.content.Id);
				pr.setRedirect(true);
				return pr;
			}
		}

		pr = new PageReference('/'+this.content.Id+'?nooverride=1');
		pr.setRedirect(true);
		return pr;
		
	}
	
}