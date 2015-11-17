public without sharing class AssignActivityToUser {
    public String success {get; set;}
    
    public void reassignActivity(){
        String recordID = ApexPages.CurrentPage().getParameters().get('id');
        String UserID = ApexPages.CurrentPage().getParameters().get('UserId');
        System.debug('RecordID: ' + recordID + ' OwnerID: ' + UserID);
        
        if(recordID != null && UserID != null){
            if(recordID.left(3) == '00T'){
                Task t = [SELECT id, OwnerID FROM Task WHERE id = :recordID LIMIT 1];
                t.OwnerID = UserID;
                update t;
                success = 'TRUE';
            }else if(recordID.left(3) == '00U'){
                Event e = [SELECT id, OwnerID FROM Event WHERE Id = :recordID Limit 1];
                e.OwnerID = UserID;
                update e;
                success = 'TRUE';
            }else{
                success = 'FALSE';
            }
        }
    }
}