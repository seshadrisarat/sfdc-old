global class ProjectRequestEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            User u = [SELECT Id FROM User WHERE Email=:email.fromAddress LIMIT 1];
            RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Project__c' AND DeveloperName='TBD' AND IsActive=TRUE LIMIT 1];
            Project__c project = new Project__c(
                RecordTypeId = (rt == null ? null : rt.Id),
                OwnerId = u.Id,
                Name = (email.subject != null ? (email.subject.length() > 80 ? email.subject.substring(0, 77) + '...' : email.subject) : 'No Subject')                
            );
            insert project;
            // Email
            insert new Project_Activity__c(
                Project__c = project.Id,
                Sender__c = u.Id,
                Name = project.Name,
                Subject_Full__c = (email.subject != null ? email.subject : 'No Subject'),
                Comments__c = (email.plainTextBody != null ? (email.plainTextBody.length() > 32000 ? email.plainTextBody.substring(0, 31997) + '...' : email.plainTextBody) : ''),
                Attachments__c = (email.binaryAttachments != null || email.textAttachments != null)
            );
            // Attachments
            List<Attachment> attachments = new List<Attachment>();
            if (email.binaryAttachments != null) {
                for (Messaging.InboundEmail.BinaryAttachment a : email.binaryAttachments) {
                    attachments.add(new Attachment(
                        ParentId = project.Id,
                        Name = (a.fileName != null ? a.fileName : 'No Name'),
                        Body = a.body
                    ));
                }
            }
            if (email.textAttachments != null) {
                for (Messaging.InboundEmail.TextAttachment a : email.textAttachments) {
                    attachments.add(new Attachment(
                        ParentId = project.Id,
                        Name = (a.fileName != null ? a.fileName : 'No Name'),
                        Body = Blob.valueOf(a.body)
                    ));
                }
            }
            if (!attachments.isEmpty()) {
                insert attachments;
            }
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing email: The email address of the sender must belong to a valid user in Salesforce';
        }
        return result;
    }

    
    private static testMethod void test() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = [SELECT Email FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Email;
        email.subject = 'subject';
        email.plainTextBody = 'body';

        Messaging.InboundEmail.BinaryAttachment bAttachment = new Messaging.InboundEmail.BinaryAttachment();
        bAttachment.body = Blob.valueOf('binary');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment> { bAttachment };

        Messaging.InboundEmail.TextAttachment tAttachment = new Messaging.InboundEmail.TextAttachment();
        tAttachment.body = 'text';
        email.textAttachments = new List<Messaging.InboundEmail.TextAttachment> { tAttachment };

        ProjectRequestEmailHandler emailHandler = new ProjectRequestEmailHandler();
        emailHandler.handleInboundEmail(email, null);

        email.fromAddress = null;
        emailHandler.handleInboundEmail(email, null);
    }
}