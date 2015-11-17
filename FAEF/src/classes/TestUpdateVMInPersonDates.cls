@isTest
public class TestUpdateVMInPersonDates{
	@isTest
    	public static void testUpdateVMInPeronDatesLogic(){
        	Account a = new Account(name = 'test');
            insert a;
            
            Contact c = new Contact(firstName = 'test', lastName = 'test', AccountId = a.id);
            insert c;
            
            Event e = new Event();
            e.WhatId = a.Id;
            e.whoId = c.Id;
            e.Subject = 'Test';
            e.Type = 'Virtual Meeting';
            e.DurationInMinutes = 60;
            e.ActivityDate = Date.today().addDays(2); 
            e.ActivityDateTime = DateTime.now().addDays(2);
            insert e;
            
            Event e2 = new Event();
            e2.WhatId = a.Id;
            e2.whoId = c.Id;
            e2.Subject = 'Test';
            e2.Type = 'In-Person Meeting';
            e2.DurationInMinutes = 60;
            e2.ActivityDate = Date.today().addDays(2); 
            e2.ActivityDateTime = DateTime.now().addDays(2);
            insert e2;
        }
}