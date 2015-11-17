@isTest(seealldata=true)
private class GenericTests {
	
@isTest static void testContact(){
    Test.startTest();
      Account a = new Account();
      a.Name = 'TEST';

      Contact l4 = new Contact(
        LastName = 'AnyLastName',
        AccountId = a.Id,
        Inbound_Lead_Record_Type_Master__c = 'PE',
        Marketo_lastMQLdate__c = DateTime.now()
      );
      Map<Id, SObject> triggerOldMap4 = new Map<Id, SObject>();
      triggerOldMap4.put(l4.id, l4);
      List<SObject> triggerNew4 = new List<Contact> { l4 };
      LeadAssignment.assignLeads(triggerNew4, triggerOldMap4, true);
      insert l4;
    Test.stopTest();
  }

  @isTest static void testContact2(){
    Test.startTest();
      Account a = new Account();
      a.Name = 'TEST';

      Contact l5 = new Contact(
        LastName = 'AnyLastName',
        AccountId = a.Id,
        Inbound_Lead_Record_Type_Master__c = 'CA',
        Transaction_Types__c = 'Raise Capital',
        Marketo_lastMQLdate__c = DateTime.now()
      );
      Map<Id, SObject> triggerOldMap5 = new Map<Id, SObject>();
      triggerOldMap5.put(l5.id, l5);
      List<SObject> triggerNew5 = new List<Contact> { l5 };
      LeadAssignment.assignLeads(triggerNew5, triggerOldMap5, true);
      insert l5;
    Test.stopTest();
  }

  @isTest static void testTask(){
    Account a = new Account();
    a.Name = 'account Test';
    insert a;
    a = [SELECT Id FROM Account WHERE Name = 'account Test' Limit 1];

    Contact c = new Contact(
      LastName = 'Lname',
        AccountId = a.Id
    );
    insert c;
    c = [SELECT Id FROM Contact WHERE LastName = 'Lname' LIMIT 1];

    Test.startTest();
      Task t = new Task();
      t.WhoId = c.Id;
      insert t;
    Test.stopTest();
  }

  @isTest static void testEvent(){
    Account a = new Account();
    a.Name = 'account Test';
    insert a;
    a = [SELECT Id FROM Account WHERE Name = 'account Test' Limit 1];

    Contact c = new Contact(
      LastName = 'Lname',
        AccountId = a.Id
    );
    insert c;
    c = [SELECT Id FROM Contact WHERE LastName = 'Lname' LIMIT 1];


    Test.startTest();

      Event e = new Event(
        DurationInMinutes=100,
        ActivityDateTime=DateTime.now(),
        WhoId=c.Id
      );
      insert e;
    Test.stopTest();
  }

  //@isTest static void testTask(){
  //  Test.startTest();
  //    Account a = new Account();
  //    a.Name = 'TEST';

  //    Contact c = new Contact(
  //      LastName = 'AnyLastName',
  //      AccountId = a.Id
  //    );
  //    insert a;
  //    insert c;

  //    Task t = new Task();
  //    t.WhoId = c.Id;
  //    insert t;
  //  Test.stopTest();
  //}

  //@isTest static void testEvent(){
  //  Test.startTest();
	 // 	Account a = new Account();
	 //   a.Name = 'TEST';

	 //   Contact c = new Contact(
	 //   	LastName = 'AnyLastName',
	 //       AccountId = a.Id
	 //   );

  //    insert a;
  //    insert c;
      
	 //   Event e = new Event(
	 //   	DurationInMinutes=100, 
	 //   	ActivityDateTime=DateTime.now(),
	 //   	WhoId=c.Id
	 //   );
	 //   insert e;
  //  Test.stopTest();
  //}

  @isTest static void testAccount(){
    Test.startTest();
      Account a = new Account(Name='Anything');
      insert a;
    Test.stopTest();
  }

  @isTest static void testDWPursuits(){
  	Account a = new Account(Name='Test Acct', Company_Type_full_name__c='Investment Bank');
	Contact c = new Contact(
	  LastName = 'AnyLastName',
	  Account = a,
	  Inbound_Lead_Record_Type_Master__c = 'PE',
	  Marketo_lastMQLdate__c = DateTime.now()
	);
	insert a;
	insert c;

	CATH_Deal__c d = new CATH_Deal__c(
		Name = 'TEST DEAL',
      	Assigned_User__c = c.id
	);
	insert d;

    Test.startTest();
      DW_Pursuit__c pc = new DW_Pursuit__c(
      	Name = 'Foo',
      	Match_Relationship_Id__c = 'anythinggoeshere',
      	Receiving_Member__c = c.id,
      	Axial_Opportunity__c = d.id
      	//Axial_Opportunity__c, Receiving_Member__c
      );
      insert pc;
    Test.stopTest();
  }

  @isTest static void testOpportunityProduct(){
    Test.startTest();
      // This data is populated by default after each refresh
      PriceBookEntry p = [SELECT Id FROM PriceBookEntry Where IsActive = true AND Name like '%basic%' LIMIT 1];
      Account a = new Account(Name='Test Acct', Company_Type_full_name__c='Investment Bank');
      insert a;
      Opportunity opp = new Opportunity(
        AccountId=a.Id, 
        Estimated_CR__c=100, 
        Name='basic', 
        CloseDate = Date.today(),
        StageName = 'Closed Won'
      );
      insert opp;
      OpportunityLineItem o = new OpportunityLineItem(
        OpportunityId=opp.Id,
        Quantity=1,
        Billing_Installments__c=1,
        Paid_Months__c=12,
        Free_Months__c=0,
        TotalPrice=100,
        PriceBookEntryId=p.Id,
        Active__c=True
      );
      insert o;
    Test.stopTest();
  }
	
}