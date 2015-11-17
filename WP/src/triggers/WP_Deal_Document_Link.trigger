trigger WP_Deal_Document_Link on Deal_Document_Link__c (before insert, before update) {
if (trigger.isBefore){
	WP_handler_WP_Deal_Document wpl = new WP_handler_WP_Deal_Document();
	List<Deal_Document_Link__c> lstOld = new List<Deal_Document_Link__c>();
	List<Deal_Document_Link__c> lstNew = new List<Deal_Document_Link__c>();
	lstNew = Trigger.new;
	lstOld = Trigger.old;
	wpl.OnBeforeChange(lstOld, lstNew);
	//Deal_Document_Link__c dealLinkNew = trigger.new[0];
	//Deal_Document_Link__c dealLinkOld = trigger.old[0]; // be sure to check if this is NOT NULL!!!!
}
}