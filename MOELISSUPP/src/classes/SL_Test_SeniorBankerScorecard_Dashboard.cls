/**
 * \author Vika Osmak 
 * \date 04/02/12
 * \see https://silverline.jira.com/browse/MBS-11
 * \brief Test Class for class SL_SeniorBankerScorecard_Dashboard 
 */
@isTest
private class SL_Test_SeniorBankerScorecard_Dashboard 
{

    static testMethod void SL_SeniorBankerScorecard_Dashboard_cover() 
    {
        Employee_Profile__c curBanker = new Employee_Profile__c(
     						Title__c = 'Managing Director',
     						MD_Promotion_Date__c = Date.today() + 1,
     						Start_Date__c = Date.today(),
     						User_ID__c = UserInfo.getUserId(), 
     						Office_Location__c = 'New York',
     						Last_Name__c = 'LTest', 
     						Group__c = 'Restructuring & Recapitalization',
     						First_Name__c = 'FTest' );
     	insert curBanker;
        SL_SeniorBankerScorecard_Dashboard dash = new SL_SeniorBankerScorecard_Dashboard();
       // dash.run(); 
        
        list<String> p_subfilters = new list<String>();
        p_subfilters.add(curBanker.Id);
        dash.getFilterItems();
        dash.getSubFilterItems();
        dash.setSubFilters(p_subfilters);
        
        dash.setFilter('title');
        dash.getFilter();
        dash.changeFilter();
        p_subfilters = new list<String>();
        p_subfilters.add('Managing Director');
        dash.setSubFilters(p_subfilters);
        dash.getSubFilters();
        dash.tmpObj.Start_Date__c  = Date.today() - 2;
        dash.tmpObj.End_Date__c = Date.today() - 1;
        dash.run();
         
        dash.setFilter('group');
        dash.changeFilter();
        p_subfilters = new list<String>();
        p_subfilters.add('Restructuring & Recapitalization');
        dash.setSubFilters(p_subfilters);
        dash.run();
        
        dash.setFilter('location');
        dash.changeFilter();
        p_subfilters = new list<String>();
        p_subfilters.add('New York');
        dash.setSubFilters(p_subfilters);
        dash.run();
        
        dash.getReport_values();
    }
}