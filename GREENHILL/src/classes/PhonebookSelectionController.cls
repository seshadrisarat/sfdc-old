public class PhonebookSelectionController {

  public String curFundID       {get;set;}
  public Opportunity minDateOpp {get;set;}
  public Opportunity maxDateOpp {get;set;}
  public String FormatStr       {get;set;}
  
  public PhonebookSelectionController() {
    this.curFundID  = System.currentPageReference().getParameters().get('fund');
    
    minDateOpp = new Opportunity(CloseDate=date.today().addDays(-365));
    maxDateOpp = new Opportunity(CloseDate=date.today());
  }


  public Pagereference save() {
    Pagereference result = null;
    if(FormatStr == 'Pdf')
    	result = Page.Phonebookreport2;
    if(FormatStr == 'Excel')
    	result = Page.ExcelPhonebookReport;
    
    result.getParameters().put('fund',curfundID);
    result.getParameters().put('mint',string.valueof(MinDateOpp.CloseDate));
    result.getParameters().put('maxt',string.valueof(maxDateOpp.CloseDate));
    result.setRedirect(true);
   
    
    return result;
  }
  
  public static testMethod void testThis() {
    
    RecordType RecordType_Contact;
    RecordType RecordType_Account;
    
    ID curUserID = UserInfo.getUserId();
    
    for( RecordType rtItem: [Select id,Name,SobjectType from RecordType where SobjectType='Contact' or SobjectType='Account'])
    {
      if(rtItem.SobjectType == 'Contact') RecordType_Contact = rtItem;
      else if(rtItem.SobjectType == 'Account') RecordType_Account = rtItem;
    }
    
    Account company = new Account(Name='Test Account Object',RecordTypeId=RecordType_Account.ID);
      insert company;
    
    Contact contact = new Contact(RecordTypeId=RecordType_Contact.ID);
    contact.LastName = 'Test Last Name';
    contact.FirstName = 'Test First Name';
    contact.AccountId = company.id; 
    insert contact;
    
    vced2__Fund__c fundObj = new vced2__Fund__c(Name = 'test Fund!');
    insert fundObj;
    
    System.currentPageReference().getParameters().put('fund', ''+fundObj.ID);
    PhonebookSelectionController con = new PhonebookSelectionController();
    
    con.curFundID = con.curFundID;

    Pagereference ref = null;

    con.FormatStr = 'Pdf';
    ref = con.save();

    con.FormatStr = 'Excel';
    ref = con.save();
  }
  
}