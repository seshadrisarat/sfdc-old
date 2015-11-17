public with sharing class WeeklyTrackerExtension {

	private final Weekly_Tracker__c myWeeklyTracker;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public WeeklyTrackerExtension(ApexPages.StandardController stdController) {
        List<Weekly_Tracker__c> existingTrackers = [SELECT Id, Outbound_Calls_predicted__c, 
                                                           One_Point_0_Calls_Predicted__c, 
                                                           FLIPs_Predicted__c, 
                                                           Total_HQI_Predicted__c,
                                                           Two_point_0_calls_predicted__c,
                                                           Three_Point_0_Calls_predicted__c,
                                                           Four_Point_0_Calls_predicted__c,
                                                           Total_Deals_Predicted__c,
                                                           One_Mil_Deals_Predicted__c,
                                                           Thre_Mil_Deals_Predicted__c,
                                                           Sell_Side_Pursuits_Predicted__c,
                                                           Buy_Side_Pursuits_Predicted__c,
                                                           New_Active_Members_Predicted__c,
                                                           Num_Strategics_Pursuing_Predicted__c,
                                                           Removed_From_AAR_predicted__c,
                                                           New_Sales_Predicted__c,
                                                           ACV_Predicted__c,
                                                           Negative_Churn_Predicted__c,
                                                           Additions_to_AAR_predicted__c,
                                                           Committed_Revenue_Predicted__c,
                                                           Committed_Revenue_Total__c,
                                                           User_First_Name__c, User_Last_Name__c,
                                                           User_Id__c, Week_Of__c, Saves_Predicted__c, Members_Saved_Non_Rate_Changers__c,
                                                           Units_Saved_Rate_Changers__c, New_CR_MRR__c, Saved_MRR__c, Total_Negative_Churn_MRR__c



                                             FROM  Weekly_Tracker__c 
                                             WHERE User_Id__c = :UserInfo.getUserId()
                                             AND   Week_Of__c = :Date.today().toStartOfWeek() LIMIT 1];

        if(existingTrackers == null || existingTrackers.size() < 1){
            // create enw
            UserRole urole = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];


            Weekly_Tracker__c existingTracker = new Weekly_Tracker__c();
            existingTracker.User_Role__c = urole.Name;
            existingTracker.User_Id__c = UserInfo.getUserId();
            existingTracker.User_First_Name__c = UserInfo.getFirstName();
            existingTracker.User_Last_Name__c = UserInfo.getLastName();

            existingTracker.Week_Of__c = Date.today().toStartOfWeek();
            this.myWeeklyTracker = existingTracker;
            //insert existingTracker;
        }else{
            this.myWeeklyTracker = existingTrackers[0];
        }
        //this.myWeeklyTracker = (Weekly_Tracker__c)stdController.getRecord();
    }

    public Weekly_Tracker__c getWeeklyTracker(){
        return this.myWeeklyTracker;
    }

    public String getWeekOf() {
        return String.valueOf(this.myWeeklyTracker.Week_Of__c.toStartOfWeek().format());
    }

    public Integer getTotalHQI() {
        Decimal total = 0;
        if(this.myWeeklyTracker.One_Point_0_Calls_Predicted__c != null)
            total+=this.myWeeklyTracker.One_Point_0_Calls_Predicted__c;
        if(this.myWeeklyTracker.Two_Point_0_Calls_Predicted__c != null)
            total+=this.myWeeklyTracker.Two_Point_0_Calls_Predicted__c;
        if(this.myWeeklyTracker.Three_Point_0_Calls_Predicted__c != null)
            total+=this.myWeeklyTracker.Three_Point_0_Calls_Predicted__c;
        if(this.myWeeklyTracker.Four_Point_0_Calls_Predicted__c != null) 
            total+=this.myWeeklyTracker.Four_Point_0_Calls_Predicted__c;

        return (Integer)total;
    }

    public PageReference save(){
        upsert this.myWeeklyTracker;
        return Page.WeeklyTrackerPredicted;
    }
}