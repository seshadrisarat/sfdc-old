/**
* @ClassName    : SL_Test_GroupMemberHandler   
* @JIRATicket   : HIL-20
* @CreatedOn    : 22/July/2015
* @ModifiedBy   : Nrusingh
* @Description  : Test class for the SL_GroupMemberHandler Handler
*/  
@isTest
private class SL_Test_GroupMemberHandler 
{
    static testMethod void SL_Test_GroupMemberHandler() 
    {
    	List <Rep_Code__c> lstRepCode = new List <Rep_Code__c> { new Rep_Code__c(Name = 'testRep1', Rep_Code__c = '123'),
    												   			new Rep_Code__c(Name = 'testRep2', Rep_Code__c = '456'),
    												   			new Rep_Code__c(Name = 'testRep3', Rep_Code__c = '789')
    												 }; 
		insert lstRepCode;
		
		List <Rep_Code_User__c> lstRepCodeUser = new List <Rep_Code_User__c> { new Rep_Code_User__c(Name = 'testRepUser1', Rep_Code__c = lstRepCode[0].Id, User__c = userInfo.getUserId())
    												 }; 
		insert lstRepCodeUser;
		
    	List <Relationship_Group__c> lstRelationshipGrp = new List <Relationship_Group__c> { new Relationship_Group__c(Name = 'h1', Rep_Code__c = lstRepCode[0].Id),
    												   										new Relationship_Group__c(Name = 'h2', Rep_Code__c = lstRepCode[0].Id ),
    												   										new Relationship_Group__c(Name = 'h3', Rep_Code__c = lstRepCode[0].Id),
    												   										new Relationship_Group__c(Name = 'h4', Rep_Code__c = lstRepCode[0].Id),
    												   										new Relationship_Group__c(Name = 'h5'),
    												   										new Relationship_Group__c(Name = 'h6')
    												 										}; 
		insert lstRelationshipGrp;
		
    	
    	
   
    	
    	
    	
    	
    	List <Account> lstAcc = new List <Account> { new Account(FirstName = 'c', LastName='1'),
    												   new Account(FirstName = 'c', LastName='2'),
    												   new Account(FirstName = 'c', LastName='3'),
    												   new Account(FirstName = 'c', LastName='4'),
    												   new Account(FirstName = 'c', LastName='5'),
    												   new Account(FirstName = 'c', LastName='6')
    												 }; 
		insert lstAcc;
		
		
		
		
    	List <Note__c> lstNotes = new List <Note__c> { new Note__c(Subject_Text__c = 'N1'),
    												   new Note__c(Subject_Text__c= 'N2'),
    												   new Note__c(Subject_Text__c= 'N3'),
    												   new Note__c(Subject_Text__c= 'N4'),
    												   new Note__c(Subject_Text__c = 'N5'),
    												   new Note__c(Subject_Text__c = 'N7'),
    												   new Note__c(Subject_Text__c = 'N8'),
    												   new Note__c(Subject_Text__c = 'N9'),
    												   new Note__c(Subject_Text__c = 'N10'),
    												   new Note__c(Subject_Text__c = 'N11'),
    												   new Note__c(Subject_Text__c = 'N12'),
    												   new Note__c(Subject_Text__c = 'N13'),
    												   new Note__c(Subject_Text__c = 'N14'),
    												   new Note__c(Subject_Text__c = 'N15'),
    												   new Note__c(Subject_Text__c = 'N16')
    												 }; 
		insert lstNotes;
		
		List <Note_Joiner__c> lstNoteJoiners = new List <Note_Joiner__c> { new Note_Joiner__c(Note__c = lstNotes[0].Id,  Client_Prospect__c = lstAcc[0].Id),
    												   new Note_Joiner__c(Note__c = lstNotes[1].Id,Client_Prospect__c = lstAcc[1].Id),
    												   new Note_Joiner__c(Note__c = lstNotes[2].Id,Client_Prospect__c = lstAcc[2].Id),
    												   new Note_Joiner__c(Note__c = lstNotes[3].Id,Client_Prospect__c = lstAcc[3].Id),
    												   new Note_Joiner__c(Note__c = lstNotes[4].Id,Client_Prospect__c = lstAcc[3].Id),
    												   new Note_Joiner__c(Note__c = lstNotes[5].Id,Client_Prospect__c = lstAcc[3].Id),
    												   new Note_Joiner__c(Note__c = lstNotes[6].Id,Client_Prospect__c = lstAcc[0].Id)
    												 }; 
		insert lstNoteJoiners;
		
		List <Group_Member__c> lstGrpMembers = new List <Group_Member__c> { new Group_Member__c(Client_Prospect__c = lstAcc[0].Id, Relationship_Group__c=lstRelationshipGrp[0].Id),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[1].Id, Relationship_Group__c=lstRelationshipGrp[0].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[2].Id, Relationship_Group__c=lstRelationshipGrp[0].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[0].Id, Relationship_Group__c=lstRelationshipGrp[1].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[1].Id, Relationship_Group__c=lstRelationshipGrp[1].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[2].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[0].Id, Relationship_Group__c=lstRelationshipGrp[4].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[1].Id, Relationship_Group__c=lstRelationshipGrp[5].ID),
    												   
    												   new Group_Member__c(Client_Prospect__c = lstAcc[3].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),
    												   new Group_Member__c(Client_Prospect__c = lstAcc[3].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),  
    												   new Group_Member__c(Client_Prospect__c = lstAcc[3].Id, Relationship_Group__c=lstRelationshipGrp[3].ID)
    												 };
    	insert lstGrpMembers;
		
		Set <Id> SetCreatedNotesId1 = new Set <Id> ();
		Set <Id> SetCreatedNotesId2 = new Set <Id> (); 
		Set <Id> SetCreatedNotesId3 = new Set <Id> (); 
		
		List <Note_Joiner__c> lstNoteJoierTobeCreated = new List <Note_Joiner__c>();
		List <Note_Joiner__c> lstNoteJoierTobeCreated2 = new List <Note_Joiner__c>();
		List <Note_Joiner__c> lstNoteJoierTobeCreated3 = new List <Note_Joiner__c>();
		List <Note_Joiner__c> lstNoteJoierTobeCreated4 = new List <Note_Joiner__c>();
		 
		for(Note_Joiner__c objNote_Joiner : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[0].Id
											])
		{
			SetCreatedNotesId1.add(objNote_Joiner.Note__c);
			lstNoteJoierTobeCreated.add(objNote_Joiner);
		}
		
		for(Note_Joiner__c objNote_Joiner2 : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[1].Id
											])
		{
			SetCreatedNotesId2.add(objNote_Joiner2.Note__c);
			lstNoteJoierTobeCreated2.add(objNote_Joiner2);
		}
		
		for(Note_Joiner__c objNote_Joiner3 : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[3].Id
											])
		{
			SetCreatedNotesId3.add(objNote_Joiner3.Note__c);
			lstNoteJoierTobeCreated3.add(objNote_Joiner3);
		}
		
		for(Note_Joiner__c objNote_Joiner4 : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[4].Id
											])
		{
			lstNoteJoierTobeCreated4.add(objNote_Joiner4);
		}
		
		system.assertEquals(lstNoteJoierTobeCreated4.size(), 0);
		
		system.assertEquals(lstNoteJoierTobeCreated.size(), 4);
		system.assertEquals(SetCreatedNotesId1.contains(lstNotes[0].Id), true);
		system.assertEquals(SetCreatedNotesId1.contains(lstNotes[6].Id), true);
		system.assertEquals(SetCreatedNotesId1.contains(lstNotes[1].Id), true);
		system.assertEquals(SetCreatedNotesId1.contains(lstNotes[2].Id), true);
		
		system.assertEquals(lstNoteJoierTobeCreated3.size(), 4);
		system.assertEquals(SetCreatedNotesId3.contains(lstNotes[3].Id), true);
		system.assertEquals(SetCreatedNotesId3.contains(lstNotes[4].Id), true);
		system.assertEquals(SetCreatedNotesId3.contains(lstNotes[5].Id), true);
		
		system.assertEquals(lstNoteJoierTobeCreated2.size(), 3);
		system.assertEquals(SetCreatedNotesId2.contains(lstNotes[0].Id), true);
		system.assertEquals(SetCreatedNotesId2.contains(lstNotes[1].Id), true);
		system.assertEquals(SetCreatedNotesId2.contains(lstNotes[6].Id), true);
		
		List <Group_Member__c> lstUpdateGrpMembers = new List <Group_Member__c> { new Group_Member__c( Id = lstGrpMembers[0].Id, Relationship_Group__c=lstRelationshipGrp[1].Id),
    												   new Group_Member__c(Id = lstGrpMembers[1].Id, Relationship_Group__c=lstRelationshipGrp[1].ID),
    												   new Group_Member__c(Id = lstGrpMembers[2].Id, Relationship_Group__c=lstRelationshipGrp[1].ID),
    												   new Group_Member__c(Id = lstGrpMembers[5].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),
    												   new Group_Member__c(Id = lstGrpMembers[8].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),
    												   new Group_Member__c(Id = lstGrpMembers[9].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),  
    												   new Group_Member__c(Id = lstGrpMembers[10].Id, Relationship_Group__c=lstRelationshipGrp[3].ID),
    												   new Group_Member__c(Id = lstGrpMembers[6].Id, Relationship_Group__c=lstRelationshipGrp[4].ID),
    												   new Group_Member__c(Id = lstGrpMembers[7].Id, Relationship_Group__c=lstRelationshipGrp[5].ID)
    												   
													};
		update lstUpdateGrpMembers;										
		
		
		Set <Id> SetUpdatedNotesId1 = new Set <Id> ();
		Set <Id> SetUpdatedNotesId2 = new Set <Id> ();
		Set <Id> SetUpdatedNotesId3 = new Set <Id> (); 
		Set <Id> SetUpdatedNotesId4 = new Set <Id> (); 
		
		List <Note_Joiner__c> lstNoteJoierTobeUpdated1 = new List <Note_Joiner__c>();
		List <Note_Joiner__c> lstNoteJoierTobeUpdated2 = new List <Note_Joiner__c>();
		List <Note_Joiner__c> lstNoteJoierTobeUpdated3 = new List <Note_Joiner__c>();
		List <Note_Joiner__c> lstNoteJoierTobeUpdated4 = new List <Note_Joiner__c>();
		
		
		for(Note_Joiner__c objNote_Joiner : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[0].Id
											])
		{
			SetUpdatedNotesId1.add(objNote_Joiner.Note__c);
			lstNoteJoierTobeUpdated1.add(objNote_Joiner);
		}
		
		for(Note_Joiner__c objNote_Joiner : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[1].Id
											])
		{
			SetUpdatedNotesId2.add(objNote_Joiner.Note__c);
			lstNoteJoierTobeUpdated2.add(objNote_Joiner);
		}
		
		//system.assertEquals(SetUpdatedNotesId2.size(),4);
		//system.assertEquals(SetUpdatedNotesId1.size(),0);
		
		for(Note_Joiner__c objNote_Joiner : [SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId 
												 FROM Note_Joiner__c
												 WHERE Relationship_Group__c=:lstRelationshipGrp[3].Id
											])
		{
			SetUpdatedNotesId3.add(objNote_Joiner.Note__c);
			lstNoteJoierTobeUpdated3.add(objNote_Joiner);
		}
		
		Delete lstUpdateGrpMembers;
		
		test.starttest();
		List <Financial_Account__c> lstFAcc = new List <Financial_Account__c> { new Financial_Account__c(Name = '1', Rep_Code__c = lstRepCode[0].Id),
    												   new Financial_Account__c(Name='2', Rep_Code__c = lstRepCode[1].Id),
    												   new Financial_Account__c(Name='3', Rep_Code__c = lstRepCode[0].Id),
    												   new Financial_Account__c(Name='4', Rep_Code__c = lstRepCode[1].Id),
    												   new Financial_Account__c(Name='5', Rep_Code__c = lstRepCode[0].Id),
    												   new Financial_Account__c(Name='6', Rep_Code__c = lstRepCode[1].Id)
    												 }; 
    	
    	
    	insert lstFAcc;
    	
    	
    	Group_Account__c obj = new Group_Account__c(Financial_Account__c = lstFAcc[0].Id, Relationship_Group__c = lstRelationshipGrp[0].Id);
		
		insert obj;
		
		List <Hilliard_Lyons_Account__c> lstHL = new List <Hilliard_Lyons_Account__c>{ new Hilliard_Lyons_Account__c(Client__c =lstAcc[0].Id, Financial_Account__c = lstFAcc[0].Id ),
    																				 new Hilliard_Lyons_Account__c(Client__c =lstAcc[1].Id, Financial_Account__c = lstFAcc[1].Id),
    																				 new Hilliard_Lyons_Account__c(Client__c =lstAcc[2].Id, Financial_Account__c = lstFAcc[2].Id)
    																				 
    																				}; 
    	insert lstHL;
		test.stoptest();
		
		lstRelationshipGrp[0].Rep_Code__c = lstRepCode[1].Id;
		update lstRelationshipGrp;
    }
}