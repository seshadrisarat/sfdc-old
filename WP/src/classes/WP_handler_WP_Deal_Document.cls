public with sharing class WP_handler_WP_Deal_Document {
	
	public void OnBeforeChange(List<Deal_Document_Link__c> oldDeals, List<Deal_Document_Link__c> newDeals)
	{
		if (oldDeals == null || newDeals == null || oldDeals.size()<> 1) return;
		Id idxLink = newDeals[0].Id;
		
		Deal_Document_Link__c dealDocLink = [select Id, Deal__c,  Type__c, Location__c, CreatedDate from Deal_Document_Link__c where Id = :idxLink limit 1];
		if (dealDocLink == null) return;
		
		Boolean bOldEnquirySent = oldDeals[0].DealNotClosedFollowingEAREnquirySent__c;
		Boolean bNewEnquirySent = newDeals[0].DealNotClosedFollowingEAREnquirySent__c;
		
		// if the record was not sent and now it is and
    	System.Debug('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' + dealDocLink.Type__c);

		Boolean bDocLinkIsValid=true; // ... and the link type is still ear and the value is not null 
		if (dealDocLink == null || dealDocLink.Type__c==null || dealDocLink.Type__c != 'Early Action Report')  bDocLinkIsValid = false;
		if (dealDocLink != null && dealDocLink.Location__c == null) bDocLinkIsValid = false; 

		Boolean bLinkIsBeingMarkedAsSent = bOldEnquirySent==false && bNewEnquirySent==true;
		
		
		
if (bLinkIsBeingMarkedAsSent && bDocLinkIsValid) {

    System.Debug ('Goooooooooooooooooooooooooooooooooooooooooooooooooo');

    Deal__c d = [select Name, WP_Groups__c, Dead_Deal_Reason__c, Stage__c, Status__c from Deal__c where Id = :dealDocLink.Deal__c limit 1 ];
						     
    System.Debug('hxxxxxxxxxxxxxxxxxxxxxxxxx' + d.Stage__c  + 'xxxxxxxxxxxxxxxxx' + d.WP_Groups__c);

    if (d!=null && (d.Status__c == 'Pipeline' || d.Status__c == 'Dead' ) && (d.WP_Groups__c == null || !d.WP_Groups__c.contains('Archive') ) ) {     // if the deal is not dead and still not closed,  


	string sEmailOverride='';
	List<WP_Lookup__c> wpl = [select Id, Value__c from WP_Lookup__c where Name = 'DealNotClosedFollowingEAREnquiryEmailOverride' and Type__c = 'DealNotClosedFollowingEAREnquiry' limit 1];
	if (wpl!=null && wpl.size()>0) sEmailOverride = wpl[0].Value__c;

	string sTemplate='';
	List<WP_Lookup__c> wpl2 = [select Id, Value__c from WP_Lookup__c where Name = 'DealNotClosedFollowingEAREnquiryEmailTemplate' and Type__c = 'DealNotClosedFollowingEAREnquiry' limit 1];
	if (wpl2!=null && wpl2.size()>0) sTemplate = wpl2[0].Value__c;
    
	System.Debug ('Goooooooooooooooooooooooooooooooooooooooooooooooooo 22222222222222222222222222222222222 ' + sTemplate);
	//Select d.UserID__c, d.Deal__r.Name, d.Employee__r.Status__c, d.Employee__r.Email, d.Employee__c, 
	//d.Deal__r.Status__c, d.Deal__r.WP_Groups_picklist__c, d.Deal__r.WP_Groups__c, d.Deal__r.Stage__c, d.Deal__c From Deal_Team__c d


	List<Deal_Team__c> dts = [
		Select d.Employee__r.User_ID__r.Email, d.Employee__r.User_ID__r.FirstName, d.Employee__r.User_ID__r.LastName, d.Employee__r.User_ID__r.Username,
		    d.Employee__r.User_ID__r.IsActive, d.UserID__c, d.Deal__r.Name, d.Employee__r.Status__c, d.Employee__r.Email, d.Employee__c, 
		    d.Deal__r.Status__c, d.Deal__r.WP_Groups_picklist__c, d.Deal__r.WP_Groups__c, d.Deal__r.Stage__c, d.Deal__c From Deal_Team__c d
		    where d.Deal__c = :dealDocLink.Deal__c
		];
    List<string> emails = new List<string>();
    Boolean bSendingAtLeastOneEmail = false;
    List<String> args = new List<String>();
    args.add(d.Name); 
    args.add(dealDocLink.CreatedDate.format('MM/dd/yyyy'));
    args.add(datetime.now().format('MM/dd/yyyy'));
    
    System.Debug ('dddddddddddddddddddddddddddddddddddddddd1:' + args[1] + '            d2:' + args[2]);
	for (Deal_Team__c dt : dts)
	{
	    System.Debug ('Gooooooooooo 3.1' + dt.Deal__r.Status__c + ' status:' + dt.Employee__r.User_ID__r.IsActive );
	if (
	    dt.Employee__c != null && 
	    dt.Employee__r.User_ID__r != null && 
	    dt.Employee__r.User_ID__r.Email != null &&
	    dt.Employee__r.User_ID__r.IsActive == true
	    ) 
	    {
	    // send the emsils (using a template) to the active members of the deal team 
	    System.Debug ('3.3-------------------------------EARNotClosedEnquiryEmailSend');
	    
	    
	    //args.add(dt.Employee__r.User_ID__r.FirstName);
	    //args.add(dt.Employee__r.User_ID__r.LastName);
            string sEmail = dt.Employee__r.User_ID__r.Email ;
	    if (sEmailOverride != null) sEmail = sEmailOverride;
	    System.Debug('3.3-------------------------------EARNotClosedEnquiryEmailSend: ' + dt.Deal__r.Name + ' --- ' +  sEmail + ' deal status:' + dt.Deal__r.Status__c);
	    emails.add(sEmail);
	    bSendingAtLeastOneEmail=true;
	    //String[] toAddresses = new String[] {sEmail}; 
	    //WP_handler_WP_Deal_Document.SendEARDealNotClosedEnquiryEmail(args, toAddresses);

	    }
	}
	if (bSendingAtLeastOneEmail)
	{
		WP_handler_WP_Deal_Document.SendEARDealNotClosedEnquiryEmail(args,emails);// emails.toArray(new String[]{}));
	}
	
    }
}
		
		
		
	}
	
	
	public static boolean SendEARDealNotClosedEnquiryEmail(List<string> args, List<string>toAddresses )//string sEmail)
	{
		Boolean bRc = true;
		 string sTemplate='';
	/*List<WP_Lookup__c> wpl2 = [select Id, Value__c from WP_Lookup__c where Name = 'DealNotClosedFollowingEAREnquiryEmailTemplate' and Type__c = 'DealNotClosedFollowingEAREnquiry' limit 1];
	if (wpl2!=null && wpl2.size()>0) sTemplate = wpl2[0].Value__c;*/
	sTemplate = '<p>An Early Action Report was submitted for {0} on {1}, but the deal has not been closed in Salesforce as of {2}.  Please address the following questions and forward to Pat Hackett.<br><br><table><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign=\'top\'>1)</td><td>If the deal is still in process, please comment on current status and next steps.</td></tr><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign=\'top\'>2)</td><td>If the deal is dead, please expand on why it is no longer alive and if the deal has been completed by another party, who and at what valuation.</td></tr></table><br><br><br><br><br>';

	string sSenderDisplay='Warburg Pincus Salesforce Notifications<noreply@warburgpincus.com>';
	List<WP_Lookup__c> wpl3 = [select Id, Value__c from WP_Lookup__c where Name = 'DealNotClosedFollowingEAREnquiryEmailSender' and Type__c = 'DealNotClosedFollowingEAREnquiry' limit 1];
	if (wpl3!=null && wpl3.size()>0) sSenderDisplay = wpl3[0].Value__c;
	
	string sSubject='Salesforce Deals - EAR Followup Enquiry';
	List<WP_Lookup__c> wpl4 = [select Id, Value__c from WP_Lookup__c where Name = 'DealNotClosedFollowingEAREnquiryEmailSubject' and Type__c = 'DealNotClosedFollowingEAREnquiry' limit 1];
	if (wpl4!=null && wpl4.size()>0) sSubject = wpl4[0].Value__c; 
	

	System.Debug('template is' + sTemplate);
	System.Debug('sender is' + sSenderDisplay);

	
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	//String[] toAddresses = new String[] {sEmail}; 
	mail.setToAddresses(toAddresses);   
	mail.setSenderDisplayName(sSenderDisplay);
	mail.setSubject(sSubject);
	mail.setBccSender(false);
	mail.setUseSignature(true);

	String sFormattedHtml = String.format(sTemplate, args);
	mail.setHtmlBody(sFormattedHtml);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         	
		
		
		return bRc;
	}

}