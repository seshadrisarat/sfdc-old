public class uploadfilecontroller {

    public document document {
    get {
      if (document == null)
        document = new document ();
      return document;
    }
    set;
  }
  public void upload()
  {
     document.AuthorId = UserInfo.getUserId();
     document.FolderId = UserInfo.getUserId();  
     
     try {
      insert document;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      
    } finally {
      if(document.id!=null)
      ExpenseTrackerEditPageController.documentid=document.id;
      document.body = null; // clears the viewstate
      document = new Document();
    }
   ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
   system.debug('documentid:'+ExpenseTrackerEditPageController.documentid );
    
  }
}