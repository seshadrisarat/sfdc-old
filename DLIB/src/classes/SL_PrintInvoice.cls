global with sharing class SL_PrintInvoice {

    public Invoice__c inv {get;set;}
    public Id objId {get;set;}
    public Id oppId {get;set;}
    public String objClass {get;set;}
    public String objRole {get;set;}  

    public String emailTo {get;set;}
    public String emailCC {get;set;}
    public String emailBCC {get;set;}
    public String replyTo {get;set;}
    public String senderDisplayName {get;set;}
    public String template {get;set;}
    public List<SelectOption> templates {get;set;}
    public String subject {get;set;}
    public String body {get;set;}
    public String fileName {get;set;}
    public SendResult sendResult {get;set;}
    public ob1__output_history__c outputHistory {get;set;}
    public PageReference stupidPage {get;set;}
    public String htmlIn {get;set;}
    public ob1__output_template__c outputTemplate {get;set;}

    public SL_PrintInvoice() {  
        this.objId = ApexPages.currentPage().getParameters().get('id');
        this.oppId = ApexPages.currentPage().getParameters().get('oppId');
        this.objClass = ApexPages.currentPage().getParameters().get('class');
        this.objRole = ApexPages.currentPage().getParameters().get('role');
        this.stupidPage = new PageReference('/apex/ob1__OutputManager?id=' + objId + '&class=' + objClass);
        this.outputHistory = new ob1__output_history__c();

        getTemplate();
        getEmailFields();
    }

    public PageReference changeTemplate() {
        this.stupidPage = new PageReference('/apex/ob1__OutputManager?id=' + objId + '&class=' + template);
        getEmailFields();
        return null;
    }

    public void getEmailFields() {
        for(ob1__output_template__c o : [select Id, Name, ob1__BCC__c, ob1__BCC_Sender__c, ob1__CC__c, ob1__Content_Type__c, ob1__Content_Type_Extension__c, 
                                                                ob1__Is_Default_for_Class__c, ob1__Keep_History__c, ob1__Object_Name__c, ob1__Subject__c,
                                                                ob1__Related_List_Field__c, ob1__Reply_To__c, ob1__Require_Approval_To_Send__c, ob1__Save_Only__c, ob1__Sender_Display_Name__c,  
                                                                ob1__Template_Class__c, ob1__To__c, TextBody__c 
                                                                // ,(select ob1__Body__c, ob1__Sequence__c from ob1__output_template_bodies__r order by ob1__sequence__c) 
                                                                from ob1__Output_Template__c where ob1__Template_Class__c = :template])
                    {
                        outputTemplate = o;

                    if(emailTo.length() > 1) emailTo = emailTo.left(emailTo.length() - 1);
                    
                    if(o.TextBody__c == null) o.TextBody__c = '';
                    senderDisplayName = o.ob1__Sender_Display_Name__c;
                    
                    replyTo = o.ob1__Reply_To__c;
                    emailBcc = o.ob1__BCC__c;
                    emailCc = o.ob1__CC__c;
                    body = o.TextBody__c;
                    if (inv.PSA_Project__r != null)
                        body = body.replace('{{projectName}}', inv.PSA_Project__r.Name);
                    if (inv.opportunity__r != null)
                        body = body.replace('{{opportunityName}}', inv.opportunity__r.Name);
                    subject = o.ob1__Subject__c == null ? '' : o.ob1__Subject__c;
                    subject = subject.replace('{{invoiceName}}', inv.Name);
                    //update new Invoice__c(Id = objId, EmailTo__c = emailTo);
                    
                }        
    }

    public void getTemplate() {
        inv = [select Access_Log__c, Acct_Date__c, Approval_Status__c, Balance__c, Billing_Contact__c, Billing_Contract__c, 
                            Billing_Event__c, Client__c, Client_Name__c, Client_QuickBooks_External_ID__c, CreatedById, CreatedDate, 
                            Credit__c, Credit_Reason__c, CurrencyIsoCode, Customer_OA_Id__c, Date__c, Due_Date__c, Emailed__c, 
                            EmailTo__c, Filter_date__c, Id, IsDeleted, Last_Payment_Date__c, LastModifiedById, LastModifiedDate, 
                            LastReferencedDate, LastViewedDate, Month__c, Name, Notes__c, OA_Invoice_Id__c, Opportunity__c, 
                            Opportunity_Name__c, Original_Invoice_OA_Id__c, OwnerId, Payment_Status__c, Project__c, Project_OA_Id__c, 
                            PSA_Project__c, Status__c, SystemModstamp, Tax__c, Tax_Federal__c, Tax_State__c, Terms__c, Third_Party_Resells__c, 
                            Total__c, Total_Invoice_Amount__c, PSA_Project__r.Name, Opportunity__r.Name, (select Accounting_Period__c, Amount__c, Billing_Contract_Line_Item__c, 
                                                                        Billing_Description__c, Billing_Event_Item__c, Billing_Rule_Id__c, Category__c, Client_id__c, 
                                                                        Cost_Per_Unit_of_Measure__c, CreatedById, CreatedDate, CurrencyIsoCode, Date__c, Expense_Item_Type__c, 
                                                                        Id, Invoice__c, IsDeleted, LastModifiedById, LastModifiedDate, Milestone__c, Name, Notes__c, 
                                                                        Number_of_Hours__c, OA_job_code__c, OA_Slip_Id__c, OA_timetype__c, Product__c, Project__c, 
                                                                        Project_Task__c, Project_Task_Type__c, Quantity__c, Quantity_for_expenses__c, Rate__c, Service__c, 
                                                                        Slip_Type__c, SystemModstamp, Third_Party_Reseller__c, Timebill_Stage__c, Total__c, 
                                                                        Unit_of_Measure__c from slips__r) from Invoice__c where Id = :objId][0];

        list<AccountContactRole> roles = [select Contact.Email, Id, AccountId, Role from AccountContactRole where Role = :objRole and AccountId = :inv.Client__c and Contact.Email != null];
        emailTo = '';
        
        this.fileName = inv.Name + '.pdf';

        templates = new List<SelectOption>();

        for(ob1__output_template__c o : [select Id, ob1__template_Class__c from ob1__output_template__c])
            templates.add(new SelectOption(o.ob1__template_Class__c,o.ob1__template_Class__c));
  
        for(AccountContactRole o : roles)
        {
            if (o.Contact.Email != null) emailTo += o.Contact.Email + ';';
        }

        Boolean isExpense = false;

        for(Slip__c s : inv.slips__r) {
            if(s.Category__c == 'Expense') {
                isExpense = true;
                break;
            }
        }

        if(inv.PSA_Project__c != null && isExpense) template = 'Expense';
        if(inv.PSA_Project__c == null) template = 'Product';
        if(inv.PSA_Project__c != null && !isExpense) template = 'Service'; 

    }

    public void create() {

    }

    public void send() {

        SendResult result = new SendResult();

 
        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        try {
            Messaging.reserveSingleEmailCapacity(2);
        } catch(Exception e) {
            result.type = 'danger';
            result.message = e.getMessage();
        }

        if(emailTo == null) {
            result.type = 'danger';
            result.message = 'Email To is required';
        } else {
            if(String.isBlank(result.type)) this.sendResult = this.sendEmail();
        }
    }

    public SendResult sendEmail() {

        SendResult result = new SendResult();
       // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.

        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Assign the addresses for the To and CC lists to the mail object.
        if(emailTo != null) mail.setToAddresses(emailTo.split(';'));
        if(!String.isBlank(emailCc)) mail.setCcAddresses(emailCc.split(';'));
        if(!String.isBlank(emailBcc)) mail.setBccAddresses(emailBcc.split(';'));
        // Specify the address used when the recipients reply to the email. 
        if(!String.isBlank(replyTo)) mail.setReplyTo(replyTo);

        if(senderDisplayName == null) senderDisplayName = UserInfo.getName();

        // Specify the name used as the display name.
        mail.setSenderDisplayName(senderDisplayName);

        // Specify the subject line for your email address.
        mail.setSubject(subject);

        // Set to True if you want to BCC yourself on the email.
        //mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        //mail.setUseSignature(false);

        // Specify the text content of the email.
        mail.setPlainTextBody(body == null ? '' : body);

        //mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created.<p>'+
             //'To view your case <a href=https://na1.salesforce.com/'+case.Id+'>click here.</a>');
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {  getPDF()  });

        // Send the email you have created.
        Messaging.SendEmailResult[] emailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     
        
        for(Messaging.SendEmailResult emailResult : emailResultList) {
            if(emailResult.isSuccess()) {
                result.message = 'e-mail sent successfully!';
                if(result.type != 'danger') result.type = 'success';
            } else {
                for(Messaging.SendEmailError e : emailResult.getErrors()) {
                    result.message += e.getMessage() + '\n';
                }
                result.type = 'danger';
            }
        }
      return result;
    }

 
    global PageReference createOutputHistory() {
        getTemplate();


        //list<ob1__output_history__c> ohList = [select Id, Invoice__c, Name, ob1__Approved__c, ob1__BCC__c, ob1__CC__c, ob1__Content_Type__c, ob1__Object_ID__c, ob1__Object_Name__c, 
        //                                        ob1__Reply_To__c, ob1__Resend__c, ob1__Resend_To__c, ob1__Sender_Display_Name__c, ob1__Status__c, ob1__Subject__c, ob1__Template_Class__c,
        //                                         ob1__Template_Name__c, ob1__To__c, ob1__View__c from ob1__Output_History__c];
        ob1__output_history__c oh;                                                   

        for(ob1__output_template__c o : [select Id, Name, ob1__BCC__c, ob1__BCC_Sender__c, ob1__CC__c, ob1__Content_Type__c, ob1__Content_Type_Extension__c, 
                                                ob1__Is_Default_for_Class__c, ob1__Keep_History__c, ob1__Object_Name__c, ob1__Subject__c,
                                                ob1__Related_List_Field__c, ob1__Reply_To__c, ob1__Require_Approval_To_Send__c, ob1__Save_Only__c, ob1__Sender_Display_Name__c,  
                                                ob1__Template_Class__c, ob1__To__c 
                                                // ,(select ob1__Body__c, ob1__Sequence__c from ob1__output_template_bodies__r order by ob1__sequence__c) 
                                                from ob1__Output_Template__c where ob1__Template_Class__c = :template]) {

            oh = new ob1__output_history__c(
                    ob1__Subject__c = o.ob1__Subject__c,
                    ob1__Object_ID__c = objId,
                    ob1__Template_Class__c = template,
                    ob1__Template_Name__c = template,
                    ob1__Status__c = 'saved',
                    ob1__Content_Type__c = o.ob1__Content_Type__c + '#' + fileName,
                    ob1__Object_Name__c = o.ob1__Object_Name__c,
                    Invoice__c = objId
                );
            ob1__output_history_body__c ohb = new ob1__Output_History_Body__c();
            ohb.ob1__Body__c = '';
            insert oh;

            //for(ob1__output_template_body__c ob : o.ob1__output_template_bodies__r) {
            ohb.ob1__output_history__c = oh.Id;
            ohb.ob1__Body__c += htmlIn;
            ohb.ob1__sequence__c = 1;

                // don't judge, it's just a couple of records ;)
            insert ohb;

        }

        this.outputHistory = oh;
        return null;
    }



    public Messaging.EmailFileAttachment getPDF() {
        // Reference the attachment page and pass in the account ID
        PageReference pdf =  Page.ob1__output;
        pdf.getParameters().put('output_id',outputHistory.id);
        pdf.setRedirect(true);

        // Take the PDF content
        Blob b;
        if (!Test.IsRunningTest()) b = pdf.getContent();
        else b = Blob.valueof('Test');

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(b);        

        return efa;
    }


    public class SendResult {
        public String type {get;set;}
        public String message {get;set;}
    }


}