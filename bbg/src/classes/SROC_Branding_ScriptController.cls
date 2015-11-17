public with sharing class SROC_Branding_ScriptController {

	SROC_System_Settings__c setting;

	public SROC_Branding_ScriptController() {
		setting = SROC_System_Settings__c.getInstance(Site.GetName());
	}

	public Boolean isOwner {
		get {
			return SROCUtilities.isOwner();
		}
	}

	public Boolean isDealer {
		get {
			return SROCUtilities.isDealer();
		}
	}

}