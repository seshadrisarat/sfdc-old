public with sharing class SL_Ctrl_DeleteNote
{
    public String parId;
    public Note_Joiner__c nj;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SL_Ctrl_DeleteNote(ApexPages.StandardController stdController)
    {
        nj = [Select Id,Note__c,Client_Prospect__c,Relationship_Group__c
                             From Note_Joiner__c WHERE Id =: stdController.getId()];
        parId = '';

        if(nj.Client_Prospect__c != null)
        {
            parId = nj.Client_Prospect__c;
        }

        if(nj.Relationship_Group__c != null)
        {
            parId = nj.Relationship_Group__c;
        }
    }

    public PageReference goToParent()
    {
        delete new Note__c(Id=nj.Note__c);
        return new PageReference('/'+parId);
    }
}