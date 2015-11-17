global class vf001_Account {
    public static id id_Integration_User {
        get {
            if(id_Integration_User==null) {
                Id id_default_integration_user='005A0000004xh17IAA';
                if(m_MMUserID_User.containsKey('integration')) id_default_integration_user=m_MMUserID_User.get('integration').Id;
                id_Integration_User=id_default_integration_user;                
            }
            return id_Integration_User;
        } set;
    }
    public static Map<string,User> m_MMUserID_User {
        get {
            if(m_MMUserID_User==null) {
                m_MMUserID_User=new Map<string,User>();
                List<User> lUser=new List<User>([select id,email,MM_UserID__c from user where isactive=true AND MM_UserID__c !=null]);
                for(User u: lUser) m_MMUserID_User.put(u.MM_UserID__c,u);
            }
            return m_MMUserID_User;
        } set;
    }   
    public static void tr_Before_Update(List<Account> triggerNew, List<Account> triggerOld, Map<Id,Account> triggerNewMap, Map<Id,Account> triggerOldMap) {
        Boolean bIsIntegrationUser=(userinfo.getuserid()==id_Integration_User)?(true):(false);

        for(Account ac_new: triggerNew) {
            if(ac_new.MM_Account_Manager__c!=null && ac_new.MM_COCD__c!=null && bIsIntegrationUser) if(m_MMUserID_User.containsKey(ac_new.MM_Account_Manager__c)) if(m_MMUserID_User.get(ac_new.MM_Account_Manager__c).Id != ac_new.OwnerId) ac_new.OwnerId=m_MMUserID_User.get(ac_new.MM_Account_Manager__c).Id;
        }
    }
    
    public static void tr_Before_Insert(List<Account> triggerNew, List<Account> triggerOld, Map<Id,Account> triggerNewMap, Map<Id,Account> triggerOldMap) {
        Boolean bIsIntegrationUser=(userinfo.getuserid()==id_Integration_User)?(true):(false);

        for(Account ac_new: triggerNew) {
            if(ac_new.MM_Account_Manager__c!=null && ac_new.MM_COCD__c!=null && bIsIntegrationUser) if(m_MMUserID_User.containsKey(ac_new.MM_Account_Manager__c)) if(m_MMUserID_User.get(ac_new.MM_Account_Manager__c).Id != ac_new.OwnerId) ac_new.OwnerId=m_MMUserID_User.get(ac_new.MM_Account_Manager__c).Id;
        }
    }
}