public without sharing class SL_Achievement_Handler{
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Achievement_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnBeforeInsert(list<Dreamforce_Achievements__c> newAchievements){
        system.debug('running before');
        system.debug(newAchievements);
        Set<String> oneTimeEvents = new Set<String>{'Attended the Client Appreciation Dinner','Attended the FinServ Insurance cocktail party', 'Attended the FinServ Capital markets cocktail party', 'Attended the FinServ dinner', 'Attended the MidMarket cocktail party', 'Attended the Commercial cocktail party', 'Attended the Silverline Party'};
        Set<String> dailyEvents =  new Set<String>{'Wore a Silverline logo'};
        //dedupe
        If(oneTimeEvents.contains(newAchievements[0].Achievement_Name__c)){
            system.debug('running once');
            List<Dreamforce_Achievements__c> onetime = [SELECT Id FROM Dreamforce_Achievements__c WHERE Achievement_Name__c =: newAchievements[0].Achievement_Name__c AND User__c =: newAchievements[0].user__c];
            if(onetime.size() != 0){
            newAchievements[0].addError('Already Achieved!');
            }
        }else if(dailyEvents.contains(newAchievements[0].Achievement_Name__c)){
            List<Dreamforce_Achievements__c> daily = [SELECT Id FROM Dreamforce_Achievements__c WHERE Achievement_Name__c =: newAchievements[0].Achievement_Name__c AND createdDate = TODAY AND User__c =: newAchievements[0].user__c];
            system.debug(daily);
            if(daily.size() != 0){
            newAchievements[0].addError('Try Again Tomorrow!');
            }
        }
    }
     
    public void OnAfterInsert(map<ID,Dreamforce_Achievements__c> newAchievementMap){
        system.debug('running after');
        List<Dreamforce_Achievements__c> pastAchievements = [SELECT Points__c, CreatedDate FROM Dreamforce_Achievements__c WHERE User__c = : newAchievementMap.values()[0].CreatedById];
        Contact uContact = [SELECT Id FROM Contact WHERE User__c =: newAchievementMap.values()[0].CreatedById LIMIT 1];
        Double points = 0;
        Double dailyPoints = 0;
        for(Dreamforce_Achievements__c dfa : pastAchievements){
            if(dfa.CreatedDate.dayOfYear() ==  System.today().dayOfYear()){
                dailyPoints += dfa.Points__c;
            }else{
                dailyPoints = dfa.Points__c;
            }
            points += dfa.Points__c;
        }
        uContact.Points__c = points;
        uContact.Points_Daily__c = dailyPoints;
        UPDATE uContact;
    }
     
    @future public static void OnAfterInsertAsync(Set<ID> newAchievementIDs){ }
     
    public void OnBeforeUpdate(map<ID,Dreamforce_Achievements__c> oldAchievementMap, map<ID,Dreamforce_Achievements__c> newAchievementMap){ }
     
    public void OnAfterUpdate(map<ID,Dreamforce_Achievements__c> oldAchievementMap, map<ID,Dreamforce_Achievements__c> newAchievementMap){ }
     
    @future public static void OnAfterUpdateAsync(Set<ID> updatedAchievementIDs){ }
     
    public void OnBeforeDelete(map<ID,Dreamforce_Achievements__c> oldAchievementMap){ }
     
    public void OnAfterDelete(map<ID,Dreamforce_Achievements__c> oldAchievementMap){ }
     
    @future public static void OnAfterDeleteAsync(Set<ID> deletedAchievementIDs){ }
     
    public void OnBeforeUndelete(list<Dreamforce_Achievements__c> restoredAchievements){ }
 
    public void OnAfterUndelete(list<Dreamforce_Achievements__c> restoredAchievements){ }
             
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
     
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }   

}