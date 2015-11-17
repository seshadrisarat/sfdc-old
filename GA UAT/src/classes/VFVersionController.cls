public with sharing class VFVersionController 
{
    public VFVersionController()
    {
    }

    public PageReference redirectForVersion()
    {
        PageReference pageRef=Page.VFVersionNotFound;
        String strV=System.currentPagereference().getParameters().get('vfVersion');
        strV=(strV==null)?'0':(strV.isNumeric()?strV:'0');
        Integer vfVersion = Integer.valueof(strV);
        List<VFVersion__c> lV=[SELECT Id, Version__c, URL__c FROM VFVersion__c WHERE Version__c=:vfVersion];
        String urlForVersion='/';
        
        if(lV.size()>0) { urlForVersion = lV.get(0).URL__c; pageRef=new PageReference(urlForVersion); }
                    
        return pageRef;
    }
    
    static testMethod void test()
    {
        Integer version = 1000000;
        VFVersion__c vfVersion = new VFVersion__c(URL__c='testurl', Version__c=version);
        insert vfVersion;
        
        PageReference pageRef = Page.VFVersion;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('vfVersion', String.valueof(version));
        VFVersionController controller = new VFVersionController();
        controller.redirectForVersion();
    }
    
}