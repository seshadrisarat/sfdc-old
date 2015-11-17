// Name			: ChatterEmailScheduler
// Author 		: Kapil Choudhary (Appirio Offshore)
// Created Date : 7-January-2013
// Description	: Schedular class for T-107258.
// Last Modified: 

global class ChatterEmailScheduler implements Schedulable{ 
  global void execute(SchedulableContext SC) {
     set<string>selectedGroupId = new set<string>();
        map<id,set<string>> internalGroupMap = new map<id,set<string>>();
        map<id,attachment>feedAttachmentMap = new map<id,attachment>();
        map<id,FeedMailGroup__c> feedmailGroupMap = new  map<id,FeedMailGroup__c>();
        
        for(FeedMailGroup__c fm :[SELECT Display_Text__c,Mail_Reply_To__c,Email_Failure__c,External_Email_Groups__c,File_Name__c,HtmlBody__c,Include_Custom_Message__c,Internal_Email_Groups__c,IsMailSent__c, 
                                  Mail_Send_On__c,Message__c,Name,Subject__c,Ad_hoc_Emails__c FROM FeedMailGroup__c WHERE IsMailSent__c = false and Mail_Send_On__c <=: system.now()]) {
             
             if(fm.Internal_Email_Groups__c != null){
                selectedGroupId = new set<string>();
                selectedGroupId.addall(fm.Internal_Email_Groups__c.split(';'));
                
                if(!internalGroupMap.containskey(fm.id)){
                  internalGroupMap.put(fm.id,new set<string>());
                }
                 internalGroupMap.get(fm.id).addall(selectedGroupId);
             }
             feedmailGroupMap.put(fm.id,fm);
         }
         
         map<id,set<id>> internalGroupMembersMap = new map<id,set<id>>();
         set<string>internalGroupSetId =  new set<string>();
        
         for(set<string> st : internalGroupMap.values()) {
             internalGroupSetId.addall(st);
         }
         
         for(GroupMember gm:[SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId in:internalGroupSetId]) {
                if(!internalGroupMembersMap.containskey(gm.GroupId)){
                  internalGroupMembersMap.put(gm.GroupId,new set<id>());
                }
                 internalGroupMembersMap.get(gm.GroupId).add(gm.UserOrGroupId);
              }
        map<id,set<string>> groupWiseMemberEmailMap = new map<id,set<string>>();
        map<id,string> groupMemberUserIdEmailMap = new map<id,string>();
        
        if(!internalGroupMembersMap.isEmpty()){
            Set<id> useridSet = new Set<id>(); 
            
            for(set<id> st : internalGroupMembersMap.values()) {
             useridSet.addall(st);
            }
            
            for(user usr : [select id ,email from user where id in : useridSet]){
                groupMemberUserIdEmailMap.put(usr.id,usr.email);
            }
            
            for(id groupId :internalGroupMembersMap.keyset()){
                for(id usrId : internalGroupMembersMap.get(groupId)){
                    if(!groupWiseMemberEmailMap.containskey(groupId)){
                        groupWiseMemberEmailMap.put(groupId,new set<string>());
                    }
                    if(groupMemberUserIdEmailMap.containskey(usrId)){
                        groupWiseMemberEmailMap.get(groupId).add(groupMemberUserIdEmailMap.get(usrId));
                    }
                }
            }
        }
        
        for(attachment att : [SELECT Body,ContentType,Id,Name,ParentId FROM Attachment where ParentId in : feedmailGroupMap.keyset()]){
            feedAttachmentMap.put(att.ParentId,att);
        }
       // system.debug('feedAttachmentMap>>>>> '+feedmailGroupMap.keyset());
        for(id feedId : feedmailGroupMap.keyset()){
             FeedMailGroup__c fmg = feedmailGroupMap.get(feedId);
             List<string> emailAddressList = new List<string>();
             
             if(fmg.Internal_Email_Groups__c != null){
                for(string groupId : fmg.Internal_Email_Groups__c.split(';')){
                    if(groupWiseMemberEmailMap.containskey(groupId)){
                        emailAddressList.addall(groupWiseMemberEmailMap.get(groupId));
                    }
                }
            }
            if(fmg.Ad_hoc_Emails__c != null && fmg.Ad_hoc_Emails__c != ''){
            	for(string emailAddress : fmg.Ad_hoc_Emails__c.split(';')){
            		 emailAddressList.add(emailAddress);
            	}
            }
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            if(fmg.File_Name__c != null){
                attach.setFileName(fmg.File_Name__c+'.pdf');
            }
            else{
                attach.setFileName('ChatterFeed'+System.Today()+'.pdf');
            }
            attach.setInline(false);
            attach.Body = feedAttachmentMap.get(fmg.id).Body;
            //system.debug('CCCCCCC>>>'+htmlpg.getContent().toString());
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
                //mail.setToAddresses(new String[] { email });
            mail.setToAddresses(emailAddressList);
            mail.setSubject(fmg.subject__c);
            if(fmg.include_Custom_Message__c){
                  mail.setHtmlBody(fmg.message__c + fmg.HtmlBody__c);
            }
            else{
                 mail.setHtmlBody(fmg.HtmlBody__c);
            }
          
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            
            if(fmg.Mail_Reply_To__c != null){
            	mail.setReplyTo(fmg.Mail_Reply_To__c );
            	system.debug('Mail_Send_From__c>>>'+fmg.Mail_Reply_To__c);
            }
            if(fmg.Display_Text__c != null){
            	mail.setSenderDisplayName(fmg.Display_Text__c);
            }
            
            // Send the email
            try{
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            	fmg.IsMailSent__c = true; 
            }
            catch (EmailException ex){
            	string emailexp ='';
            	for (Integer i = 0; i < ex.getNumDml(); i++) {
        			// Process exception here
        			System.debug('Email exception >>> '+ex.getDmlMessage(i)); 
        			emailexp += ex.getDmlMessage(i);
    			}
            	fmg.Email_Failure__c = emailexp;
            }
        }
                
        update feedmailGroupMap.values();
       // system.debug('-->>> '+internalGroupMap);
       // system.debug('-->>> '+internalGroupMembersMap);
      // system.debug('-->>> @@@@ '+groupWiseMemberEmailMap);
  }
}