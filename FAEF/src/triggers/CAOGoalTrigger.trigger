trigger CAOGoalTrigger on CAO_Goal__c (before insert, before update) {
    
    //Get This Year and Last Year
    Date today = Date.Today();
    Integer thisYear = today.Year();
    Integer lastYear = thisYear - 1;
    
    for(CAO_Goal__c c : Trigger.New){
        //This Year's CAO Goal
        if(c.CAO_User__c != null && c.Level_Type__c == 'CAO' && c.Item_Type__c == 'GROSS_MARGIN' && c.Period_Type__c == 'ANNUAL' && c.Period_Start_Date__c.Year() == thisYear){
            List <User> u = [SELECT id, This_Year_s_Goal__c FROM User WHERE id = :c.CAO_User__c LIMIT 1];
            if(u.Size() > 0){
                u[0].This_Year_s_Goal__c = c.CAO_Goal__c;
                update u;
            }
        //Last Year's CAO Goal
        }else if(c.CAO_User__c != null && c.Level_Type__c == 'CAO' && c.Item_Type__c == 'GROSS_MARGIN' && c.Period_Type__c == 'ANNUAL' && c.Period_Start_Date__c.Year() == lastYear){
            List <User> u = [SELECT id, Last_Year_s_Goal__c FROM User WHERE id = :c.CAO_User__c LIMIT 1];
            if(u.Size() > 0){
                u[0].Last_Year_s_Goal__c = c.CAO_Goal__c;
                update u;
            }
        }
    }
    
}