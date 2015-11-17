public with sharing class SL_DisplayAttachment {
	public Id idCredit {get; set;}
	public string strCredit {get; set;}
	public SL_DisplayAttachment(ApexPages.StandardController stdController)
    {
         id idcreditScore = (Id)stdController.getRecord().Id;
          Attachment obj = [Select Id, Body From Attachment where ParentId =: idcreditScore limit 1];
         strCredit = obj.Body.toString();
         idCredit = obj.Id;
    }
}