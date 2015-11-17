@isTest
private class SL_Test_ProceedHandler 
{
    static testMethod void SL_Test_ProceedHandler() 
    {
    	list<Proceeds__c> lstProceedsToInsert = new list<Proceeds__c>();
    	
    	// Insert Account record
    	Account objAcc = new Account(Name = 'Test Acc - 1');
        insert objAcc ;
        System.assert(objAcc.Id != NULL);
        
        // Insert LetterofIntent record
        Letter_of_Intent__c objLetterofIntent = new Letter_of_Intent__c(Facility_Rating__c = '5', Account__c = objAcc.Id);
        insert objLetterofIntent ;
        System.assert(objLetterofIntent.Id != NULL);
        
        // Insert Schedule record
        Schedule__c objSchedule = new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Schedule-8', Count_for_A_A__c = 'Yes');
        insert objSchedule;
        
        Schedule__c objSchedule1 = new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Schedule-1', Count_for_A_A__c = 'Yes');
        insert objSchedule1;
        
        System.assert(objSchedule.Id != NULL);
        
        // Insert Proceeds
    	Proceeds__c objProceeds1 = new Proceeds__c(Amount__c = 1000, schedule__c = objSchedule.Id, Date_Posted__c = System.today()+8);
    	lstProceedsToInsert.add(objProceeds1);
    	
    	 // Insert Proceeds
    	Proceeds__c objProceeds2 = new Proceeds__c(Amount__c = 1000, schedule__c = objSchedule.Id, Date_Posted__c = System.today()+88);
    	lstProceedsToInsert.add(objProceeds2);
    	
    	 // Insert Proceeds
    	Proceeds__c objProceeds3 = new Proceeds__c(Amount__c = 1000, schedule__c = objSchedule.Id, Date_Posted__c = System.today()-78);
    	lstProceedsToInsert.add(objProceeds3);
    	
    	 // Insert Proceeds
    	Proceeds__c objProceeds4 = new Proceeds__c(Amount__c = 1000, schedule__c = objSchedule.Id, Date_Posted__c = System.today()+25);
    	lstProceedsToInsert.add(objProceeds4);
    	
    	
    	// Insert Proceeds
    	Proceeds__c objProceeds5 = new Proceeds__c(Amount__c = 400, schedule__c = objSchedule.Id, Date_Posted__c = System.today()+45);
    	lstProceedsToInsert.add(objProceeds5);
    	
    	 // Insert Proceeds
    	Proceeds__c objProceeds6 = new Proceeds__c(Amount__c = 1000, schedule__c = objSchedule.Id, Date_Posted__c = System.today()+10);
    	lstProceedsToInsert.add(objProceeds6);
    	
    	 // Insert Proceeds
    	Proceeds__c objProceeds7 = new Proceeds__c(Amount__c = 1000, schedule__c = objSchedule.Id, Date_Posted__c = System.today()+1);
    	lstProceedsToInsert.add(objProceeds7);
    	
    	insert lstProceedsToInsert;
    	lstProceedsToInsert = new list<Proceeds__c>();
    	
    	// Update Proceeds
    	Proceeds__c objProceedToUpdate1 = new Proceeds__c(Id = objProceeds1.Id, Amount__c = 200);
    	lstProceedsToInsert.add(objProceedToUpdate1);
    	
    	Proceeds__c objProceedToUpdate2 = new Proceeds__c(Id = objProceeds2.Id, Date_Posted__c = System.today()+ 80);
    	lstProceedsToInsert.add(objProceedToUpdate2);
    	
    	Proceeds__c objProceedToUpdate3 = new Proceeds__c(Id = objProceeds3.Id, Schedule__c = objSchedule1.Id);
    	lstProceedsToInsert.add(objProceedToUpdate3);
    	
    	Proceeds__c objProceedToUpdate4 = new Proceeds__c(Id = objProceeds4.Id, Schedule__c = objSchedule1.Id, Date_Posted__c = System.today()+ 80, Amount__c = 200);
    	objProceedToUpdate4.Amount__c = 100;
    	lstProceedsToInsert.add(objProceedToUpdate4);
    	
    	Proceeds__c objProceedToUpdate5 = new Proceeds__c(Id = objProceeds5.Id, Schedule__c = objSchedule1.Id, Date_Posted__c = System.today()+ 80);
    	objProceedToUpdate5.Amount__c = 100;
    	lstProceedsToInsert.add(objProceedToUpdate5);
    	
    	Proceeds__c objProceedToUpdate6 = new Proceeds__c(Id = objProceeds6.Id, Schedule__c = objSchedule1.Id, Amount__c = 200);
    	objProceedToUpdate6.Amount__c = 100;
    	lstProceedsToInsert.add(objProceedToUpdate6);
    	
    	Proceeds__c objProceedToUpdate7 = new Proceeds__c(Id = objProceeds7.Id, Date_Posted__c = System.today()+ 80, Amount__c = 200);
    	objProceedToUpdate7.Amount__c = 100;
    	lstProceedsToInsert.add(objProceedToUpdate7);
    	
    	
    	update lstProceedsToInsert;
    	    	
    	delete objProceeds1;
    	
    	undelete objProceeds1;
    	
    }
}