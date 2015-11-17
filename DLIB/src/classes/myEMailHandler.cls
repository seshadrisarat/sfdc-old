global class myEMailHandler  implements Messaging.InboundEmailHandler 
{
 public static testmethod void testhandleInboundEmail1()
    {
        // Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        // Data to test for unknown email address
        email.subject = 'Rohit Marathe';
        email.plainTextBody  = 'Test Description';
        
        email.fromAddress = 'unknown_contact@gmail.com';
        
        // Call the class and test it with the data in the testMethod
        myEMailHandler myEMailHandlerobj = new myEMailHandler();
        myEMailHandlerobj.handleInboundEmail(email, env );
    }
   
global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
                // Create an inboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        // Do not proceed further is subject is null/''/' '
        if(email.subject == null || email.subject == '' || email.subject == ' ')
        {
            return result;
        }
       
                      
        // Split the formatted subject for spaces
        String[] subjectArray = email.subject.split(' ');
        
        
        
               
       // Create a new Lead with the Email data
       Lead ld = new Lead();
       ld.FirstName = subjectArray[0];
       ld.LastName = subjectArray[1];
       ld.Email =  email.fromAddress; 
       ld.Description= email.plainTextBody; 
       ld.Status = 'Open - Not Contacted';
       ld.Company = 'V2 Solutions';
       Database.SaveResult[] lsr = Database.insert(new Lead[]{ld},false);
          
       
       String strErrMsg = '';
       strErrMsg = getDMLSuccess(lsr);
       if(strErrMsg != '')// If lead insertion fails then log error and come out
       {
           System.debug('Lead Insertion Failure in myEmailHandler.handleInboundEmail: ' + strErrMsg);
           return result;
       }
       //  Email Subject
       system.debug('Hi'+ lsr[0].isSuccess());
       String strSub = subjectArray[0] +' '+subjectArray[1]+' has requested to contacted via email at: '+ email.fromAddress; 
       
       // Email body
       String textEmailBody = 'The customer has indicated that he/she is a Residential Customer in Staten Island and use Electricity.\n';
       textEmailBody += 'Contact phone numbers:\n';
       textEmailBody += 'day phone: 718-494-8482\n';
       textEmailBody += 'day phone: 718-494-8482\n';
       // Send Email to owner 
       sendEmail('bes.developer@gmail.com','Salesforce Support', 'bes.developer@gmail.com', 'rich@businessendurance.net', strSub, textEmailBody, textEmailBody);
       return result;

    }
    /*
        // Reusable function to find out the success of DML(Single/Bulk) operations
        // Returns '' in case of success
        // Returns error message string in case of failure   
    */
    private String getDMLSuccess(Database.SaveResult[] lsr)
    {
        String strErrMsg = '';
        for(Database.SaveResult sr:lsr)
        {
            if(!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                strErrMsg += err.getMessage()+'\n';
            }
        }  
        return strErrMsg;
    }
    
    /*
        // This function will be used to send an Email
    */
    private void sendEmail(String fromAddress, String sendersDisplayName, String toAddress, String ccAddress, String Subject , String htmlBody, String textBody)
    {
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {toAddress};
        String[] ccAddresses = new String[] {ccAddress};
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo(fromAddress);
        // Specify the name used as the display name.
        mail.setSenderDisplayName(sendersDisplayName);
        // Specify the subject line for your email address.
        mail.setSubject(Subject);
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        // Allows the email to be saved as an activity.
        mail.setSaveAsActivity(false);
        // Specify the text content of the email.
        mail.setPlainTextBody(textBody);
        // Specify the html version of the content as well.
        mail.setHtmlBody(htmlBody);
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    } 

}