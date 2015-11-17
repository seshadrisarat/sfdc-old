public with sharing class WP_handler_Synch_Log {
	public static WP_Synch_Log__c CreateSynchLogEvent(string sEventType, string sObjectName, string sObjectId, string sAssociatedDealId)
	{
	return CreateSynchLogEvent(sEventType,sObjectName,sObjectId,sAssociatedDealId,'');
	}
	public static WP_Synch_Log__c CreateSynchLogEvent(string sEventType, string sObjectName, string sObjectId, string sAssociatedDealId, string sRemoteObjectId)
	{
		if (kjoDealReportController.bCheckingDealWriteability) return null;
		System.debug('---> CreateSynchLogEvt: ' + sEventType + '  objName:' + sObjectName + '  Objid:' + sObjectId + ' dealid:' + sAssociatedDealId + ' remoteid:' + sRemoteObjectId);
	WP_Synch_Log__c wps = new WP_Synch_Log__c();
	wps.Event_Type__c = sEventType;
	wps.Object_Name__c = sObjectName;
	wps.Object_Id__c = sObjectId;
	wps.RemoteObject_Id__c = sRemoteObjectId;
	Datetime z = Datetime.Now();
    Datetime l = z.Date();
    l = l.addHours(z.hour());
    l = l.addMinutes(z.minute());
    l = l.addSeconds(z.second());
    wps.Event_Timestamp__c  = l;
    
    // for deletes of deals, we right the guid (whihc is the 2nd to last parameter) to object id
   // if (sEventType!='DEL' && sObjectName != 'Deal' )//&& sAssociatedDealId!=null && sAssociatedDealId != '')
    	//wps.Object_Id__c=sAssociatedDealId;     	else
    if (sEventType!='DEL' && sAssociatedDealId!=null && sAssociatedDealId != '') { 
    	wps.AssociatedDeal__c = sAssociatedDealId;
    	wps.AssociatedDealIdAsString__c=sAssociatedDealId;
    }
    
   // it throw exception "SL_User: System.LimitException: Too many DML statements: 151"
	////insert wps;
	return wps;	
	}
	
	static testMethod void unitTestsAreAWasteOfTime() {
	//	CreateSynchLogEvent('abc','abc','abc');
		CreateSynchLogEvent('abc','abc','abc', '');
	}
/*	public static void CreateSynchLogEvent(string sEventType, string sObjectName, string sObjectId)
	{
	WP_Synch_Log__c wps = new WP_Synch_Log__c();
	wps.Event_Type__c = sEventType;
	
	wps.Object_Name__c = sObjectName;
	wps.Object_Id__c = sObjectId;
	Datetime z = Datetime.Now();
    Datetime l = z.Date();
    l = l.addHours(z.hour());
    l = l.addMinutes(z.minute());
    l = l.addSeconds(z.second());
    wps.Event_Timestamp__c  = l;
    
//    if (sObjectName == 'Deal' && sObjectId!=null && sObjectId != '') wps.AssociatedDeal__c = sObjectId;
	insert wps;
	} */
}