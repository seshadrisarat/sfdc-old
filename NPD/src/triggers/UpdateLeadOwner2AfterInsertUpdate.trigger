/* Written: 02/13/2013
* Modified: 03/01/2013 - Do not update converted Leads
*  Author : KR
* This trigger is used to load the User ID into a custom field on the Lead object
* called Lead Owner 2. In turn this field can be used to get to User object data in formulas
*/
trigger UpdateLeadOwner2AfterInsertUpdate on Lead (after update) {

    string txtLdID;
    
    List<Lead> listLeads = new List<Lead>();
    
    //Iterate through all records that need updating
    for (Lead oLead : [Select Id,OwnerId,Lead_Owner_2__c,IsConverted from Lead where Id in :Trigger.new]) {
            txtLdID = oLead.OwnerId;
            // If not converted and Owner ID is a Queue, clear Lead Owner 2 field, otherwise load Owner ID
            IF (oLead.IsConverted == FALSE) {
               listLeads.add(oLead);
               if (txtLdID.startsWith('00G') == TRUE) {
                    oLead.Lead_Owner_2__c = null;
                } else {
                    oLead.Lead_Owner_2__c = oLead.OwnerId;
                }
            }
    }  
     //Post the changes to the database if not already running
    If (listLeads.isEmpty() == false && UpdateLeadOwner2Running.recursive == false) {
        UpdateLeadOwner2Running.recursive = true;
        Update listLeads;
    }
    
 }