public with sharing class SL_ProjectsWidget extends WidgetAbstract {

    public SL_ProjectsWidget() {
//        System.debug('Hello');
 
    }
    
    public String Name {get; set;}

    public override ApexPages.Component newComponent() {
        Component.c.SL_ProjectsWidget c = new Component.c.SL_ProjectsWidget();
        c.aComponentImpl = this;
        return c;
    }
    
}