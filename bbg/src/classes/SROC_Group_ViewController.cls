public with sharing class SROC_Group_ViewController {

	private CORECONNECT__CC_Custom_Group__c customgroup;
	
	public SROC_Group_ViewController(ApexPages.standardController setController) {
		this.customgroup = (CORECONNECT__CC_Custom_Group__c)setController.getRecord();
	}


	public PageReference redirect() {
		
		PageReference pr;

		if(Test.isRunningTest() || SROCUtilities.isCCU() || SROCUtilities.isCCL()) {
 
			String strcollaborationGroupId = [SELECT CORECONNECT__Collaboration_GroupId__c 
										      FROM CORECONNECT__CC_Custom_Group__c 
										      WHERE  Id =: this.customgroup.Id ].CORECONNECT__Collaboration_GroupId__c;

			if(String.isNotEmpty(strcollaborationGroupId)) {

				pr = new PageReference('/CORECONNECT__CC_CommunityGroupDetail?id='+strcollaborationGroupId);
				pr.setRedirect(true);
				return pr;
			}
		}

		pr = new PageReference('/'+this.customgroup.Id+'?nooverride=1');
		pr.setRedirect(true);
		return pr;	
	}

}