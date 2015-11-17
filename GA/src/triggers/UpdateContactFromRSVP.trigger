trigger UpdateContactFromRSVP on RSVP__c (after insert, after update) 
{
    Contact c;
    List<Contact> lC=new List<Contact>();

    for(RSVP__c rsvp : trigger.new)
    {
        c=new Contact(Id=rsvp.Contact__c,phone=rsvp.phone__c,email=rsvp.email__c,
          FirstName=rsvp.First_Name__c,LastName=rsvp.Last_Name__c,
          Assistant_Email__c=rsvp.Assistant_Email__c,AssistantPhone=rsvp.Assistant_Phone__c,AssistantName=rsvp.Assistant_Name__c,
          MailingCity=rsvp.Mailing_City__c,MailingCountry=rsvp.Mailing_Country__c,MailingPostalCode=rsvp.Mailing_Postal_Code__c,
          MailingState=rsvp.Mailing_State__c,MailingStreet=rsvp.Mailing_Street__c,Middle_Name__c=rsvp.Middle_Name__c,
          Electronic_Delivery_Consent__c=rsvp.Electronic_Delivery_Consent__c,fax=rsvp.fax__c);
        lC.add(c);
    }
    
    if(lC.size()>0)
        update lC;

}