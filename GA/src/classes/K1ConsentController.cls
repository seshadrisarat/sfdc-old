public class K1ConsentController 
{
    public RSVP__c rsvp { public get; public set; }
    public Contact c { public get; public set; }
    public String consent { public get; public set; }
    
    public K1ConsentController() 
    {
        c=findContact(System.currentPageReference().getParameters().get('cID'));
        rsvp=loadRSVP();  
    }

    private Contact findContact(String cID)
    {
        List<Contact> lC=[SELECT Id,Name, title,FirstName,Middle_Name__c,LastName,Account.Name,email,Phone,fax,Electronic_Delivery_Consent__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,AssistantName,AssistantPhone,Assistant_Email__c FROM Contact WHERE Id=:cID];
        
        if(lC.size()>0)
            return lC.get(0);
        
        return null;
    }

    public List<SelectOption> getConsentItems() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','YES, the Investor hereby consents to receive electronic Schedule K-1s.')); 
        options.add(new SelectOption('No','NO, the Investor does not consent to receive electronic Schedule K-1s.')); 
        return options; 
    }
    
    public PageReference save()
    {
        upsert rsvp;
        return Page.K1ConsentThanks;
    }
        
    private RSVP__c loadRSVP()
    {
        List<RSVP__c > lRsvp=[SELECT Contact__c,Company__c,title__c,First_Name__c,Middle_Name__c,Last_Name__c,Assistant_Email__c,Assistant_Phone__c,Assistant_Name__c,email__c,fax__c,phone__c, Interest_1__c, Interest_2__c,Electronic_Delivery_Consent__c,Mailing_Street__c,Mailing_City__c,Mailing_State__c,Mailing_Postal_Code__c,Mailing_Country__c  FROM RSVP__c WHERE Contact__c=:c.Id ];
        
        if(lRsvp.size()>0)
            return lRsvp.get(0);
        
        return new RSVP__c(Contact__c=c.Id,title__c=c.title,First_Name__c=c.FirstName,Middle_Name__c=c.Middle_Name__c,Last_Name__c=c.LastName,Company__c=c.Account.Name,email__c=c.email,fax__c=c.fax,phone__c=c.phone,Assistant_Email__c=c.Assistant_Email__c,Assistant_Phone__c=c.AssistantPhone,Assistant_Name__c=c.AssistantName,
        Electronic_Delivery_Consent__c=c.Electronic_Delivery_Consent__c,Mailing_Street__c=c.MailingStreet,Mailing_City__c=c.MailingCity,Mailing_State__c=c.MailingState,Mailing_Postal_Code__c=c.MailingPostalCode,Mailing_Country__c=c.MailingCountry);
    }    
    
    static testMethod void testController()
    {
        Contact cont=new Contact(firstname='test',lastname='tester');
        insert cont;
        
        ApexPages.currentPage().getParameters().put('cID',cont.Id);
        K1ConsentController con=new K1ConsentController();
        con.getConsentItems();
        con.save();
    }
}