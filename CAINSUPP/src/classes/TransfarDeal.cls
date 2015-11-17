Public Class TransfarDeal{

    public TransfarDeal(ApexPages.StandardController controller) {
    }
    
    Public PageReference SaveCloneDeal(){  
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Banker_Allocation__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String dealID = ApexPages.currentPage().getParameters().get('newid');
        String OppID = ApexPages.currentPage().getParameters().get('oid');
        
        System.debug('Deal ID ::' + dealID);
        System.debug('Opportunity ID ::'+ OppID);
        
        List<Banker_Allocation__c> lstOldBankerAllocation = new List<Banker_Allocation__c>();
        List<Banker_Allocation__c> lstNewBankerAllocation = new List<Banker_Allocation__c>();   

        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
           String theName = s.getDescribe().getName();   
           theQuery += theName + ',';
        }          
        theQuery = theQuery.removeEnd(',');   
        theQuery += ' from Banker_Allocation__c where Opportunity__c = '+'\''+OppID +'\'' ;        
        lstOldBankerAllocation = Database.query(theQuery);
        System.debug('lstOldBankerAllocation '+lstOldBankerAllocation );
        Banker_Allocation__c objBankerAllocation ;
        for(Banker_Allocation__c objLoopBankerAllocation : lstOldBankerAllocation ){
            objBankerAllocation = new Banker_Allocation__c();
            objBankerAllocation =  objLoopBankerAllocation.Clone(false);
            objBankerAllocation.Deal_Name__c = dealID;
            lstNewBankerAllocation.add(objBankerAllocation);          
        }        
        insert lstNewBankerAllocation;
        return new PageReference('/'+dealID); 
    }
}