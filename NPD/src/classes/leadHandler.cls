public class leadHandler {

    Public Static Void leadDeDuper(Map<String,ID> newLeads) {

//KR 20130621: Add new fields to the select (Subscriptions__c & NPD_Group_Blog__c)
//KR 20130905: Remove old Blog field handling
        Map<id,Lead> newLeadMap = new Map <ID, Lead>([Select Id, Phone, Title, PrimaryAreaOfInterest__c,MarketingCampaign__c, Email, HasOptedOutOfEmail,Press_Releases__c,Insights_Newsletter__c,Product_Announcements__c,Entertainment_Outlook__c,Food_For_Thought_Brief__c,UK_Foodservice_Topline_Top_3__c ,Marketing_Opt_Out__c,Subscriptions__c,NPD_Group_Blog__c from Lead Where ID IN: newLeads.values()]);
        Set<Lead> leadsToDeleteSet = new Set<Lead>();
        List<Lead> existingLeads = new List<Lead>();
        List<Contact> existingContacts = new List<Contact>();
        
        System.debug('Made it to the leadHandler Class');       
        //finds existing Leads where their email equals the incoming Lead
        //KR 20130314: Add Marketing Campaign 'Web-Marketing-UK Opt In Web Page-201303' in the filter
        //KR 20130621: Add new fields to the select (Subscriptions__c & NPD_Group_Blog__c)
        For(Lead leadB : [select Id, FirstName, LastName,PrimaryAreaofInterest__c,Phone, Title,Email,HasOptedOutofEmail,Product_Announcements__c, MarketingCampaign__c, Insights_Newsletter__c,Press_Releases__c,Entertainment_Outlook__c,Food_For_Thought_Brief__c,UK_Foodservice_Topline_Top_3__c,Marketing_Opt_Out__c,Lead_Type__c,Rating,Status,LeadSource,Subscriptions__c,NPD_Group_Blog__c from Lead where Email IN :newLeads.KeySet() And IsConverted = False and MarketingCampaign__c <> 'Web-Marketing-Opt In Web Page-200807' and MarketingCampaign__c <> 'Web-Marketing-Blog Opt In Web Page-201207' and MarketingCampaign__c <> 'Web-Marketing-UK Opt In Web Page-201303' and HasOptedOutofEmail = false]) {
            for(ID newLeadID : newLeads.values()) {
                if(newLeadID <> leadB.ID) {
                    //updates fields in existing leads
                    leadB.HasOptedOutOfEmail = false;
                    
                    //NC 20130319: further customize each opt-in page subscription for Leads

                    leadB.Marketing_Opt_Out__c = false;
                                            
                    if (newLeadMap.get(newLeads.get(leadB.email)).MarketingCampaign__c == 'Web-Marketing-Opt In Web Page-200807') {
                        leadB.Press_Releases__c = newLeadMap.get(newLeads.get(leadB.email)).Press_Releases__c;
                        leadB.Insights_Newsletter__c = newLeadMap.get(newLeads.get(leadB.email)).Insights_Newsletter__c;
                        leadB.Product_Announcements__c = newLeadMap.get(newLeads.get(leadB.email)).Product_Announcements__c;
                        leadB.Entertainment_Outlook__c =newLeadMap.get(newLeads.get(leadB.email)).Entertainment_Outlook__c;
                        leadB.Food_For_Thought_Brief__c =newLeadMap.get(newLeads.get(leadB.email)).Food_For_Thought_Brief__c;
//KR 20130621: Added new NPD Blog & Subscription fields, commented out individual Blog fields
                        leadB.Subscriptions__c = newLeadMap.get(newLeads.get(leadB.email)).Subscriptions__c;
                    }

                    if (newLeadMap.get(newLeads.get(leadB.email)).MarketingCampaign__c == 'Web-Marketing-UK Opt In Web Page-201303') {
                        leadB.Press_Releases__c = newLeadMap.get(newLeads.get(leadB.email)).Press_Releases__c;
                        leadB.Insights_Newsletter__c = newLeadMap.get(newLeads.get(leadB.email)).Insights_Newsletter__c;
                        leadB.Product_Announcements__c = newLeadMap.get(newLeads.get(leadB.email)).Product_Announcements__c;
                        leadB.Food_For_Thought_Brief__c =newLeadMap.get(newLeads.get(leadB.email)).Food_For_Thought_Brief__c;
                        leadB.UK_Foodservice_Topline_Top_3__c =newLeadMap.get(newLeads.get(leadB.email)).UK_Foodservice_Topline_Top_3__c;
//KR 20130621: Added new NPD Blog & Subscription fields, commented out individual Blog fields
                        leadB.Subscriptions__c = newLeadMap.get(newLeads.get(leadB.email)).Subscriptions__c;
                    }

                    //KR 20130621: Add or portion of check to run code for either campaign
                    if (newLeadMap.get(newLeads.get(leadB.email)).MarketingCampaign__c == 'Web-Marketing-Blog Opt In Web Page-201207') {
                        //KR 20130621: Change the following code for new multi-select Subscriptions field update
                        leadB.Subscriptions__c = newLeadMap.get(newLeads.get(leadB.email)).Subscriptions__c;
                    }

                    if(newLeadMap.get(newLeads.get(leadB.email)).Title <> null) {
                        leadB.Title = newLeadMap.get(newLeads.get(leadB.email)).Title;
                    }
                    if(newLeadMap.get(newLeads.get(leadB.email)).PrimaryAreaOfInterest__c <> null) {                    
                        leadB.PrimaryAreaOfInterest__c = newLeadMap.get(newLeads.get(leadB.email)).PrimaryAreaOfInterest__c;
                    }   
                    //NC 20120516 leadB.Phone = newLeadMap.get(newLeads.get(leadB.email)).Phone;
                    //NC 20120516 - Start of Trial fix of Phone number overwrite problem:
                    if(newLeadMap.get(newLeads.get(leadB.email)).Phone <> null) {
                        leadB.Phone = newLeadMap.get(newLeads.get(leadB.email)).Phone;
                    }
                    //NC 20120516 - End of Trial fix of Phone number overwrite problem
                    
                    if(null == leadB.Rating) {
                        leadB.Rating = 'Z - Not Contacted - Unknown Quality';
                    }
                    
                    if(null == leadB.Status) {
                        leadB.Status = 'New Leads - Not Yet Working';
                    }
                    
                    if(leadB.Status == 'Dead Leads - No Future Opport') {
                        leadB.Status = 'Archived Leads - Possible Future Opport';
                    }
                    
                    if(null == leadB.Lead_Type__c) {
                        leadB.Lead_Type__c = 'Inbound Web Site Form';
                    }
                    
                    if(null == leadB.LeadSource) {
                        leadB.LeadSource = 'Other';
                    }
                    //KR 20130701: add following code to make sure NPD Group Blog field is updated correctly
                    If(leadB.Subscriptions__c == null) {
                        leadB.NPD_Group_Blog__c = false;
                    } else {
                        leadB.NPD_Group_Blog__c = true;
                    }
                    
                    existingLeads.add(leadB);
                } else {
                    leadsToDeleteSet.add(newLeadMap.get(newLeads.get(leadB.Email)));
                }
            }
        }
       
        if(existingLeads.size()>0) {
             update existingLeads;
        }
        //finds existing contacts where their email equals the incoming leads
        //KR 20130621: Add new fields to the select (Subscriptions__c & NPD_Group_Blog__c)
        for(Contact contactA : [select ID, Phone, Title, Email, HasOptedOutofEmail, Insights_Newsletter__c, Press_Releases__c,Product_Announcements__c,Entertainment_Outlook__c,Food_For_Thought_Brief__c,UK_Foodservice_Topline_Top_3__c,JobFunction__c,ContactType__c,NPD_Client_Satisfaction_Survey__c,Subscriptions__c,NPD_Group_Blog__c from Contact where Email IN :newLeads.keySet()]) {
                       
            
            //updates the existing q contact         
            //NC 20130319: further customize each opt-in page subscription for Contacts

            contactA.HasOptedOutOfEmail = false;
        
            if(newLeadMap.get(newLeads.get(contactA.email)).MarketingCampaign__c == 'Web-Marketing-Opt In Web Page-200807') {
                contactA.Insights_Newsletter__c = newLeadMap.get(newLeads.get(contactA.email)).Insights_Newsletter__c;
                contactA.Press_Releases__c = newLeadMap.get(newLeads.get(contactA.email)).Press_Releases__c;
                contactA.Product_Announcements__c = newLeadMap.get(newLeads.get(contactA.email)).Product_Announcements__c;
                contactA.Entertainment_Outlook__c = newLeadMap.get(newLeads.get(contactA.email)).Entertainment_Outlook__c;
                contactA.Food_For_Thought_Brief__c = newLeadMap.get(newLeads.get(contactA.email)).Food_For_Thought_Brief__c;
//KR 20130621: Added new NPD Blog & Subscription fields, commented out individual Blog fields
                contactA.Subscriptions__c = newLeadMap.get(newLeads.get(contactA.email)).Subscriptions__c;
            }

            if(newLeadMap.get(newLeads.get(contactA.email)).MarketingCampaign__c == 'Web-Marketing-UK Opt In Web Page-201303') {
                contactA.Insights_Newsletter__c = newLeadMap.get(newLeads.get(contactA.email)).Insights_Newsletter__c;
                contactA.Press_Releases__c = newLeadMap.get(newLeads.get(contactA.email)).Press_Releases__c;
                contactA.Product_Announcements__c = newLeadMap.get(newLeads.get(contactA.email)).Product_Announcements__c;
                contactA.Food_For_Thought_Brief__c = newLeadMap.get(newLeads.get(contactA.email)).Food_For_Thought_Brief__c;
                contactA.UK_Foodservice_Topline_Top_3__c = newLeadMap.get(newLeads.get(contactA.email)).UK_Foodservice_Topline_Top_3__c;
//KR 20130621: Added new NPD Blog & Subscription fields, commented out individual Blog fields
                 contactA.Subscriptions__c = newLeadMap.get(newLeads.get(contactA.email)).Subscriptions__c;
            }

            if(newLeadMap.get(newLeads.get(contactA.email)).MarketingCampaign__c == 'Web-Marketing-Blog Opt In Web Page-201207') {
//KR 20130621: Added new NPD Blog & Subscription fields, commented out individual Blog fields
                contactA.Subscriptions__c = newLeadMap.get(newLeads.get(contactA.email)).Subscriptions__c;
            }
        
            if(newLeadMap.get(newLeads.get(contactA.email)).Title <> null) {
                contactA.Title = newLeadMap.get(newLeads.get(contactA.email)).Title;
            }
            //NC 20120516 contactA.Phone = newLeadMap.get(newLeads.get(contactA.email)).Phone;
            //NC 20120516 - Start of Trial fix of Phone number overwrite problem:
            if(newLeadMap.get(newLeads.get(contactA.email)).Phone <> null) {
                contactA.Phone = newLeadMap.get(newLeads.get(contactA.email)).Phone;
            }
            //NC 20120516 - End of Trial fix of Phone number overwrite problem            
            
            if(null == contactA.JobFunction__c) {
                contactA.JobFunction__c = 'Other';
            }
            
            if (null == contactA.ContactType__c) {
                contactA.ContactType__c = 'Other';
            }
            
            if (null == contactA.NPD_Client_Satisfaction_Survey__c) {
                contactA.NPD_Client_Satisfaction_Survey__c = 'No';
            }
            If(contactA.Subscriptions__c == null) {
                contactA.NPD_Group_Blog__c = false;
            } else {
                contactA.NPD_Group_Blog__c = true;
            }            
            leadsToDeleteSet.add(newLeadMap.get(newLeads.get(contactA.email)));
            existingContacts.add(contactA);
        }
      
        if(existingContacts.size()>0) {
            update existingContacts;
        }

// 20120522 NC LEADS SHOULD NO LONGER BE DELETED       
        if(existingLeads.size()>0 || existingContacts.size()>0) {

            List<Lead> leadsToUpdate = new List<Lead>();

            for(Lead leadToUpdate : leadsToDeleteSet) {
                leadToUpdate.HasOptedOutOfEmail = true;
                leadToUpdate.Description = 'Duplicate';
                leadToUpdate.Insights_Newsletter__c = false;
                leadToUpdate.Press_Releases__c = false;
                leadToUpdate.Product_Announcements__c = false;
                leadToUpdate.Entertainment_Outlook__c = false;
                leadToUpdate.Food_For_Thought_Brief__c = false;
                leadToUpdate.UK_Foodservice_Topline_Top_3__c = false;
//KR 20130621: Added new NPD Blog & Subscription fields, commented out individual Blog fields
                leadToUpdate.NPD_Group_Blog__c = false;
                leadToUpdate.Subscriptions__c = '';
                leadsToUpdate.add(leadToUpdate);
            }
            
            update leadsToUpdate;

        }
       
    }
}