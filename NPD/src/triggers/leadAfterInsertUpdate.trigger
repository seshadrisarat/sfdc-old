trigger leadAfterInsertUpdate on Lead (after insert) {
//Mod: 03/14/2013 KR, Add Marketing Campaign 'Web-Marketing-UK Opt In Web Page-201303'   

   if(UserInfo.getUserId() <> '00500000006z3qKAAQ'){
       
       Map<String,String> newLeadsMap = new Map<String,String>();
       
       for(Lead newLead : Trigger.new) {
           if((null != newLead.Email) && ((newLead.MarketingCampaign__c == 'Web-Marketing-Opt In Web Page-200807') || (newLead.MarketingCampaign__c == 'Web-Marketing-Blog Opt In Web Page-201207') || (newLead.MarketingCampaign__c == 'Web-Marketing-UK Opt In Web Page-201303'))) {
                if(newLeadsMap.containsKey(newLead.Email.toLowerCase())) {
                   newLead.Email.addError('Another new lead is already using this email address.');
               }else {
                   string emailString = newLead.Email.toLowerCase();//this line is necessary because map keys are case sensitive and therefore have to be converted to lowercase.   
                   system.debug('This is the incoming email(the map Key)after being converted to LowerCase: '+emailString);
                   newLeadsMap.put(emailString, newLead.ID);
               }
           }
       }
       
       leadHandler.leadDeDuper(newLeadsMap);
   }
}