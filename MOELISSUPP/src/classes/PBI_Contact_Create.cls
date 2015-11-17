/**
* Test methods are in Test_PBI.cls
**/
public without sharing class PBI_Contact_Create 
{
    public String CurPBIId {get; set;}
    public String CurPBIName {get; set;}
    public String CurPBIContactId {get; set;}
    public Potential_Buyer_Investor_Contact__c CurPBIContact {get; set;}
    public Boolean isEdit {get; set;}
    

    public PBI_Contact_Create(ApexPages.StandardController stdController)       
    {
        
        Potential_Buyer_Investor_Contact__c tmpObj = (Potential_Buyer_Investor_Contact__c)stdController.getRecord();
        this.CurPBIContactId = tmpObj.Id;
        if(this.CurPBIContactId != null && this.CurPBIContactId != '')
        {
            this.isEdit = true;
            this.CurPBIContact = [  SELECT ID,Contact__c,Roles__c,Target_Buyer__c,Company_Name__r.Name,Target_Buyer__r.Name,Title__c,Phone__c,Email__c,Business_State_Province__c,Business_City__c,Company_Name__c,Manager__c,Notes__c 
                                        FROM Potential_Buyer_Investor_Contact__c 
                                        WHERE ID = : this.CurPBIContactId];
            this.CurPBIId = this.CurPBIContact.Target_Buyer__c;
            this.CurPBIName = this.CurPBIContact.Target_Buyer__r.Name;
        }
        else
        {
            this.isEdit = false;
            if(System.currentPageReference().getParameters().get('pbid')!=null && System.currentPageReference().getParameters().get('pbid')!='')
                this.CurPBIId = System.currentPageReference().getParameters().get('pbid');
            this.CurPBIContact = new Potential_Buyer_Investor_Contact__c();
            if( this.CurPBIId != null &&  this.CurPBIId != '')
            {
                Potential_Buyer_Investor__c tmp = [Select Name From Potential_Buyer_Investor__c WHERE ID = :this.CurPBIId ];
                this.CurPBIName = tmp.Name;
            }
        }           
    }
   
    private void saveObj()
    {
        if(this.CurPBIContactId != null && this.CurPBIContactId != '')
        {
            update this.CurPBIContact;
        }
        else
        {
            if(this.CurPBIId != null && this.CurPBIId != '')
            {
                this.CurPBIContact.Target_Buyer__c = this.CurPBIId;
                insert this.CurPBIContact;
            }
        }
    }

    public PageReference save()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/'+this.CurPBIId );
        pageRef.setRedirect(true);
        return pageRef;
     }
     
    public PageReference save_new()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/apex/PBI_Contact_Create?clid='+this.CurPBIId );
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+this.CurPBIId );
        pageRef.setRedirect(true);
        return pageRef;
    }
     
}