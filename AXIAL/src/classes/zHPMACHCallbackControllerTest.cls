@isTest
public class zHPMACHCallbackControllerTest{
    static TestMethod void testzHPMACHCallbackController() {
        Test.startTest();
        
        zHPMACHCallbackController hpmachcall = new zHPMACHCallbackController();        
        hpmachcall.processCallbackParameters();
        
        Test.stopTest();
        
    }
}