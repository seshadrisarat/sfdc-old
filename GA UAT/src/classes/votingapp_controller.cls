public class votingapp_controller {

    public PageReference RedirectToLatestVersion() {
        
        string latestVersionName = Label.LiveVersionName ;
        VFVersion__c liveVersion = [Select URL__c From VFVersion__c where Name = :latestVersionName limit 1];
        PageReference pg = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+liveVersion.URL__c);
        pg.setRedirect(true);
        return pg;
    }

}