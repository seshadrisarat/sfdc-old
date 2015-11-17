public with sharing class zHPMACHCallbackController extends zqu.ZCheckoutBaseCallbackController {
    
    /**
        Default Callback page.
    */
    public zHPMACHCallbackController() {
        this.hostedPageSettingName = 'NewACH';
        system.debug('Hosted Page setting name :  ' + this.hostedPageSettingName);
    }
      
    public String refId {get;set;}
      
    public String objectId {get;set;}
    /*
    public override void onload(){
    	
    	this.hostedPageSettingName = 'NewACH';
        system.debug('Hosted Page setting name :  ' + this.hostedPageSettingName);
    }
      */
    public override void processCallbackParameters() {
    	system.debug('processCallbackParameters');
    	//this.hostedPageSettingName = 'NewACH';
    	system.debug('Hosted Page setting name :  ' + this.hostedPageSettingName);
        super.processCallbackParameters();
        this.refId = callbackparameters.get('refId');
        this.objectId = callbackparameters.get('field_passthrough1');
        system.debug('Call back refid :  ' + this.refId);
        system.debug('Call back object id :  ' + this.objectId);
    }
}