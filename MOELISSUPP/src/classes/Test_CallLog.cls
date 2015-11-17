@isTest
private class Test_CallLog {
    static testMethod void Call_Log_Create_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		
		
		Event event = new Event();
		event.StartDateTime = DateTime.now();
		event.EndDateTime = DateTime.now().addMinutes(90);
		event.DurationInMinutes = 90;
		event.Subject = 'Other';
		event.Type = 'test';
		insert event;
		
		/*Call_Log_Contact__c clc_del = new Call_Log_Contact__c();
		clc_del.Call_Log__c = cl.Id;
		clc_del.Contact__c = cntct.Id;
		insert clc_del;*/
		Test.startTest();
		ApexPages.currentPage().getParameters().put('eid', event.Id);
		Call_Log_Create cls;
		cls = new Call_Log_Create();
		cls.save();
		cls = new Call_Log_Create();
		cls.save_new();
		cls.cancel();
		Test.stopTest();
    }
    
    
    static testMethod void Call_Log_Contact_Create_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		cl.Detailed_Description__c = 'test';
		cl.HIDDEN_Email_Feild__c = 'vika@test.ru';
		cl.Send_Email__c = true;
		cl.Subject__c = 'test';
		cl.Type__c = 'test';
		insert cl;
		
		Call_Log_Contact__c clc = new Call_Log_Contact__c();
		clc.Call_Log__c = cl.Id;
		clc.Contact__c = cntct.Id;
		insert clc;

		Test.startTest();
		Call_Log_Contact_Create cls;
		cls = new Call_Log_Contact_Create(new ApexPages.StandardController(clc));
		cls.save();
		//cls = new Call_Log_Contact_Create();
		cls.save_new();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void Call_Log_Attendee_Create_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		User newUser = [SELECT id, name FROM User LIMIT 1].get(0);
        Employee_Profile__c empl = new Employee_Profile__c();
		empl.First_Name__c = 'Test';
		empl.Last_Name__c = 'Test';
		empl.User_ID__c = newUser.Id;
		//empl.Contact__c = cntct.Id;
		insert empl;
		Call_Log_Moelis_Attendee__c cla = new Call_Log_Moelis_Attendee__c();
		cla.Employee__c = empl.Id;
		cla.Call_Log__c = cl.Id;
		insert cla;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('clid', cl.Id);
		Call_Log_Attendee_Create cls;
		cls = new Call_Log_Attendee_Create();
		cls.save();
		cls = new Call_Log_Attendee_Create();
		cls.save_new();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void Call_Log_Deal_Create_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('clid', cl.Id);
		Call_Log_Deal_Create cls;
		cls = new Call_Log_Deal_Create();
		cls.save();
		cls = new Call_Log_Deal_Create();
		cls.save_new();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void CallLog_Contact_new_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		//insert cl;
		
		Test.startTest();
		//ApexPages.currentPage().getParameters().put('clid', cl.Id);
		ApexPages.currentPage().getParameters().put('contactid', cntct.Id);
		CallLog_Contact_new cls;
		cls = new CallLog_Contact_new();
		cls.callLog = cl;
		cls.save();
		cls = new CallLog_Contact_new();
		cl = new Call_Log__c();
		cl.Date__c = Date.today();
		cls.callLog = cl;
		cls.save_new();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void CallLog_Deal_new_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		
		Test.startTest();
		//ApexPages.currentPage().getParameters().put('contactid', cntct.Id);
		CallLog_Deal_new cls;
		cls = new CallLog_Deal_new();
		cls.callLog = cl;
		cls.save();
		cls = new CallLog_Deal_new();
		cl = new Call_Log__c();
		cl.Date__c = Date.today();
		cls.callLog = cl;
		cls.save_new();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void CallLogAttendees_AddMultipleJSON_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		User newUser = [SELECT id, name FROM User LIMIT 1].get(0);
        Employee_Profile__c empl = new Employee_Profile__c();
		empl.First_Name__c = 'Test';
		empl.Last_Name__c = 'Test';
		empl.User_ID__c = newUser.Id;
		//empl.Contact__c = cntct.Id;
		insert empl;
		Call_Log_Moelis_Attendee__c cla = new Call_Log_Moelis_Attendee__c();
		cla.Employee__c = empl.Id;
		cla.Call_Log__c = cl.Id;
		insert cla;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('clid', cl.Id);
		CallLogAttendees_AddMultipleJSON cls = new CallLogAttendees_AddMultipleJSON();
		Test.stopTest();
    }
    
    static testMethod void CallLogContacts_AddMultipleJSON_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		Call_Log_Contact__c clc = new Call_Log_Contact__c();
		clc.Call_Log__c = cl.Id;
		clc.Contact__c = cntct.Id;
		insert clc;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('clid', cl.Id);
		CallLogContacts_AddMultipleJSON cls = new CallLogContacts_AddMultipleJSON();
		Test.stopTest();
    }
    
    static testMethod void CallLogAttendees_AddMultiple_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		User newUser = [SELECT id, name FROM User LIMIT 1].get(0);
        Employee_Profile__c empl = new Employee_Profile__c();
		empl.First_Name__c = 'Test';
		empl.Last_Name__c = 'Test';
		empl.User_ID__c = newUser.Id;
		//empl.Contact__c = cntct.Id;
		insert empl;
		Call_Log_Moelis_Attendee__c cla = new Call_Log_Moelis_Attendee__c();
		cla.Employee__c = empl.Id;
		cla.Call_Log__c = cl.Id;
		insert cla;
		Call_Log_Moelis_Attendee__c cla2 = new Call_Log_Moelis_Attendee__c();
		cla2.Employee__c = empl.Id;
		cla2.Call_Log__c = cl.Id;
		insert cla2;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('clid', cl.Id);
		CallLogAttendees_AddMultiple cls = new CallLogAttendees_AddMultiple();
		cls.isTest = true;
		cls.jsonContent = '{"delList" : ["'+cla.Id+'"], "table" : ['
						+'[{}, {"value":{"lkid":"'+empl.Id+'"}}, {"value":""}, {"value":""}]'
						+',[{}, {"value":{"lkid":"'+empl.Id+'"}}, {"value":""}, {"value":""}]'
						+'], "rows" : ["new_0", "'+cla2.Id+'"]}';
		cls.canDelete = false;
		cls.save();
		cls.canDelete = true;
		cls.save();
		cls.jsonContent = '{}';
		cls.save_close();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void CallLogContacts_AddMultiple_Test() {
        Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		Call_Log_Contact__c clc = new Call_Log_Contact__c();
		clc.Call_Log__c = cl.Id;
		clc.Contact__c = cntct.Id;
		insert clc;
		Call_Log_Contact__c clc2 = new Call_Log_Contact__c();
		clc2.Call_Log__c = cl.Id;
		clc2.Contact__c = cntct.Id;
		insert clc2;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('clid', cl.Id);
		CallLogContacts_AddMultiple cls = new CallLogContacts_AddMultiple();
		cls.isTest = true;
		cls.jsonContent = '{"delList" : ["'+clc.Id+'"], "table" : ['
						+'[{}, {"value":{"lkid":"'+cntct.Id+'"}}, {"value":""}, {"value":""}, {"value":""}, {"value":""}, {"value":""}, {"value":""}, {"value":""}]'
						+',[{}, {"value":{"lkid":"'+cntct.Id+'"}}, {"value":""}, {"value":""}, {"value":""}, {"value":""}, {"value":""}, {"value":""}, {"value":""}]'
						+'], "rows" : ["new_0", "'+clc2.Id+'"]}';
		cls.canDelete = false;
		cls.save();
		cls.canDelete = true;
		cls.save();
		cls.jsonContent = '{}';
		cls.save_close();
		cls.cancel();
		Test.stopTest();
    }
    
    static testMethod void Account_CallLog_Link_Test() {
    	
    	Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		cl.Detailed_Description__c = 'test';
		cl.HIDDEN_Email_Feild__c = 'vika@test.ru';
		cl.Send_Email__c = true;
		cl.Subject__c = 'test';
		cl.Type__c = 'test';
		insert cl;
		
		Call_Log_Contact__c clc = new Call_Log_Contact__c();
		clc.Call_Log__c = cl.Id;
		clc.Contact__c = cntct.Id;
		insert clc;
		
		Call_Log_related__c clr = new Call_Log_related__c();
		clr.Call_Log__c = cl.Id;
		clr.Account__c = acc.Id;
		clr.Call_Log_Contact_del__c = clc.Id;
		insert clr;
		update cl;
		
		
    	Test.startTest();
        Account_CallLog_Link tmp = new Account_CallLog_Link(new ApexPages.StandardController(clr));
        Account_CallLog_related_link tmp2 = new Account_CallLog_related_link(new ApexPages.StandardController(clr));
        tmp.autoReload();
        tmp2.autoReload();
        Test.stopTest();
        delete clr;
    }
}