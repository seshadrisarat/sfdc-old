public without sharing class FileUploadController {
 
  String caseId = null;
  public Attachment a {
    get {
      if (a == null) a = new Attachment();
      return a;
    }
    set;
  }
  
  public CaseComment c {
    get {
      if (c == null) c = new CaseComment();
      return c;
    }
    set;
  }
  
  public FileUploadController(){
     caseId = ApexPages.currentPage().getParameters().get('caseId');
  }    
 
  public PageReference upload() {
    try {
      a.parentId = caseId;
      insert a;
      c.parentId = caseId;
      insert c;     
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      return null;
    } finally {
      a.body = null; 
      a= new Attachment();
      c.commentBody = null;
      c = new CaseComment();
    }
 
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
    return null;
  }
 
}