trigger AccountOwner on Account (before Insert, before Update) {

    // handle arbitrary number of opps
    for(Account x : Trigger.New){

        // check that owner is a user (not a queue)
        if( ((String)x.OwnerId).substring(0,3) == '005' ){
            x.User_Name__c = x.OwnerId;
        }
        else{
            // in case of Queue we clear out our copy field
            x.User_Name__c = null;
        }
    }

}