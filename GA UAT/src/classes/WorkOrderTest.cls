public class WorkOrderTest {

    static testMethod void testWorkOrderProcessor() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'test';
        email.plainTextBody = 'test';
        env.fromAddress='ttieu@cinovate.com';
        env.toAddress='ttieu@cinovate.com';
        
        WorkOrderProcessor emailServiceObj = new WorkOrderProcessor();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
    }
}