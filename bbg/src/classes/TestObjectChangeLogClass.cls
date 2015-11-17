@isTest(seeAllData=true)
private class TestObjectChangeLogClass {
    
    private static RecordType srLeadRecordType = [Select Id, DeveloperName From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Sea_Ray_Lead'];
    private static RecordType bwLeadRecordType = [Select Id, DeveloperName From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Boston_Whaler_Lead'];
    private static RecordType mdLeadRecordType = [Select Id, DeveloperName From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Meridian_Yachts_Lead'];
    private static RecordType blLeadRecordType = [Select Id, DeveloperName From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Bayliner_Lead'];
    private static User srPardotUser = PardotAssignment.getPardotUser('SRPardot');
    private static User bwPardotUser = PardotAssignment.getPardotUser('BWPardot');
    private static User mdPardotUser = PardotAssignment.getPardotUser('MDPardot');
    private static User blPardotUser = PardotAssignment.getPardotUser('BLPardot');
    private static User unknownUser = PardotAssignment.getPardotUser('UnknownUser');
    
    private static pi__ObjectChangeLog__c createOCL(Id leadId, Id leadOwnerId) {
        pi__ObjectChangeLog__c ocl = new pi__ObjectChangeLog__c();
            
        ocl.pi__ObjectEmail__c = 'testlead@brunswickboatgroup.com';
        ocl.pi__ObjectFid__c = leadId;
        ocl.pi__ObjectState__c = 1;
        ocl.pi__ObjectType__c = 2;
        ocl.ownerId = leadOwnerId;
        
        return ocl;
    }
    
    public static testMethod void testInsertSRObjectChangeLog() {
    
        //Get a lead
        if (srLeadRecordType != null && srPardotUser != null) {
            system.debug('SeaRay lead record type id = ' + srLeadRecordType.id);
            system.debug('SeaRay Pardot user id = ' + srPardotUser.id);
            list<Lead> srLeads = [Select l.Id, l.Name, l.OwnerId From Lead l Where RecordTypeId = :srLeadRecordType.Id And l.OwnerId != :srPardotUser.Id LIMIT 10];
            
            system.debug('Leads is null? ' + srLeads.isEmpty());
            
            if (srLeads.size() > 0) {
                pi__ObjectChangeLog__c ocl = createOCL(srLeads.get(0).Id, srLeads.get(0).OwnerId);
                
                system.debug('Lead id: ' + srLeads.get(0).Id);
                system.debug('Lead owner: ' + srLeads.get(0).OwnerId);
                system.debug('Owner before trigger fired: ' + ocl.ownerId);
                
                insert ocl;
                
                pi__ObjectChangeLog__c oclUpdated = [Select ownerId From pi__ObjectChangeLog__c Where id = :ocl.id];
                
                system.debug('Owner after trigger fired: ' + oclUpdated.ownerId);
                
                System.assertNotEquals(ocl.ownerId, oclUpdated.ownerId);
            }
    	}
    }
    
    public static testMethod void testInsertBWObjectChangeLog() {
    
        //Get a lead
        if (bwLeadRecordType != null && bwPardotUser != null) {
            system.debug('Boston Whaler lead record type id = ' + bwLeadRecordType.id);
            system.debug('Boston Whaler Pardot user id = ' + bwPardotUser.id);
            list<Lead> bwLeads = [Select l.Id, l.Name, l.OwnerId From Lead l Where RecordTypeId = :bwLeadRecordType.Id And l.OwnerId != :bwPardotUser.Id LIMIT 10];
            
            system.debug('Leads is null? ' + bwLeads.isEmpty());
            
            if (bwLeads.size() > 0) {
                pi__ObjectChangeLog__c ocl = createOCL(bwLeads.get(0).Id, bwLeads.get(0).OwnerId);
                
                system.debug('Lead id: ' + bwLeads.get(0).Id);
                system.debug('Lead owner: ' + bwLeads.get(0).OwnerId);
                system.debug('Owner before trigger fired: ' + ocl.ownerId);
                
                insert ocl;
                
                pi__ObjectChangeLog__c oclUpdated = [Select ownerId From pi__ObjectChangeLog__c Where id = :ocl.id];
                
                system.debug('Owner after trigger fired: ' + oclUpdated.ownerId);
                
                System.assertNotEquals(ocl.ownerId, oclUpdated.ownerId);
            }
    	}
    } 
    
    public static testMethod void testInsertMDObjectChangeLog() {
    
        //Get a lead
        if (mdLeadRecordType != null && mdPardotUser != null) {
            system.debug('Meridian lead record type id = ' + mdLeadRecordType.id);
            system.debug('Meridian Pardot user id = ' + mdPardotUser.id);
            list<Lead> mdLeads = [Select l.Id, l.Name, l.OwnerId From Lead l Where RecordTypeId = :mdLeadRecordType.Id And l.OwnerId != :mdPardotUser.Id LIMIT 10];
            
            system.debug('Leads is null? ' + mdLeads.isEmpty());
            
            if (mdLeads.size() > 0) {
                pi__ObjectChangeLog__c ocl = createOCL(mdLeads.get(0).Id, mdLeads.get(0).OwnerId);
                
                system.debug('Lead id: ' + mdLeads.get(0).Id);
                system.debug('Lead owner: ' + mdLeads.get(0).OwnerId);
                system.debug('Owner before trigger fired: ' + ocl.ownerId);
                
                insert ocl;
                
                pi__ObjectChangeLog__c oclUpdated = [Select ownerId From pi__ObjectChangeLog__c Where id = :ocl.id];
                
                system.debug('Owner after trigger fired: ' + oclUpdated.ownerId);
                
                System.assertNotEquals(ocl.ownerId, oclUpdated.ownerId);
            }
        }
    }   
    
   public static testMethod void testInsertBLObjectChangeLog() {
    
        //Get a lead
        if (blLeadRecordType != null && blPardotUser != null) {
            system.debug('Bayliner lead record type id = ' + blLeadRecordType.id);
       		system.debug('Bayliner Pardot user id = ' + blPardotUser.id);
            list<Lead> blLeads = [Select l.Id, l.Name, l.OwnerId From Lead l Where RecordTypeId = :blLeadRecordType.Id And l.OwnerId != :blPardotUser.Id LIMIT 10];
            
            system.debug('Leads is null? ' + blLeads.isEmpty());
            
            if (blLeads.size() > 0) {
                pi__ObjectChangeLog__c ocl = createOCL(blLeads.get(0).Id, blLeads.get(0).OwnerId);
                
                system.debug('Lead id: ' + blLeads.get(0).Id);
                system.debug('Lead owner: ' + blLeads.get(0).OwnerId);
                system.debug('Owner before trigger fired: ' + ocl.ownerId);
                
                insert ocl;
                
                pi__ObjectChangeLog__c oclUpdated = [Select ownerId From pi__ObjectChangeLog__c Where id = :ocl.id];
                
                system.debug('Owner after trigger fired: ' + oclUpdated.ownerId);
                
                System.assertNotEquals(ocl.ownerId, oclUpdated.ownerId);
            }
        }
    }     
    
    public static testMethod void testDirectAssignSRObjectChangeLog() {
    
        //Get a lead
        system.debug('SeaRay lead record type id = ' + srLeadRecordType.Id);
        list<Lead> srLeads = [Select l.Id, l.Name, l.OwnerId From Lead l Where RecordTypeId = :srLeadRecordType.Id And l.OwnerId != :srPardotUser.Id LIMIT 10];
        
        system.debug('Leads size = ' + srLeads.size());
        
        if (srLeads.size() > 0) {
            pi__ObjectChangeLog__c ocl = new pi__ObjectChangeLog__c();
            
            ocl.pi__ObjectEmail__c = 'testlead@brunswickboatgroup.com';
            ocl.pi__ObjectFid__c = srLeads.get(0).Id;
            ocl.pi__ObjectState__c = 1;
            ocl.pi__ObjectType__c = 2;
            ocl.ownerId = srLeads.get(0).OwnerId;
            
            system.debug('Lead id: ' + srLeads.get(0).Id);
            system.debug('Lead owner: ' + srLeads.get(0).OwnerId);
            system.debug('Owner before assignment: ' + ocl.ownerId);
            
            PardotAssignment.assignToPardotOwner(new list<pi__ObjectChangeLog__c> {ocl}); 
            
            system.debug('Owner after assignment: ' + ocl.ownerId);
            
            System.assertNotEquals(ocl.ownerId, srLeads.get(0).OwnerId);
        }
    }
    
    public static testMethod void testNoPardotUserForAlias() {
    	System.assert(unknownUser == null);
    }    
	
}