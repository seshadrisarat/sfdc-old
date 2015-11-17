@isTest
private class votingapp_controllertest {
    static testMethod void votingapp_controller_Test() {
    string name = '' ;
    if(!isSandbox()) {
        name = 'Stable 1.0';
    }else {
        name = 'Live Version' ;
    }
    VFVersion__c vfobj= new VFVersion__c(Name=name,URL__c='/testmeeting',Version__c=1);
    insert vfobj;
    votingapp_controller vcont=new votingapp_controller();
    vcont.RedirectToLatestVersion();
    //System.currentPageReference().getParameters().put('retURL','https://ap1.salesforce.com/003/e?retURL=%2F003%');
    }
    
    // Next method tells us if we're in a sandbox

    public Static Boolean isSandbox(){

        String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0,host.indexOf('.'));

        // It's easiest to check for 'my domain' sandboxes first 
        // even though that will be rare
        if(server.contains('--'))
            return true;

        // tapp0 is a unique "non-cs" server so we check it now
        if(server == 'tapp0')
            return true;

        // If server is 'cs' followed by a number it's a sandbox
        if(server.length()>2){
            if(server.substring(0,2)=='cs'){
                try{
                    Integer.valueOf(server.substring(2,server.length()));
                }
                catch(exception e){
                    //started with cs, but not followed by a number
                    return false;
                }

                //cs followed by a number, that's a hit
                return true;
            }
        }

        // If we made it here it's a production box
        return false;
    }
}