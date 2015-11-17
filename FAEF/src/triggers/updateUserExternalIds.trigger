trigger updateUserExternalIds on User (before insert, before update) {
    
    //Copy alias and extension fields to text fields for boomi external use
    for(User u : Trigger.New){
        if(u.External_Alias__c != null && u.External_Alias__c != u.Alias){
            //Do Nothing
        }else{
            u.External_Extension__c = u.Extension;
            
            String shortExternalAlias = null;
            
            if(u.External_Alias__c != null){
                shortExternalAlias = u.External_Alias__c.Left(8);
            }else{
                shortExternalAlias = '';   
            }
            
            if(u.Alias != shortExternalAlias || u.External_Alias__c == null){
                u.External_Alias__c = u.Alias;
            }
         }
    }
    
}