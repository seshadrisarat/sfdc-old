public with sharing class WSDLSample
{
    private String strAccName;
    private Date planningPeriod;
    private Integer planNumber;
    private WSDLIntegration__c objIntegrationParams = WSDLIntegration__c.getInstance('Default');
    public WSDLSample(String strAccName, Date planningPeriod, Integer planNumber)
    {
         this.strAccName = strAccName;
         this.planningPeriod = planningPeriod;
         this.planNumber = planNumber;
    }
    public soapSforceComSchemasClassAccountpla.Plan WSDLSampleFunction()
    {
        String strUserName = objIntegrationParams.UserName__c;
        String strPwd = objIntegrationParams.Password__c + objIntegrationParams.Security_Token__c;
    
        partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
        partnerSoapSforceCom.LoginResult loginResult = sp.login(strUserName, strPwd);
    
        soapSforceComSchemasClassAccountpla.Plan objPlan = new soapSforceComSchemasClassAccountpla.Plan();
        objPlan.name = strAccName;
        objPlan.planningPeriod = planningPeriod;
        objPlan.planNumber = planNumber;
    
        soapSforceComSchemasClassAccountpla.SessionHeader_element objs = new soapSforceComSchemasClassAccountpla.SessionHeader_element();
        objs.sessionId = loginResult.sessionid;
        soapSforceComSchemasClassAccountpla.AccountPlan obj2 = new soapSforceComSchemasClassAccountpla.AccountPlan();
        obj2.SessionHeader= objs;
    
        objPlan = obj2.createAccountPlan(objPlan);
        return objPlan;
    }

}