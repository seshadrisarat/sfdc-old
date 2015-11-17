/**  
* \arg ClassName        : SL_AssetInlineVFCtrl
* \arg JIRATicket       : NPD-138
* \arg CreatedOn        : 29/Sep/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : This is controller for assert inline vf page.
*/
public with sharing class SL_AssetInlineVFCtrl 
{
    public List<Asset> lstAsset  {get;set;}
    
    /**/
    public SL_AssetInlineVFCtrl(ApexPages.StandardController stdController)
    {
        lstAsset = new List<Asset>();
        String query = 'SELECT ';
        List<String> lstFields = new List<String>();
        for(Schema.FieldSetMember f : SObjectType.Asset.FieldSets.SL_AssetInlineVF.getFields()) 
        {
            lstFields.add(f.getFieldPath());
        }
        query += String.join(lstFields, ', ');
        query += ' FROM Asset'
                +' WHERE PurchaseDate <= TODAY AND UsageEndDate >= TODAY AND (AccountId = \''+stdController.getId() 
                +'\' OR Account.Company_Account__c = \''+stdController.getId() 
                +'\' OR Account.Company_Account__r.Corporate_Account__c = \''+stdController.getId()+'\')' ;
        lstAsset = Database.query(query);
    }
}