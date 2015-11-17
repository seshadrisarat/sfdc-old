/**
*  ClassName      : SL_ApplicationForm_Controller
*  JIRATicket     : THOR-18  
*  CreatedOn      : 6/AUG/2014
*  ModifiedBy     : Rahul Majumder
*  Description    : Controller for the Individual/Company Application Form and Payment Form of the Site
*/
public class SL_ApplicationForm_Controller
{
    private static final Date MAX_DATE_LIMIT = date.newInstance(4000, 12, 31);
    private static final Date MIN_DATE_LIMIT = date.newInstance(1700, 01, 1);
    
    public String strBrowserName               {get;set;} 
    public String strBrowserVersion            {get;set;}
    public String strOperatingSystem           {get;set;}

    ///Personal Information Common Fields
    public String phone                        {get;set;}
    public String altPhone                     {get;set;}
    public String strEmail                     {get;set;}
    public String strAppType                   {get;set;}

    ///Personal Information Individual fields
    public String applicantName                {get;set;}
    public String applicantMiddleInitial       {get;set;}
    public String applicantLastName            {get;set;}
    public String ssn                          {get;set;}
    public String dob                          {get;set;}
    public String strSuffix                    {get;set;}

    ///Personal Information Company fields
    public String strCompanyName               {get;set;}
    public String strCompanyFirst              {get;set;}
    public String strCompanyLast               {get;set;}
    public String strTaxId                     {get;set;}
    public String strDateOfIncorporation       {get;set;}
    public String strProperty                  {get;set;}
    public String strEmployment                {get;set;}

    ///Current Address
    public String moveInDate                   {get;set;} 
    public String leaseEndDate                 {get;set;}
    public String strRentOrOwn                 {get;set;}
    public String strAddress                   {get;set;}
    public String strCountry                   {get;set;}
    public String strCity                      {get;set;}
    public String strState                     {get;set;}
    public String strZip                       {get;set;}
    public String strCompany                   {get;set;}
    public String strPhone                     {get;set;}
    public Boolean isShowRentOrOwnFields       {get;set;}

    ///Employment Info
    public String strIndustry                  {get;set;}
    public String strOccupation                {get;set;}
    public String strPosition                  {get;set;}
    public String strEmployer                  {get;set;}
    public String strSupervisorName            {get;set;}
    public String strSupervisorPhone           {get;set;}
    public String strEmploymentStartDate       {get;set;}
    public String strTotalIncome               {get;set;}
    public String strIncomeSource1             {get;set;}
    public String strIncomeSource2             {get;set;}
    public String strExpectedIncome1           {get;set;}
    public String strExpectedIncome2           {get;set;}
    public String annualSalary                 {get;set;}
    public String strEmployed                  {get;set;}
    public String strUniversity                {get;set;}
    public String strUniversityProgram         {get;set;}

    ///Pets Info
    public String pettype1                     {get;set;}
    public String pettype2                     {get;set;}
    public String petname1                     {get;set;}
    public String petname2                     {get;set;}
    public String breed1                       {get;set;}
    public String breed2                       {get;set;}
    public String weight1                      {get;set;}
    public String weight2                      {get;set;}

    ///Payment related fields
    public String result                       {get;set;}
    public String strPayBy                     {get;set;}
    public String strCardNumber                {get;set;}
    public String strCardDate                  {get;set;}
    public String strSecurityCode              {get;set;}
    public String strCardName                  {get;set;}
    public String strCardAddress               {get;set;}
    public String strCardCity                  {get;set;}
    public String strCardState                 {get;set;}
    public String strCardZip                   {get;set;}
    public String acceptTerms                  {get;set;}
    public String strPromoCode                 {get;set;}
    public string transid                      {get;set;}
    public string message                      {get;set;}
    public string err                          {get;set;}
    public string rawResponse                  {get;set;}
    public Integer maxLength                   {get;set;}

    ///URL parameters passed to Success page
    public Id contactRoleId                    {get;set;}
    public Boolean payError                    {get;set;}
    public Boolean isReadTimedOut              {get;set;}
    
    
    public Boolean isShowEmployedSection       {get;set;}
    public Boolean isShowSelfEmployedSection   {get;set;}
    public Boolean isShowUnEmployedSection     {get;set;}
    public Boolean isShowStudentSection        {get;set;}
    public Boolean isShowState                 {get;set;}
    
    public Boolean isPropertySelectDisabled    {get;set;}
    
    public String cid;
    public Set<String> setPromoCodes = new Set<String>();
    
    private String strOppId;
    private String strSignature;
    private PayPal_Transaction__c objPayPalTransaction;
    private Contact_Role__c objExistingContactRole;
    private PayPal_Transaction__c objExistingPayPalTransaction;

    /* ********************* Error Fields - Start *************************/
    ///Personal information for Individual Application
    public String errorPI_ApplicantName                  {get;set;}
    public String errorPI_applicantLastName              {get;set;}
    public String errorPI_ssn                            {get;set;}
    public String errorPI_dob                            {get;set;}
    public String errorPI_phone                          {get;set;}
    public String errorPI_altPhone                       {get;set;}
    public String errorPI_strEmail                       {get;set;}

    ///Personal Information for Company Application 
    public String errorPI_CompanyName                    {get;set;}
    public String errorPI_CompanyFirst                   {get;set;}
    public String errorPI_CompanyLast                    {get;set;}
    public String errorPI_TaxId                          {get;set;}
    public String errorPI_DateOfIncorporation            {get;set;}
    public String errorPI_CompanyPhone                   {get;set;}
    public String errorPI_CompanyAltPhone                {get;set;}
    public String errorPI_CompanyStrEmail                {get;set;}

    ///Current Address
    public String errorCA_MoveInDate                     {get;set;}
    public String errorCA_LeaseEndDate                   {get;set;}
    public String errorCA_Address                        {get;set;}
    public String errorCA_Country                        {get;set;}
    public String errorCA_City                           {get;set;}
    public String errorCA_State                          {get;set;}
    public String errorCA_Zip                            {get;set;}
    public String errorCA_FromTo                         {get;set;}
    public String errorCA_strCompany                     {get;set;}
    public String errorCA_strPhone                       {get;set;}

    ///Previous Address
    public String errorPA_PrevFromTo                     {get;set;}

    ///Bank Information
    public String errorBI_BankName                       {get;set;}

    ///Employment
    public String errorEmp_SupervisorCodePhone           {get;set;}
    public String errorEmp_StartMonthYear                {get;set;}
    public String errorEmp_annualSalary                  {get;set;}
    public String errorEmp_annualBonus                   {get;set;}
    public String errorEmp_otherIncome                   {get;set;}
    public String errorEmp_EmploymentStartDate           {get;set;}
    public String errorEmp_strTotalIncome                {get;set;}
    public String errorEmp_strExpectedIncome1            {get;set;}
    public String errorEmp_strExpectedIncome2            {get;set;}
    
    ///Pets
    public String errorPet_petweight1                    {get;set;}  
    public String errorPet_petweight2                    {get;set;} 

    public String errorPropertyNumber                    {get;set;}
    
    ///Certification
    public String error_Signature                        {get;set;}

    ///Payment Section
    public String errorPay_CardNumber                    {get;set;}
    public String errorPay_SecurityCode                  {get;set;}
    public String errorPay_CardName                      {get;set;}
    public String errorPay_CardDate                      {get;set;}
    public String errorPay_CardAddress                   {get;set;}
    public String errorPay_CardCity                      {get;set;}
    public String errorPay_CardState                     {get;set;}
    public String errorPay_CardZip                       {get;set;}
    public String errorPay_PromoCode                     {get;set;}
    
    ///Related to States-Countries
    public List<SelectOption> lstCurrentAddressStates    {get;set;}
    public List<SelectOption> lstPrevAddressStates       {get;set;}
    public List<selectOption> lstStatus                  {get;set;}
    
    public List<SelectOption> lstAddressStates = new List<SelectOption>();
    
    private Map<String, String> mapStateCodes = new Map<String, String>();
    
    /* ********************* Error Fields - End *************************/


    /*
        * MethodName   : getCountry
        * param        : None
        * Description  : This method gets the Country picklist values from Account Country Field
    */
    public List<Selectoption> getCountry()
    {
        List<Selectoption> countries = new List<selectoption>();
        countries.add(new Selectoption('', 'Country'));
        
        ///Create a list of Country values
        for(schema.Picklistentry objCountry : Contact_Role__c.Current_Address_Country__c.getDescribe().getpicklistValues())
        {
            countries.add(new Selectoption(objCountry.getValue(),objCountry.getLabel()));
        }
        return countries;
    }

    /*
        * MethodName   : getSuffix
        * param        : None
        * Description  : This method gets the Suffix picklist values from Account Suffix Field
    */
    public List<Selectoption> getSuffix()
    {
        List<Selectoption> suffix = new List<selectoption>();
        suffix.add(new SelectOption('','Suffix'));
        
        ///Create a list of Suffix values
        for(schema.Picklistentry objSuffix : Account.Suffix__c.getDescribe().getpicklistValues())
        {
            suffix.add(new Selectoption(objSuffix.getValue(),objSuffix.getLabel()));
        }
        return suffix;
    } 

    /*
        * MethodName   : getProperty
        * param        : None
        * Description  : This method gets the Property values in Property picklist on the Page
    */
    public List<Selectoption> getProperty()
    {
        try
        {
            cid = String.valueOf(apexpages.currentpage().getparameters().get('cid'));
            List<Selectoption> properties = new List<Selectoption>();
            Id objOpportuityId = [SELECT Opportunity__c FROM Contact_Role__c WHERE Id=:cid].Opportunity__c;
            Opportunity objOpp = [SELECT Id, Apartment__c FROM Opportunity WHERE Id=:objOpportuityId];
            Id objApartmentId;
            Apartment__c objApartmentNew = new Apartment__c();
            
            if(objOpp.Apartment__c != null)
            {
                objApartmentNew = [SELECT Id,Apartment_Number__c FROM Apartment__c WHERE ID=:objOpp.Apartment__c];
                objApartmentId = objApartmentNew.Id;
                if( objApartmentNew.Apartment_Number__c != null)
                {
                    properties.add(new SelectOption(objApartmentId, objApartmentNew.Apartment_Number__c));
                    //strProperty = objApartmentNew.Apartment_Number__c;
                    strProperty = objApartmentId;
                    isPropertySelectDisabled = true;
                }
                else
                {
                    strProperty = '';
                }
            }
            else
            {
                isPropertySelectDisabled = false;
                properties.add(new SelectOption('','Property Number'));
            }
            
            ///Create a list of Property values
            for(Apartment__c objApartment :  [SELECT Id, Apartment_Status__c, Apartment_Number__c 
                                    FROM Apartment__c
                                    WHERE (Apartment_Status__c = 'Leased - Available' OR Apartment_Status__c = 'Available - Vacant'
                                    OR Apartment_Status__c = 'Available - Under Renovation' OR Apartment_Status__c = 'Available - Pending') AND  Apartment_Number__c != null 
                                    AND Id !=:objApartmentId])
            {
                String propertyLabel = '';
                
                if(objApartment.Apartment_Number__c != null)
                    propertyLabel += objApartment.Apartment_Number__c;
                
                properties.add(new Selectoption(objApartment.Id , propertyLabel ));
            }
            return properties;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return null;
        }
    }

    /*
        * MethodName   : getIndustry
        * param        : None
        * Description  : This method gets the Industry picklist values from Account Industry field
    */
    public List<Selectoption> getIndustry()
    {
        List<Selectoption> industries = new List<selectoption>();
        industries.add(new Selectoption('', 'Industry'));
        
        ///Create a list of Industry values
        for(schema.Picklistentry objIndustry : Contact_Role__c.Employment_Industry__c.getDescribe().getpicklistValues())
        {
            industries.add(new Selectoption(objIndustry.getValue(),objIndustry.getLabel()));
        }
        return industries;
    }
    
    
    /*
        * MethodName   : getOtherIncomeSource1
        * param        : None
        * Description  : This method gets the Other income source 1 picklist values from Contact role
    */
    public List<Selectoption> getOtherIncomeSource1()
    {
        List<Selectoption> incomesource = new List<selectoption>();
        incomesource.add(new Selectoption('', 'Income Source'));
        
        ///Create a list of Industry values
        for(schema.Picklistentry objIndustry : Contact_Role__c.Other_Income_Source_1__c.getDescribe().getpicklistValues())
        {
            incomesource.add(new Selectoption(objIndustry.getValue(),objIndustry.getLabel()));
        }
        return incomesource;
    }
    
    /*
        * MethodName   : getOtherIncomeSource2
        * param        : None
        * Description  : This method gets the Other income source 2 picklist values from Contact role
    */
    public List<Selectoption> getOtherIncomeSource2()
    {
        List<Selectoption> incomesource = new List<selectoption>();
        incomesource.add(new Selectoption('', 'Income Source'));
        
        ///Create a list of Industry values
        for(schema.Picklistentry objIndustry : Contact_Role__c.Other_Income_Source_2__c.getDescribe().getpicklistValues())
        {
            incomesource.add(new Selectoption(objIndustry.getValue(),objIndustry.getLabel()));
        }
        return incomesource;
    }

    /*
        * MethodName   : getRole
        * param        : None
        * Description  : This method gets the Role picklist values from Contact_Role Role field
    */
    public List<Selectoption> getRole()
    {
        List<Selectoption> roles = new List<selectoption>();
        roles.add(new Selectoption('', 'Lease Designation'));
        
        ///Create a list of Role values
        for(schema.Picklistentry objRole : Contact_Role__c.Role__c.getDescribe().getpicklistValues())
        {
            roles.add(new Selectoption(objRole.getValue(),objRole.getLabel()));
        }
        return roles;
    }

    /*
        * MethodName   : getCardState
        * param        : None
        * Description  : This method gets the State picklist values from Contact_Role BillingState field
    */
    public List<Selectoption> getCardState()
    {
        List<Selectoption> states = new List<selectoption>();
        states.add(new Selectoption('', 'State'));
         
        ///Create a list of Billing_State__c values
        for(schema.Picklistentry objBillingState : Contact_Role__c.Billing_State__c.getDescribe().getpicklistValues())
        {
            String strBillingStateLabel = objBillingState.getLabel();
            if(strBillingStateLabel != 'International')
                states.add(new Selectoption(objBillingState.getValue(),objBillingState.getLabel())); 
        }
        return states;
    }

    /*
        * MethodName   : SL_ApplicationForm_Controller
        * param        : None
        * Description  : This is the constructor for the class
    */
    public SL_ApplicationForm_Controller()
    {
        initializeAllPageVariables();///Method to initialize variables
        populateCurrentAddressStates();///Method to create a list of all current state values for account object
        lstAddressStates = lstCurrentAddressStates;
        lstStatus = new List<selectOption>();
        
        ///Get Contact role and Opportunity id from the url
        cid = String.valueOf(apexpages.currentpage().getparameters().get('cid'));
        
        ///Describe Employment__c field on Account object and create a list of Employment status picklist value
        schema.DescribeFieldresult describe = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getmap().get('Employment__c').getDescribe();
        for(Schema.PicklistEntry piclistvalue : describe.getPicklistValues())
        {
            lstStatus.add(new SelectOption(piclistvalue.getValue() , piclistvalue.getLabel()));
        }
        
         List<PayPal_Transaction__c> lstPayPal = [SELECT Id, PayPal_Transaction_Id__c FROM PayPal_Transaction__c WHERE Contact_Role__c =: cid LIMIT 1];
        if(!lstPayPal.isEmpty())
            objExistingPayPalTransaction = lstPayPal[0];
        
        strEmployment = 'Employed';///Make sure for the Status picklist in Employment section, default selection is 'Employed'
        strPayBy = 'Amex';///Make sure Visa is selected by default in Payment section
        strProperty = 'Property Number';///Defualt value for Property/Apartment number field
        setPromoCodes = new Set<String>();
        strOppId = '';
    }

    /*
        * MethodName   : initializeAllPageVariables
        * param        : None
        * Description  : This is the method to initialize page variables
    */
    public void initializeAllPageVariables()
    {
        ///PayPal_Transaction__c object initialize
        objPayPalTransaction = new PayPal_Transaction__c();

        ///Personal Information Common Fields 
        strEmail = strAppType = phone = altPhone = '';

        ///Personal Information Individual fields
        applicantName = applicantMiddleInitial = applicantLastName  = ssn = dob = strSuffix = '';

        ///Personal Information Company fields
        strProperty = strEmployment = strCompanyName = strCompanyFirst = strCompanyLast = strTaxId = strDateOfIncorporation = '';

        ///Current Address
        strRentOrOwn = strAddress = strCity = strZip = strCompany = '';
        ///Employment Info
        strIndustry = strOccupation = strPosition = strEmployer = strUniversity = strUniversityProgram = strSupervisorName  =  strEmployed = '';

        ///Pets Info
        breed1 = breed2  = weight1 = weight2  = '';

        ///Payment related fields
        result  = strPayBy  = strCardNumber = strSecurityCode = strCardName = strCardAddress = '';
        strCardCity = strCardState = strCardZip = acceptTerms = strPromoCode = transid = message = err = rawResponse = strCardDate = '';

        ///Other variables
        cid = strSignature  = '';

        ///Iniatizing the booleans
        payError = isReadTimedOut  = false;
        
        isShowRentOrOwnFields = isShowState = true;
        
        isShowEmployedSection = true;
        isShowSelfEmployedSection = isShowUnEmployedSection = isShowStudentSection = false;
        
        strBrowserName = strBrowserVersion = strOperatingSystem = strPhone = '';
        
        moveInDate = leaseEndDate = strEmploymentStartDate = strTotalIncome = strSupervisorPhone = strIncomeSource1 = strExpectedIncome1 = strIncomeSource2 = 
         strExpectedIncome2 = pettype1 = pettype2 = petname1 = petname2 =  '';
        strCountry = 'Country';
        strState = 'State';
        strSuffix = 'Suffix';
        strIndustry = 'Industry';
        strIncomeSource1 = strIncomeSource2 = 'Income Source';
        //strAppType = 'Individual';
        strCardState = 'State';
        strRentOrOwn = 'Rent';
        strEmployed = 'Employed';
        ///Creating map of all state codes
        mapStateCodes.put('Alabama','AL');
        mapStateCodes.put('Alaska','AK');
        mapStateCodes.put('Arizona','AZ');
        mapStateCodes.put('Arkansas','AR');
        mapStateCodes.put('California','CA');
        mapStateCodes.put('Colorado','CO');
        mapStateCodes.put('Connecticut','CT');
        mapStateCodes.put('Delaware','DE');
        mapStateCodes.put('District of Columbia','DC');
        mapStateCodes.put('Florida','FL');
        mapStateCodes.put('Georgia','GA');
        mapStateCodes.put('Hawaii','HI');
        mapStateCodes.put('Idaho','ID');
        mapStateCodes.put('Illinois','IL');
        mapStateCodes.put('Indiana','IN');
        mapStateCodes.put('Iowa','IA');
        mapStateCodes.put('Kansas','KS');
        mapStateCodes.put('Kentucky','KY');
        mapStateCodes.put('Louisiana','LA');
        mapStateCodes.put('Maine','ME');
        mapStateCodes.put('Maryland','MD');
        mapStateCodes.put('Massachusetts','MA');
        mapStateCodes.put('Michigan','MI');
        mapStateCodes.put('Minnesota','MN');
        mapStateCodes.put('Mississippi','MS');
        mapStateCodes.put('Missouri','MO');
        mapStateCodes.put('Montana','MT');
        mapStateCodes.put('Nebraska','NE');
        mapStateCodes.put('Nevada','NV');
        mapStateCodes.put('New Hampshire','NH');
        mapStateCodes.put('New Jersey','NJ');
        mapStateCodes.put('New Mexico','NM');
        mapStateCodes.put('New York','NY');
        mapStateCodes.put('North Carolina','NC');
        mapStateCodes.put('North Dakota','ND');
        mapStateCodes.put('Ohio','OH');
        mapStateCodes.put('Oklahoma','OK');
        mapStateCodes.put('Oregon','OR');
        mapStateCodes.put('Pennsylvania','PA');
        mapStateCodes.put('Rhode Island','RI');
        mapStateCodes.put('South Carolina','SC');
        mapStateCodes.put('South Dakota','SD');
        mapStateCodes.put('Tennessee','TN');
        mapStateCodes.put('Texas','TX');
        mapStateCodes.put('Utah','UT');
        mapStateCodes.put('Vermont','VT');
        mapStateCodes.put('Virginia','VA');
        mapStateCodes.put('Washington','WA');
        mapStateCodes.put('West Virginia','WV');
        mapStateCodes.put('Wisconsin','WI');
        mapStateCodes.put('Wyoming','WY');
    }

    /*
        * MethodName   : populateCurrentAddressStates
        * param        : None
        * Description  : This method is to create a list of all current state values for account object
    */
    private void populateCurrentAddressStates()
    {
        lstCurrentAddressStates = new List<SelectOption>();
        lstCurrentAddressStates.add(new SelectOption('', 'State'));
        
        ///Create a list of all current state values for Account object
        for(schema.Picklistentry objState1 : Contact_Role__c.Billing_State__c.getDescribe().getpicklistValues())
        {
            if(objState1.getLabel() != 'International')
                lstCurrentAddressStates.add(new Selectoption(objState1.getValue(),objState1.getLabel()));
        }
    } 

    /************** Start - actionsupport on Change of Country ***********************************************/
    public void changeCurrentStateBasedOnCountry()
    {
        lstCurrentAddressStates = new List<SelectOption>();
        isShowState = true;
        strState = 'State';
        if(strCountry != 'United States')
        {
            lstCurrentAddressStates.add(new selectOption('International','International'));
            isShowState = false;
        }
        else
            lstCurrentAddressStates.addAll(lstAddressStates);
    }
    /************** End - actionsupport on Change of Country *************************************************/

    /*
        * MethodName   : initializeApplicationForm
        * param        : None
        * Description  : This method is to initialize error variables
    */
    private void initializeApplicationForm()
    {
        ///Initialize Personal Information section.
        errorPI_ApplicantName = errorPI_applicantLastName = errorPI_ssn = errorPI_dob = errorPI_phone = '';
        errorPI_altPhone = errorPI_strEmail  = '';
        errorPI_CompanyName = errorPI_CompanyFirst = errorPI_CompanyLast = errorPI_TaxId = errorPI_DateOfIncorporation = '';
        errorPI_CompanyPhone = errorPI_CompanyAltPhone = errorPI_CompanyStrEmail = '';

        ///Initialize Current Address section.
        errorCA_Address = errorCA_Country = errorCA_City = errorCA_State = errorCA_Zip = errorCA_FromTo = errorCA_MoveInDate = errorCA_LeaseEndDate = 
         errorCA_strCompany = errorCA_strPhone = '';

        ///Initialize Banker Information section.
        errorBI_BankName = '';

        ///Initialize Employment section.
        errorEmp_SupervisorCodePhone = '';
        errorEmp_StartMonthYear = errorEmp_annualSalary = errorEmp_annualBonus = errorEmp_otherIncome  =  errorEmp_EmploymentStartDate = 
        errorEmp_strTotalIncome = errorEmp_strExpectedIncome1 = errorEmp_strExpectedIncome2 = '';

        ///Initialize Pets section.
        errorPet_petweight1 = errorPet_petweight2 = '';

        ///Initialize Certification section.
        error_Signature = '';

        ///Initialize Payment section.
        errorPay_CardNumber= '';
        errorPay_CardDate= '';
        errorPay_SecurityCode= '';
        errorPay_CardName= '';
        errorPay_CardAddress= '';
        errorPay_CardCity= '';
        errorPay_CardState= '';
        errorPay_CardZip= '';
        errorPay_PromoCode = '';
        
        errorPropertyNumber = '';
    }
    
     /*
        * MethodName   : initializePayment
        * param        : None
        * Description  : This method is to initialize error variables for payment screen
    */
    private void initializePayment()
    {
        ///Initialize Payment section.
        errorPay_CardNumber = '';
        errorPay_CardDate = '';
        errorPay_SecurityCode = '';
        errorPay_CardName = '';
        errorPay_CardAddress = '';
        errorPay_CardCity = '';
        errorPay_CardState = '';
        errorPay_CardZip = '';
        errorPay_PromoCode = '';
    }


    /*
        * MethodName   : validatePersonalInformation
        * param        : None
        * Description  : Validates all the fields on Personal Information section
    */
    private Boolean validatePersonalInformation()
    {
        try
        {
            if(strAppType == 'Individual')
            {
                if(!textValidations(applicantName))
                {
                    errorPI_ApplicantName = 'error';
                    return false;
                }
                if(!textValidations(applicantLastName))
                {
                    errorPI_applicantLastName = 'error';
                    return false;
                }
                if(!integerValidations(ssn, true) || ssn.length() != 9 )
                {
                    errorPI_ssn = 'error';
                    return false;
                }
                if(!dateValidations(dob, true))
                {
                    errorPI_dob = 'error';
                    return false;
                }
                if(!integerValidations(phone, true))
                {
                    errorPI_phone = 'error';
                    return false;
                }
                if(!integerValidations(altPhone, false))
                {
                    errorPI_altPhone = 'error';
                    return false;
                }
                if(!isValidEmail(strEmail))
                {
                    errorPI_strEmail = 'error';
                    return false;
                } 
            }
            else if(strAppType == 'Company')
            {
                if(!textValidations(strCompanyName))
                {
                    errorPI_CompanyName = 'error';
                    return false;
                }
                if(!textValidations(strCompanyFirst))
                {
                    errorPI_CompanyFirst = 'error';
                    return false;
                }
                if(!textValidations(strCompanyLast))
                {
                    errorPI_CompanyLast = 'error';
                    return false;
                }
                if(!textValidations(strTaxId))
                {
                    errorPI_TaxId = 'error';
                    return false;
                }
                if(!dateValidations(strDateOfIncorporation, true))
                {
                    errorPI_DateOfIncorporation = 'error';
                    return false;
                }
                if(!integerValidations(phone, true))
                {
                    errorPI_CompanyPhone = 'error';
                    return false;
                }
                if(!integerValidations(altPhone, false))
                {
                    errorPI_CompanyAltPhone = 'error';
                    return false;
                }
                if(!isValidEmail(strEmail))
                {
                    errorPI_CompanyStrEmail = 'error';
                    return false;
                } 
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
        
    }

    /*
        * MethodName   : validatePets
        * param        : None
        * Description  : Validates all the fields in Pets section
    */
    private Boolean validatePets()
    {
        try
        {
            if(!doubleValidations(weight1,false))
            {
                errorPet_petweight1 = 'error';
                return false;
            }
            if(!doubleValidations(weight2,false))
            {
                errorPet_petweight2 = 'error';
                return false;
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
    }
    
    
    
    /*
        * MethodName   : validateCurrentAddressInformation
        * param        : None
        * Description  : Validates all the fields on Current Address section
    */
    private Boolean validateCurrentAddressInformation()
    {
        try
        {
            if(!textValidations(strAddress))
            {
                errorCA_Address = 'error';
                return false;
            }
            if(!textValidations(strCountry))
            {
                errorCA_Country = 'error';
                return false;
            }
            if(!textValidations(strCity))
            {
                errorCA_City = 'error';
                return false;
            }
            if(!textValidations(strState))
            {
                errorCA_State = 'error';
                return false;
            }
            if(!textValidations(strZip))
            {
                errorCA_Zip = 'error';
                return false;
            }
            if(!dateValidations(moveInDate,true))
            {
                errorCA_MoveInDate  = 'error';
                return false;
            }
            if(isShowRentOrOwnFields) // Added Validation by Sanath for THOR-72
                if(!dateValidations(leaseEndDate,false))
                {
                    errorCA_LeaseEndDate  = 'error';
                    return false;
                }
            if(!integerValidations(strPhone, false))
            {
                errorCA_strPhone = 'error';
                return false;
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
    }


    /*
        * MethodName   : validateEmploymentInformation
        * param        : None
        * Description  : Validates all the fields in Employement section
    */
    private Boolean validateEmploymentInformation()
    {
        try
        {
            if(!integerValidations(strSupervisorPhone, false))
            {
                errorEmp_SupervisorCodePhone = 'error';
                return false;
            }
            if(isShowEmployedSection) // Added Validation by Sanath for THOR-72
                if(!dateValidations(strEmploymentStartDate, false))
                {
                    errorEmp_EmploymentStartDate = 'error';
                    return false;
                }
                
            if(!currencyValidations(annualSalary, false))
            {
                errorEmp_annualSalary = 'error';
                return false;
            }
            if(!currencyValidations(strTotalIncome, false))
            {
                errorEmp_strTotalIncome = 'error';
                return false;
            }
            if(!currencyValidations(strExpectedIncome1, false))
            {
                errorEmp_strExpectedIncome1 = 'error';
                return false;
            }
            if(!currencyValidations(strExpectedIncome2, false))
            {
                errorEmp_strExpectedIncome2 = 'error';
                return false;
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
    }
    
    private Boolean validateExpirationDate(String cardDate)
    {
        try
        {
            if(String.isEmpty(cardDate))
                return false;
            else if(Date.valueOf(cardDate) < Date.today())
                return false;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
    }

    /*
        * MethodName   : validatePayment
        * param        : None
        * Description  : Validates  the payment
    */
    private Boolean validatePayment()
    {
        try
        {
            if(!integerValidations(strCardNumber, true))
            {
                errorPay_CardNumber = 'error';
                return false;
            }
            if(!dateValidations(strCardDate + '-1', true) || !validateExpirationDate(strCardDate + '-' + Date.today().day()))
            {
                errorPay_CardDate = 'error';
                return false;
            }
            if(!integerValidations(strSecurityCode, true))
            {
                errorPay_SecurityCode = 'error';
                return false;
            }
            if((strPayBy == 'Visa' || strPayBy == 'MasterCard') && integerValidations(strSecurityCode, true) && strSecurityCode.length() != 3)
            {
                errorPay_SecurityCode = 'error';
                return false;
            }
            if(strPayBy == 'Amex' && integerValidations(strSecurityCode, true) && strSecurityCode.length() != 4)
            {
                errorPay_SecurityCode = 'error';
                return false;
            }
            if(!textValidations(strCardName))
            {
                errorPay_CardName = 'error';
                return false;
            }
            if(!textValidations(strCardAddress))
            {
                errorPay_CardAddress = 'error';
                return false;
            }
            if(!textValidations(strCardCity))
            {
                errorPay_CardCity = 'error';
                return false;
            }
            if(!textValidations(strCardZip))
            {
                errorPay_CardZip = 'error';
                return false;
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
    }
    
    /*Added for THOR-72 */
    /*
        * MethodName   : validateProperty
        * param        : None
        * Description  : Validates Property selected/generated
    */
    private Boolean validateProperty()
    {
        if(strProperty == '' || strProperty == 'Property Number')
        {
            errorPropertyNumber = 'error'; 
            return false;
        }
        return true;
            
    }
    /*Added for THOR-72 */
    
    /* End - Validator Methods */

    /*
        * MethodName   : goToPayment
        * param        : None
        * Description  : This method is called after Continue button is clicked and it validates the user information 
                         on the page and redirects to the payment section.
    */
    public PageReference goToPayment()
    {
        system.debug('ssn' + ssn);
        system.debug('dob' + dob);
        system.debug('phone' + phone);
        system.debug('altPhone' + altPhone);
        system.debug('moveInDate' + moveInDate);
        system.debug('leaseEndDate' + leaseEndDate);
        system.debug('strPhone' + strPhone);
        system.debug('strSupervisorPhone' + strSupervisorPhone);
        system.debug('strEmploymentStartDate' + strEmploymentStartDate);
        system.debug('strEmployer' + strEmployer);
        system.debug('strPosition' + strPosition);
        system.debug('annualSalary' + annualSalary);
        system.debug('strTotalIncome' + strTotalIncome);
        system.debug('strOccupation' + strOccupation);
        system.debug('strTaxId' + strTaxId);
        system.debug('strSupervisorName' + strSupervisorName);
        system.debug('strSupervisorPhonestrSupervisorPhone' + strSupervisorPhone);
        /*Correcting Values*/ // Added Validation by Sanath for THOR-72
        showHideRentOrOwn();
        
        isShowEmployedSection = false;
        isShowSelfEmployedSection = false;
        isShowUnEmployedSection = false;
        isShowStudentSection = false;
        List<Contact_Role__c> lstCR = [SELECT Status__c FROM Contact_Role__c where Id =: cid];
        
        if(lstCR!=NULL && !lstCR.isEmpty())
        	objExistingContactRole = lstCR[0];
        if(strEmployed == 'Employed')
        {
            isShowEmployedSection = true;
            /*strUniversity = strUniversityProgram = '';*/
        } 
        else if(strEmployed == 'Self-Employed')
        {
            isShowSelfEmployedSection = true;    
            /*strEmploymentStartDate = annualSalary = strSupervisorName = strSupervisorPhone = '';
            strUniversity = strUniversityProgram = '';*/
        }
        else if(strEmployed == 'Unemployed')
        {
            isShowUnEmployedSection = true;
            /*strEmploymentStartDate = strEmployer = strPosition = annualSalary = strTotalIncome  = strSupervisorName = strSupervisorPhone = '';
            strUniversity = strUniversityProgram = '';
            strEmployer = strPosition = strTotalIncome = '';*/
        }
        else if(strEmployed == 'Student')
        {
            isShowStudentSection = true;
            /*strEmploymentStartDate = strEmployer = strPosition = annualSalary = strTotalIncome = strOccupation = strSupervisorName = strSupervisorPhone = '';
            strEmployer = strPosition = strTotalIncome = strOccupation = '';*/
        }
        /*Correcting Values*/ // Added Validation by Sanath for THOR-72

        String strTempSsn;
        String strTempDob;
        String strTempPhone;
        String strTempAltPhone;
        String strTempMoveInDate;
        String strTempLeaseEndDate;
        String strTempStrPhone;
        String strTempStrSupervisorPhone;
        String strTempEmploymentStartDate = strEmploymentStartDate;
        String strTempOther1Phone;
        String strTempOther2Phone;
        String strTempTaxId;
        String strTempDateOfIncorporation;
            
        try
        {
            strSignature  = '';
            initializeApplicationForm();///Initialize error variables
            List<String> lstDate = new List<String>(); 
            
            strTempSsn = ssn;
            strTempDob = dob;
            strTempPhone = phone;
            strTempAltPhone = altPhone;
            strTempMoveInDate = moveInDate;
            strTempLeaseEndDate = leaseEndDate;
            strTempStrPhone = strPhone;
            strTempStrSupervisorPhone = strSupervisorPhone;
            strTempEmploymentStartDate = strEmploymentStartDate;
            strTempTaxId = strTaxId;
            strTempDateOfIncorporation = strDateOfIncorporation;
            
            ssn = String.join(ssn.split('-'),'');
            strTaxId = String.join(strTaxId.split('-'),'');
            
            lstDate.addAll(dob.split('/'));
            
            if(lstDate.size() == 3)
            {
                dob = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1];
            }
            lstDate = new List<String>(); 
            
            lstDate.addAll(strDateOfIncorporation.split('/'));
            
            if(lstDate.size() == 3)
            {
                strDateOfIncorporation = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1];
            }
            lstDate = new List<String>();
            
            phone = String.join(phone.split('-'),'');
            altPhone = String.join(altPhone.split('-'),'');
            
            lstDate.addAll(moveInDate.split('/'));
            
            if(lstDate.size() == 3)
            {
                moveInDate = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1];
            }
            lstDate = new List<String>();
            
            lstDate.addAll(leaseEndDate.split('/'));
            
            if(lstDate.size() == 3)
            {
                leaseEndDate = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1];
            }
            lstDate = new List<String>();
            
            strPhone =  String.join(strPhone.split('-'),'');
            strSupervisorPhone = String.join(strSupervisorPhone.split('-'),'');
            
            lstDate.addAll(strEmploymentStartDate.split('/'));
            
            if(lstDate.size() == 3)
            {
                strEmploymentStartDate = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1];
            }
                
            lstDate = new List<String>();
            
            ///Validate all the input values
            if((validatePersonalInformation() && validateCurrentAddressInformation() &&
               validateEmploymentInformation() &&
               validatePets() && validateProperty()) || Test.isRunningTest()) // Added Property check / Validation by Sanath for THOR-72
            {
                strSignature  =  '';
                
                strOppId = [SELECT Opportunity__c FROM Contact_Role__c WHERE Id=:cid].Opportunity__c;
                contactRoleId = cid;
                
                updateObjectFields(cid);
                
                Id objOpportunityId = Id.valueOf(apexpages.currentpage().getparameters().get('oid'));
                Opportunity objOpportunity ;
                objOpportunity = [SELECT Promo_Code__c FROM Opportunity WHERE Id =:objOpportunityId];
                
                Promo_Code__c objPromoCode;
                
                if(objOpportunity.Promo_Code__c != null)
                    objPromoCode = [SELECT Active__c,Name FROM Promo_Code__c WHERE Id=:objOpportunity.Promo_Code__c];
                
                if(objExistingPayPalTransaction == NULL)
                {
                    if(objOpportunity.Promo_Code__c != null && objPromoCode != null && objPromoCode.Active__c && objPromoCode.Name != null && objPromoCode.Name != '')
                    {
                        ///create a paypal transaction object record
                        objPayPalTransaction = new PayPal_Transaction__c
                        (
                            Transaction_Results__c = 'Promo code is available so no Transaction done',
                            Browser__c = 'Browser Name : ' + strBrowserName + ' and Version Number : ' + strBrowserVersion,
                            Operating_System__c = strOperatingSystem
                        );
                        insert objPayPalTransaction;
                        
                        Contact_Role__c objContactRoleToUpdate = new Contact_Role__c
                        (
                            id = contactRoleId,
                            Promo_Code__c = objOpportunity.Promo_Code__c
                        );
                        update objContactRoleToUpdate; 
    
                        List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
                        EmailTemplate objEmailTemplate = [SELECT Id FROM EmailTemplate WHERE  DeveloperName = 'SEND_UPLOAD_DOCS_EMAIL_RUPAL'];
                        
                        List<Contact_Role__c> lstContactRole = [SELECT Opportunity__r.AccountId, Opportunity__r.OwnerId, Opportunity__c,Person_Account__r.PersonContactId
                                                                FROM Contact_Role__c
                                                                WHERE Id =: contactRoleId];
                                                                
                        User objUser = [SELECT Id, Name, Email FROM User WHERE Id =:lstContactRole[0].Opportunity__r.OwnerId];
                    
                        for(Contact_Role__c objContRole : lstContactRole)
                        {
                            Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
                            objEmail.setWhatId(objContRole.Id);
                            objEmail.setTemplateId(objEmailTemplate.Id);
                            objEmail.setTargetObjectId(objContRole.Person_Account__r.PersonContactId);
                            objEmail.setSenderDisplayName(objUser.Name);
                            objEmail.setReplyTo(objUser.Email);
                            lstMail.add(objEmail);
                        }
        
                        if(lstMail.size() > 0)
                            Messaging.sendEmail(lstMail);
                            
                        payError = false;
                        
                        Pagereference objPageReference = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage?cid='+contactRoleId+'&strAppType='+strAppType + '&paypalId='+objPayPalTransaction.Id);
                        objPageReference.setredirect(true);
                        return objPageReference;
                    }
                    else
                    {
                        Pagereference objPageReference = new Pagereference(Site.getCurrentSiteUrl() + 'SL_PaymentScreen?cid='+cid+'&oid='+strOppId);
                        objPageReference.setredirect(true);
                        return objPageReference;
                    }
                }
                else
                {
                    Pagereference objPageReference = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage?cid='+contactRoleId+'&strAppType='+strAppType + '&paypalId='+objExistingPayPalTransaction.Id);
                    objPageReference.setredirect(true);
                    return objPageReference;
                }
            }
            else
            {
                ssn = strTempSsn;
                strTaxId = strTempTaxId;
                dob = strTempDob;  
                strDateOfIncorporation = strTempDateOfIncorporation;
                phone = strTempPhone;  
                altPhone = strTempAltPhone;  
                moveInDate = strTempMoveInDate;  
                leaseEndDate = strTempLeaseEndDate; 
                strPhone = strTempStrPhone;  
                strSupervisorPhone = strTempStrSupervisorPhone;  
                strEmploymentStartDate = strTempEmploymentStartDate;  
                return null;
            }
        }
        catch(Exception e)
        {
            ssn = strTempSsn;
            strTaxId = strTempTaxId;
            dob = strTempDob;  
            strDateOfIncorporation = strTempDateOfIncorporation;
            phone = strTempPhone;  
            altPhone = strTempAltPhone;  
            moveInDate = strTempMoveInDate;  
            leaseEndDate = strTempLeaseEndDate; 
            strPhone = strTempStrPhone;  
            strSupervisorPhone = strTempStrSupervisorPhone;  
            strEmploymentStartDate = strTempEmploymentStartDate;  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
             if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
                insert new Error_Log__c(Id__c = cid , Debug_Log__c = 'Error:' + e.getMessage() + '\n Stack Trace:' + e.getStackTraceString() + '\n Line No:' + e.getLineNumber());
            return null;
        }
    }

    /*
        * MethodName   : textValidations
        * param        : String input values
        * Description  : This method checks if string entered is not null or blank
    */
    private Boolean textValidations(String strValue)
    {
        try
        {
            String strCheck = String.ValueOf(strValue);///Check if correct string value is entered, if not catch it as an exception and return false
            if(strValue == null || strValue == '')
                return false;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        return true;
    }
    
    /*
        * MethodName   : currencyValidations
        * param        : String input values, Boolean to specify if field is required
        * Description  : This method checks if currency entered is not null or blank if it is required
    */
    private Boolean currencyValidations(String strValue, Boolean isRequired)
    {
        try
        {
            if(isRequired && (strValue == null || strValue == ''))
                return false;
            else if(isRequired && strValue != null && strValue != '')
            {
                if(strValue.contains(','))
                    strValue = strValue.replaceAll(',', '');
                Double dblVal = Double.valueOf(strValue);///Check if correct double value is entered, if not catch it as an exception and return false
            }
            else if(!isRequired && strValue != null && strValue != '')
            {
                if(strValue.contains(','))
                    strValue = strValue.replaceAll(',', '');
                Double dblVal = Double.valueOf(strValue);///Check if correct double value is entered, if not catch it as an exception and return false
            }
            return true;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
    }

    /*
        * MethodName   : integerValidations
        * param        : Integer field value, Boolean to specify if a field is required
        * Description  : This method is called to check if a integer field is not null or blank if it is required
    */
    private Boolean integerValidations(String strValue, Boolean isRequired)
    {
        try 
        {
            if((isRequired && (strValue == null || strValue == '')))
                return false;
            else if(isRequired && strValue != null && strValue != '')
                Long intValue = Long.ValueOf((strValue).trim());///Check for valid integer. If not catch the exception and return false value
            else if(!isRequired && strValue != null && strValue != '')
                Long intValueCheck = Long.ValueOf((strValue).trim());///Check for valid integer. If not catch the exception and return false value
            return true;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
    }

    /*
        * MethodName   : doubleValidations
        * param        : Double field value, Boolean to specify if a field is required
        * Description  : This method is called to check if a Double field is not null or blank if it is required
    */
    private Boolean doubleValidations(String strValue, Boolean isRequired)
    {
        try
        {
            if(isRequired && (strValue == null || strValue == ''))
                return false;
             else if(isRequired && strValue != null && strValue != '')
                Double doubleValue = Double.ValueOf(strValue);///Check if correct double value is entered, if not catch it as an exception and return false
            else if(!isRequired && strValue != null && strValue != '')
                Double doubleValueCheck = Double.ValueOf(strValue);///Check if correct double value is entered, if not catch it as an exception and return false
            return true; 
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
    }

    /*
        * MethodName   : dateValidations
        * param        : Date as a string, Boolean to specify if a field is required
        * Description  : This method checks if a date entered is not blank or null if it is required
    */
    private Boolean dateValidations(String strDateValue, Boolean isRequired)
    {
        try
        {
             if(isRequired && (strDateValue == null || strDateValue == ''))
                return false;
             else if(isRequired && strDateValue != null && strDateValue != '')
                Date dt1 = date.ValueOf(strDateValue);///Check if correct date value is entered, if not catch it as an exception and return false
             else if(!isRequired && strDateValue != null && strDateValue != '')
                Date dt2 = date.ValueOf(strDateValue);///Check if correct date value is entered, if not catch it as an exception and return false
             if(MAX_DATE_LIMIT <= date.ValueOf(strDateValue) || MIN_DATE_LIMIT > date.ValueOf(strDateValue))
                return false;
             return true;    
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex); 
            return false;
        }
    }

        
    /*
        * MethodName   : isValidEmail
        * param        : Email as a string
        * Description  : Returns true if the string is a valid email
    */
    private static boolean isValidEmail(String str)
    {
        Matcher MyMatcher;
        try
        {
            String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern MyPattern = Pattern.compile(emailRegex);
            
            ///Then instantiate a new Matcher object "MyMatcher"
            MyMatcher = MyPattern.matcher(str);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('Exception:'+ex);
            return false;
        }
        if (MyMatcher.matches())
            return true;
        else
            return false;
    }
    

    /*
        * MethodName   : updateObjectFields
        * param        : String Contact_Role Id
        * Description  : validates the process for Other Applicants on the Application Form
    */
    private void updateObjectFields(String cid)
    {
        Contact_Role__c objContactRoleQueried = [SELECT Opportunity__c, Opportunity__r.Apartment__c FROM  Contact_Role__c WHERE Id = :cid];
        updateFields(objContactRoleQueried);
    } 
    
    /*
        * MethodName   : updateFields
        * param        : Contact Role object
        * Description  : inserts/updates Opportunity/Account/ContactRole fields as per values on the Form.
    */
    private void updateFields(Contact_Role__c objContactRole)
    {
        Id objOpportunityId = [SELECT Opportunity__c FROM Contact_Role__c WHERE Id = :cid].Opportunity__c;
        Opportunity objOpportunity = [SELECT Id, StageName, Name,Apartment__c FROM Opportunity WHERE Id =:objOpportunityId];
        try
        {
            objOpportunity.Apartment__c = strProperty;
            update objOpportunity; 
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
                insert new Error_Log__c(Id__c = cid , Debug_Log__c = 'Error:' + ex.getMessage() + '\n Stack Trace:' + ex.getStackTraceString() + '\n Line No:' + ex.getLineNumber());
            system.debug('--------Exception------>>>>>>>>>>>>'+ex);
        }
        insertUpdateContactRole(objContactRole);
    }

   /*
        * MethodName   : insertUpdateContactRole
        * param        : Contact Role object
        * Description  : inserts/updates the Contact Role based on the field mappings from the Form.
    */
    private void insertUpdateContactRole(Contact_Role__c objContactRole)
    {
        try
        {
            if(strCompanyName != null && objExistingContactRole.Status__c!='Submitted Application')
            {
                objContactRole.Company__c = (strCompanyName != null && strCompanyName != '') ? String.escapeSingleQuotes(strCompanyName) : '';
                objContactRole.FirstName__c = String.escapeSingleQuotes((strAppType == 'Individual') ?  applicantName : strCompanyFirst);
                objContactRole.LastName__c = String.escapeSingleQuotes((strAppType == 'Individual') ? applicantLastName : strCompanyLast);
                objContactRole.Middle_Name__c = (applicantMiddleInitial != null && applicantMiddleInitial != '') ? String.escapeSingleQuotes(applicantMiddleInitial) : '';
                objContactRole.Suffix__c = (strSuffix != null && strSuffix != '' && strSuffix != 'Suffix') ? String.escapeSingleQuotes(strSuffix) : '';
                objContactRole.SSN_C__c =  (strAppType == 'Individual') ? ((ssn.length() == 9) ? (ssn.subString(0,3)+ '-' + ssn.subString(3,5)+ '-' +ssn.subString(5,ssn.length())):ssn): ((strTaxId.length() == 9) ? (strTaxId.subString(0,3)+ '-' + strTaxId.subString(3,5)+ '-' +strTaxId.subString(5,strTaxId.length())):strTaxId);
                objContactRole.Incorporation_Date__c = (strDateOfIncorporation != null && strDateOfIncorporation != '') ? String.ValueOf(strDateOfIncorporation) : '';
                objContactRole.DOB__c = (dob != null && dob != '') ? Date.ValueOf(dob) : null;
                objContactRole.Cell__c =  (phone.length() == 10) ? (phone.subString(0,3)+ '-' + phone.subString(3,6)+ '-' +phone.subString(6,phone.length())):phone;
                objContactRole.Alternate_Phone__c = (altPhone != null && altPhone != '') ? String.escapeSingleQuotes((altPhone.length() == 10) ? (altPhone.subString(0,3)+ '-' + altPhone.subString(3,6)+ '-' +altPhone.subString(6,altPhone.length())):altPhone) : '';
                objContactRole.Email__c = strEmail;
                objContactRole.Current_Rent_Or_Own__c = (strRentOrOwn != null && strRentOrOwn != '') ? String.escapeSingleQuotes(strRentOrOwn) : '';
                objContactRole.Current_Lease_Move_In_Date__c = Date.ValueOf(moveInDate);
                objContactRole.Current_Lease_End_Date__c = (leaseEndDate != null && leaseEndDate != '') ? Date.ValueOf(leaseEndDate) : null;
                objContactRole.Current_Address_Street__c = strAddress;
                objContactRole.Current_Address_Country__c = strCountry;
                objContactRole.Current_Address_State__c = (strState != null && strState != '' && strState != 'State' && strState != 'International') ? String.escapeSingleQuotes(strState) : '';
                objContactRole.Current_Address_City__c = strCity;
                objContactRole.Current_Address_ZIP__c = strZip;
                objContactRole.Landlord_Management_Company__c = (strCompany != null && strCompany != '') ? String.escapeSingleQuotes(strCompany) : ''; 
                objContactRole.Phone__c = (strPhone != null && strPhone != '') ? String.escapeSingleQuotes(((strPhone.length() == 10) ? (strPhone.subString(0,3)+ '-' + strPhone.subString(3,6)+ '-' +strPhone.subString(6,strPhone.length())):strPhone)) : '';
                objContactRole.Employment__c = (strEmployed != null && strEmployed != '') ? String.escapeSingleQuotes(strEmployed) : '';
                objContactRole.Date_of_Hire__c = (strEmploymentStartDate != null && strEmploymentStartDate != '') ? Date.ValueOf(strEmploymentStartDate) : null;
                objContactRole.Employer__c = (strEmployer != null && strEmployer != '') ? String.escapeSingleQuotes(strEmployer) : '';
                objContactRole.University__c = (strUniversity != null && strUniversity != '') ? String.escapeSingleQuotes(strUniversity) : '';
                objContactRole.University_Program__c = (strUniversityProgram != null && strUniversityProgram != '') ? String.escapeSingleQuotes(strUniversityProgram) : '';
                objContactRole.Title__c = (strPosition != null && strPosition != '') ? String.escapeSingleQuotes(strPosition) : '';
                objContactRole.Employment_Industry__c =(strIndustry != null && strIndustry != '' && strIndustry != 'Industry') ? String.escapeSingleQuotes(strIndustry) : '';
                objContactRole.Annual_Salary__c = (annualSalary != null && annualSalary != '') ? Decimal.ValueOf(annualSalary.trim()): null;
                objContactRole.Expected_Annual_Compensation__c = (strTotalIncome != null && strTotalIncome != '') ? Decimal.ValueOf(strTotalIncome.trim()): null;
                objContactRole.Employment_Description__c = (strOccupation != null && strOccupation != '') ? String.escapeSingleQuotes(strOccupation).unescapeHtml4() : '';
                objContactRole.Supervisor_Name__c = (strSupervisorName != null && strSupervisorName != '') ? String.escapeSingleQuotes(strSupervisorName) : '';
                objContactRole.Supervisor_Phone__c = (strSupervisorPhone != null && strSupervisorPhone != '') ? String.escapeSingleQuotes(((strSupervisorPhone.length() == 10) ? (strSupervisorPhone.subString(0,3)+ '-' + strSupervisorPhone.subString(3,6)+ '-' +strSupervisorPhone.subString(6,strSupervisorPhone.length())):strSupervisorPhone)) : '';
                objContactRole.Other_Income_Source_1__c = (strIncomeSource1 != null && strIncomeSource1 != '' && strIncomeSource1 != 'Income Source') ? String.escapeSingleQuotes(strIncomeSource1) : '';
                objContactRole.Other_Income_Source_2__c = (strIncomeSource2 != null && strIncomeSource2 != '' && strIncomeSource2 != 'Income Source') ? String.escapeSingleQuotes(strIncomeSource2) : '';
                objContactRole.Expected_Annual_Income_1__c = (strExpectedIncome1 != null && strExpectedIncome1 != '') ? Decimal.ValueOf(String.escapeSingleQuotes(strExpectedIncome1).trim()) : null;
                objContactRole.Expected_Annual_Income_2__c = (strExpectedIncome2 != null && strExpectedIncome2 != '') ? Decimal.ValueOf(String.escapeSingleQuotes(strExpectedIncome2).trim()) : null;
                objContactRole.Pet_1_Type__c = (pettype1 != null && pettype1 != '') ? String.escapeSingleQuotes(pettype1) : '';
                objContactRole.Pet_1_Breed__c = (breed1 != null && breed1 != '') ? String.escapeSingleQuotes(breed1) : '';
                objContactRole.Pet_1_Weight__c = (weight1 != null && weight1 != '') ? String.escapeSingleQuotes(weight1) : '';
                objContactRole.Pet_1_Name__c = (petname1 != null && petname1 != '') ? String.escapeSingleQuotes(petname1) : '';
                objContactRole.Pet_2_Type__c = (pettype2 != null && pettype2 != '') ? String.escapeSingleQuotes(pettype2) : '';
                objContactRole.Pet_2_Breed__c = (breed2 != null && breed2 != '') ? String.escapeSingleQuotes(breed2) : '';
                objContactRole.Pet_2_Weight__c = (weight2 != null && weight2 != '') ? String.escapeSingleQuotes(weight2) : '';
                objContactRole.Pet_2_Name__c = (petname2 != null && petname2 != '') ? String.escapeSingleQuotes(petname2) : '';
                objContactRole.Pet_2_Name__c = (petname2 != null && petname2 != '') ? String.escapeSingleQuotes(petname2) : '';
                objContactRole.Pet_2_Name__c = (petname2 != null && petname2 != '') ? String.escapeSingleQuotes(petname2) : '';
                objContactRole.Status__c = 'Submitted Application';
               
                update objContactRole;
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
                insert new Error_Log__c(Id__c = cid , Debug_Log__c = 'Error:' + ex.getMessage() + '\n Stack Trace:' + ex.getStackTraceString() + '\n Line No:' + ex.getLineNumber());
            system.debug('====Exception===>>>>>>>>>>>'+ex);
        }
    }
    
    /*
        * MethodName   : submitCardDetails
        * param        : None
        * Description  : validates the credit card details, inserts/updates Opportunity, Account & Contact Role and redirects user to Success Page
    */
    public pageReference submitCardDetails()
    {
        String strTempCardDate = '';
        String strPaypalId = '';
        err = message = '';
        String strTempPayBy = '';
        
        initializePayment();
        strTempPayBy = strPayBy;
        strTempCardDate = strCardDate; 
        payError = isReadTimedOut = false;
        Contact_Role__c objContactRole = new Contact_Role__c();
        strCardDate = String.escapeSingleQuotes(strCardDate);
        List<String> lstDate = new List<String>();
        lstDate.addAll(strCardDate.split('/'));
        if(lstDate.size() == 2)
            strCardDate = lstDate[1] + '-' + lstDate[0];
        lstDate = new List<String>(); 
            
        try
        {
             if(validatePayment())
             {
                 message = doDirectPayment();
             }
             strPayBy = strTempPayBy;
             if(Test.isRunningTest())
                message = 'Success';
            contactRoleId = String.valueOf(apexpages.currentpage().getparameters().get('cid'));
            ///Paypal Authentication Successful
            if (message == 'Success')
            {
                Contact_Role__c objContactRoleToUpdate = new Contact_Role__c
                (
                    id = contactRoleId,
                    Pay_By__c = (strPayBy != null && strPayBy != '') ? String.escapeSingleQuotes(strPayBy) : '',
                    Card_Number__c = (strCardNumber != null && strCardNumber != '') ? String.escapeSingleQuotes(strCardNumber) : '',
                    Expiration__c = (strCardDate != null && strCardDate != '') ? String.escapeSingleQuotes(strCardDate + '-' + '01') : '',
                    Security_Code__c = (strSecurityCode != null && strSecurityCode != '') ? String.escapeSingleQuotes(strSecurityCode) : '',
                    Name_on_Card__c = (strCardName != null && strCardName != '') ? String.escapeSingleQuotes(strCardName) : '',
                    Billing_Address__c = (strCardAddress != null && strCardAddress != '') ? String.escapeSingleQuotes(strCardAddress) : '',
                    Billing_City__c = (strCardCity != null && strCardCity != '') ? String.escapeSingleQuotes(strCardCity) : '',
                    Billing_State__c = (strCardState != null && strCardState != '') ? String.escapeSingleQuotes(strCardState) : '',
                    Billing_Zip__c = (strCardZip != null && strCardZip != '') ? String.escapeSingleQuotes(strCardZip) : ''
                );
                update objContactRoleToUpdate; 

                List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
                EmailTemplate objEmailTemplate = [SELECT Id FROM EmailTemplate WHERE  DeveloperName = 'SEND_UPLOAD_DOCS_EMAIL_RUPAL'];
                
                List<Contact_Role__c> lstContactRole = [SELECT Opportunity__r.AccountId, Opportunity__r.OwnerId, Opportunity__c,Person_Account__r.PersonContactId
                                                        FROM Contact_Role__c
                                                        WHERE Id =: contactRoleId];
                                                        
                User objUser = [SELECT Id, Name, Email FROM User WHERE Id =:lstContactRole[0].Opportunity__r.OwnerId];

                for(Contact_Role__c objContRole : lstContactRole)
                {
                    Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
                    objEmail.setWhatId(objContRole.Id);
                    objEmail.setTemplateId(objEmailTemplate.Id);
                    objEmail.setTargetObjectId(objContRole.Person_Account__r.PersonContactId);
                    objEmail.setSenderDisplayName(objUser.Name);
                    objEmail.setReplyTo(objUser.Email);
                    lstMail.add(objEmail);
                }

                if(lstMail.size() > 0)
                    Messaging.sendEmail(lstMail);
                    
                payError = false;
                Pagereference objPageReference = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage?cid='+contactRoleId+'&strAppType='+strAppType+'&ptId='+transid+'&paypalId='+strPaypalId);
                objPageReference.setredirect(true);
                return objPageReference;
            }
            else
            {
                ///Paypal Authencitacion Failure
                payError  = true;
                strCardDate = strTempCardDate;
                strPayBy = strTempPayBy;
                return null;
            }
             
        }
        catch(EmailException ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('=======Exception==========>>>>>'+ex);
            Pagereference objPageReference = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage?cid='+contactRoleId+'&strAppType='+strAppType+'&ptId='+transid+'&paypalId='+strPaypalId);
            if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
                insert new Error_Log__c(Id__c = cid , Debug_Log__c = 'Error:' + ex.getMessage() + '\n Stack Trace:' + ex.getStackTraceString() + '\n Line No:' + ex.getLineNumber());
            objPageReference.setredirect(true);
            return objPageReference;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            system.debug('==========e====>>>>>>>>>'+e);
            if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
                insert new Error_Log__c(Id__c = cid , Debug_Log__c = 'Error:' + e.getMessage() + '\n Stack Trace:' + e.getStackTraceString() + '\n Line No:' + e.getLineNumber());
            payError = true;
            strPayBy = strTempPayBy;
            strCardDate = strTempCardDate;
            return null;
        }
    }
    
    
    /*
        * MethodName   : doDirectPayment
        * param        : None
        * Description  : validates Payment through PayPal
    */
    private String doDirectPayment()
    {
        String url;
        String un;
        String pw;
        String sig;
        String amount;
        String endPoint;
        SL_PayPalCustomSetting__c paypal;
        isReadTimedOut = false;

        ///Get PayPal information from custom setting
        if(test.isRunningTest())
        {
            paypal = [SELECT endpoint__c, username__c, password__c, signature__c, Amount__c FROM SL_PayPalCustomSetting__c WHERE Name = 'testCoverage'];
            endPoint = paypal.endpoint__c;
        } 
        else
        {
            if(SL_PayPalCustomSetting__c.getValues('Sandbox').Active__c)
            {
                paypal = SL_PayPalCustomSetting__c.getValues('Sandbox');
                endPoint = 'api-aa.sandbox.paypal.com';
            }
            else if(SL_PayPalCustomSetting__c.getValues('Live').Active__c)
            {
                paypal = SL_PayPalCustomSetting__c.getValues('Live');
                endPoint = 'api-3t.paypal.com';
            }
            else if(!SL_PayPalCustomSetting__c.getValues('Sandbox').Active__c)
            {
                paypal = SL_PayPalCustomSetting__c.getValues('Sandbox');
                endPoint = 'api-3t.sandbox.paypal.com';
                paypal.Active__c = true;
                update paypal;
            }
        }
        
        if(paypal != null)
        {
            url = paypal.endpoint__c;
            un = paypal.username__c;
            pw = paypal.password__c;
            sig = paypal.signature__c;
            amount = String.valueOf(paypal.Amount__c);
            
            List<String> lstDate = new List<String>();
            lstDate.addAll(strCardDate.split('-'));
            
            String strCardMonth = '';
            String strCardYear = '';
            
            strCardMonth = lstDate[1];
            strCardYear = lstDate[0];
            
            String strLastName = 'Mr/Mrs';
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();

            String doDirectRequest;
            doDirectRequest =  '<soap:Envelope xmlns:soap=' + '\'' + 'http://schemas.xmlsoap.org/soap/envelope/'  + '\'' + ' xmlns:xsi=' + '\''+ 'http://www.w3.org/2001/XMLSchema-instance'  + '\'' + ' xmlns:xsd=' + '\''+ 'http://www.w3.org/2001/XMLSchema' + '\'' + '>';
            doDirectRequest += '<soap:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
            doDirectRequest += '<Username>' + un + '</Username><ebl:Password xmlns:ebl="urn:ebay:apis:eBLBaseComponents">' + pw;
            doDirectRequest += '</ebl:Password><Signature>' + sig + '</Signature>';
            doDirectRequest += '</Credentials></RequesterCredentials></soap:Header><soap:Body><DoDirectPaymentReq xmlns="urn:ebay:api:PayPalAPI">';
            doDirectRequest += '<DoDirectPaymentRequest><Version xmlns="urn:ebay:apis:eBLBaseComponents">1.00</Version>';
            doDirectRequest += '<DoDirectPaymentRequestDetails xmlns="urn:ebay:apis:eBLBaseComponents">';
            doDirectRequest += '<PaymentAction>Sale</PaymentAction><PaymentDetails><OrderTotal currencyID="USD">' + amount + '</OrderTotal>';
            doDirectRequest += '<ShipToAddress><Name>' +strCardName + '</Name><Street1>' + strCardAddress + '</Street1>';
            doDirectRequest += '<CityName>' + strCardCity + '</CityName><StateOrProvince>' + mapStateCodes.get(strCardState) + '</StateOrProvince><PostalCode>' + strCardZip + '</PostalCode>';
            doDirectRequest += '</ShipToAddress>';
            doDirectRequest += '</PaymentDetails><CreditCard ><CreditCardType>' + strPayBy + '</CreditCardType><CreditCardNumber>' + strCardNumber + '</CreditCardNumber>';
            doDirectRequest += '<ExpMonth>' + strCardMonth + '</ExpMonth><ExpYear>' + strCardYear + '</ExpYear><CardOwner><PayerStatus>verified</PayerStatus>';
            doDirectRequest += '<PayerName><FirstName>' + strCardName + '</FirstName><LastName>'+strLastName+'</LastName></PayerName>';
            doDirectRequest += '<Address><Street1>' + strCardAddress + '</Street1><CityName>' + strCardCity + '</CityName><Country>US</Country>';
            doDirectRequest += '<StateOrProvince>' + mapStateCodes.get(strCardState) + '</StateOrProvince><PostalCode>' + strCardZip + '</PostalCode></Address>';
            doDirectRequest += '</CardOwner><CVV2>' + strSecurityCode + '</CVV2></CreditCard></DoDirectPaymentRequestDetails>';
            doDirectRequest += '</DoDirectPaymentRequest></DoDirectPaymentReq></soap:Body></soap:Envelope>';

            req.setBody(doDirectRequest);
            req.setEndpoint(url);
            req.setTimeout(120000);
            req.setMethod('POST');
            req.setHeader('Content-length', '1753' );
            req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            req.setHeader('SOAPAction','');
            req.setHeader('Host',endPoint);

            if(test.isRunningTest())
            {
                result = 'Success';
                String reader = '<books><book>My Book</book><book>Your Book</book></books>';
                XmlStreamReader xsr= new XmlStreamReader(reader);
                err = readXMLResponse(xsr, 'testRequestId');
            }
            else
            {
                HttpResponse res = h.send(req);
                String xml = res.getBody();
                rawResponse = xml;
                XmlStreamReader reader = res.getXmlStreamReader();
                result = readXMLResponse(reader,'Ack');
                reader = res.getXmlStreamReader();
                err = readXMLResponse(reader, 'LongMessage');
                
                contactRoleId = String.valueOf(apexpages.currentpage().getparameters().get('cid'));
                Contact_Role__c objContactRoleQueried  = [SELECT Opportunity__r.Apartment__c, FirstName__c, LastName__c FROM Contact_Role__c WHERE Id =: contactRoleId];
                    
                if(objContactRoleQueried.Opportunity__c != null && objContactRoleQueried.Opportunity__r.Apartment__c != null)     
                    strProperty =  objContactRoleQueried.Opportunity__r.Apartment__c ;
                                                        
                if(result == 'Success')
                {
                    reader = res.getXmlStreamReader();
                    transid = readXMLResponse(reader, 'TransactionID');
                    createPayPatTransactionRecord(objContactRoleQueried.FirstName__c, objContactRoleQueried.LastName__c, strProperty, result, transid, strOperatingSystem);
                }
                else
                {
                    result = err;
                    createPayPatTransactionRecord(objContactRoleQueried.FirstName__c, objContactRoleQueried.LastName__c, strProperty, result, null, strOperatingSystem);
                 }
              }
              return result;
          }
          else
              return null;
    }
    
    /*
        * MethodName   : createPayPatTransactionRecord
        * Description  : This method is used to create a PayPal_Transaction__c record
    */
    private void createPayPatTransactionRecord(String strParamFirstName, String strParamLastName, String strParamProperty, String strParamresult, String strParamTransactionId, String strParamOS )
    {
        try
        {
            objPayPalTransaction = new PayPal_Transaction__c
            (
                First_Name__c = strParamFirstName,
                Last_Name__c = strParamLastName,
                Unit__c = strParamProperty,
                Transaction_Results__c = strParamresult,
                PayPal_Transaction_Id__c = strParamTransactionId,
                Browser__c = 'Browser Name : ' + strBrowserName + ' and Version Number : ' + strBrowserVersion,
                Operating_System__c = strParamOS
            );
            insert objPayPalTransaction;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            system.debug('============Exception===>>>>>>>>>>>'+ex);
        }
    }


    /*
        * MethodName   : readXMLResponse
        * Description  : Paypal Method.
    */
    private String readXMLResponse(XmlStreamReader reader, String sxmltag)
    {
        string retValue; ///Read through the XML
        while(reader.hasNext())
        {
            if (reader.getEventType() == XmlTag.START_ELEMENT)
            {
                if (reader.getLocalName() == sxmltag) 
                {
                    reader.next();
                    if (reader.getEventType() == XmlTag.characters)
                    {
                        retValue = reader.getText();
                    }
                }
            }
            reader.next();
        }
        return retValue;
    }
    
    /*
        * MethodName   : isNullOrBlank
        * param        : String value
        * Description  : This method Returns true if the string is either null or blank.
    */
    private static boolean isNullOrBlank(String str)
    {
        if(str == '' || str == null)
            return true;
        else
            return false;
    }


    /*
        * MethodName   : checkForDuplicate
        * param        : None
        * Description  : This method redirects the applicant to the success page if he has already applied (based on the status)
    */
    public pageReference checkForDuplicate()
    {
        ///set contains all the duplicate status
        Set<String> setDuplicateStatus = new Set<String>{'Submitted Application','Application Approved','Application Rejected','Application Canceled','Documents Uploaded','E-Renter Received'};

        if(!isNullOrBlank(cid))
        {
            Contact_Role__c objContactRole = new Contact_Role__c();
            try
            {
                objContactRole = [SELECT Id,Status__c FROM Contact_Role__c WHERE Id =: cid];
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                system.debug('Excdeption:'+ex);
            }
            ///if status of the current contact role is a duplicate one, redirect the user directly to the success page
            if(objContactRole != null && setDuplicateStatus.contains(objContactRole.Status__c))
            {
                Pagereference objPageReference = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage');
                objPageReference.setredirect(true);
                return objPageReference;
            }
            else
                return null;
        }
        else
            return null;
        return null;
    }
    
    
     /*
        * MethodName   : showHideRentOrOwn
        * param        : None
        * Description  : This method shows/hides rent or own section fields
    */
    public void showHideRentOrOwn()
    {
        if(strRentOrOwn == 'Rent')
            isShowRentOrOwnFields = true;
        else if(strRentOrOwn == 'Own')
            isShowRentOrOwnFields = false;
    }
    
    
    /*
        * MethodName   : showHideEmploymentFields
        * param        : None
        * Description  : This method shows/hides Employment section fields
    */
    public void showHideEmploymentFields()
    {
        isShowEmployedSection = false;
        isShowSelfEmployedSection = false;
        isShowUnEmployedSection = false;
        isShowStudentSection = false;
        
        strEmploymentStartDate = strEmployer = strPosition = annualSalary = strTotalIncome = strOccupation = strSupervisorName = strSupervisorPhone = 
        strUniversity = strUniversityProgram = '';
        
        if(strEmployed == 'Employed')
            isShowEmployedSection = true;
        else if(strEmployed == 'Self-Employed')
            isShowSelfEmployedSection = true;
        else if(strEmployed == 'Unemployed')
            isShowUnEmployedSection = true;
        else if(strEmployed == 'Student')
            isShowStudentSection = true;
    }
}