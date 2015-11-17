@istest
private class trigCase_Test{
static Testmethod void validateTrigger()
{
Test.starttest();
List<case> testcase= new List<Case>();

//Test Case

Case c1=new Case();
c1.Origin='Web';
c1.Case_Type__c='Public Relations';
testcase.add(c1);

Case c2=new Case();
c2.Origin='Web';
c2.Case_Type__c='Not Public Relations';
testcase.add(c2);

Case c3=new Case();
c3.IsWebOrigin__c=True;
c3.Case_Type__c='Public Relations';
testcase.add(c3);

Case c4=new Case();
c4.IsWebOrigin__c=True;
c4.Case_Type__c='Not Public Relations';
testcase.add(c4);

Case c5=new Case();
c5.External_Contact_Name__c='Web';
c5.Case_Type__c='Public Relations';
testcase.add(c5);

Case c6=new Case();
c6.External_Contact_Name__c='Web';
c6.Case_Type__c='Not Public Relations';
testcase.add(c6);


Case c7=new Case();
c7.Origin='Not Web';
c7.IsWebOrigin__c=False;
c7.External_Contact_Name__c='Not Web';
c7.Property_Address_Name__c=c7.id;
c7.Case_Type__c='Public Relations';
testcase.add(c7);

Case c8=new Case();
c8.Origin='Not Web';
c8.IsWebOrigin__c=False;
c8.External_Contact_Name__c='Not Web';
c8.Property_Address_Name__c=c8.id;
c8.Case_Type__c='Not Public Relations';
testcase.add(c8);


insert c1;
System.assertNotEquals(null,[select Id From Case where Id=:c1.Id limit 1],'Sql is null');
c1=[select Id,RecordTypeId From Case where Id=:c1.Id ];
System.debug(c1.RecordTypeId);
System.assertEquals('012E00000005zDi',c1.RecordTypeId);

insert c2;

c2=[select Id,RecordTypeId From case where Id=:c2.Id];
System.debug('record type'+c2.RecordTypeId);
System.assertEquals('012E00000005zDj',c2.RecordTypeId);

insert c3;

c3=[select Id,RecordTypeId From case where Id=:c3.Id];

System.debug('record type'+c3.RecordTypeId);
System.assertEquals('012E00000005zDi',c3.RecordTypeId);

insert c4;

c4=[select Id,RecordTypeId From case where Id=:c4.Id];
System.debug('record type'+c4.RecordTypeId);
System.assertEquals('012E00000005zDj',c4.RecordTypeId);

insert c5;

c5=[select Id,RecordTypeId From case where Id=:c5.Id];
System.debug('record type'+c5.RecordTypeId);
System.assertEquals('012E00000005zDi',c5.RecordTypeId);

insert c6;

c6=[select Id,RecordTypeId From case where Id=:c6.Id];
System.debug('record type'+c6.RecordTypeId);
System.assertEquals('012E00000005zDj',c6.RecordTypeId);

insert c7;

c7=[select Id,RecordTypeId From case where Id=:c7.Id];
System.debug('record type'+c7.RecordTypeId);
System.assertEquals('012E00000005zDh',c7.RecordTypeId);

insert c8;

c8=[select Id,RecordTypeId From case where Id=:c8.Id];
System.debug('record type'+c8.RecordTypeId);
System.assertEquals('012E00000005zDg',c8.RecordTypeId);


//After insert
For(case c:testcase)
{
  AssignmentRule AR = new AssignmentRule();
  AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
  Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
     system.debug('@@newCase AR.id'+AR.id);
     System.assertNotEquals(null,dmlOpts.assignmentRuleHeader.assignmentRuleId,'dmlOpts is null');
     System.assertNotEquals(null,AR.id,'Ar.id is null');
     System.assertEquals(dmlOpts.assignmentRuleHeader.assignmentRuleId, AR.id);

}


test.stoptest();


}
}