public class CapitalIQ_Company_Controller 
{
    public static testMethod void TestHarness()
    {
        CapitalIQSetup_Controller.InitOrgInfo();
        Session.Account = new Account();
        Session.Account.CapitalIQ_CompanyId__c = '29096';
        CapitalIQ_Company_Controller controller = new CapitalIQ_Company_Controller();
        controller.setDrawControls(true);
        controller.getDrawControls();
        
        try
        {
            String s = controller.getTearSheetLink();
            s = controller.getTearSheetLink();
            s = controller.getDocumentsLink();
            s = controller.getProsLink();
            s = controller.getDirectInvestmentsLink();
            s = controller.getSubsLink();
            s = controller.getSuppliersLink();
            GetCompanyInfo.CompanySummary a = controller.getCapitalIQBasicInfo();
            GetBusinessRelationships.BusinessRelationship[] mySuppliers = controller.getSuppliers();
            SearchDocuments.DocumentInfo[] mySearchDocumentInfo = controller.getSearchDocumentInfo();
            GetCompanyRelationships.CompanyRelationship[] myCompRels = controller.getDirectInvestment();
            GetCompanyRelationships.CompanyRelationship[] mySubs = controller.getSubs();
            
            s = controller.getYearFounded();
            s = controller.getCity();
            s = controller.getCompanyStatusName();
            s = controller.getCompanyTypeName(); 
            s = controller.getCountry();
            s = controller.getDescription();
            s = controller.getFax();
            s = controller.getZipCode();
            s = controller.getYearFounded();
            s = controller.getTickerSymbol();
            s = controller.getStreetAddress();
            
            controller.setSuppliers(new GetBusinessRelationships.BusinessRelationship[1]);
            GetCompanyInfo.CompanySummary info = new GetCompanyInfo.CompanySummary();
            info.PrimaryAddressInfo = new GetCompanyInfo.PrimaryCompanyAddress();
            controller.setCapitalIQBasicInfo(info);
            s = controller.getYearFounded();
            s = controller.getCity();
            s = controller.getCompanyStatusName();
            s = controller.getCompanyTypeName();
            s = controller.getCountry();
            s = controller.getDescription();
            s = controller.getFax();
            s = controller.getZipCode();
            s = controller.getYearFounded();
            s = controller.getTickerSymbol();
            s = controller.getStreetAddress();
        }
        catch(Exception e)
        {
            System.debug('Company Controller threw --> ' + e);
        }
    }
    
    public String getTearSheetLink()
    {
        if(acctId.CapitalIQ_CompanyId__c == null)
        {
            return '';
        }
        return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.CompanyTearsheet, 'View On Capital IQ');
    }
    
    public String getDocumentsLink()
    {
        if(acctId.CapitalIQ_CompanyId__c == null)
        {
            return '';
        }
        return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.SECFilings, 'View More Filings');
    }
    
    public String getProsLink()
    {
        if(acctId.CapitalIQ_CompanyId__c == null)
        {
            return '';
        }
        return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.Professionals, 'View More Professionals');
    }
    
    public String getDirectInvestmentsLink()
    {
        if(acctId.CapitalIQ_CompanyId__c == null)
        {
            return '';
        }
        return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.DirectInvestmentSubs, 'View More Direct Investments');
    }
    
    public String getSubsLink()
    {
        if(acctId.CapitalIQ_CompanyId__c == null)
        {
            return '';
        }
        return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.DirectInvestmentSubs, 'View More Subsidiaries');
    }
    
    public String getSuppliersLink()
    {
        if(acctId.CapitalIQ_CompanyId__c == null)
        {
            return '';
        }
        return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.Suppliers, 'View More Suppliers');
    }
    
    public CapitalIQ_Company_Controller()
    {
        try
        {
            acctId = Session.Account; 
        }
        catch(Exception e)
        {
            System.debug('CapitalIQ_Company_Controller.ctor threw -> ' + e);
            return;
        }
    }
    
    private Boolean myDrawControls = true;
    public void setDrawControls(Boolean drawControls)
    {
        myDrawControls = drawControls;
        if(acctId.CapitalIQ_CompanyId__c != null && SessionId() != null)
        {
            if(myDrawControls)
            {
                if(myCompanySummary == null )
                {    
                    myCompanySummary = GetCompanyInfo.FetchCompanySummary(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
                }
                if(mySuppliers == null)
                {
                    mySuppliers = GetBusinessRelationships.GetSuppliers(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
                }
                if(mySearchDocumentInfo == null)
                {
                    SearchDocuments.DocumentInfo[] temp = SearchDocuments.Last30Days(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
                    if(temp!= null && temp.size() >= 3)
                    {
                        mySearchDocumentInfo = new SearchDocuments.DocumentInfo[3];
                        mySearchDocumentInfo[0] = temp[0];
                        mySearchDocumentInfo[1] = temp[1];
                        mySearchDocumentInfo[2] = temp[2];
                    }
                }
                if(myDirectInvestment == null)
                {
                    myDirectInvestment = GetCompanyRelationships.GetDirectInv(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
                }
                if(mySubs == null)
                {
                    mySubs = GetCompanyRelationships.GetSubs(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
                }
            }
        }
    }
    public Boolean getDrawControls()
    {
        return myDrawControls;
    }
    
    private GetCompanyInfo.CompanySummary myCompanySummary;
    public GetCompanyInfo.CompanySummary getCapitalIQBasicInfo() 
    {
        return myCompanySummary;
    }
    public void setCapitalIQBasicInfo(GetCompanyInfo.CompanySummary input)
    {
        myCompanySummary = input;
    }
    
    private GetBusinessRelationships.BusinessRelationship[] mySuppliers; 
    public GetBusinessRelationships.BusinessRelationship[] getSuppliers()
    {
        return mySuppliers;
    }
    private void setSuppliers(GetBusinessRelationships.BusinessRelationship[] input)
    {
        mySuppliers = input;
    }
    
    private SearchDocuments.DocumentInfo[] mySearchDocumentInfo;
    public SearchDocuments.DocumentInfo[] getSearchDocumentInfo()
    {
        return mySearchDocumentInfo;
    }
    public void setSearchDocumentInfo(SearchDocuments.DocumentInfo[] input)
    {
        mySearchDocumentInfo = input;
    }
    
    private GetCompanyRelationships.CompanyRelationship[] myDirectInvestment;
    public GetCompanyRelationships.CompanyRelationship[] getDirectInvestment()
    {
        return myDirectInvestment;
    }
    
    private GetCompanyRelationships.CompanyRelationship[] mySubs;
    public GetCompanyRelationships.CompanyRelationship[] getSubs()
    {
        return mySubs;
    }
    
    private Account acctId;
    
    private String myASPNETSessionId;
    private String SessionId()
    {
        if(myASPNETSessionId == null)
        {
            myASPNETSessionid = String.valueOf(Session.get(Session.CapitalIQSession)); 
        }
        return myASPNETSessionid;
    }
    
    public String getYearFounded()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        
        return String.valueOf(getCapitalIQBasicInfo().YearFounded);
    }
    
    public String getPrimaryIndustryName()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().IndustryName;
    }
    
    public String getPrimaryExchangeName()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().PrimaryExchangeName;
    }
    
    public String getTickerSymbol()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().PrimaryTickerSymbol;
    }
    
    public String getNumberOfEmployees()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return String.valueOf(getCapitalIQBasicInfo().NumberOfEmployees); 
    }
    
    public String getCompanyStatusName()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().CompanyStatusTypeName;
    }
    
    public String getCompanyTypeName()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().CompanyTypeName;
    }
    
    public String getWebSite()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().WebSiteURL;
    }
    
    public String getDescription()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        return getCapitalIQBasicInfo().BusinessDescription;
    }
    
    public String getStreetAddress()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.StreetAddress1;
    }
    
    public String getCity()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.City;
    }
    
    public String getState()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.StateName;
    }
    
    public String getZipCode()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.ZipPostalCode;
    }
    
    public String getCountry()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.CountryName;
    }
    
    public String getPhone()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.Phone;
    }
    
    public String getFax()
    {
        if(getCapitalIQBasicInfo() == null) {return 'No Data';}
        if(getCapitalIQBasicInfo().PrimaryAddressInfo == null) { return 'No Data'; }
        return getCapitalIQBasicInfo().PrimaryAddressInfo.Fax;
    }
}