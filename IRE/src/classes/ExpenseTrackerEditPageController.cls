public class ExpenseTrackerEditPageController {

    public ExpenseTrackerEditPageController (){ }


    //Public Member varibales Used 
    public final Expense_Tracker__c cont;
    @TestVisible private list<ContactSubClass> ContactList {get; set;}
    @TestVisible private set<Id> ContactSelectedSet;
    public Integer ContactSelectedCount {get; set;}
    public boolean EducationalRecType{get;set;}
    public final id userid;
    
    /*Document upload */
     public document document {
    get {
      if (document == null)
        document = new document ();
      return document;
    }
    set;
   } 
       
   list<attachment> documentlist = new list<attachment>();
   
    /***********/
    /****pagination**********/
    public Integer first;
    public Integer last;
    public Integer total;
    public boolean isnext {get;set;}
    public boolean isprevious{get;set;}
    public boolean ischanged{get;set;}
    /****/
    // selection and filter 
    public String SearchName {get; set;}
    @TestVisible private String SaveSearchName;
    @TestVisible private String QueryContact;
    
    // display sort and number
    public String RecPerPage {get; set;}
    public list<SelectOption> RecPerPageOption {get; set;}  
    public String SortFieldSave;
    
       
    //controller 
    public ExpenseTrackerEditPageController (ApexPages.StandardController stdController) {
        this.cont = (Expense_Tracker__c)stdController.getRecord();
        first=0;
        
        //Managing fields based on Record Type
        if(apexpages.currentpage().getparameters().get('RecordType')!=null && string.valueof(Schema.SObjectType.Expense_Tracker__c.getRecordTypeInfosByName().get('Educational Meeting').getRecordTypeId()).contains(string.valueof(apexpages.currentpage().getparameters().get('RecordType'))))
        {
           EducationalRecType=true;
        }
        else
        {
            EducationalRecType=false;
        }
        
        //Intialising the wrapper class & contact list id
        ContactList = new list<ContactSubClass>();
        ContactSelectedSet = new set<Id>();
        
        //records for page initialization
        RecPerPageOption = new list<SelectOption>();
        RecPerPageOption.add(new SelectOption('10','10'));
        RecPerPageOption.add(new SelectOption('25','25'));
        RecPerPageOption.add(new SelectOption('50','50'));
        RecPerPageOption.add(new SelectOption('100','100'));
        RecPerPageOption.add(new SelectOption('200','200'));
        RecPerPage = '10'; //default records per page
        
        first=1;
        last=Integer.valueof(RecPerPage);  
        isnext=false;
        isprevious=false; 
        total=0;  
        ischanged=false;
        userid=UserInfo.getuserid();
        
        //Auto Prepopulate Section
        if(ApexPages.currentPage().getParameters().get('accid')!=null && ApexPages.currentPage().getParameters().get('conid')!=null)
        {
            cont.Account__c=string.valueof(ApexPages.currentPage().getParameters().get('accid'));
            ContactSelectedSet.add(ApexPages.currentPage().getParameters().get('conid'));
            contact rec =[select name from contact where id=:ApexPages.currentPage().getParameters().get('conid')];
            SaveSearchName=rec.name;
            BuildQuery();
        }
    }
    
    //list controllers 
    Transient public list<contact> StdSetControllerContact {get;set;}
        
        
    //method returns the contact records with the checkbox values
    public list<ContactSubClass> getCurrentContactList() {
        
        UpdateContactSelectedSet();
       list<ContactSubClass> pagelist=new list<ContactSubClass>();
       
       //Adding the list as per the pagination.
            for(integer i=first;i<=last && i<=total;i++)
            {
             
              pagelist.add(ContactList[i-1]);
            }
            
            //checking the boolean values.
            if(total-last<0)
            {
               isnext=false;
            }
            else
            {
               isnext=true;
            }
            if(first>1)
            {
               isprevious=true;
            }
            else
            {
               isprevious=false;
            }
            system.debug('first:'+first+'last:'+last); 
            system.debug('pagelist:'+pagelist);
            
            return pagelist;
            
        }
       
    public void UpdateContactSelectedSet(){
   
        for(ContactSubClass a : ContactList ){
            if(a.aCheckBox == true) {
                ContactSelectedSet.add(a.aContact.Id);
            } else {
                if(ContactSelectedSet.contains(a.aContact.Id)) {
                    ContactSelectedSet.remove(a.aContact.Id);
                }
            }
        }  
        ContactSelectedCount = ContactSelectedSet.size();
    }
    
    public void BuildQuery() {
        StdSetControllerContact = null;
        
        String QueryWhere = '';
        system.debug('EnteredBuildQuery');
        //Clear All values if accountID changes
        if(ischanged)
        {
           ClearAll();
        }
        //search button
        if(SaveSearchName != null)
        {  
           ContactList = new list<ContactSubClass>();
           QueryContact = 'SELECT Id, Name, Email, Phone FROM Contact'; 
           QueryWhere= ' where AccountID =\''+ cont.Account__c+'\'';
        }
        else
        {
           QueryContact = 'SELECT Id, Name, Email, Phone FROM Contact where AccountID =\''+ cont.Account__c+'\''; 
        }
        
        
        if (SaveSearchName != null) {
            QueryWhere = BuildWhere(QueryWhere, ' (Name LIKE \'%' + String.escapeSingleQuotes(SaveSearchName) + '%\')');
        }
        
        QueryContact += QueryWhere;
      QueryContact += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 2500';
        
        system.debug('QueryContact:' + QueryContact);
        
        //execute soql query if the lookup field is not null.
        if(cont.Account__c != null)
        {
         StdSetControllerContact=(list<contact>)Database.Query(QueryContact); 
         system.debug('executedresult:'+StdSetControllerContact);
         //adding the wrapper class
           for (Contact a : StdSetControllerContact) {
               
               ContactList.add(new ContactSubClass(a, ContactSelectedSet.contains(a.Id)));
           }total=StdSetControllerContact.size();}
           
        system.debug('OriginalList:'+ContactList);
        system.debug('OriginalListSize():'+ContactList.size());
        //reset the pagination values 
        first=1;
        last=Integer.valueof(RecPerPage);
        if(total-last<0)
        {
           isnext=false;
        }
        else
        {
           isnext=true;
        }
        
    }
    //Pagination section for dropdown
    public void Pagination()
    {
        first=1;
        last=Integer.valueof(RecPerPage);
    }
    
    //BuildWhere Section
    public String BuildWhere(String QW, String Cond) {
        if (QW == '') {
            return ' WHERE ' + Cond;
        } else {
            return QW + ' AND ' + Cond;
        }
    }
    // Clears all the varibles & returns to the list view page
    public PageReference ClearAll(){
        ContactList.clear();
        ContactSelectedSet.clear();
        ContactSelectedCount = 0;
        SearchName = '';
        SaveSearchName = '';
        
        if(ischanged)
        {
           ischanged=false;
           return null;
        }
        else
        {
          list<document> documents=[select body, id , name,createddate from document where folderid=:userid AND keywords='Expense_Tracker' ORDER BY createddate DESC   limit 1]; 
          if(documents.size()>0)
          documentdelete(documents[0]);
          pageReference PgRef= new PageReference('/a0Q/o');
          PgRef.setRedirect(true);
          return PgRef;
        }  
    }
    
    // search method
    public PageReference SearchContact() {
        SaveSearchName = SearchName;
        
        
        BuildQuery();
        
        return null;
    }
    
    //sort Direction Default is 'asc'
    public String SortDirection {
        get { if (SortDirection == null) {  SortDirection = 'asc'; } return SortDirection;  }
        set;
    }
    
    //sort the field Default is 'name'
    public String SortField {
        get { if (SortField == null) {SortField = 'Name'; } return SortField;  }
        set; 
    }
    
    //Save method & returns to the list view 
    public PageReference DoSomethingMany() {
     
    list<Expense_Tracker__c> ETRec =new List<Expense_Tracker__c>();
        for (Id ContactId : ContactSelectedSet) {
            system.debug('Checked: ' + ContactId);
            Expense_Tracker__c Rec=new Expense_Tracker__c();
            Rec.Expense_Date__c=cont.Expense_Date__c;
            Rec.Expense_Details__c=cont.Expense_Details__c;
            Rec.Expense_Type__c=cont.Expense_Type__c;
            Rec.Amount__c=cont.Amount__c;
            Rec.Status__c=cont.Status__c;
            Rec.Source__c=cont.Source__c;
            Rec.Notes__c=cont.Notes__c;
            Rec.Contact__c=ContactId;
            Rec.Account__c=cont.Account__c;
            Rec.Educational_Meeting__c=cont.Educational_Meeting__c;
            if(EducationalRecType)
            {
               Rec.RecordTypeId=string.valueOf(Schema.SObjectType.Expense_Tracker__c.getRecordTypeInfosByName().get('Educational Meeting').getRecordTypeId());
            }
            ETRec.add(Rec);
        }
        if(ETRec.size()>0)
        Insert ETRec; // insert the list of expense records
        system.debug('Rec:'+ETRec);
        
        /*upload document */
        
         list<document> documents=[select body, id , name,description,createddate from document where folderid=:userid AND keywords='Expense_Tracker' ORDER BY createddate DESC   limit 1]; 
         if(documents.size()>0)
            document=documents[0];
         system.debug('document:'+document);
        if(document.body!=null)
        { 
        for (integer i=0; i<ETRec.size();i++)
        {
           attachment file= new attachment();
           file.ParentId=ETRec[i].id;
           file.body=document.body;
           file.name=document.name;
           file.description=document.description;
           system.debug('file'+file);
           documentlist.add(file);
         }  
        try {
      insert documentlist;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      
    } finally {
      for(integer i=0;i<documentlist.size();i++)
      {
          documentlist[i].body = null; // clears the viewstate
          
      }  
      documentdelete(document);
      document = new document();  
    }
    }
    /*****************/
    
        pageReference PgRef= new PageReference('/a0Q/o');
        PgRef.setRedirect(true);
        return PgRef;
    }
    
    
   public void documentdelete(document docu)
   {
      if(docu!=null)
        try {
        Delete docu;
        }catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      
    } 
   } 
    
    /****************/
    //Toggle method changes the asc to dsc
    public void SortToggle() {
        SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        // reset sort sequence when sorted field is changed
        if (SortFieldSave != SortField) {
            SortDirection = 'asc';
            SortFieldSave = SortField;
        }
        // run the query again
        BuildQuery();
    }
    //disables the button if it not useful
    public boolean getenable() {
        if(ContactList.size()==0)
        {     return true;}
        else
         {    return false;     }
    } 
    //pagination Previous button
    public void previous (){
       // if(StdSetControllerContact.getHasPrevious() )
       if(isprevious)
        {
           first=first-Integer.valueof(RecPerPage);
           last=last-Integer.valueof(RecPerPage);
          
        
        }
    } 
    //pagination next button
    public void next (){
    
        //system.debug('next:'+StdSetControllerContact.getHasNext());
        //if(StdSetControllerContact.getHasNext() )
        if(isnext)
        { 
           
           first=last+1;
           last=first+Integer.valueof(RecPerPage)-1;
           
            system.debug('nextfirst:'+first+'nextlast:'+last);
        }
     }
     
  public void upload()
  {
     document.AuthorId = UserInfo.getUserId();
     document.FolderId = UserInfo.getUserId();
     document.keywords='Expense_Tracker';  
     
     try {
      insert document;
      system.debug('inserteddocumentid:'+document.id);
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
      
      
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      
    } finally {
      
      document.body = null; // clears the viewstate
      document = new Document();
    }
   
  
  }
    //wrapper Class starts
    public class ContactSubClass {
        public Boolean aCheckBox {get;set;}
        public Contact aContact {get;set;}
        
        // sub-class initialization
        public ContactSubClass(Contact a, Boolean chk){
            aContact = a;
            aCheckBox = chk;
        }
    }
}