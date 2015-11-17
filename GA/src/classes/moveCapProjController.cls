public class moveCapProjController 
{
  private  Map<Id,Id> mWo=new Map<Id,Id>();
  
  public moveCapProjController()
  {
      List<Work_Order__c> lWo=[SELECT Id,Name,Capital_Project__c FROM Work_Order__c];
      
      for(Work_Order__c w : lWo)
      {
          mWo.put(w.Capital_Project__c,w.Id);
      }
  }
  
  public PageReference moveChatter()
  {     
      List<FeedItem> lF=[SELECT Id, type, parentId, createdDate, createdById, title, body, linkurl, relatedrecordid, contentdata,contentfilename, contentdescription FROM FeedItem WHERE type!='TrackedChange' AND parentId IN :mWo.keySet()];
      List<FeedItem> lFNew=new List<FeedItem>();
      
      for(FeedItem f : lF)
      {
          lFNew.add(new FeedItem(createdById=f.createdById, 
              parentId=mWo.get(f.parentId),
              createdDate=f.createdDate,
              type=f.type,
              title=f.title,
              body=f.body,
              linkurl=f.linkurl,
              //relatedrecordid=f.relatedrecordid, 
              contentdata=f.contentdata,
              contentfilename=f.contentfilename, 
              contentdescription=f.contentdescription
              ));
      }
      
      insert lFNew;
      
      return null;
  }

  public PageReference moveAttachments()
  {
      List<Attachment> lA=[SELECT Id, ParentId, name, IsPrivate, Body, OwnerId, CreatedDate, CreatedById, Description  FROM Attachment WHERE parentId IN :mWo.keySet()];
      List<Attachment> lANew=new List<Attachment>();
      
      for(Attachment a : lA)
      {
          lANew.add(new Attachment(
              parentId=mWo.get(a.parentId),
              Name=a.Name,
              IsPrivate=a.IsPrivate,
              Body=a.body,
              OwnerId=a.OwnerId,
              Description=a.Description
            ));
      }
      
      insert lANew;
      
      return null;
  }
  
  public PageReference moveNotes()
  {
      List<Note> lN=[SELECT Id, ParentId, Title, Body, OwnerId, CreatedDate, CreatedById FROM Note WHERE parentId IN :mWo.keySet()];
      List<Note> lNNew=new List<Note>();
      
      for(Note n : lN)
      {
          lNNew.add(new Note(
              parentId=mWo.get(n.parentId),
              title=n.title,
              Body=n.body,
              OwnerId=n.OwnerId
            ));
      }
      
      insert lNNew;
      
      return null;
  } 
  
  static testMethod void test()
  {
  	/*
      moveCapProjController cont=new moveCapProjController();
      cont.moveChatter();
      cont.moveAttachments();
      cont.moveNotes();
      */
  }
   
}