public class BES_showContacts 
{
  public static testMethod void myUnitTest() 
    {
       Account objAcc = new Account();
      objAcc.Name = 'Test';
      insert objAcc;
      
      Opportunity objOpp = new Opportunity();
      objOpp.Name = 'Test';
      objOpp.StageName = 'Prospecting';
      Date dtCurr = Date.newInstance(2009, 1, 1);
      objOpp.CloseDate = dtCurr;
      objOpp.AccountId = objAcc.Id;
      insert objOpp;
      
       Contact con = new Contact();
      con.LastName = 'test';
      con.AccountId = objAcc.Id;
      con.Email = 'test@test.com'; 
      insert con;
      
      OpportunityContactRole objOCR = new OpportunityContactRole();
      objOCR.Role = 'Tenant';
      objOCR.OpportunityId = objOpp.Id;
      objOCR.ContactId = con.Id;
      insert objOCR;
      
      //string OpprId = [select Id from Opportunity Limit 1].Id;
      
      system.currentPageReference().getParameters().put('Id',objOpp.Id);
      system.currentPageReference().getParameters().put('ContactId','');
      BES_showContacts ShowContacts = new BES_showContacts();
      ShowContacts.RedirectToRole();
      ShowContacts.getNullEmailContacts();
      ShowContacts.getNullEmailContact();
      ShowContacts.RedirectToEmail();
      ShowContacts.CancelContacts();
    }
  public String OpprId{get;set;}
  public String ContactId{get;set;}
  public Boolean renderMessage{get;set;}
  public String Message{get;set;}
  List<OpportunityContactRole> lstOCRole;
  List<OpportunityContactRole> lstContactRole = new List<OpportunityContactRole>();
  public BES_showContacts()
  {
    OpprId = system.currentPageReference().getParameters().get('Id');
    //lstOCRole = [select ContactId from OpportunityContactRole where OpportunityId =:OpprId and ]
    lstContactRole = [select ContactId, Contact.Email from OpportunityContactRole where OpportunityId =:OpprId and (Contact.Email = null or Role != 'Tenant' or Role != 'Guarantor')];
    getNullEmailContacts();
    
  }
  public List<ContactObject> getNullEmailContact()
    {
      return lstconObj;
    }
  List<ContactObject> lstconObj;
  public PageReference RedirectToRole()
  {
    
      PageReference pr = new PageReference('/p/opp/ContactRoleEditUi/e?oppid=' + OpprId + '&retURL=' + OpprId);
      pr.setRedirect(true);
      return pr;
    
  }
  public PageReference RedirectToEmail()
  {
    ContactId = system.currentPageReference().getParameters().get('ContactId');
    if(ContactId != null)
    {
      PageReference pr = new PageReference('/' + ContactId);
      pr.setRedirect(true);
      return pr;
    }
    else
    {
      return null;
    }
  }
    /*public class ContactObject
    {
      public string  ContactName{get;set;}
      public string ContactId{get;set;}
      public Boolean isRole{get;set;}
      public Boolean isEmail{get;set;}
      public ContactObject(OpportunityContactRole con)
      {
        ContactId = con.ContactId;
        if(con.Contact.Email == null)
        {
          isRole = false;
          isEmail = true;
        }
        else
        {
          isRole = true;
          isEmail = false;
        }  
        system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Contact Id &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&' +  con.ContactId);
        String  FirstName = [select LastName  from Contact where Id = : con.ContactId Limit 1].LastName;
      ContactName = FirstName;
      system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&& Contact Name &&&&&&&&&&&&&&&&&&&&&&&&&&&' + FirstName); 
      }
    }*/
    public PageReference getNullEmailContacts()
  {
    lstconObj = new List<ContactObject>();
    for(Integer k=0;k<lstContactRole.size();k++)
    {
      ContactObject conObj = new ContactObject(lstContactRole[k]);
      lstconObj.add(conObj);
    }
    if(lstconObj.size() <= 0) 
    {
      renderMessage = true;
    }
    else
    {
      renderMessage = false;
    }
    return null;  
  }
  public PageReference CancelContacts()
  {
    PageReference pr = new PageReference('/'+OpprId);
    pr.setRedirect(true);
    return pr;
  } 
}