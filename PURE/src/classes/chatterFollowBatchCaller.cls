public with sharing class chatterFollowBatchCaller {
    
    public String followRule {get;set;}
    
    public Id followList {get;set;}
    
    public Chatter_Follow_Rules__c chatterSetting = new Chatter_Follow_Rules__c();
    
    public List<Chatter_Follow_List__c> chatterLists = new List<Chatter_Follow_List__c>();
    
    public List<SelectOption> getRules() { 
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Department','Department')); 
        options.add(new SelectOption('Division','Division')); 
       // options.add(new SelectOption('Everyone','Everyone')); 
        options.add(new SelectOption('Hierarchy','Hierarchy')); 
        options.add(new SelectOption('Profile','Profile')); 
        options.add(new SelectOption('Role','Role')); 
        options.add(new SelectOption('Team','Team'));       
        return options; 
    }
    
    public List<SelectOption> getLists() { 
        
        chatterLists = [Select c.RecordType.Name, c.RecordTypeId, c.Name, c.Id From Chatter_Follow_List__c c];
        
        List<SelectOption> options = new List<SelectOption>(); 
        
        for(Chatter_Follow_List__c thisfollowlist : chatterLists){
            options.add(new SelectOption(thisfollowlist.Id,thisfollowlist.Name));
        }
            
        return options; 
    }
    
    public chatterFollowBatchCaller() {
        
    }
    
    public Chatter_Follow_Rules__c getChatterSetting (){
        //List<Chatter_Follow_Rules__c> thisSettingList = [select id,Follow_Team__c, Follow_Everyone__c, Follow_Role__c, Follow_Profile__c, Follow_Department__c, Follow_Division__c, Follow_Manager_Hierarchy__c from Chatter_Follow_Rules__c where setupownerid=:UserInfo.getOrganizationId()];
        List<Chatter_Follow_Rules__c> thisSettingList = [select id,Follow_Team__c, Follow_Role__c, Follow_Profile__c, Follow_Department__c, Follow_Division__c, Follow_Manager_Hierarchy__c from Chatter_Follow_Rules__c where setupownerid=:UserInfo.getOrganizationId()];
        
        if (thisSettingList.size()==0){
            chatterSetting = new Chatter_Follow_Rules__c();
        } else {
            chatterSetting = thisSettingList[0];
        }
        
        return chatterSetting;
    }
    
    public void setChatterSetting (Chatter_Follow_Rules__c myrules){
        chatterSetting = myrules;
        
    }
    
    public void updateSettings(){
        if (chatterSetting.Id==null){
            insert chatterSetting;
        } else {
            update chatterSetting;
        }
        
        showInfoMsg('Chatter Follow Rules updated');
    }
    
    public List<Chatter_Follow_List__c> getChatterLists (){
        chatterLists = [Select c.RecordType.Name, c.RecordTypeId, c.Name, c.Id From Chatter_Follow_List__c c];
        
        return chatterLists; 
    }
    
    public void callChatterFollowBatch(){
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 

        if(Test.isRunningTest())
            chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true LIMIT 5';     
        else
            chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = followRule;

        Id batchprocessid = Database.executeBatch(chatterBatch, 50);
        
        if(followRule=='Department'){
            chatterSetting.Follow_Department__c = true;
        } else if(followRule=='Division'){
            chatterSetting.Follow_Division__c = true;
       /* } else if(followRule=='Everyone'){
            chatterSetting.Follow_Everyone__c = true;
            chatterSetting.Follow_Department__c = false;
            chatterSetting.Follow_Division__c = false;
            chatterSetting.Follow_Manager_Hierarchy__c = false;
            chatterSetting.Follow_Profile__c = false;
            chatterSetting.Follow_Role__c = false;
            chatterSetting.Follow_Team__c = false;*/
        } else if(followRule=='Hierarchy'){
            chatterSetting.Follow_Manager_Hierarchy__c = true;
        } else if(followRule=='Profile'){
            chatterSetting.Follow_Profile__c = true;
        } else if(followRule=='Role'){
            chatterSetting.Follow_Role__c = true;
        } else if(followRule=='Team'){
            chatterSetting.Follow_Team__c = true;
        }
        update chatterSetting;
        showInfoMsg('Chatter Follow Rule applied and Rules updated');
    }
    
    public void callChatterListBatch(){
        chatterFollowListBatch chatterBatch = new chatterFollowListBatch(); 

        if(Test.isRunningTest())
            chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true LIMIT 5'; 
        else
            chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true';

        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followList = followList;
        Id batchprocessid = Database.executeBatch(chatterBatch);
          
        showInfoMsg('Chatter Follow List applied');
    }
    
    private void showInfoMsg(String arg){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, arg);
        ApexPages.addMessage(myMsg);  
    }
    
    static testMethod void testchatterFollowBatchCaller_callChatterFollowBatch() {
        chatterFollowBatchCaller mychatterFollowBatchCaller = new chatterFollowBatchCaller();
        
        mychatterFollowBatchCaller.getRules();
        mychatterFollowBatchCaller.getLists();
        mychatterFollowBatchCaller.getChatterSetting();
        mychatterFollowBatchCaller.setChatterSetting (mychatterFollowBatchCaller.getChatterSetting());
        mychatterFollowBatchCaller.updateSettings();
        mychatterFollowBatchCaller.getChatterLists();
        
        mychatterFollowBatchCaller.followRule = 'Hierarchy';
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Chatter_Follow_List__c; 
        Map<String,Schema.RecordTypeInfo> chatterRulesRTMap = cfrSchema.getRecordTypeInfosByName();
        
        List<Chatter_Follow_List__c> existingRules = [select id from Chatter_Follow_List__c];
        delete existingRules;
        
        User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        List<User> usersforCreation = new List<User>();
            
        User user1 = new User();
        user1.FirstName = 'Joe';
        user1.LastName = 'smith';
        user1.ProfileId = thisUser.ProfileId;
        user1.LocaleSidKey = thisUser.LocaleSidKey;
        user1.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user1.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user1.EmailEncodingKey = thisUser.EmailEncodingKey;
        user1.alias = 'user1';
        user1.username = 'user1@adfjkluiopasfuioasjijklasdfjlajio.com';
        user1.CommunityNickname = 'user1adfjkluiopasfuioasjijklasdfjlajio';
        user1.email = 'user1@email.com';
        insert user1;
                
        Chatter_Follow_List__c bigwigs = new Chatter_Follow_List__c();
        bigwigs.Name = 'bigwigs';
        bigwigs.RecordTypeId = chatterRulesRTMap.get('Everyone Follows List').getRecordTypeId();
        insert bigwigs;
        
        Chatter_List_User__c bigWig = new Chatter_List_User__c();
        bigWig.Chatter_Follow_List__c = bigwigs.id;
        bigWig.User__c = user1.id;
        insert bigWig;
        
        mychatterFollowBatchCaller.followList = bigwigs.Id;
        
        Test.StartTest();
        mychatterFollowBatchCaller.callChatterFollowBatch();
        //mychatterFollowBatchCaller.callChatterListBatch();
        Test.StopTest();
        
        List<EntitySubscription> afterFollows = [select id from EntitySubscription where parentId = :user1.id];
        //system.assert(afterFollows.size()>0);
    }

    static testMethod void testchatterFollowBatchCaller_callChatterListBatch() {
        chatterFollowBatchCaller mychatterFollowBatchCaller = new chatterFollowBatchCaller();
        
        mychatterFollowBatchCaller.getRules();
        mychatterFollowBatchCaller.getLists();
        mychatterFollowBatchCaller.getChatterSetting();
        mychatterFollowBatchCaller.setChatterSetting (mychatterFollowBatchCaller.getChatterSetting());
        mychatterFollowBatchCaller.updateSettings();
        mychatterFollowBatchCaller.getChatterLists();
        
        mychatterFollowBatchCaller.followRule = 'Hierarchy';
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Chatter_Follow_List__c; 
        Map<String,Schema.RecordTypeInfo> chatterRulesRTMap = cfrSchema.getRecordTypeInfosByName();
        
        List<Chatter_Follow_List__c> existingRules = [select id from Chatter_Follow_List__c];
        delete existingRules;
        
        User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        List<User> usersforCreation = new List<User>();
            
        User user1 = new User();
        user1.FirstName = 'Joe';
        user1.LastName = 'smith';
        user1.ProfileId = thisUser.ProfileId;
        user1.LocaleSidKey = thisUser.LocaleSidKey;
        user1.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user1.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user1.EmailEncodingKey = thisUser.EmailEncodingKey;
        user1.alias = 'user1';
        user1.username = 'user1@adfjkluiopasfuioasjijklasdfjlajio.com';
        user1.CommunityNickname = 'user1adfjkluiopasfuioasjijklasdfjlajio';
        user1.email = 'user1@email.com';
        insert user1;
                
        Chatter_Follow_List__c bigwigs = new Chatter_Follow_List__c();
        bigwigs.Name = 'bigwigs';
        bigwigs.RecordTypeId = chatterRulesRTMap.get('Everyone Follows List').getRecordTypeId();
        insert bigwigs;
        
        Chatter_List_User__c bigWig = new Chatter_List_User__c();
        bigWig.Chatter_Follow_List__c = bigwigs.id;
        bigWig.User__c = user1.id;
        insert bigWig;
        
        mychatterFollowBatchCaller.followList = bigwigs.Id;
        
        Test.StartTest();
        //mychatterFollowBatchCaller.callChatterFollowBatch();
        mychatterFollowBatchCaller.callChatterListBatch();
        Test.StopTest();
        
        List<EntitySubscription> afterFollows = [select id from EntitySubscription where parentId = :user1.id];
        System.debug('~~~~ afterFollows: ' + afterFollows);
        //system.assert(afterFollows.size()>0);
        
    }
}