/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Ibanking_Project__c trigger handler. Runs onAfterInsert 
 * \test SL_Test_Deal_Trigger_Handler
 */
 public without sharing class SL_Deal_Trigger_Handler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToFollowersAdded = false;
    private static Boolean HasRun = false;
    private static Lead tempLead;
     
    public SL_Deal_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(map<ID,Ibanking_Project__c> newMap_DealIds_Deals)
    {   
        if(!isFeedToFollowersAdded)
        {
            isFeedToFollowersAdded = true;
            setFeedToAccount(newMap_DealIds_Deals);
        }
        SendNbrcEmails(newMap_DealIds_Deals, null);
    }

    /*
    public void onBeforeInsert(map<Id,Ibanking_Project__c> newMap)
    {
       
    }
    */
    
    public void onBeforeUpdate(map<Id,Ibanking_Project__c> newMap, map<Id,Ibanking_Project__c> oldMap)
    {
        /*if(!HasRun)
        {
            HasRun = true;
            for(Ibanking_Project__c objDeal : newMap.values())
            {
                system.debug('==========In trigger here=========');
                if((objDeal.Senior_Banker_Deal_Team_Member__c == null && objDeal.Deal_Team_Members__c == null) || objDeal.Senior_Banker_Deal_Team_Member__c!=oldMap.get(objDeal.Id).Senior_Banker_Deal_Team_Member__c || objDeal.Deal_Team_Members__c!=oldMap.get(objDeal.Id).Deal_Team_Members__c)
                {
                    objDeal.Apex_Context__c = true;
                }
            }
        }*/
    }
    

    public void OnAfterUpdate(map<Id,Ibanking_Project__c> newMap, map<Id,Ibanking_Project__c> oldMap)
    {
        SendNbrcEmails(newMap, oldMap);
    }

    public void SendNbrcEmails(map<Id,Ibanking_Project__c> newMap, map<Id,Ibanking_Project__c> oldMap)
    {
        map<Id,Ibanking_Project__c> DealsForConflictClearanceEmail = new map<Id,Ibanking_Project__c>();
        map<Id,Ibanking_Project__c> DealsForConflictClearance1bEmail = new map<Id,Ibanking_Project__c>();
        map<Id,Ibanking_Project__c> DealsForNdaCdaEmail = new map<Id,Ibanking_Project__c>();
        map<Id,Ibanking_Project__c> DealsForConflictClearanceApprovalEmail = new map<Id,Ibanking_Project__c>();
        map<Id,Ibanking_Project__c> DealsForAmlKycEmail = new map<Id,Ibanking_Project__c>();
        If(oldMap == null){
            for(Id deal : newMap.keySet())
            {
                if(newMap.get(deal).Business_Conflict_Checked_Status__c == 'Approved'){
                    DealsForConflictClearanceApprovalEmail.put(deal,newMap.get(deal));
                }
            }
        }
        else
        {
            for(Id deal : newMap.keySet())
            {
                
                if(newMap.get(deal).Send_Conflict_Clearance__c && !oldMap.get(deal).Send_Conflict_Clearance__c){
                    DealsForConflictClearanceEmail.put(deal,newMap.get(deal));
                }
                else if(newMap.get(deal).Send_Conflict_Clearance_Update__c 
                    && !oldMap.get(deal).Send_Conflict_Clearance_Update__c){
                    DealsForConflictClearance1bEmail.put(deal,newMap.get(deal));
                }

                if(newMap.get(deal).Send_NDA_CDA_Review__c && !oldMap.get(deal).Send_NDA_CDA_Review__c){
                    DealsForNdaCdaEmail.put(deal,newMap.get(deal));
                }
                if(newMap.get(deal).Send_Conflict_Clearance_Approved__c && !oldMap.get(deal).Send_Conflict_Clearance_Approved__c){
                    DealsForConflictClearanceApprovalEmail.put(deal,newMap.get(deal));
                }
                if(newMap.get(deal).Send_AML_KYC__c && !oldMap.get(deal).Send_AML_KYC__c){
                    DealsForAmlKycEmail.put(deal,newMap.get(deal));
                }     
            }
        }

        list<Messaging.Email> mailToSend = new list<Messaging.Email>();
        list<EmailTemplate> templates = [  SELECT Id, DeveloperName FROM EmailTemplate 
                                            WHERE DeveloperName IN (
                                                'Conflict_Clearance_1_Request_Confirmation',
                                                'Conflict_Clearance_1b_Request_Confirmation',
                                                'Conflict_Clearance_2a_NDA_Review_Deal_Team',
                                                'Conflict_Clearance_2b_NDA_Review_Legal',
                                                'Conflict_Clearance_3_Conflict_Clearance_Approval',
                                                'Conflict_Clearance_4_AML_KYC_Requirements')
                                        ];
        Map<String,EmailTemplate> developerNameToTemplate = new Map<String,EmailTemplate>();
        for(EmailTemplate template : templates){
            developerNameToTemplate.put(template.DeveloperName, template);
        }

        map<Id,set<String>> dealToDealTeamEmails = getDealTeamEmails(newMap);
        map<Id,String> dealToLastModifiedEmail = getLastModifiedEmails(newMap);
        
        map<Id,set<String>> DealTeamAndLastModified = new map<Id,set<String>>();
        if( DealsForConflictClearanceEmail.size() > 0 || DealsForConflictClearance1bEmail.size() > 0 
            || DealsForNdaCdaEmail.size() > 0 || DealsForAmlKycEmail.size() > 0){
            DealTeamAndLastModified = dealToDealTeamEmails;
            for(Id Deal : DealsForConflictClearanceEmail.keyset())
            {
                if(DealTeamAndLastModified.containsKey(Deal) && DealTeamAndLastModified.get(Deal).size() > 0){
                    DealTeamAndLastModified.get(Deal).add(dealToLastModifiedEmail.get(Deal));
                }
                else{
                    DealTeamAndLastModified.put(Deal, new set<String>{dealToLastModifiedEmail.get(Deal)});
                }
            }
        }

        if(DealsForConflictClearanceEmail.size() > 0)
        {
            mailToSend.addAll(buildEmails(  developerNameToTemplate.get('Conflict_Clearance_1_Request_Confirmation'),
                                            DealsForConflictClearanceEmail,
                                            DealTeamAndLastModified,
                                            true));
        }
        if(DealsForConflictClearance1bEmail.size() > 0)
        {
            mailToSend.addAll(buildEmails(  developerNameToTemplate.get('Conflict_Clearance_1b_Request_Confirmation'),
                                            DealsForConflictClearance1bEmail,
                                            DealTeamAndLastModified,
                                            true));
        }
        if(DealsForNdaCdaEmail.size() > 0)
        {
            mailToSend.addAll(buildEmails(  developerNameToTemplate.get('Conflict_Clearance_2a_NDA_Review_Deal_Team'),
                                            DealsForNdaCdaEmail,
                                            DealTeamAndLastModified,
                                            false));

            mailToSend.addAll(buildEmails(  developerNameToTemplate.get('Conflict_Clearance_2b_NDA_Review_Legal'), 
                                            DealsForNdaCdaEmail,
                                            getLegalEmails(DealsForNdaCdaEmail),
                                            false));
        }
        if(DealsForConflictClearanceApprovalEmail.size() > 0){
            mailToSend.addAll(buildEmails(  developerNameToTemplate.get('Conflict_Clearance_3_Conflict_Clearance_Approval'), 
                                            DealsForConflictClearanceApprovalEmail,
                                            dealToDealTeamEmails,
                                            false));
        }
        if(DealsForAmlKycEmail.size() > 0)
        {
            mailToSend.addAll(buildEmails(  developerNameToTemplate.get('Conflict_Clearance_4_AML_KYC_Requirements'),
                                            DealsForAmlKycEmail,
                                            DealTeamAndLastModified,
                                            false));
        }
        System.debug(mailToSend);
        if(mailToSend.size() > 0){
            sendMail(MailToSend);
        }
    }

    public list<Messaging.Email> buildEmails(   EmailTemplate template,
                                                map<Id,Ibanking_Project__c> DealsForNbrcEmail,
                                                map<Id,set<String>> toAddresses,
                                                boolean ccConflictClearance)
    {
        map<Id,String> dealsToLinks = getDealsToLinks(DealsForNbrcEmail);
        map<Id,String> dealsToLastModifiedNames = getLastModifiedNames(DealsForNbrcEmail);

        list<Messaging.Email> conflictClearanceEmails = new list<Messaging.Email>();
        if(tempLead == null){
            tempLead = new Lead(lastName = 'Test', Email = 'Salesforce.Admin@moelis.com', Status = 'Open', Company = 'Silverline');
            insert tempLead;
        }
        Id targetId = tempLead.Id;
        for(Id Deal : DealsForNbrcEmail.keySet())
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            //mail.setSubject(template.Subject + ': ' + DealsForNbrcEmail.get(Deal).Name);
            mail.setTemplateId(template.Id);
            mail.setWhatId(Deal);
            mail.setTargetObjectId(targetId);
            mail.setSaveAsActivity(false);

            if(toAddresses.containsKey(Deal) && toAddresses.get(Deal).size() > 0){
                list<String> toAddressList = new list<String>();
                toAddressList.addAll(toAddresses.get(Deal));
                mail.setToAddresses(toAddressList);
            }

            if(ccConflictClearance && URL.getSalesforceBaseUrl().toexternalform() == 'https://moelis.my.salesforce.com'){
                mail.setCcAddresses(new list<String>{'DL_ConflictClearance@moelis.com'});
            }

            Id fromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'Salesforce.Admin@moelis.com'].Id;

            mail.setOrgWideEmailAddressId(fromAddress);

            conflictClearanceEmails.add(mail);
        }
        return conflictClearanceEmails;

    }

    public map<Id,set<String>> getDealTeamEmails(map<Id,Ibanking_Project__c> Deals)
    {
        map<Id, set<String>> dealsToEmails = new map<Id, set<String>>();


        list<Project_Resource__c> DealTeam = [  SELECT Project__c, Banker__r.Email__c 
                                                FROM Project_Resource__c
                                                WHERE Project__c IN :Deals.keySet()
                                                AND Status__c = 'Active'];

        for(Project_Resource__c member : DealTeam)
        {
            If(dealsToEmails.containsKey(member.Project__c)){
                dealsToEmails.get(member.Project__c).add(member.Banker__r.Email__c);
            }
            else{
                dealsToEmails.put(member.Project__c, new set<String>{member.Banker__r.Email__c});
            }
        }
        return dealsToEmails;
    }

    public map<Id,set<String>> getLegalEmails(map<Id,Ibanking_Project__c> Deals)
    {
        map<Id, set<String>> dealsToEmails = new map<Id, set<String>>();

        set<Id> legalTeamIds = new set<Id>();
        for(GroupMember legalTeamMember :  [ SELECT UserOrGroupId from groupMember WHERE Group.DeveloperName = 'Legal_NDA_Review'])
        {
            if(legalTeamMember.UserOrGroupId.getSObjectType() == User.sObjectType){
                legalTeamIds.add(legalTeamMember.UserOrGroupId);
            }
        }
        system.debug('%#% legalTeamIds: ' + legalTeamIds);
        set<String> legalEmails = new set<String>();
        for(User legalTeamMember : [Select Email From User Where Id In :legalTeamIds])
        {
            legalEmails.add(legalTeamMember.Email);
        }

        for(Id DealId : Deals.keyset())
        {
            dealsToEmails.put(DealId, legalEmails);
        }
        return dealsToEmails;
    }

    public map<Id,String> getLastModifiedEmails(map<Id,Ibanking_Project__c> Deals)
    {
        set<Id> lastModifiedIds = new set<Id>();
        for(Ibanking_Project__c Deal : Deals.values())
        {
            lastModifiedIds.add(Deal.LastModifiedById);
        }
        
        map<Id,User> UserIdToUserEmails = new map<Id,User>([Select Id, Email From User Where Id IN :lastModifiedIds]);
        map<Id,String> DealsToLastModifiedEmails = new map<Id,String>();

        for(Ibanking_Project__c Deal : Deals.values())
        {
            DealsToLastModifiedEmails.put(Deal.Id, UserIdToUserEmails.get(Deal.LastModifiedById).Email);
        }

        return DealsToLastModifiedEmails;
    }

    public map<Id,String> getLastModifiedNames(map<Id,Ibanking_Project__c> Deals)
    {
        set<Id> lastModifiedIds = new set<Id>();
        for(Ibanking_Project__c Deal : Deals.values())
        {
            lastModifiedIds.add(Deal.LastModifiedById);
        }
        
        map<Id,User> UserIdToUserNames = new map<Id,User>([Select Id, Name From User Where Id IN :lastModifiedIds]);
        map<Id,String> DealsToLastModifiedNames = new map<Id,String>();

        for(Ibanking_Project__c Deal : Deals.values())
        {
            DealsToLastModifiedNames.put(Deal.Id, UserIdToUserNames.get(Deal.LastModifiedById).Name);
        }

        return DealsToLastModifiedNames;
    }

    public map<Id,String> getDealsToLinks(map<Id,Ibanking_Project__c> Deals)
    {
        map<Id,String> dealsToLinks = new map<Id,String>();
        for(Ibanking_Project__c Deal : Deals.values())
        {
            String fullUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + Deal.Id;
            dealsToLinks.put(Deal.Id, fullUrl);
        }
        return dealsToLinks;
    }

    public void sendMail(list<Messaging.Email> mailToSend)
    {
        Messaging.sendEmail(mailToSend);
        if(!Test.isRunningTest()){
            Delete tempLead;
        }
    }
     
    private void setFeedToAccount(map<ID,Ibanking_Project__c> map_DealIds_Deals)
    {
        Set<Id> listDealIds = map_DealIds_Deals.keySet(); 
        map<Id, SL_Trigger_Helper.AccountValues> map_DealIds_Account = new map<Id, SL_Trigger_Helper.AccountValues>();
        map<Id, Id> map_DealId_AccountId = new map<Id, Id>();
        for(Ibanking_Project__c item :[ SELECT id,Client__c,Client__r.Name
                                        FROM Ibanking_Project__c
                                        WHERE Id IN : listDealIds])
        {
            map_DealIds_Account.put(item.Id,new SL_Trigger_Helper.AccountValues(item.Client__c,item.Client__r.Name));
            map_DealId_AccountId.put(item.Id,item.Client__c);
        }
        SL_Trigger_Helper.createFeedMessage(map_DealIds_Account, 'Deal');
        
        //test case from letter: do not add feed for contacts when new Deal is created
        //SL_Trigger_Helper.createFeedMessageForContactsOfAccount(map_DealId_AccountId, 'Deal');
        
        /*
        map<Id, list<EntitySubscription>> map_DealIds_listFollowers = new map<Id, list<EntitySubscription>>();
        //List<EntitySubscription> followers = 
        for(EntitySubscription item :[  SELECT id,parentid, subscriberid, subscriber.Name
                                        FROM EntitySubscription 
                                        WHERE parentid IN : listDealIds])
        {
            if(!map_DealIds_listFollowers.keySet().contains(item.parentid))map_DealIds_listFollowers.put(item.parentid, new list<EntitySubscription>());
            map_DealIds_listFollowers.get(item.parentid).add(item);
        }
        system.debug('map_DealIds_listFollowers = '+map_DealIds_listFollowers);
        
        if(map_DealIds_listFollowers.keySet().size() > 0 )
        {
            for(Id dealId : map_DealIds_listFollowers.keySet()) 
            {
                if(map_DealIds_listFollowers.get(dealId) != null)
                {
                    for(EntitySubscription follower : map_DealIds_listFollowers.get(dealId))
                    {
                        //Adding a Link post
                        FeedItem post = new FeedItem();
                        post.ParentId = follower.subscriberid;
                        post.Body = follower.subscriber.Name+' has created an Deal with '+(map_DealIds_Account.get(dealId)!=null ? map_DealIds_Account.get(dealId).Company_Counsel_Firm__r.Name : '');
                        post.LinkUrl = ApexPages.currentPage().getUrl()+dealId;
                        listFeedItemToAdd.add(post);
                        if(listFeedItemToAdd.size() == 100 ) 
                        {   
                            insert listFeedItemToAdd;
                            listFeedItemToAdd = new list<FeedItem>();
                        }
                    }
                }
            }
        }
        if(listFeedItemToAdd.size() > 0 ) insert listFeedItemToAdd;
         */
    } 
}