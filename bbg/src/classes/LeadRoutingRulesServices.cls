public class LeadRoutingRulesServices {

    public static Lead_Routing_Rule__c[] getAllRoutingRules(){
        return [SELECT Name, Country_Code__c, Brand_Code__c, Routing_Attempt_1_Type__c, Number_of_Leads_1__c, Routing_Attempt_2_Type__c, Number_of_Leads_2__c, Routing_Attempt_3_Type__c, Number_of_Leads_3__c, Routing_Attempt_4_Type__c, Number_of_Leads_4__c
                                                      FROM Lead_Routing_Rule__c];
    }
}