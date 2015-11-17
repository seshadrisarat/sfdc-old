@isTest
public class SL_Test_Note_Handler {
	
	//Test method for class SL_Note_Handler
    static testmethod void testSL_Note_Handler()
    {
    	// Preparing Test Data
    	
    	// Inserting custom setting records
    	List<SObjectAPIName__c> lstCS = new List<SObjectAPIName__c>();
    	SObjectAPIName__c sObjCS = new SObjectAPIName__c(Name='Letter_of_Intent__c', LatestNoteFieldAPIName__c = 'Latest_Note__c');
    	SObjectAPIName__c sObjCS1 = new SObjectAPIName__c(Name='Schedule__c', LatestNoteFieldAPIName__c = 'Latest_Note__c');
    	lstCS.add(sObjCS);
    	lstCS.add(sObjCS1);
    	insert lstCS;
    	
    	Letter_of_Intent__c sObjLOI = new Letter_of_Intent__c(Latest_Note__c = ' ');
    	insert sObjLOI;
    	
    	Schedule__c sObjSchedule = new Schedule__c(Letter_of_Intent__c = sObjLOI.Id, Latest_Note__c = ' ');
    	insert sObjSchedule;
    	
    	Note sObjNote1 = new Note();
    	sObjNote1.Title = 'This is for test LOI purpose';
    	sObjNote1.ParentId = sObjSchedule.Id;
    	insert sObjNote1;
    	
        Schedule__c objSchedule = [Select Id,Letter_of_Intent__c,Latest_Note__c
        							from Schedule__c
        							where id=:sObjSchedule.id];
        							
    	system.assertequals(objSchedule.Latest_Note__c ,'This is for test LOI purpose');
    	
    	Note sObjNote3 = new Note();
    	sObjNote3.Title = 'This is for test Schedule purpose';
    	sObjNote3.Body = 'This is body';
    	sObjNote3.ParentId = sObjSchedule.Id;
    	insert sObjNote3;
        							
    	Note sObjNote2 = new Note();
    	sObjNote2.Title = 'This is for test Schedule purpose';
    	sObjNote2.ParentId = sObjLOI.Id;
    	insert sObjNote2;
	    
	    Letter_of_Intent__c objLOI = [Select Id,Latest_Note__c
        							  from Letter_of_Intent__c
        							  where id=:sObjLOI.id];
        							       
        system.assert(objLOI.Latest_Note__c == 'This is for test Schedule purpose'); 
        							       
	    Note sObjNote4 = new Note();
    	sObjNote4.Title = 'This is for test LOI';
    	sObjNote4.Body = 'This is body';
    	sObjNote4.ParentId = sObjLOI.Id;
    	insert sObjNote4;
    	
	    sObjNote3.IsPrivate = true;
	    update sObjNote3;
	    Schedule__c objSchedule2 = [Select Id,Letter_of_Intent__c,Latest_Note__c
        							from Schedule__c
        							where id=:sObjSchedule.id];
	    
	    system.assert(objSchedule2.Latest_Note__c == 'This is for test LOI purpose');
	    
	    sObjNote4.IsPrivate = true;
	    update sObjNote4;
	    Letter_of_Intent__c objLOI2 = [Select Id,Latest_Note__c
        							       from Letter_of_Intent__c
        							       where id=:sObjLOI.id];
	    
	    system.assert(objLOI2.Latest_Note__c == 'This is for test Schedule purpose');  
	    
	    delete sObjNote1;
	    
    }
}