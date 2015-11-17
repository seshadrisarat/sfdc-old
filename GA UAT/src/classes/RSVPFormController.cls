public without sharing class RSVPFormController 
{
    public RSVP__c rsvp { public get; public set; }
    public Contact c { public get; public set; }
    public Campaign cp { public get; private set; }
    public String status { public get; public set; }
    public boolean isRSVP { public get; public set; }
    
    public RSVPFormController()
    {
        String str=System.currentPageReference().getParameters().get('isrsvp');
        str=(str==null?'0':str);
        isRSVP=(str.equals('1')?true:false);
        c=findContact(System.currentPageReference().getParameters().get('cID'));
        cp=findCampaign(System.currentPageReference().getParameters().get('cpID'));
        status=System.currentPageReference().getParameters().get('status'); 
        rsvp=loadRSVP();   
        //updateCampaign(cp.Id,c.Id, getStatusName());
    }
    
    public String getStatusName()
    {
        if(status.equalsIgnoreCase('yes'))
            return 'Responded Yes';
    
        return 'Responded No';
    }
    
    public PageReference save()
    {
        updateCampaign(cp.Id,c.Id, getStatusName());
        upsert rsvp;
        
        return Page.RSVPFormThanks;
    }
    
    private RSVP__c loadRSVP()
    {
        List<RSVP__c > lRsvp=[SELECT Contact__c,Last_Name__c,Company__c,title__c,Assistant_Email__c,Assistant_Phone__c,Assistant_Name__c,email__c,phone__c, Interest_1__c, Interest_2__c  FROM RSVP__c WHERE Contact__c=:c.Id ];
        
        if(lRsvp.size()>0)
            return lRsvp.get(0);
        
        return new RSVP__c(Contact__c=c.Id,title__c=c.title,Last_Name__c=c.LastName,Company__c=c.Account.Name,email__c=c.email,phone__c=c.phone,Assistant_Email__c=c.Assistant_Email__c,Assistant_Phone__c=c.AssistantPhone,Assistant_Name__c=c.AssistantName);
    }
    
    private void updateCampaign(Id idCp, Id idC, String strStatus)
    {
        CampaignMember cm=null;
        List<CampaignMember> lCM=[SELECT Id,CampaignID,ContactId FROM CampaignMember WHERE CampaignID=:idCp AND ContactId=:idC];
        
        if(lCM.size()>0)
        {
            cm=lCM.get(0);
            cm.Status=strStatus;
            update cm;
        }
        else
        {
            cm=new CampaignMember(CampaignID=idCp,ContactId=idC,Status=strStatus);
            insert cm;
        }
    }
    
    private Contact findContact(String cID)
    {
        List<Contact> lC=[SELECT Id,Name,FirstName,LastName,Account.Name,title,email,Phone,AssistantName,AssistantPhone,Assistant_Email__c FROM Contact WHERE Id=:cID];
        
        if(lC.size()>0)
            return lC.get(0);
        
        return null;
    }
    
    private Campaign findCampaign(String cpID)
    {
        List<Campaign> lCp=[SELECT Id,Name,Description FROM Campaign WHERE Id=:cpID];
        
        if(lCp.size()>0)
            return lCp.get(0);
        
        return null;
    }
    
    static testMethod void testRSVP()
    {
        Campaign camp=new Campaign(name='test');
        insert camp;
        Contact cont=new Contact(firstname='test',lastname='tester');
        insert cont;
        
        ApexPages.currentPage().getParameters().put('cpID',camp.Id);
        ApexPages.currentPage().getParameters().put('cID',cont.Id);
        ApexPages.currentPage().getParameters().put('status','yes');
        RSVPFormController con=new RSVPFormController();
        con.save();
        con.status='no';
        con.save();
    }

}