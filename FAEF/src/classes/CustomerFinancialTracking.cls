global class CustomerFinancialTracking {
    
    WebService static String createFinancialRecord(String taskID, String relatedTo){
         
         if(taskID != null || relatedTo != null){
             
             //Create a new Customer Financial Tracking record.
             Customer_Financial_Tracking__c cft = new Customer_Financial_Tracking__c();
             cft.Account__c = relatedTo;
             insert cft;
             
             //Query the task and change the relatedTo field to the new Financial
             //Tracking record
             Task t = [SELECT id, WhatId FROM Task WHERE id = :taskID LIMIT 1];
             t.WhatId = cft.id;
             update t;
             
             //Reassign Notes
             List<Note> notes = [SELECT Body, OwnerId, Title FROM Note WHERE ParentID = :t.Id];
             List<Note> newNotes = new List<Note>();
             for(Note n : notes){
                 Note newNote = n.clone(false, false, true, false);
                 newNote.ParentID = cft.id;
                 newNotes.add(newNote);
             }
             insert newNotes;
             delete notes;
             
             //Reassign Attachments
             List<Attachment> attachments = [SELECT Body, BodyLength, ContentType, Description, Name, OwnerID, CreatedDate FROM Attachment WHERE ParentID = :t.Id];
             List<Attachment> newAttachments = new List<Attachment>();
             for(Attachment a : attachments){
                 Attachment newAttachment = a.clone(false, false, true, false);
                 newAttachment.ParentID = cft.id;
                 newAttachments.add(newAttachment);
             }
             insert newAttachments;
             delete attachments;
             
             //Navigate to the new CFT record (In edit mode)
             return '/' + cft.id + '/e?retURL=%2F' + cft.id;
             
         }else{
             //If the fields aren't filled out, stay on the current page.
             return '/' + taskID;
         }
            
    }

}