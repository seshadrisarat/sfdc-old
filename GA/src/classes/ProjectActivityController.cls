public with sharing class ProjectActivityController {
    public class Recipient {    
        public User record { get; private set; }
        public Boolean selected { get; set; }
        
        public Recipient(User record) {
            this.record = record;
            selected = true;
        }
    }

    public Project__c project { get; private set; }
    public Project_Activity__c projectActivity { get; private set; }
    public List<Recipient> recipients { get; private set; }
    public Attachment attachment { get; private set; }
    public Boolean submitForApproval { get; set; }

    public ProjectActivityController() {
        try {
            Id projectId = ApexPages.currentPage().getParameters().get('Id');
            project = [SELECT Id, Name, Project_Number__c, Status__c, Owner.Name, Owner.Email, (SELECT Team_Member__r.Name, Team_Member__r.Email FROM Communication_Team_Members__r) FROM Project__c WHERE Id=:projectId LIMIT 1];
            recipients = new List<Recipient>();
            for (Communication_Team_Member__c ctm : project.Communication_Team_Members__r) {
                recipients.add(new Recipient(ctm.Team_Member__r));
            }
            projectActivity = new Project_Activity__c(
                Project__c = project.Id,
                Sender__c = UserInfo.getUserId(),
                Name = 'Project ' + project.Project_Number__c + ' - ' + project.Name
            );
            attachment = new Attachment(
                ParentId = projectId
            );
            submitForApproval = false;
        } catch (Exception e) {
        }
    }
       
    public PageReference cancel() {
        return new PageReference('/' + projectActivity.Project__c);
    }
    
    public PageReference send() {
        Messaging.EmailFileAttachment emailAttachment;
        if (projectActivity.Attachments__c && attachment.Body !=null) {
            emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setBody(attachment.Body);
            emailAttachment.setFileName(attachment.Name);
            emailAttachment.setContentType(attachment.ContentType);
        }
        projectActivity.Attachments__c = (emailAttachment != null);

        if (submitForApproval) {
            projectActivity.Name = projectActivity.Name + ': Approval Request';
        }
        String subject = projectActivity.Name;
        projectActivity.Name = (subject.length() > 80 ? subject.substring(0, 77) + '...' : subject);
        projectActivity.Subject_Full__c = subject;
        insert projectActivity;
        if (emailAttachment != null) {
            insert attachment;
        }
        
        EmailServicesAddress eServiceAddress = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart=:(submitForApproval ? 'project_approval' : 'project_activity') LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        if (submitForApproval) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> { project.Owner.Email });
            email.setReplyTo(eServiceAddress.LocalPart + '@' + eServiceAddress.EmailDomainName);
            email.setReferences('<' + projectActivity.Id + project.Owner.Id + '@' + eServiceAddress.EmailDomainName + '>');
            email.setSubject(subject + ' [' + EncodingUtil.base64Encode(Blob.valueOf('' + projectActivity.Id + project.Owner.Id)) + ']');
            email.setPlainTextBody('To approve or reject this item, reply to this email with APPROVE, APPROVED, YES, REJECT, REJECTED, or NO in the first line of the email message\n\n' + projectActivity.Comments__c);
            if (emailAttachment != null) {
                email.setFileAttachments(new List<Messaging.EmailFileAttachment> { emailAttachment});
            }
            emails.add(email);
            
            update new Project__c(
                Id = project.Id,
                Status__c = 'Completed / Awaiting Approval'
            );
        } else {
            for (Recipient r : recipients) {
                if (!r.selected) {
                    continue;
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String> { r.record.Email });
                email.setReplyTo(eServiceAddress.LocalPart + '@' + eServiceAddress.EmailDomainName);
                email.setReferences('<' + projectActivity.Id + r.record.Id + '@' + eServiceAddress.EmailDomainName + '>');
                email.setSubject(subject + ' [' + EncodingUtil.base64Encode(Blob.valueOf('' + projectActivity.Id + r.record.Id)) + ']');
                email.setPlainTextBody(projectActivity.Comments__c);
                if (emailAttachment != null) {
                    email.setFileAttachments(new List<Messaging.EmailFileAttachment> { emailAttachment });
                }
                emails.add(email);
            }
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        return cancel();
    }
    
    private static testMethod void test() {
        Project__c p = new Project__c(
            Name = 'Project'
        );
        insert p;
        
        ApexPages.currentPage().getParameters().put('Id', p.Id);
        ProjectActivityController controller;
        controller = new ProjectActivityController();
        controller.projectActivity.Comments__c = 'Comments';
        controller.send();
        controller.cancel();
        controller = new ProjectActivityController();
        controller.submitForApproval = true;
        controller.send();
    }
}