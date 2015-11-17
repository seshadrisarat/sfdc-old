public with sharing class SL_DisplayExpenseReportPDF {

	private final sObject mysObject;
    public Id expReportId;
    public List<pse__expense__c> lstAtt {get;set;}
 

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SL_DisplayExpenseReportPDF(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        this.expReportId = mysObject.Id;
        lstAtt = getAttachments(this.expReportId);
    }
    public SL_DisplayExpenseReportPDF() {
        this.expReportId = ApexPages.currentPage().getParameters().get('Id');
        lstAtt = getAttachments(this.expReportId);
    }

    public static List<pse__expense__c> getAttachments(String id) {
        return [select Id, Name, pse__amount__c, (select Id from attachments) from pse__expense__c where pse__expense_report__c = :id];
    }

    //@RemoteAction
    //public static String getBody(String id) {
    //    return EncodingUtil.base64Encode([select Body from Attachment where Id = :id limit 1][0].Body);
    //}
 
}