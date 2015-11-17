/**
* \arg ClassName      : SL_Test_MappingTrigger_Handler
* \arg JIRATicket     : FAEF-4
* \arg CreatedOn      : 10/09/2013
* \arg CreatedBy      : Rahul
* \arg ModifiedBy     : -
* \arg Description    : This is test class for SL_MappingTrigger_Handler.
*/

@isTest
private class SL_Test_MappingTrigger_Handler 
{
    static testMethod void TestMappingTriggerHandlerPositiveCase() 
    {
        // Get a list of field mappings for easy insertion later.
        // Also get all the record types we might need.
        List<Field_Mapping__c> lstFM = new List<Field_Mapping__c>();
        RecordType recTypeDirectAssoc  = [Select Id,DeveloperName from RecordType where DeveloperName = 'Direct_Association' limit 1];
        RecordType recTypeRelatedList = [Select Id,DeveloperName from RecordType where DeveloperName = 'Related_List' limit 1];
        RecordType recTypeReference = [Select Id,DeveloperName from RecordType where DeveloperName = 'Reference' limit 1];
        RecordType recTypeValue = [Select Id,DeveloperName from RecordType where DeveloperName = 'Value' limit 1];

        // Create a custom Mapping for Oppty;
        Custom_Mapping__c objCustomMapping = new Custom_Mapping__c(Sobject_API_Name__c = 'Opportunity');
        insert objCustomMapping;

        User objUser = new User(Alias = 'faef', 
				                Email='faef1@salesforce.com',
				                EmailEncodingKey='UTF-8', 
				                LastName='Test1',   
				                LanguageLocaleKey='en_US',
				                LocaleSidKey='en_US', 
				                ProfileId = [SELECT Id FROM Profile WHERE Name=:'Operations - Marketing'].Id, 
				                TimeZoneSidKey='America/Los_Angeles',
				                isActive = true,
				                UserName='faef3@salesforce.com');
        insert objUser;
       
        // Create an object relationship from oppty to LOI.
        Object_Relationship__c objObjectRelationship = new Object_Relationship__c(Name  = 'Object Relationship 1', Order__c = 1, Custom_Mapping__c = objCustomMapping.Id
                                                         , RecordTypeId = recTypeDirectAssoc.Id, Context_Object_API__c = 'Opportunity'
                                                         , Target_Object_API__c = 'Letter_of_Intent__c', Target_Relationship_Id__c = 'Opportunity__c'
                                                         , Context_Relationship_Id__c = 'Id', Copy_Notes__c = true, Copy_Attachments__c = true,Copy_Sharing_Rules__c = true);
        insert objObjectRelationship;

        // Create 2 field mappings for Oppty-LOI.
        // One is reference, one is value.        
        Field_Mapping__c objFieldMapping = new Field_Mapping__c(Active__c = true , Context_Field_Name__c = 'Equipment_Detail_Purpose__c',RecordTypeId = recTypeReference.Id,
                                                                Target_Field_Name__c = 'Latest_Note__c' , Object_Relationship__c = objObjectRelationship.Id);
        Field_Mapping__c objFieldMapping1 = new Field_Mapping__c(Active__c = true , Target_Field_Name__c = 'Status__c',RecordTypeId = recTypeValue.Id,
                                                                Target_Value__c = '123' , Object_Relationship__c = objObjectRelationship.Id);

        Field_Mapping__c objFieldMapping8 = new Field_Mapping__c(Active__c = true , Target_Field_Name__c = 'Legacy_Award_LOI_Date__c',RecordTypeId = recTypeReference.Id,
                                                                Context_Field_Name__c = 'CloseDate' , Object_Relationship__c = objObjectRelationship.Id);
        
        
        // Create an object relationship from oppty to schedule.
        Object_Relationship__c objObjectRelationship2 = new Object_Relationship__c(Name  = 'Object Relationship 2', Order__c = 2, Custom_Mapping__c = objCustomMapping.Id
                                                         , RecordTypeId = recTypeDirectAssoc.Id, Context_Object_API__c = 'Opportunity'
                                                         , Target_Object_API__c = 'Schedule__c', Target_Relationship_Id__c = 'Letter_of_Intent__r.Opportunity__c'
                                                         , Context_Relationship_Id__c = 'Id', Parent_Object_Relationship__c = objObjectRelationship.Id);
        insert objObjectRelationship2;
        
        // Create some field mappings from oppty-schedule.
        // One is reference, one is value.
        Field_Mapping__c objFieldMapping2 = new Field_Mapping__c(Active__c = true , Context_Field_Name__c = 'Equipment_Detail_Purpose__c',RecordTypeId = recTypeReference.Id,
                                                                Target_Field_Name__c = 'Latest_Note__c' , Object_Relationship__c = objObjectRelationship2.Id);
        Field_Mapping__c objFieldMapping3 = new Field_Mapping__c(Active__c = true , Target_Field_Name__c = 'Referral_Code__c',RecordTypeId = recTypeValue.Id,
                                                                Target_Value__c = '12345' , Object_Relationship__c = objObjectRelationship2.Id);



        // Create an object relationship from oppty to team member on schedule.
        Object_Relationship__c objObjectRelationship3 = new Object_Relationship__c(Name  = 'Object Relationship 3', Order__c = 3, Custom_Mapping__c = objCustomMapping.Id
                                                         , RecordTypeId = recTypeRelatedList.Id, Context_Object_API__c = 'Opportunity'
                                                         , Target_Object_API__c = 'Team_Member__c', Target_Relationship_Id__c = 'Schedule__r.Letter_of_Intent__r.Opportunity__r.Id'
                                                         , Context_Relationship_Id__c = 'OpportunityContactRole', Related_Record_Parent_Id__c = 'OpportunityId'
                                                         , Parent_Object_Relationship__c = objObjectRelationship2.Id, Copy_Notes__c = true, Copy_Attachments__c = true);
        insert objObjectRelationship3;
        
        // Create field mappings for team members.
        Field_Mapping__c objFieldMapping4 = new Field_Mapping__c(Active__c = true , Context_Field_Name__c = 'ContactId',RecordTypeId = recTypeReference.Id,
                                                                Target_Field_Name__c = 'Contact__c' ,Object_Relationship__c = objObjectRelationship3.Id);
        Field_Mapping__c objFieldMapping5 = new Field_Mapping__c(Active__c = true , Target_Field_Name__c = 'Role__c',RecordTypeId = recTypeValue.Id,
                                                                Target_Value__c = 'Internal Auditor' , Object_Relationship__c = objObjectRelationship3.Id);
        
        // create an object relationship from oppty
        Object_Relationship__c objObjectRelationship4 = new Object_Relationship__c(Name  = 'Object Relationship 4', Order__c = 4, Custom_Mapping__c = objCustomMapping.Id
                                                         , RecordTypeId = recTypeDirectAssoc.Id, Context_Object_API__c = 'Opportunity',
                                                         Target_Object_API__c = 'Funding_Source__c', Target_Relationship_Id__c = 'Letter_of_Intent__r.Opportunity__r.Id'
                                                         , Context_Relationship_Id__c = 'Id',
                                                          Parent_Object_Relationship__c = objObjectRelationship.Id);
        /// insert Object_Relationship__c
        insert objObjectRelationship4;
        
        Field_Mapping__c objFieldMapping6 = new Field_Mapping__c(Active__c = true , Context_Field_Name__c = 'Latest_Note__c',RecordTypeId = recTypeReference.Id,
                                                                Target_Field_Name__c = 'Collateral__c' ,Object_Relationship__c = objObjectRelationship4.Id);
        Field_Mapping__c objFieldMapping7 = new Field_Mapping__c(Active__c = true , Target_Field_Name__c = 'Status__c',RecordTypeId = recTypeValue.Id,
                                                                Target_Value__c = 'Not Submitted Yet' , Object_Relationship__c = objObjectRelationship4.Id);

        // add all the field mappings to the list and insert all field mappings.
        lstFM.add(objFieldMapping);
        lstFM.add(objFieldMapping1);
        lstFM.add(objFieldMapping2);
        lstFM.add(objFieldMapping3);
        lstFM.add(objFieldMapping4);
        lstFM.add(objFieldMapping5);
        lstFM.add(objFieldMapping6);
        lstFM.add(objFieldMapping7);
        lstFM.add(objFieldMapping8);
        insert lstFM;

        /////////////////////////////////////////
        // Done setting up custom mapping data.//
        // Actual Test setup is below.         //
        /////////////////////////////////////////
        
        List<Opportunity> lstOpportunity = new List<Opportunity>(); /// create a list to store Opportunities to insert
        
        Account objAccount = new Account(Name = 'Test Account');
        /// insert account
        insert objAccount; 
        
        Opportunity objOpportunity1 = new Opportunity(Name = 'Test Opportunity 1', AccountId = objAccount.Id , StageName = 'Lost', CloseDate = system.today()
                                                       ,Equipment_Detail_Purpose__c = 'Test Detail-01', Opp_Is_Approved__c = false, Amount = 50000);
        Opportunity objOpportunity2 = new Opportunity(Name = 'Test Opportunity 2', AccountId = objAccount.Id , StageName = 'Lost', CloseDate = system.today()
                                                       ,Equipment_Detail_Purpose__c = 'Test Detail-02', Opp_Is_Approved__c = false, Amount = 100000);
		Opportunity objOpportunity3 = new Opportunity(Name = 'Test Opportunity 2', AccountId = objAccount.Id , StageName = 'Approved', CloseDate = system.today()
                                                       ,Equipment_Detail_Purpose__c = 'Test Detail-02', Opp_Is_Approved__c = true, Amount = 100000);                                                       

        // Add opptys to the list and insert it.
        lstOpportunity.add(objOpportunity1);
        lstOpportunity.add(objOpportunity2);
        lstOpportunity.add(objOpportunity3);
        insert lstOpportunity;
        
		List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>{
																					new OpportunityShare(UserOrGroupId = objUser.Id, OpportunityId = lstOpportunity[0].Id, OpportunityAccessLevel = 'Edit'),
																					new OpportunityShare(UserOrGroupId = objUser.Id, OpportunityId = lstOpportunity[1].Id, OpportunityAccessLevel = 'Edit')
																			   };
		insert lstOpportunityShare;
        
        // Create a contact and create an oppty contact role for each of the opptys'
        // insert all the oppty contact roles.
        Contact objContact = new Contact(LastName = 'Contact-01');
        insert  objContact;
        
        List<OpportunityContactRole> lstOCR = new List<OpportunityContactRole>{
                    new OpportunityContactRole(ContactId = objContact.Id, OpportunityId = objOpportunity1.Id, Role = 'Decision Maker'),
                    new OpportunityContactRole(ContactId = objContact.Id, OpportunityId = objOpportunity1.Id, Role = 'Decision Maker'),
                    new OpportunityContactRole(ContactId = objContact.Id, OpportunityId = objOpportunity2.Id, Role = 'Decision Maker'),
                    new OpportunityContactRole(ContactId = objContact.Id, OpportunityId = objOpportunity2.Id, Role = 'Decision Maker')                  
        };
        insert lstOCR;

        // Create some attachments and notes for the oppties
        Attachment attachment = new Attachment(ParentId = lstOpportunity[0].Id, Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment', ContentType = 'txt');
        Attachment attachment1 = new Attachment(ParentId = lstOpportunity[1].Id, Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment', ContentType = 'txt');
        insert attachment;
        insert attachment1;
        
        Note note = new Note(Title='Test Note', Body = 'Test Body ',ParentId = lstOpportunity[0].Id);
        Note note1 = new Note(Title='Test Note', Body = 'Test Body ',ParentId = lstOpportunity[1].Id);
        insert note;
        insert note1;
        
        lstOpportunity[0].StageName = 'Approved';
        lstOpportunity[0].Opp_Is_Approved__c = true;
        lstOpportunity[1].StageName = 'Approved';
        lstOpportunity[1].Opp_Is_Approved__c = true;
        Test.startTest();
        update lstOpportunity;
        Test.stopTest();
        //System.assertEquals(objOpportunity1.Id,null);
        //System.assertEquals(2,[SELECT Id FROM Letter_of_Intent__c ].Size());
        //System.assertEquals('Test Detail-01', [SELECT Id, Latest_Note__c FROM Letter_of_Intent__c WHERE Opportunity__c =: objOpportunity1.Id LIMIT 1].Latest_Note__c);
        //System.assertEquals('Test Detail-01', [SELECT Id, Latest_Note__c FROM Letter_of_Intent__c WHERE Opportunity__c =: objOpportunity2.Id LIMIT 1].Latest_Note__c);
        //System.assertEquals(4,[SELECT Id FROM Team_Member__c ].Size());
    } 
    
    
    static testMethod void TestMappingTriggerHandlerNegativeCase() 
    {
        Custom_Mapping__c objCustomMapping = new Custom_Mapping__c(Sobject_API_Name__c = 'Opportunity');
        /// insert Custom_Mapping__c record with Sobject_API_Name__c as Opportunity
        insert objCustomMapping;
        
        RecordType recTypeDirectAssoc = [Select Id,DeveloperName from RecordType where DeveloperName = 'Direct_Association' limit 1];
        RecordType recTypeReference = [Select Id,DeveloperName from RecordType where DeveloperName = 'Reference' limit 1];
        
        Object_Relationship__c objObjectRelationship = new Object_Relationship__c(Name  = 'Object Relationship 1', Order__c = 1, Custom_Mapping__c = objCustomMapping.Id
                                                         , RecordTypeId = recTypeDirectAssoc.Id, Context_Object_API__c = 'Opportunity',
                                                         Target_Object_API__c = 'Letter_of_Intent__c', Target_Relationship_Id__c = 'Opportunity__c'
                                                         , Context_Relationship_Id__c = 'Id', Copy_Notes__c = true, Copy_Attachments__c = true);
        /// insert Object_Relationship__c
        insert objObjectRelationship;
        
        Field_Mapping__c objFieldMapping = new Field_Mapping__c(Active__c = true , Context_Field_Name__c = 'Equipment_Detail_Purpose__c',RecordTypeId = recTypeReference.Id,
                                          Target_Field_Name__c = 'Latest_Note__c' ,Object_Relationship__c = objObjectRelationship.Id);
        /// insert Field_Mapping__c
        insert objFieldMapping;
        
        List<Opportunity> lstOpportunity = new List<Opportunity>(); /// create a list to store Opportunities to insert
        
        Account objAccount = new Account(Name = 'Test Account');
        /// insert account
        insert objAccount; 
        
        
        Opportunity objOpportunity1 = new Opportunity(Name = 'Test Opportunity 1', AccountId = objAccount.Id , StageName = 'Approved', CloseDate = system.today(), 
                                           Equipment_Detail_Purpose__c = '123', Opp_Is_Approved__c = true);
        lstOpportunity.add(objOpportunity1);
                
        Opportunity objOpportunity2 = new Opportunity(Name = 'Test Opportunity 2', AccountId = objAccount.Id , StageName = 'Lost', CloseDate = system.today()
                                            ,Equipment_Detail_Purpose__c = '123',  Opp_Is_Approved__c = false);
        lstOpportunity.add(objOpportunity2);
        /// insert Opportunity records
        insert lstOpportunity;
        lstOpportunity[1].StageName = 'Approved';
        lstOpportunity[1].Opp_Is_Approved__c = true;
        update lstOpportunity;
        //System.assertEquals([SELECT Id, Latest_Note__c FROM Letter_of_Intent__c ].Size(),1);
    }
}