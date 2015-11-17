global class ProjectActivityEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult ();

        String references = '';
        for (Messaging.InboundEmail.Header h : email.headers) {
            if (h.name.equalsIgnoreCase('references')) {
                references = h.value;
                break;
            }
        }
        try {
            String ref = email.subject.substring(email.subject.lastIndexOf('[') + 1, email.subject.lastIndexOf(']'));
            email.subject = email.subject.replace('[' + ref + ']', '');
            EmailServicesAddress eServiceAddress = [SELECT EmailDomainName FROM EmailServicesAddress WHERE LocalPart='project_activity' LIMIT 1];
            references += ' <' + EncodingUtil.base64Decode(ref).toString() + '@' + eServiceAddress.EmailDomainName + '>';
        } catch (Exception e) {
        }
        try {
            EmailServicesAddress eServiceAddress = [SELECT EmailDomainName FROM EmailServicesAddress WHERE LocalPart='project_activity' LIMIT 1];
            Integer index = references.indexOf('@' + eServiceAddress.EmailDomainName);
            String reference = references.substring(index - 36, index);
            Project_Activity__c projectActivity = [SELECT Project__c, Sender__c FROM Project_Activity__c WHERE Id=:reference.substring(0, 18) LIMIT 1];
            // Email
            insert new Project_Activity__c(
                Project__c = projectActivity.Project__c,
                Sender__c = reference.substring(18),
                Notify_User__c = projectActivity.Sender__c,
                Name = (email.subject != null ? (email.subject.length() > 80 ? email.subject.substring(0, 77) + '...' : email.subject) : 'No Subject'),
                Subject_Full__c = (email.subject != null ? email.subject : 'No Subject'),
                Comments__c = (email.plainTextBody != null ? (email.plainTextBody.length() > 32000 ? email.plainTextBody.substring(0, 31997) + '...' : email.plainTextBody) : ''),
                Attachments__c = (email.binaryAttachments != null || email.textAttachments != null)
            );
            // Attachments
            List<Attachment> attachments = new List<Attachment>();
            if (email.binaryAttachments != null) {
                for (Messaging.InboundEmail.BinaryAttachment a : email.binaryAttachments) {
                    attachments.add(new Attachment(
                        ParentId = projectActivity.Project__c,
                        Name = (a.fileName != null ? a.fileName : 'No Name'),
                        Body = a.body
                    ));
                }
            }
            if (email.textAttachments != null) {
                for (Messaging.InboundEmail.TextAttachment a : email.textAttachments) {
                    attachments.add(new Attachment(
                        ParentId = projectActivity.Project__c,
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
            result.message = 'Error processing email';
        }

        return result;
    }

    private static testMethod void test() {
        Project__c p = new Project__c(
            Name = 'Project'
        );
        insert p;
        Project_Activity__c pa = new Project_Activity__c(
            Project__c = p.Id,
            Name = 'Project Activity',
            Sender__c = UserInfo.getUserId()
        );
        insert pa;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = [SELECT Email FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Email;
        email.subject = 'subject [' + pa.Id + UserInfo.getUserId() + ']';

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'references';
        header.value = '' + pa.Id + pa.Sender__c + '@' + [SELECT EmailDomainName FROM EmailServicesAddress WHERE LocalPart='project_activity'].EmailDomainName;
        email.headers = new List<Messaging.InboundEmail.Header> { header };

        Messaging.InboundEmail.BinaryAttachment bAttachment = new Messaging.InboundEmail.BinaryAttachment();
        bAttachment.body = Blob.valueOf('binary');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment> { bAttachment };

        Messaging.InboundEmail.TextAttachment tAttachment = new Messaging.InboundEmail.TextAttachment();
        tAttachment.body = 'text';
        email.textAttachments = new List<Messaging.InboundEmail.TextAttachment> { tAttachment };

        ProjectActivityEmailHandler emailHandler = new ProjectActivityEmailHandler();
        emailHandler.handleInboundEmail(email, null);

        email.headers.clear();
        emailHandler.handleInboundEmail(email, null);
    }
}