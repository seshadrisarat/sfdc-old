@istest
public with sharing class ExpenseTrackerEditPageControllerTest
{
   // Testing for the Standard Record Type
   public static testmethod void testcontrollerStandard()
   {
      
      //Creating Test Records for Account,Contact,ExpenseTracker
      Account Acc=new Account();
      Acc.name='testaccount';
      insert Acc;
      
      contact co= new contact();
      co.lastname='test';
      insert co;
      
      Expense_Tracker__c ET=new Expense_Tracker__c();
      ET.contact__C=co.id;
      ET.Expense_Type__c='Client Mailing';
      ET.Account__C=Acc.id;
      insert ET;
      
      // Setting URL parameters
      apexpages.currentpage().getparameters().put('RecordType',Schema.SObjectType.Expense_Tracker__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId());
      apexpages.currentpage().getparameters().put('accid',acc.id);
      apexpages.currentpage().getparameters().put('conid',co.id);
      
      Document Doc= new Document();
      Doc.body=blob.valueof('Testing File');
      Doc.name='Expense';
      Doc.Keywords='Expense_Tracker';
      Doc.AuthorId =UserInfo.getUserId();
      Doc.FolderId = UserInfo.getUserId();
      insert Doc;
      
      Expense_Tracker__c rec = [select recordTypeid,Expense_Type__c,Account__C,Amount__c,Educational_Meeting__c,Expense_Date__c,Notes__c,Source__c,Status__c,Expense_Details__c from Expense_Tracker__c where Expense_Type__c='Client Mailing' LIMIT 1];
      
      //Testing the controller of the class
      ApexPages.StandardController sc = new ApexPages.standardController(rec);
      ExpenseTrackerEditPageController con=new ExpenseTrackerEditPageController (sc);
      //con.cont=rec;
      
      //Test Wrapper Class
      ExpenseTrackerEditPageController.ContactSubClass WRC = new  ExpenseTrackerEditPageController.ContactSubClass(co,true);
      ExpenseTrackerEditPageController.ContactSubClass WRC2 = new  ExpenseTrackerEditPageController.ContactSubClass(co,false);
      
     //calling all the methods & properties in the class 
      con.contactlist.add(WRC2);
      con.UpdateContactSelectedSet();
      con.contactlist.add(WRC);
      con.UpdateContactSelectedSet();
      con.DoSomethingMany();
      con.BuildQuery();
      con.SearchName='';
      Con.BuildWhere('y','Cond');
      con.ischanged=true;
      con.clearAll();
      con.SearchContact();
      con.SortField='Email';
      con.SortToggle();
           
      con.getCurrentContactList();
      con.getenable();
      con.pagination();
      con.next();
      con.previous();

   }
   
    // Testing for the Educational Record Type
   public static testmethod void testcontrollerEducational()
   {
      // Setting URL parameters
      apexpages.currentpage().getparameters().put('RecordType',Schema.SObjectType.Expense_Tracker__c.getRecordTypeInfosByName().get('Educational Meeting').getRecordTypeId());
      
      //Creating Test Records for Account,Contact,ExpenseTracker
      Account Acc=new Account();
      Acc.name='testaccount';
      insert Acc;
      
      contact co= new contact();
      co.lastname='test';
      insert co;
      
      Expense_Tracker__c ET=new Expense_Tracker__c();
      ET.contact__C=co.id;
      ET.Expense_Type__c='Client Mailing';
      ET.Account__C=Acc.id;
      insert ET;
      
      
      Document Doc= new Document();
      //Doc.body=blob.valueof('Testing File');
      Doc.name='Expense';
      Doc.Keywords='Expense_Tracker';
      Doc.AuthorId =UserInfo.getUserId();
      Doc.FolderId = UserInfo.getUserId();
      insert Doc;
      
      
      Expense_Tracker__c rec = [select recordTypeid,Expense_Type__c,Account__C,Amount__c,Educational_Meeting__c,Expense_Date__c,Notes__c,Source__c,Status__c,Expense_Details__c from Expense_Tracker__c where Expense_Type__c='Client Mailing' LIMIT 1];
      
      //Testing the controller of the class
      ApexPages.StandardController sc = new ApexPages.standardController(rec);
      ExpenseTrackerEditPageController con=new ExpenseTrackerEditPageController (sc);
      ExpenseTrackerEditpageController Con1=new ExpenseTrackerEditPageController(); 
      
      //Test Wrapper Class
      ExpenseTrackerEditPageController.ContactSubClass WRC = new  ExpenseTrackerEditPageController.ContactSubClass(co,true);
      ExpenseTrackerEditPageController.ContactSubClass WRC2 = new  ExpenseTrackerEditPageController.ContactSubClass(co,false);
      
      //calling all the methods & properties in the class with different values than previous method
      con.contactlist.add(WRC2);
      con.UpdateContactSelectedSet();
      con.contactlist.add(WRC);
      con.getenable();
      con.clearAll();
      con.DoSomethingMany();
      con.BuildWhere('','false');
      con.SearchName='';
      con.BuildQuery();
      con.SearchContact();
      con.SortField='Email';
      con.SortToggle();
      con.total=0;
      con.last=1;
      con.first=2;
      con.getCurrentContactList();
      con.RecPerpage='25';
      con.pagination();
      con.isnext=true;
      con.isprevious=true;
      con.next();
      con.previous();
      con.upload();
   }
}