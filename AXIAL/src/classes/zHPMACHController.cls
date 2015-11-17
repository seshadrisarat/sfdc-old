public class zHPMACHController extends zqu.ZCheckoutBaseController {
    
    public string pmId{get;set;}
    public string displayMessage{get;set;}
    public string id{get;set;}
    
    public zHPMACHController() {
        //Set Name of HPM
        this.hostedPageSettingName = 'NewACH';
        pmId = '';
    }
    
    public override PageReference getPageRef() {
        setPageRef(Page.zACHPaymentMethodCreation);
        return Page.zACHPaymentMethodCreation;
    }
    
    public override PageReference navigateBack(){
        return new PageReference('/' + System.currentPageReference().getParameters().get('id'));
    }
    
    public override PageReference navigateNext(){
        return new PageReference('/' + System.currentPageReference().getParameters().get('id'));
    }
    
    public override string getBackURL(){
        return '';
    }
    
    public override string getNextURL(){
        return '/' + System.currentPageReference().getParameters().get('id');
    }
    
    public PageReference setQuotePaymentMethod(){
        if (!Test.isRunningTest()){
            id = System.currentPageReference().getParameters().get('id');
        }
        zqu__Quote__c quote = ([Select Id, zqu__ElectronicPaymentMethodId__c from zqu__Quote__c where Id=:id]).get(0);
        quote.zqu__ElectronicPaymentMethodId__c = pmId;
        update quote;
        return new PageReference('/' + id + '?pmid=' + pmId + '&displayMessage=' + displayMessage);
    }
}