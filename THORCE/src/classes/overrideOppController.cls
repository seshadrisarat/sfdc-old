public class overrideOppController{
case c;
public string contactEmail{get;set;}
public string contactPhone{get;set;}
public boolean noContact{get;set;}
public boolean displayContSec{get;set;}
public id contactId{get;set;}
    public overrideOppController(ApexPages.StandardController stdcontroller) {
     this.c = (case)stdController.getRecord();
       // stdcontroller.addFields(new LIST<String>{'Id','Name','case_type__c'});
       string firstNam = userInfo.getFirstName();
       string lastNam = userInfo.getLastName();
       Contact con= [select id,firstname,lastname from contact where firstname=:firstNam AND lastname=:lastNam limit 1];
       c.ContactId = con.id;
    }

    public boolean dispPubRel{get;set;}
    
    public void checkDispPubRel(){
        
         if(c.case_type__c =='Public Relations')
         dispPubRel=true;
         else
         dispPubRel=false;
        system.debug('@@ in dispPubRel'+c.case_type__c);
    }
    
    public void dispNewContactSec(){
        system.debug('@@in dispNewContactSec'+noContact);
        if(noContact==true){
            system.debug('@@in if of dispNewContactSec'+noContact);
          displayContSec = true;  
        }
        else
            displayContSec = false;
        
    }
}