public with sharing class timeentriesController {

// Constructor
 public timeentriesController(ApexPages.StandardController controller) {
  this.proj = (Case)controller.getSubject();
  
     this.tercd = [ SELECT 
      te.Name, te.Case__c,te.Entry_Date__c,te.Time_Spent_Minutes__c,te.Comments__c       
      FROM 
      Time_Entry__c te 
      WHERE 
      te.Case__c = :proj.id ];
 }
 
 // Action Method called from page button
 public pagereference saveChanges() { 
  upsert this.tercd;
  return null;
 }
 
 // Action Method called from page link
 public pagereference newTimeEntry() { 
  Time_Entry__c te = new Time_Entry__c();
  te.Case__c =this.proj.id; 
  tercd.add( te );
  return null;
 }
 
 // public Getter to provide table headers 
 public string[] getheaders() { return new string [] 
  {'Name','Case','Date','Time Spent', 'Comments'
    } ; }
 
 // public Getter to list project timeentries
 public Time_Entry__c[] gettimeentries() { 
  return this.tercd; 
 } 
 
 // class variables
 Case proj;
 Time_Entry__c[] tercd; 
 
}