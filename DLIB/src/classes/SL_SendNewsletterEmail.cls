/**
* \arg ClassName  : SL_SendNewsletterEmail
* \arg JIRATicket : SILVERLINE-273
* \arg CreatedOn  : 31-7-2014
* \arg ModifiedBy : Pankaj Ganwani
* \arg Description: This class is used to email the newsletter to all contacts where record type is employee and isresourceactive is true
*/
public with sharing class SL_SendNewsletterEmail 
{
    /* Start - Variables */
    private Newsletter__c objNewsletter;
    private String strType;    
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_SendNewsletterEmail()
    {
        objNewsletter = [SELECT Approved_to_Send__c, Delivery_Updates__c, Developer_Updates__c, Learning_Development__c, Marketing_Updates__c, Operations__c, Product_Sales_Updates__c, Sales_Updates__c, Intro__c
                         FROM Newsletter__c WHERE Id =:Apexpages.currentPage().getParameters().get('Id') LIMIT 1];
        strType = Apexpages.currentPage().getParameters().get('type');
    }
    /* End - Constructor */
    
    /*!
        * MethodName : sendNewsletterEmail
        * param      : -
        * Description: This method is called to send an email to Contacts
    */
    public void sendNewsletterEmail()
    {
        if(objNewsletter!=null)
        {
            String strOrgWideAddressId = '';
            
            //Calling function to get the html content
            String strhtmlcontent = prepareString(objNewsletter);
            List<Messaging.Singleemailmessage> lstEmailMessage = new List<Messaging.Singleemailmessage>();
            //getting value of Default Sender address from custom setting
            SL_DefaultSenderEmail__c objSenderEmailAddress = SL_DefaultSenderEmail__c.getInstance('Default Sender');
            String strSenderEmailAddress = (objSenderEmailAddress!=null && String.isNotEmpty(objSenderEmailAddress.Sender_Email_Address__c))?objSenderEmailAddress.Sender_Email_Address__c:'';
            //Getting the Id of the sender's email address
            List<OrgWideEmailAddress> lstOWemailAddress = String.isNotEmpty(strSenderEmailAddress)?[SELECT Id FROM OrgWideEmailAddress WHERE Address=:strSenderEmailAddress LIMIT 1]:null;
            if(lstOWemailAddress!=null && !lstOWemailAddress.isEmpty())
                strOrgWideAddressId = lstOWemailAddress[0].Id;
            
            if(String.isNotEmpty(strType))
            {
                if(strType == 'Send')
                {
                    //Iterating over contact to send an email where record type is Employee and pse__Is_Resource_Active__c is true
                    for(Contact objContact : [SELECT Id, Email FROM Contact WHERE RecordType.DeveloperName =:'Employee' AND pse__Is_Resource_Active__c = true])
                    {
                        //Checking if contact's email address is not null or blank
                        if(String.isNotEmpty(objContact.Email))
                        {
                            Messaging.Singleemailmessage mailHandler=new Messaging.Singleemailmessage();
                            mailHandler.setTargetObjectId(objContact.Id);
                            mailHandler.setSubject('Newsletter');
                            mailHandler.setHtmlBody(strhtmlcontent);
                            if(String.isNotEmpty(strSenderEmailAddress))
                                mailHandler.setReplyTo(strSenderEmailAddress);
                            if(String.isNotEmpty(strOrgWideAddressId))
                                mailHandler.setOrgWideEmailAddressId(strOrgWideAddressId);
                            lstEmailMessage.add(mailHandler);
                        }
                    }
                }
                else
                {
                    Messaging.Singleemailmessage mailHandler=new Messaging.Singleemailmessage();
                    mailHandler.setToAddresses(new String[]{'pankaj.ganwani@silverlinecrm.com','maggie.rupel@silverlinecrm.com','kathleen.ferrie@silverlinecrm.com'});
                    mailHandler.setSubject('Newsletter');
                    mailHandler.setHtmlBody(strhtmlcontent);
                    if(String.isNotEmpty(strSenderEmailAddress))
                        mailHandler.setReplyTo(strSenderEmailAddress);
                    if(String.isNotEmpty(strOrgWideAddressId))
                        mailHandler.setOrgWideEmailAddressId(strOrgWideAddressId);
                    lstEmailMessage.add(mailHandler);
                }
            }
            try
            {
                if(!lstEmailMessage.isEmpty())
                {
                    //Method to send an email
                    Messaging.sendEmail(lstEmailMessage);
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Email has been successfully sent to all Contacts.'));
                }
                else
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Contacts exist to send an email.'));
            }
            catch(EmailException ex)
            {
                System.debug('=========Exception============'+ex.getMessage());
                if(ex.getMessage().contains('UNVERIFIED_SENDER_ADDRESS'))
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please verify Sender email from Org wide Email Address'));
                else if(ex.getMessage().contains('INVALID_EMAIL_ADDRESS'))
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Email Id is not valid'));
            }
        }
    }
    
    /*!
        * MethodName : prepareString
        * param      : Newsletter object
        * Description: This method is used to form a html string that will be used to show the content in email body
    */
    private String prepareString(Newsletter__c objNewsletter)
    {       
        //Framing html string for intro section of email
        String strIntro = String.isNotEmpty(objNewsletter.Intro__c) ?'<br/><br/><center><div style="text-align:justify;width:900px;">'+replacecontent(objNewsletter.Intro__c)+'</div></center>':'';
        //Framing html string for sales update section of email
        String strSalesUpdates = String.isNotEmpty(objNewsletter.Sales_Updates__c) ? '<center><div style="text-align:justify;width:900px;"><h2 align="center">Service Sales Update</h2><br/>'+replacecontent(objNewsletter.Sales_Updates__c)+'</div></center>':'';
        //Framing html string for product sales update section of email
        String strProductSalesUpdates = String.isNotEmpty(objNewsletter.Product_Sales_Updates__c) ?'<center><div style="text-align:justify;width:900px;"><h2 align="center">Product Sales Update</h2><br/>'+replacecontent(objNewsletter.Product_Sales_Updates__c)+'</div></center>':'';
        //Framing html string for marketing updates section of email
        String strMarketingUpdates = String.isNotEmpty(objNewsletter.Marketing_Updates__c) ?'<center><div style="text-align:justify;width:900px;"><h2 align="center">Marketing Update</h2><br/>'+replacecontent(objNewsletter.Marketing_Updates__c)+'</div></center>':'';
        //Framing html string for delivery updates section of email
        String strDeliveryUpdates = String.isNotEmpty(objNewsletter.Delivery_Updates__c)?'<center><div style="text-align:justify;width:900px;"><h2 align="center">Delivery Update</h2><br/>'+replacecontent(objNewsletter.Delivery_Updates__c)+'</div></center>':'';        
        //Framing html string for developer updates section of email
        String strDeveloperUpdates = String.isNotEmpty(objNewsletter.Developer_Updates__c)?'<center><div style="text-align:justify;width:900px;"><h2 align="center">Developer Update</h2><br/>'+replacecontent(objNewsletter.Developer_Updates__c)+'</div></center>':'';
        //Framing html string for operation updates section of email
        String strOperationsUpdates = String.isNotEmpty(objNewsletter.Operations__c)?'<center><div style="text-align:justify;width:900px;"><h2 align="center">Operations Update</h2><br/>'+replacecontent(objNewsletter.Operations__c)+'</div></center>':'';
        //Framing html string for learning & development updates section of email
        String strLearningUpdates = String.isNotEmpty(objNewsletter.Learning_Development__c)?'<center><div style="text-align:justify;width:900px;"><h2 align="center">Learning and Development Update</h2><br/>'+replacecontent(objNewsletter.Learning_Development__c)+'</div></center>':'';
        String strHeaderHTML = '';
        String strFooterHTML = '';
        Map <String,Id> mapIdToDocument = new Map<String,Id>();
        //Iterating over Document object to get the Ids of Header and Footer image documents
        for(Document objDocument :[SELECT Id, DeveloperName FROM Document WHERE DeveloperName IN ('News_Letter_Header', 'News_Letter_Footer')])
        {
            mapIdToDocument.put(objDocument.DeveloperName, objDocument.Id);
        }   
        //Checking if map is not null   
        if(mapIdToDocument!=null)
        {
            if(mapIdToDocument.containskey('News_Letter_Header'))
            {
                String HeaderId = String.valueOf(mapIdToDocument.get('News_Letter_Header')).substring(0, 15);
                strHeaderHTML='<center><img src="'+Url.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+HeaderId+'&oid='+Userinfo.getOrganizationId()+'" alt="Image not found"/></center>';
            }
            
            if(mapIdToDocument.containskey('News_Letter_Footer'))
            {
                String FooterId = String.valueOf(mapIdToDocument.get('News_Letter_Footer')).substring(0, 15);
                strFooterHTML = '<center><img src="'+Url.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+FooterId+'&oid='+Userinfo.getOrganizationId()+'" alt="Image not found"/></center>';
            }
        }
        return strHeaderHTML+strIntro+strSalesUpdates+strProductSalesUpdates+strDeliveryUpdates+strDeveloperUpdates+strLearningUpdates+strMarketingUpdates+strOperationsUpdates+'<br/><br/>'+strFooterHTML;
    }
    
    /*!
        * MethodName : replacecontent
        * param      : value of rich text area field
        * Description: This method is used to replace the place holder(DOCUMENT_IMAGE_ID=) with img tag in passed string
    */
    private String replacecontent(String strhtml)
    {
        String strDocumentId = 'DOCUMENT_IMAGE_ID=';
        //Checking if string is not empty or null
        if(String.isNotEmpty(strhtml))
        {
            if(strhtml.contains('DOCUMENT_IMAGE_ID='))
            {
                //while loop to check until index of placeholder is not equal to -1 
                while(strhtml.indexOf('DOCUMENT_IMAGE_ID=')!=-1)
                {
                    //Checking if string contains placeholder
                    if(strhtml.contains('DOCUMENT_IMAGE_ID='))
                    {
                        String strTemp = strhtml.substring(strhtml.indexOf('DOCUMENT_IMAGE_ID='),strhtml.indexOf('DOCUMENT_IMAGE_ID=') + strDocumentId.length()+15);
                        String strId = strTemp.split('=')[1];
                        strhtml = strhtml.replace(strTemp, '<center><img src="'+Url.getSalesforceBaseUrl().toExternalForm().replace('my.salesforce.','content.force.')+'/servlet/servlet.ImageServer?id='+strId+'&oid='+Userinfo.getOrganizationId()+'" alt="Image not found" /><center>');
                    }               
                }
            }
            else if(strhtml.contains('<img'))
            {
                strhtml = strhtml.replaceAll('<img', '<img style="max-width:900px;"');
            }
        }
        return strhtml;
    }   
}