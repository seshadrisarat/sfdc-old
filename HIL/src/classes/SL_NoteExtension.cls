public with sharing class SL_NoteExtension
{

    //private final ApexPages.StandardController m_controller;
	//private Note__c m_note;
    public Note__c Note {get;set;}  
    public Note_Joiner__c UINoteJoiner {get;set;}
    private Set<Id> repcodeUserIDList;
    private  List<RelationshipGroupModel> RelatedRelationshipGroups {get;set;}
    public List<String> RelatedGroups {get;set;}
    
	public SL_NoteExtension()
    {
        Note = new Note__c();

        Note.OwnerId = UserInfo.getUserId();
        
        Note.Type__c = ApexPages.currentPage().getParameters().get('type');
        Note.Status__c = ApexPages.currentPage().getParameters().get('status');
        
        this.RelatedRelationshipGroups = new List<RelationshipGroupModel>();
        this.RelatedGroups = new  List<string>();
        
        Id lkupId = ApexPages.currentPage().getParameters().get('lkupId');
        
        if(lkupId != null)
        {
            Schema.SObjectType sObjType = lkupId.getSobjectType();
            
            if(sObjType == Schema.Account.SObjectType)
            {
                Note.Account_del__c = lkupId;
                populateRelatedGroups();
            }
            
            if(sObjType == Schema.Relationship_Group__c.SObjectType)
            {
                Note.Relationship_Group__c = lkupId;
                populateGroupMembers();
            }
        }
    }
    
    public List<Schema.FieldSetMember> getFields()
    {
        return SObjectType.Note__c.FieldSets.test.getFields();
    }
        
    
    public void populateGroupMembers()
    {
        Id relatedGroupId = Note.Relationship_Group__c;
        
        this.RelatedRelationshipGroups = new List<RelationshipGroupModel>();
        this.RelatedGroups = new  List<string>();
        
        /*Additional WHERE Filter, Rel_Group__r.Rep_Code__c IN: Set<RepCode_Ids>*/        
        List<Group_Member__c> groupMembers = [select Client_Prospect__r.Name,
                                                     Client_Prospect__c,
                                                     Relationship_Group__r.Rep_Code__c
                                                     From Group_Member__c
                                                     where Relationship_Group__c =: relatedGroupId];
		repcodeUserIDList = new Set<Id>();
        
        for (Group_Member__c member : groupMembers)
        {
            RelationshipGroupModel  model = new RelationshipGroupModel();
            
            repcodeUserIDList.add(member.Relationship_Group__r.Rep_Code__c);
            model.GroupName = member.Client_Prospect__r.Name;
            model.GroupID = member.Client_Prospect__c;
            
            this.RelatedGroups.add(member.Client_Prospect__c);
            this.RelatedRelationshipGroups.add(model);
        }
	}

	public void populateRelatedGroups()
    {
        Id relatedAccountId = Note.Account_del__c;
        
        this.RelatedRelationshipGroups = new List<RelationshipGroupModel>();
        this.RelatedGroups = new  List<string>();
        
        /*Query Rep_Code_User__c object to get Set<RepCode_Ids> current user belongs*/

        List<Rep_Code_User__c> repcodeUserList = [select Rep_Code__c from Rep_Code_User__c where User__c =: Note.OwnerId];
        repcodeUserIDList = new Set<Id>();
        
        for (Rep_Code_User__c reprecord: repcodeUserList)
        {
            repcodeUserIDList.add(reprecord.Rep_Code__c);
        }
        
        /*Additional WHERE Filter, Rel_Group__r.Rep_Code__c IN: Set<RepCode_Ids>*/        
        List<Group_Member__c> groupMembers = [select Relationship_Group__r.Name, Relationship_Group__c, Relationship_Group__r.Rep_Code__c from Group_Member__c where Client_Prospect__c =  :relatedAccountId  and  Relationship_Group__r.Rep_Code__c in :repcodeUserIDList];
		
        repcodeUserIDList.clear();
        
        for (Group_Member__c member : groupMembers)
        {
            RelationshipGroupModel  model = new RelationshipGroupModel();
            
            model.GroupName = member.Relationship_Group__r.Name;
            model.GroupID = member.Relationship_Group__c;
            
            this.RelatedGroups.add(member.Relationship_Group__c);
            this.RelatedRelationshipGroups.add(model);
            
            repcodeUserIDList.add(member.Relationship_Group__r.Rep_Code__c);
        }
	}
	
    public PageReference saveAndRedirect()
	{
    	if(Save())
        {
            if(Note.Account_del__c != null)
            {
                return new PageReference('/'+Note.Account_del__c);
            }
            
            if(Note.Relationship_Group__c != null)
            {
                return new PageReference('/'+Note.Relationship_Group__c);
            }
            
            return null;
    	}else 
    	{
        	return null;
    	}
	}
    
    public PageReference cancel()
    {
        if(Note.Account_del__c != null)
        {
            return new PageReference('/'+Note.Account_del__c);
        }
        
        if(Note.Relationship_Group__c != null)
        {
            return new PageReference('/'+Note.Relationship_Group__c);
        }
        
        return null;
    }

     public boolean Save()
     {
         boolean recordSaved = false;
         
         try
         {
            insert Note;

             Note_Joiner__c[] listNj = new Note_Joiner__c[]{};

             Note_Joiner__c firstNJ = new Note_Joiner__c();

             firstNJ.Client_Prospect__c = Note.Account_del__c;
             firstNJ.Relationship_Group__c = Note.Relationship_Group__c;
             firstNJ.Note__c = Note.Id;

             listNj.add(firstNJ);
                 
             for(String groupID : RelatedGroups)
             {
                 Note_Joiner__c oNotejoiner = new Note_Joiner__c();
                 oNotejoiner.Note__c = Note.Id;
                 
                 if(Note.Account_del__c != null)
                 {
                    oNotejoiner.Relationship_Group__c=groupID;
                 }
                 
                 if(Note.Relationship_Group__c != null)
                 {                    
                     oNotejoiner.Client_Prospect__c = groupId;
                 }
                 
                 listNj.add(oNotejoiner);
             }
             
             insert listNj;

             if(!Note.Private__c)
             {             
                 SL_Util_SharingController.RepCodeType[] shareList = new SL_Util_SharingController.RepCodeType[]{};
                     
                 for(Id i : repcodeUserIDList)
                 {
                     if(i != Note.OwnerId)
                     {
                     	shareList.add(new SL_Util_SharingController.RepCodeType(Note.Id,i));
                     }
                 }             
                 
                 insert SL_Util_SharingController.createSharingRecords(shareList, 'Edit');
             }
             
             recordSaved = true;
             
         }catch(DmlException ex)
         {
             ApexPages.addMessages(ex);
             recordSaved = false;
         }
         
         return recordSaved;
     }

	public void AccountPopulated()
 	{
    	populateRelatedGroups();
 	}
    
    public void GroupPopulated()
    {
        populateGroupMembers();
    }  

    public List<SelectOption> getRelatedRelationshipGroupsForView()
    {
        List<selectoption> options = new List<selectoption>();        

        for (RelationshipGroupModel a : RelatedRelationshipGroups) 
        {   
            options.add(new SelectOption(a.GroupID, a.GroupName));
        }             
                
        return options;          
    }

    public class RelationshipGroupModel
    {
        public RelationshipGroupModel(){}
        
        public boolean Include { get;set;}
        public String GroupName { get; set; }
        public String GroupID { get; set; }
    }
}