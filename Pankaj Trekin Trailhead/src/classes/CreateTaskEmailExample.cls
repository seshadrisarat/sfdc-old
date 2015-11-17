global class CreateTaskEmailExample implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env)
    {
        return new Messaging.InboundEmailResult();
    }
}