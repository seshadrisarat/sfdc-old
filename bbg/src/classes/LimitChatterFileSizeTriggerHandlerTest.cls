@isTest
private class LimitChatterFileSizeTriggerHandlerTest 
{
    static testMethod void myUnitTest() 
    {
        SROC_System_Settings__c objSROCSystemSettings = new SROC_System_Settings__c(Name='SROC',
                                                                                    Owner_CCU_Profile_Id__c='00eM0000000QZfSIAW',
                                                                                    Ambassador_Indicator_Image__c='/sroc/servlet/servlet.ImageServer?id=015M0000000pYCn&oid=00DM0000000FaEu',
                                                                                    Owner_CCL_Profile_Id__c='00eM0000000QZrnIAG',
                                                                                    Default_Person_Account_Owner_Id__c='005E0000003zGyX',
                                                                                    Max_Chatter_File_Size__c=2000000,
                                                                                    Captcha_Public_Key__c='6LewUA4TAAAAAJEOl4bj56b_vig8YUQaRb3DBNPJ',
                                                                                    Default_My_Boat_Banner_URL__c='https://bbg1--partial--c.cs7.content.force.com/servlet/servlet.ImageServer?id=015M0000000Quiv&oid=00DM0000000FaEu',
                                                                                    Sea_Ray_Living_Image_URL__c='https://bbg1--partial--c.cs7.content.force.com/servlet/servlet.ImageServer?id=015M0000000QsdF&oid=00DM0000000FaEu',
                                                                                    Chatter_Answers_Zone_Id__c='09aM0000000Catu',
                                                                                    Dealer_CCU_Profile_Id__c='00eM0000000QZqaIAG',
                                                                                    Dealer_CCL_Profile_Id__c='00eM0000000QZrsIAG',
                                                                                    Registration_System_Admin_User_Id__c='005E0000003zGyX',
                                                                                    Captcha_Private_Key__c='6LewUA4TAAAAALbLnCj-hDZG3FA_HOwrp66dTk4h',
                                                                                    Default_Home_Page_Banner_URL__c='https://bbg1--partial--c.cs7.content.force.com/servlet/servlet.ImageServer?id=015M0000000Quiq&oid=00DM0000000FaEu',
                                                                                    Launchpad_Image_URL__c='https://bbg1--partial--c.cs7.content.force.com/servlet/servlet.ImageServer?id=015M0000000QscW&oid=00DM0000000FaEu',
                                                                                    Event_Invite_Select_All_Max__c=1000);
    
        insert objSROCSystemSettings;
    }   
}