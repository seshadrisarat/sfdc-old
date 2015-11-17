global without sharing class SL_UsersWithMismatchedContacts_Cleanup implements Database.Batchable<sObject>, Database.Stateful {
    
    // Query to get all Active Portal Users associated with Contacts which are NOT Primary Contacts
    global String query;
    global String contactQueryStart;
    global String contactFields;
    //Set<SObject>  objectsToDelete;
    //Set<SObject> objectsToUpdate;
    //Set<SObject> objectsToInsert;
    //Set<SObject> relatedObjectsToUpdate;
    //Set<SObject> relatedObjectsToInsert;
    
    global SL_UsersWithMismatchedContacts_Cleanup(String optionalQuery) {
        if(optionalQuery != null && optionalQuery != '')
            query = optionalQuery;
        else{
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Pure Customer Community Login User' LIMIT 1].Id;
            query = 'SELECT Id, Name, Email, ContactId, isActive ' +
                    'FROM User ' + 
                    'WHERE isActive = true AND ' +
                              'ContactId NOT in (SELECT Id ' +
                                                'FROM Contact ' +
                                                'WHERE Primary__c = true) AND ' +
                              'ContactId != null AND ' +
                              'ProfileId = \'' + profileId + '\'';
        }

        // Build a query with all Contact fields
        Map<String, Schema.SObjectField> fieldObjMap = schema.SObjectType.Contact.fields.getMap();
        List<Schema.SObjectField> fieldObjMapValues = fieldObjMap.values();

        contactQueryStart = 'SELECT ';
        contactFields = '';

        for(Schema.SObjectField s : fieldObjMapValues)
        {
            String theName = s.getDescribe().getName();
            
            if(s.getDescribe().isUpdateable()){
                contactFields += theName + ',';
                contactQueryStart += theName + ',';
            }
        }

        // Trim last comma
        contactQueryStart = contactQueryStart.subString(0, contactQueryStart.length() - 1);
        contactQueryStart += ' FROM Contact ';

        contactFields = contactFields.subString(0, contactFields.length() - 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest())
            return Database.getQueryLocator(query + ' ORDER BY CreatedDate DESC LIMIT 150');
        else
            return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() == 0)
            return;

        String contactQuery = contactQueryStart + 'WHERE ID in (\'';
        for(User u : (List<User>)scope){ 
            contactQuery += u.ContactId + '\',\'';
        }

        // Trim last comma and quotation mark
        contactQuery = contactQuery.substring(0, contactQuery.length()-2);
        contactQuery += ')';

        System.debug('~~~~ contactQuery: ' + contactQuery);
        Map<Id, Contact> contactsMap = new Map<Id, Contact>((List<Contact>)Database.query(contactQuery));
        System.debug('~~~~ contactsMap: ' + contactsMap);

        String primaryContactQuery = contactQueryStart + 'WHERE Primary__c = true AND AccountId in (';

        Map<Id, List<Contact>> accountIdContactMap = new Map<Id, List<Contact>>();

        if(contactsMap.values().size() > 0){

            primaryContactQuery += '\'';

            for(Contact c : contactsMap.values()){
                
                primaryContactQuery += c.AccountId + '\',\'';
                addToMap(c, accountIdContactMap);
            }

            // Trim last comma and quotation mark
            primaryContactQuery = primaryContactQuery.substring(0, primaryContactQuery.length()-2);
        }
        else {
            primaryContactQuery += '\'\'';
        }

        primaryContactQuery += ')';

        System.debug('~~~~ Primary query: ' + primaryContactQuery);

        List<Contact> primaryContacts =(List<Contact>)Database.query(primaryContactQuery);
        List<Id> primaryContactIds = new List<Id>();
        for(Contact pc : primaryContacts){
            primaryContactIds.add(pc.Id);
            addToMap(pc, accountIdContactMap);
        }

        List<CampaignMember> campaignMembers = [SELECT Id, ContactId, CampaignId, Status
                                                FROM CampaignMember 
                                                WHERE ContactId IN :primaryContactIds];
        Map<Id, List<CampaignMember>> campaignMembersMap = mapObjects(campaignMembers, 'ContactId');

        List<Task> tasks = [SELECT Id, WhoId FROM Task WHERE WhoId IN :primaryContactIds];
        Map<Id, List<Task>> taskMap = mapObjects(tasks, 'WhoId');

        List<Event> events = [SELECT Id, WhoId FROM Event WHERE WhoId IN :primaryContactIds];
        Map<Id, List<Event>> eventMap = mapObjects(events, 'WhoId');

        List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, 
                                              Description, OwnerId, ParentId 
                                        FROM Attachment 
                                        WHERE ParentId IN :primaryContactIds];
        Map<Id, List<Attachment>> attachmentsMap = mapObjects(attachments, 'ParentId');

        List<Note> notes = [SELECT Id, Body, Title, 
                                   ParentId, IsPrivate
                            FROM Note 
                            WHERE ParentId IN :primaryContactIds];
        Map<Id, List<Note>> notesMap = mapObjects(notes, 'ParentId');

        List<ContactFeed> contactFeeds = [SELECT Id, Type, CreatedById,
                                            ParentId, Body, Title, ContentData,
                                            ContentFileName, ContentDescription, RelatedRecordId, 
                                            LinkURL, NetworkScope, Visibility,
                                         (SELECT Id, CommentBody, CreatedDate,
                                                CreatedById, CreatedBy.FirstName, CreatedBy.LastName
                                                FROM FeedComments ORDER BY CreatedDate LIMIT 10)
                                         FROM ContactFeed
                                         WHERE ParentId IN :primaryContactIds
                                         ORDER BY CreatedDate DESC, Id DESC
                                         LIMIT 20];
        Map<Id, List<ContactFeed>> contactFeedMap = mapObjects(contactFeeds, 'ParentId');
        
        Set<SObject> objectsToDelete = new Set<sObject>();
        Set<SObject> objectsToUpdate = new Set<sObject>();
        Set<SObject> objectsToInsert = new Set<sObject>();
        Set<SObject> relatedObjectsToUpdate = new Set<SObject>();
        Set<SObject> relatedObjectsToInsert = new Set<SObject>();

        // For each account with a mismatched user and contact, clone user associated contact
        // copy data from primary contact to user associated contact original, and
        // delete the primary contact
        for(Id accountId : accountIdContactMap.keySet()){

            List<Contact> contacts = accountIdContactMap.get(accountId);
            Contact primaryContact;
            Contact userAssociatedContact;

            if(contacts.size() != 2){
                System.debug('~~~~ Contact without a corresponding primary contact: ' + contacts);
                continue;
            } else {
                for(Contact c : contacts){
                    if(c.Primary__c == true)
                        primaryContact = c;
                    else
                        userAssociatedContact = c;
                }

                if(primaryContact == null || userAssociatedContact == null){
                    System.debug('~~~~ Missing a contact! --primaryContact: ' + primaryContact + ' --userAssociatedContact: ' + userAssociatedContact);
                    continue;
                }

                // Deep clone contact
                Contact clonedContact = userAssociatedContact.clone(false, true, true, false);

                // Update all Task and Event WhoIds
                // user associated contact -> clone
                // primary -> user associated contact
                relatedObjectsToUpdate.addAll(updateObjects(taskMap, userAssociatedContact.Id, clonedContact.Id, 'WhoId'));
                relatedObjectsToUpdate.addAll(updateObjects(taskMap, primaryContact.Id, userAssociatedContact.Id, 'WhoId'));

                relatedObjectsToUpdate.addAll(updateObjects(eventMap, userAssociatedContact.Id, clonedContact.Id, 'WhoId'));
                relatedObjectsToUpdate.addAll(updateObjects(eventMap, primaryContact.Id, userAssociatedContact.Id, 'WhoId'));

                // Duplicate all CampaignMember where ContactId matches
                relatedObjectsToInsert.addAll((List<SObject>)duplicateCampaignMember(campaignMembersMap, userAssociatedContact.Id, clonedContact.Id));
                relatedObjectsToInsert.addAll((List<SObject>)duplicateCampaignMember(campaignMembersMap, primaryContact.Id, userAssociatedContact.Id));

                // Duplicate all attachments
                relatedObjectsToInsert.addAll((List<SObject>)duplicateAttachments(attachmentsMap, userAssociatedContact.Id, clonedContact.Id));
                relatedObjectsToInsert.addAll((List<SObject>)duplicateAttachments(attachmentsMap, primaryContact.Id, userAssociatedContact.Id));

                // Duplicate all notes
                relatedObjectsToInsert.addAll((List<SObject>)duplicateNotes(notesMap, userAssociatedContact.Id, clonedContact.Id));
                relatedObjectsToInsert.addAll((List<SObject>)duplicateNotes(notesMap, primaryContact.Id, userAssociatedContact.Id));
                
                // Duplicate all chatter posts that can be duplicated
                relatedObjectsToInsert.addAll((List<SObject>)duplicateContactFeeds(contactFeedMap, userAssociatedContact.Id, clonedContact.Id));
                relatedObjectsToInsert.addAll((List<SObject>)duplicateContactFeeds(contactFeedMap, primaryContact.Id, userAssociatedContact.Id));

                //Overwrite user associated contact with primary contact's information
                for(String field : contactFields.split(',')){
                    userAssociatedContact.put(field, primaryContact.get(field));
                }

                // Delete old Primary Contact, update user associated contact,
                // insert cloned contact
                objectsToDelete.add(primaryContact);
                objectsToUpdate.add(userAssociatedContact);
                objectsToInsert.add(clonedContact);

                System.debug('~~~~ Cloned Contact: ' + clonedContact);
                System.debug('~~~~ User Associated Contact: ' + userAssociatedContact);
                System.debug('~~~~ Primary Contact ' + primaryContact);
            }
        }

        System.debug('~~~~ Related objects to update: ' + relatedObjectsToUpdate);
        if(relatedObjectsToUpdate.size() > 0){
            List<sObject> relatedUpdateList = new List<sObject>();
            relatedUpdateList.addAll(relatedObjectsToUpdate);
            update relatedUpdateList;
        }

        System.debug('~~~~ Related objects to insert' + relatedObjectsToInsert);
        if(relatedObjectsToInsert.size() > 0){
            List<sObject> relatedInsertList = new List<sObject>();
            relatedInsertList.addAll(relatedObjectsToInsert);
            insert relatedInsertList;
        }

        System.debug('~~~~ Deleting: ' + objectsToDelete);
        if(objectsToDelete.size() > 0){
            List<sObject> relatedDeleteList = new List<sObject>();
            relatedDeleteList.addAll(objectsToDelete);
            delete relatedDeleteList;
        }

        System.debug('~~~~ Updating: ' + objectsToUpdate);
        if(objectsToUpdate.size() > 0){
            List<sObject> updateList = new List<sObject>();
            updateList.addAll(objectsToUpdate);
            update updateList;
        }

        System.debug('~~~~ Inserting: ' + objectsToInsert);
        if(objectsToInsert.size() > 0){
            List<sObject> insertList = new List<sObject>();
            insertList.addAll(objectsToInsert);
            insert insertList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //System.debug('~~~~ Related objects to update: ' + relatedObjectsToUpdate);
        //if(relatedObjectsToUpdate.size() > 0){
        //  List<sObject> relatedUpdateList = new List<sObject>();
        //  relatedUpdateList.addAll(relatedObjectsToUpdate);
        //  update relatedUpdateList;
        //}

        //System.debug('~~~~ Related objects to insert' + relatedObjectsToInsert);
        //if(relatedObjectsToInsert.size() > 0){
        //  List<sObject> relatedInsertList = new List<sObject>();
        //  relatedInsertList.addAll(relatedObjectsToInsert);
        //  insert relatedInsertList;
        //}

        //System.debug('~~~~ Deleting: ' + objectsToDelete);
        //if(objectsToDelete.size() > 0){
        //  List<sObject> relatedDeleteList = new List<sObject>();
        //  relatedDeleteList.addAll(objectsToDelete);
        //  delete relatedDeleteList;
        //}

        //System.debug('~~~~ Updating: ' + objectsToUpdate);
        //if(objectsToUpdate.size() > 0){
        //  List<sObject> updateList = new List<sObject>();
        //  updateList.addAll(objectsToUpdate);
        //  update updateList;
        //}

        //System.debug('~~~~ Inserting: ' + objectsToInsert);
        //if(objectsToInsert.size() > 0){
        //  List<sObject> insertList = new List<sObject>();
        //  insertList.addAll(objectsToInsert);
        //  insert insertList;
        //}
    }

    private void addToMap(Contact c, Map<Id, List<Contact>> accountContactMap){
        List<Contact> contacts = accountContactMap.get(c.AccountId);

        if(contacts == null){ contacts = new List<Contact>(); }

        contacts.add(c);
        accountContactMap.put(c.AccountId, contacts);
    }

    private List<sObject> updateObjects(Map<Id, List<sObject>> objectsMap, Id contactToChange, Id contactReplacement, String fieldToUpdate){
        List<sObject> objects = objectsMap.get(contactToChange);
        List<sObject> objectsToUpdate = new List<sObject>();
        if(objects != null){
            for(sObject a : objects){
                a.put(fieldToUpdate, contactReplacement);
                objectsToUpdate.add(a);
            }
        }
        System.debug('~~~~ Adding these objects to update: ' + objectsToUpdate);
        return objectsToUpdate;
    }

    private Map<Id, List<sObject>> mapObjects(List<sObject> objectList, String fieldToUpdate){
        List<sObject> objects = objectList;
                
        // Map from primary contact id to Object with primary contact as fieldToUpdate
        Map<Id, List<sObject>> primaryContactObjectMap = new Map<Id, List<sObject>>();

        // Map all Objects with fieldToUpdate that match with a primary contact to the contact id
        if(objects.size() > 0){
            for(SObject a : objects){

                Id contactId = (Id)a.get(fieldToUpdate);
                List<sObject> primaryContactObjects = primaryContactObjectMap.get(contactId);

                if(primaryContactObjects == null){ primaryContactObjects = new List<sObject>(); }

                primaryContactObjects.add(a);
                primaryContactObjectMap.put(contactId, primaryContactObjects);
            }
        }

        return primaryContactObjectMap;
    }

    private List<CampaignMember> duplicateCampaignMember(Map<Id, List<CampaignMember>> campaignMembersMap, Id contactToReplace, Id contactReplacement){
        List<CampaignMember> contactCampaignMembers = campaignMembersMap.get(contactToReplace);
        List<CampaignMember> duplicateCampaignMembers = new List<CampaignMember>();

        if(contactCampaignMembers != null){
            for(CampaignMember cm : contactCampaignMembers){
                CampaignMember dupeCM= new CampaignMember();
                dupeCM.CampaignId = cm.CampaignId;
                dupeCM.ContactId = contactReplacement;
                dupeCM.Status = cm.Status;
                duplicateCampaignMembers.add(dupeCM);
            }
        }

        return duplicateCampaignMembers;
    }

    private List<Attachment> duplicateAttachments(Map<Id, List<Attachment>> attachmentsMap, Id contactToReplace, Id contactReplacement){
        List<Attachment> contactAttachments = attachmentsMap.get(contactToReplace);
        List<Attachment> duplicateAttachments = new List<Attachment>();

        if(contactAttachments != null){
            for(Attachment a : contactAttachments){
                Attachment dupeA = new Attachment();
                dupeA.Name = a.Name;
                dupeA.Body = a.Body;
                dupeA.Description = a.Description;
                dupeA.ContentType = a.ContentType;
                dupeA.OwnerId = a.OwnerId;
                dupeA.ParentId = contactReplacement;
                duplicateAttachments.add(dupeA);
            }
        }

        return duplicateAttachments;
    }

    private List<Note> duplicateNotes(Map<Id, List<Note>> notesMap, Id contactToReplace, Id contactReplacement){
        List<Note> contactNotes = notesMap.get(contactToReplace);
        List<Note> duplicateNotes = new List<Note>();

        if(contactNotes != null){
            for(Note a : contactNotes){
                Note dupeN = new Note();
                dupeN.Title = a.Title;
                dupeN.IsPrivate = a.IsPrivate;
                dupeN.Body = a.Body;
                dupeN.ParentId = contactReplacement;
                duplicateNotes.add(dupeN);
            }
        }

        return duplicateNotes;
    }

    private List<FeedItem> duplicateContactFeeds(Map<Id, List<ContactFeed>> feedMap, Id contactToReplace, Id contactReplacement){

         List<ContactFeed> contactFeeds = feedMap.get(contactToReplace);
         List<FeedItem> duplicateFeedItems = new List<FeedItem>();

         if(contactFeeds != null){
            for(ContactFeed cf : contactFeeds){

                // Not supporting chatter posts that don't at least have a body or title, or
                // other accessible data
                if(cf.Type == 'ContentPost' || cf.Type == 'LinkPost' || 
                   !String.isBlank(cf.Body) || !String.isBlank(cf.Title)){

                    FeedItem dupePost = new FeedItem();
                    dupePost.ContentData = cf.ContentData;
                    dupePost.ContentFileName = cf.ContentFileName;
                    dupePost.ContentDescription = cf.ContentDescription;
                    dupePost.RelatedRecordId = cf.RelatedRecordId;
                    dupePost.Type = cf.Type;
                    dupePost.Title = cf.Title;
                    dupePost.Body = cf.Body;
                    dupePost.NetworkScope = cf.NetworkScope;
                    dupePost.Visibility = cf.Visibility;
                    dupePost.CreatedById = cf.CreatedById;
                    dupePost.LinkURL = cf.LinkURL;
                    dupePost.ParentId = contactReplacement;
                    duplicateFeedItems.add(dupePost);
                }
            }
         }

         return duplicateFeedItems;
    }
}