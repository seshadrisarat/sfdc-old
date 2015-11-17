@isTest
private class SROC_Branding_ScriptControllerTest {

    static testMethod void myUnitTest() {
        
        SROC_Branding_ScriptController objBranding_Script = new SROC_Branding_ScriptController();
        Boolean isDealer = objBranding_Script.isDealer;
        System.assertEquals(isDealer, false);
        Boolean isOwner = objBranding_Script.isOwner;
        System.assertEquals(isOwner, false);
    }
}