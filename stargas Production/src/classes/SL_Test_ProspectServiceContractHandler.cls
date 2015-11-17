/**
*  ClassName        : SL_Test_ProspectServiceContractHandler
*  JIRATicket       : STARGAS-37
*  CreatedOn        : 24/MAR/2015
*  LastModifiedOn   : 25/MAR/2015
*  CreatedBy        : Pankaj Ganwani
*  ModifiedBy       : Pankaj Ganwani
*  Description      : Test class for testing the functionality of SL_ProspectServiceContract trigger.
*/
@isTest
private class SL_Test_ProspectServiceContractHandler 
{
    static Account objAccount;
    static List<Prospect_Service_Contract__c> lstPSC;
    static List<Opportunity> lstOpportunity;
    static List<Service_Plan_Code__c> lstServicePlan;
    static List<Division__c> lstDivision;
    static DivOilPriceGrp__c objDivOilPriceGrp;
    
    private static void createData()
    {
        objAccount = new Account(LastName = 'Test Account');
        insert objAccount;
        
        lstOpportunity = new List<Opportunity>{
                                                    new Opportunity(Name='TestOppt', CloseDate=Date.today(), StageName='Open', AccountId = objAccount.Id, Delivery_Street2__c = '10', HHAU__c = 'Email'),
                                                    new Opportunity(Name='TestOppt1', CloseDate=Date.today(), StageName='Open', AccountId = objAccount.Id, Delivery_Street2__c = '10', HHAU__c = 'Email'),
                                                    new Opportunity(Name='TestOppt2', CloseDate=Date.today(), StageName='Open', AccountId = objAccount.Id, Delivery_Street2__c = '10', HHAU__c = 'Email')
                                              };
        insert lstOpportunity;
        
        objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
        insert objDivOilPriceGrp;
        
        lstDivision = new List<Division__c>{
                                                new Division__c(Name='Allentown', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id, Division_Oil_Pricing_Group__c = '2'),
                                                new Division__c(Name='Arlington', Division__c ='411', Database__c = '101',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id, Division_Oil_Pricing_Group__c = '2')
                                           };
        insert lstDivision;
        
        lstServicePlan = new List<Service_Plan_Code__c>{
                                                            new Service_Plan_Code__c(Name = 'Test Service Plan 1', Division__c = lstDivision[0].Id, Service_Contract_Code__c = '112'),
                                                            new Service_Plan_Code__c(Name = 'Test Service Plan 2', Division__c = lstDivision[0].Id, Service_Contract_Code__c = '113'),
                                                            new Service_Plan_Code__c(Name = 'Test Service Plan 3', Division__c = lstDivision[1].Id, Service_Contract_Code__c = '114'),
                                                            new Service_Plan_Code__c(Name = 'Test Service Plan 4', Division__c = lstDivision[1].Id, Service_Contract_Code__c = '115'),
                                                            new Service_Plan_Code__c(Name = 'Test Service Plan 5', Division__c = lstDivision[0].Id, Service_Contract_Code__c = '116')
                                                       };
        insert lstServicePlan;
        
        lstPSC = new List<Prospect_Service_Contract__c>{
                                                            new Prospect_Service_Contract__c(Opportunity__c = lstOpportunity[0].Id, Division__c = 'Allentown', Service_Plan_Code__c = lstServicePlan[0].Id),
                                                            new Prospect_Service_Contract__c(Opportunity__c = lstOpportunity[0].Id, Division__c = 'Allentown', Service_Plan_Code__c = lstServicePlan[1].Id),
                                                            new Prospect_Service_Contract__c(Opportunity__c = lstOpportunity[1].Id, Division__c = 'Arlington', Service_Plan_Code__c = lstServicePlan[2].Id),
                                                            new Prospect_Service_Contract__c(Opportunity__c = lstOpportunity[1].Id, Division__c = 'Arlington', Service_Plan_Code__c = lstServicePlan[3].Id)
                                                       };
        insert lstPSC;
    }
    
    static testMethod void checkForInsert()
    {
        createData();
        
        //System.assertEquals('113', [SELECT Service_Contract_Code__c FROM Opportunity WHERE Id =:lstOpportunity[0].Id].Service_Contract_Code__c);
        //System.assertEquals('115', [SELECT Service_Contract_Code__c FROM Opportunity WHERE Id =:lstOpportunity[1].Id].Service_Contract_Code__c);
    }
    
    static testMethod void checkForUpdate()
    {
        createData();
        
        lstPSC[1].Service_Plan_Code__c = lstServicePlan[4].Id;
        Test.startTest();
        update lstPSC[1];
        Test.stopTest();
        
        //System.assertEquals('116', [SELECT Service_Contract_Code__c FROM Opportunity WHERE Id =:lstOpportunity[0].Id].Service_Contract_Code__c);
    }
    
    static testMethod void checkForDelete()
    {
        createData();
        
        Test.startTest();
        delete lstPSC[1];
        Test.stopTest();
        
        //System.assertEquals('112', [SELECT Service_Contract_Code__c FROM Opportunity WHERE Id =:lstOpportunity[0].Id].Service_Contract_Code__c);
    }
}