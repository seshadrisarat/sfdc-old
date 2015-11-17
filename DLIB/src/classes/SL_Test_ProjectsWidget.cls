@isTest
public class SL_Test_ProjectsWidget{

static testMethod void testWidget() {
    Test.StartTest();
    (new SL_ProjectsWidget()).newComponent();
    new SL_ProjectsWidgetController();
    Test.StopTest();    
}

}