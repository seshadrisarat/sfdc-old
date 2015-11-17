@istest
private class NewProjectHandlerTest {
    static testMethod void NewProjectHandler_Test() {
    
    Messaging.InboundEmail  email = new Messaging.InboundEmail ();
    email.subject = 'test sunmjct';
    email.htmlBody = '';
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    GAPSMailHandlerBase gaps = new GAPSMailHandlerBase();
    NewProjectHandler  obj = new NewProjectHandler();
    obj.handleInboundEmail(email, env);
        
   }
}