@isTest 
private class moveCapProjControllerTest {
 static testMethod void moveCapProjController_test()
  {
      moveCapProjController cont=new moveCapProjController();
      cont.moveChatter();
      cont.moveAttachments();
      cont.moveNotes();
   }
   }