public with sharing class RECADealNoteExtension{

    Task MyTask = new Task();
    
    public RECADealNoteExtension(ApexPages.StandardController controller) {
        this.MyTask = (Task)controller.getRecord();
      
        MyTask.Status = 'Completed';
      
        if (MyTask.ActivityDate == NULL) {
            MyTask.ActivityDate = Date.today();
            }
        else { 
            MyTask.ActivityDate = MyTask.ActivityDate;
            }
    }
}