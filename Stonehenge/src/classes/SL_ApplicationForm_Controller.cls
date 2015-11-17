/**
* \Author: Kamal Mehta
* \Date: 21/Dec/2011
* \See http://silverline.jira.com/browse/STONEPII-26
* \Brief : Controller for the Individual/Company Application Form and Payment Form of the Site
*/

public class SL_ApplicationForm_Controller
{
  // PayPal Transaction

  private PayPal_Transaction__c objPayPalTransaction;
  public String strBrowserName {get;set;}
  public String strBrowserVersion {get;set;}
  public String strOperatingSystem {get;set;}

    // Personal Information Common Fields
    public String phoneCode{get;set;}
    public String phoneNumber{get;set;}
    public String phoneNumber1{get;set;}
    public String altPhoneCode{get;set;}
    public String altPhoneNumber{get;set;}
    public String altPhoneNumber1{get;set;}
    public String strEmail{get;set;}
    public String strAppType{get;set;}

    // Personal Information Individual fields
    public String applicantName{get;set;}
    public String applicantMiddleInitial{get;set;}
    public String applicantLastName{get;set;}
    public String ssn1{get;set;}
    public String ssn2{get;set;}
    public String ssn3{get;set;}
    public String dobDate{get;set;}
    public String dobMonth{get;set;}
    public String dobYear{get;set;}
    public String strSuffix{get;set;}

    // Personal Information Company fields
    public String strCompanyName{get;set;}
    public String strCompanyFirst{get;set;}
    public String strCompanyLast{get;set;}
    public String strTaxId{get;set;}
    public String strDateOfIncorporationD{get;set;}
    public String strDateOfIncorporationM{get;set;}
    public String strDateOfIncorporationY{get;set;}
    public String strProperty{get;set;}
    public String strEmployment{get;set;}

    // Current Address
    public String strRentOrOwn{get;set;}
    public String strAddress{get;set;}
    public String strCountry{get;set;}
    public String strCity{get;set;}
    public String strState{get;set;}
    public String strZip{get;set;}
    public String strFromMonth{get;set;}
    public String strFromYear{get;set;}
    public String strToMonth{get;set;}
    public String strToYear{get;set;}

    // Previous Address
    public String strPrevRentOrOwn{get;set;}
    public String strPrevAddress{get;set;}
    public String strPrevCountry{get;set;}
    public String strPrevCity{get;set;}
    public String strPrevState{get;set;}
    public STring strPrevZip{get;set;}
    public String strPrevFromMonth{get;set;}
    public String strPrevFromYear{get;set;}
    public String strPrevToMonth{get;set;}
    public String strPrevToYear{get;set;}

    // Bank Info
    public String strBankName{get;set;}

    // Employment Info
    public String strIndustry{get;set;}
    public String strOccupation{get;set;}
    public String strPosition{get;set;}
    public String strEmployer{get;set;}
    public String strSupervisorName{get;set;}
    public String strSupervisorCode{get;set;}
    public String strSupervisorPhone1{get;set;}
    public String strSupervisorPhone2{get;set;}
    public String strStartMonth{get;set;}
    public String strStartYear{get;set;}
    public String annualSalary{get;set;}
    public String annualBonus{get;set;}
    public String strOtherIncomeSource{get;set;}
    public String otherIncome{get;set;}

    //Pets Info
    public Integer numberOfPets{get;set;}
    public String breed1{get;set;}
    public String breed2{get;set;}
    public String breed3{get;set;}
    public String weight1{get;set;}
    public String weight2{get;set;}
    public String weight3{get;set;}

    // Property Info
    public String propertyId{get;set;}

    // Other Applicants
    public Integer numberOfApplicants{get;set;}
    public String other1FirstName{get;set;}
    public String other1LastName{get;set;}
    public String other1Email{get;set;}
    public String other1Role{get;set;}
    public String other2FirstName{get;set;}
    public String other2LastName{get;set;}
    public String other2Email{get;set;}
    public String other2Role{get;set;}
    public String other3FirstName{get;set;}
    public String other3LastName{get;set;}
    public String other3Email{get;set;}
    public String other3Role{get;set;}
    public String other4FirstName{get;set;}
    public String other4LastName{get;set;}
    public String other4Email{get;set;}
    public String other4Role{get;set;}

    // Certification Info
    public String signatureFirst{get;set;}
    public String signatureMiddle{get;set;}
    public String signatureLast{get;set;}

    // Payment related fields
    public String result {get;set;}
    public String strPayBy{get;set;}
    public String strPropertyName{get;set;}
    public String strCardNumber{get;set;}
    public String strCardMonth{get;set;}
    public String strCardYear{get;set;}
    public String strSecurityCode{get;set;}
    public String strCardName{get;set;}
    public String strCardAddress{get;set;}
    public String strCardCity{get;set;}
    public String strCardState{get;set;}
    public String strCardZip{get;set;}
    public String acceptTerms{get;set;}
    public String strPromoCode{get;set;}
    public string transid {get; set;}
    public string message {get; set; }
    public string err {get; set; }
    public string rawResponse {get; set; }
    public Integer maxLength{get;set;}

    // URL parameters passed to Success page
    public Id contactRoleId {get;set;}
    public Set<String> setPromoCodes = new Set<String>();

    public String cid;
    private String strOppId;//Used for StonePII-89
    private Map<String,List<String>> mapOtherDetails = new Map<String,List<String>>();
    private String strSignature;
    private String strStartDate;
    private String strToDate;
    private String strFromDate;
    private Date dateOfBirth;
    private Date dateOfIncorporation;
    private Boolean isLeadConverted;

    public Boolean isAdditionalApplicant {get;set;}
    public Boolean isValid{get;set;}
    public Boolean hasError{get;set;}
    public Boolean payError{get;set;}
    public Boolean isReadTimedOut  {get;set;}

/* ********************* Error Fields - Start *************************/

    // Personal information for Individual Application
    public String errorPI_ApplicantName{get;set;}
    public String errorPI_applicantLastName{get;set;}
    public String errorPI_ssn{get;set;}
    public String errorPI_dob{get;set;}
    public String errorPI_phone{get;set;}
    public String errorPI_altPhone{get;set;}
    public String errorPI_strEmail{get;set;}

    // Personal Information for Company Application
    public String errorPI_CompanyName{get;set;}
    public String errorPI_CompanyFirst{get;set;}
    public String errorPI_CompanyLast{get;set;}
    public String errorPI_TaxId{get;set;}
    public String errorPI_DateOfIncorporationD{get;set;}
    //public String errorPI_DateOfIncorporationM{get;set;}
    //public String errorPI_DateOfIncorporationY{get;set;}
    public String errorPI_CompanyPhone{get;set;}
    public String errorPI_CompanyAltPhone{get;set;}
    public String errorPI_CompanyStrEmail{get;set;}

    // Current Address
    public String errorCA_Address{get;set;}
    public String errorCA_Country{get;set;}
    public String errorCA_City{get;set;}
    public String errorCA_State{get;set;}
    public String errorCA_Zip{get;set;}
    public String errorCA_FromTo{get;set;}

    // Previous Address
    public String errorPA_PrevZip{get;set;}
    public String errorPA_PrevFromTo{get;set;}

    // Bank Information
    public String errorBI_BankName{get;set;}

    // Employment
    public String errorEmp_Occupation{get;set;}
    public String errorEmp_Position{get;set;}
    public String errorEmp_Employer{get;set;}
    public String errorEmp_SupervisorName{get;set;}
    public String errorEmp_SupervisorCodePhone{get;set;}
    public String errorEmp_StartMonthYear{get;set;}
    public String errorEmp_annualSalary{get;set;}
    public String errorEmp_annualBonus{get;set;}
    public String errorEmp_otherIncome{get;set;}

    // Pets
    public String errorPet_breed{get;set;}
    public String errorPet_weight{get;set;}

    // Other Applicants
    public String errorOA_Other1FirstName{get;set;}
    public String errorOA_Other1LastName{get;set;}
    public String errorOA_Other1Email{get;set;}
    public String errorOA_Other2FirstName{get;set;}
    public String errorOA_Other2LastName{get;set;}
    public String errorOA_Other2Email{get;set;}
    public String errorOA_Other3FirstName{get;set;}
    public String errorOA_Other3LastName{get;set;}
    public String errorOA_Other3Email{get;set;}
    public String errorOA_Other4FirstName{get;set;}
    public String errorOA_Other4LastName{get;set;}
    public String errorOA_Other4Email{get;set;}

    // Certification
    public String error_Signature{get;set;}

    // Payment Section
    public String errorPay_CardNumber{get;set;}
    public String errorPay_SecurityCode{get;set;}
    public String errorPay_CardName{get;set;}
    public String errorPay_CardDate{get;set;}
    public String errorPay_CardAddress{get;set;}
    public String errorPay_CardCity{get;set;}
    public String errorPay_CardState{get;set;}
    public String errorPay_CardZip{get;set;}
    public String errorPay_PromoCode{get;set;}

    private static Id ACCOUNT_RECORDTYPE_ID = [Select Id From RecordType Where Name = 'Client/Tenant Account' And SobjectType='Account'].Id;
    // Related to States-Countries
    public List<SelectOption> lstCurrentAddressStates {get;set;}
    public List<SelectOption> lstPrevAddressStates {get;set;}
    public List<SelectOption> lstAddressStates = new List<SelectOption>();

    private Map<String, String> mapStateCodes = new Map<String, String>();
    private String aa;
  public List<selectOption> lstStatus {get;set;}

/* ********************* Error Fields - End *************************/

    /*  getting Country picklist values from Account Country Field  */
    public List<Selectoption> getCountry()
    {
        List<Selectoption> countries = new List<selectoption>();
        countries.add(new Selectoption('', ''));
        for(schema.Picklistentry c : Account.Country__c.getDescribe().getpicklistValues())
        {
            countries.add(new Selectoption(c.getValue(),c.getLabel()));
        }
        return countries;
    }


    /*  getting Suffix picklist values from Account Suffix Field    */
    public List<Selectoption> getSuffix()
    {
        List<Selectoption> suffix = new List<selectoption>();
        suffix.add(new SelectOption('','None'));
        for(schema.Picklistentry c : Account.Suffix__c.getDescribe().getpicklistValues())
        {
            suffix.add(new Selectoption(c.getValue(),c.getLabel()));
        }
        return suffix;
    }

    /*  getting Previous Country picklist values from Account Previous Country Field    */
    public List<Selectoption> getPrevCountry()
    {
        List<Selectoption> countries = new List<selectoption>();
        countries.add(new Selectoption('', ''));
        for(schema.Picklistentry c : Account.Previous_Country__c.getDescribe().getpicklistValues())
        {
            countries.add(new Selectoption(c.getValue(),c.getLabel()));
        }
        return countries;
    }

    /*  getting Property values in Property picklist on the Page    */
    public List<Selectoption> getProperty()
    {
        List<Selectoption> properties = new List<Selectoption>();

        // PS: The list of Select options are filtered
        for(Property__c property : [Select Id, Unit_Status__c, Unit_Number__c, Property_Name_Friendly__c From Property__c
                                    Where Unit_Status__c = '2. Rent Ready' OR Unit_Status__c = '3. Renovating' 
                                       OR Unit_Status__c = '4. Not Started' OR Unit_Status__c = '5. Notice'
                                       OR Unit_Status__c = '8. Roommate Change'
                                    Order By Property_Name_Friendly__c ASC])
        {
            String propertyLabel = '';

            if(property.Property_Name_Friendly__c != null && property.Unit_Number__c != null)
                propertyLabel += property.Property_Name_Friendly__c + '- ' + property.Unit_Number__c;
            else if((property.Property_Name_Friendly__c != null && property.Unit_Number__c == null))
                propertyLabel += property.Property_Name_Friendly__c;
            else if((property.Property_Name_Friendly__c == null && property.Unit_Number__c != null))
                propertyLabel += property.Unit_Number__c;

            try
            {
                if(propertyId != null && propertyId != '' && property.Id == propertyId)
                {
                    strPropertyName = propertyLabel;
                }
            }
            catch(Exception e)
            {
                // Do nothing
            }
            properties.add(new Selectoption(property.Id,propertyLabel));

        }
        if(strPropertyName == '')strPropertyName = 'Invalid Property';
        return properties;
    }

    /*  getting Industry picklist values from Account Industry field    */
    public List<Selectoption> getIndustry()
    {
        List<Selectoption> industries = new List<selectoption>();
        for(schema.Picklistentry i : Account.Industry.getDescribe().getpicklistValues())
        {
            industries.add(new Selectoption(i.getValue(),i.getLabel()));
        }
        return industries;
    }

    /*  getting Role picklist values from Contact_Role Role field   */
    public List<Selectoption> getRole()
    {
        List<Selectoption> roles = new List<selectoption>();
        for(schema.Picklistentry r : Contact_Role__c.Role__c.getDescribe().getpicklistValues())
        {
            roles.add(new Selectoption(r.getValue(),r.getLabel()));
        }
        return roles;
    }

    /*  getting State picklist values from Contact_Role BillingState field  */
    public List<Selectoption> getCardState()
    {
        List<Selectoption> states = new List<selectoption>();
        for(schema.Picklistentry bs : Contact_Role__c.Billing_State__c.getDescribe().getpicklistValues())
        {
            String temp = bs.getLabel();
            if(temp != 'International')
                states.add(new Selectoption(bs.getValue(),mapStateCodes.get(temp)));
        }
        return states;
    }


    /********************************************* Start - Constructor ******************************************/
        public SL_ApplicationForm_Controller()
        {
            initializeAllPageVariables();
            populateCurrentAddressStates();
            populatePreviousAddressStates();
            lstAddressStates = lstCurrentAddressStates;
            lstStatus = new List<selectOption>();
            /*  getting the parameter values using Cookies  */
            if(ApexPages.currentPage().getCookies().containsKey('cid'))
            {
              cid = String.valueOf(ApexPages.currentPage().getCookies().get('cid'));
              cid = cid.substring(cid.indexOf('cid=') + 4, cid.indexOf('cid=') + 19);
            }

            if(ApexPages.currentPage().getCookies().containsKey('pid'))
            {
              propertyId = String.valueOf(ApexPages.currentPage().getCookies().get('pid'));
              propertyId = propertyId.substring(propertyId.indexOf('pid=') + 4, propertyId.indexOf('pid=') + 19);
            }
            if(ApexPages.currentPage().getCookies().containsKey('aa'))
            {
              aa = String.valueOf(ApexPages.currentPage().getCookies().get('aa'));
              aa = aa.substring(aa.indexOf('aa=') + 3, aa.indexOf('a=') + 4);
            }

            /*  getting the parameter values using Cookies  */
            schema.DescribeFieldresult describe = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getmap().get('Employment__c').getDescribe();
      for(Schema.PicklistEntry piclistvalue : describe.getPicklistValues())
      {
        lstStatus.add(new SelectOption(piclistvalue.getValue() , piclistvalue.getLabel()));
      }

            strRentOrOwn = 'Rent';
            strPrevRentOrOwn = 'Rent';
            strEmployment = 'Employed';
            strAppType = 'Individual';
            strPayBy = 'Visa';
            dobDate = strDateOfIncorporationD ='dd';
            strStartMonth = strCardMonth = strDateOfIncorporationM = dobMonth = strFromMonth = strToMonth = strPrevToMonth = strPrevFromMonth = 'mm';
            strStartYear = strDateOfIncorporationY = dobYear = strFromYear = strToYear = strPrevToYear = strPrevFromYear = 'yyyy';
            strCardYear = 'YY';
            signatureFirst = 'First';
            signatureMiddle = 'M';
            signatureLast = 'Last';

            strProperty = (propertyId != null) ? propertyId : '';
            //String aa = ApexPages.currentPage().getParameters().get('aa');
            isAdditionalApplicant = (aa != null) ? true : false;
            setPromoCodes = new Set<String>();
            isLeadConverted = false;
            strOppId = '';

        }
    /********************************************* End - Constructor ******************************************/

    /* Start - Initialize all page variables */
    public void initializeAllPageVariables()
    {
      strBrowserName = '';
      strBrowserVersion = '';
      strOperatingSystem = '';
      // PayPal_Transaction__c object initialize

      objPayPalTransaction = new PayPal_Transaction__c();

        // Personal Information Common Fields
         phoneCode = phoneNumber = phoneNumber1 = altPhoneCode = altPhoneNumber = altPhoneNumber1 = strEmail = strAppType = '';

        // Personal Information Individual fields
         applicantName = applicantMiddleInitial = applicantLastName = ssn1 = ssn2 = ssn3 = dobDate = dobMonth = dobYear = strSuffix = '';

        // Personal Information Company fields
         strCompanyName = strCompanyFirst = strCompanyLast = strTaxId = strDateOfIncorporationD = strDateOfIncorporationM = '';
         strDateOfIncorporationY = strProperty = strEmployment = '';

        // Current Address
         strRentOrOwn = strAddress = strCountry = strCity = strState = strZip = strFromMonth = strFromYear = strToMonth = strToYear = '';

        // Previous Address
         strPrevRentOrOwn = strPrevAddress = strPrevCountry = strPrevCity = strPrevState = strPrevZip = strPrevFromMonth = strPrevFromYear ='';
         strPrevToMonth = strPrevToYear = '';

        // Bank Info
         strBankName = '';

        // Employment Info
         strIndustry = strOccupation = strPosition = strEmployer = strSupervisorName = strSupervisorCode = strSupervisorPhone1 = strSupervisorPhone2 = '';
         strStartMonth = strStartYear = strOtherIncomeSource = '';
         //annualSalary = annualBonus = otherIncome = '0';

        //Pets Info
        numberOfPets = 0;
        breed1 = breed2 = breed3 = weight1 = weight2 = weight3 = '';

        // Property Info
        propertyId = '';

        // Other Applicants
        numberOfApplicants = 0;
        other1FirstName = other1LastName = other1Email = other1Role = other2FirstName = other2LastName = other2Email = other2Role = '';
        other3FirstName = other3LastName = other3Email = other3Role = other4FirstName = other4LastName = other4Email = other4Role = '';

        // Certification Info
        signatureFirst = signatureMiddle = signatureLast = '';

        // Payment related fields
         result  = strPayBy = strPropertyName = strCardNumber = strCardMonth = strCardYear = strSecurityCode = strCardName = strCardAddress = '';
         strCardCity = strCardState = strCardZip = acceptTerms = strPromoCode = transid = message = err = rawResponse = '';

        // Other variables
        cid = strSignature = strStartDate = strToDate = strFromDate = '';

        // Iniatizing the booleans
        isAdditionalApplicant = isValid = hasError = payError = isReadTimedOut = false;

        //getting all state codes
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
    /* End - Initialize all page variables */


    /*************************************** Start - Getting State picklist values ****************************/
        public void populateCurrentAddressStates()
        {
            //List<Selectoption> states = new List<selectoption>();
            lstCurrentAddressStates = new List<SelectOption>();
            lstCurrentAddressStates.add(new SelectOption('', ''));
            for(schema.Picklistentry s : Account.State1__c.getDescribe().getpicklistValues())
            {
                if(s.getLabel() != 'International')
                    lstCurrentAddressStates.add(new Selectoption(s.getValue(),s.getLabel()));
            }
        }

        public void populatePreviousAddressStates()
        {
            lstPrevAddressStates = new List<SelectOption>();
            lstPrevAddressStates.add(new SelectOption('', ''));
            for(schema.Picklistentry s : Account.Previous_State__c.getDescribe().getpicklistValues())
            {
                if(s.getLabel() != 'International')
                    lstPrevAddressStates.add(new Selectoption(s.getValue(),s.getLabel()));
            }
        }
    /*************************************** End - Getting State picklist values *****************************/


    /************** Start - actionsupport on Change of Country ***********************************************/
        public void changeCurrentStateBasedOnCountry()
        {
            lstCurrentAddressStates = new List<SelectOption>();
            if(strCountry != 'United States')
                lstCurrentAddressStates.add(new selectOption('International','International'));
            else
                lstCurrentAddressStates.addAll(lstAddressStates);
        }

        public void changePrevStateBasedOnCountry()
        {
            lstPrevAddressStates = new List<SelectOption>();
            if(strPrevCountry != 'United States')
                lstPrevAddressStates.add(new selectOption('International','International'));
            else
                lstPrevAddressStates.addAll(lstAddressStates);
        }
    /************** End - actionsupport on Change of Country *************************************************/

    /* Start - Initialize all error variables */
        public void initializeApplicationForm()
        {
            // Initialize Personal Information section.
            errorPI_ApplicantName = errorPI_applicantLastName = errorPI_ssn = errorPI_dob = errorPI_phone = '';
            errorPI_altPhone = errorPI_strEmail = '';
            errorPI_CompanyName = errorPI_CompanyFirst = errorPI_CompanyLast = errorPI_TaxId = errorPI_DateOfIncorporationD = '';
            errorPI_CompanyPhone = errorPI_CompanyAltPhone = errorPI_CompanyStrEmail = '';

            // Initialize Current Address section.
            errorCA_Address = errorCA_Country = errorCA_City = errorCA_State = errorCA_Zip = errorCA_FromTo = '';

            // Initialize Previous Address section.
            errorPA_PrevZip = errorPA_PrevFromTo = '';

            // Initialize Banker Information section.
            errorBI_BankName = '';

            // Initialize Employment section.
            errorEmp_Occupation = errorEmp_Position = errorEmp_Employer = errorEmp_SupervisorName = errorEmp_SupervisorCodePhone = '';
            errorEmp_StartMonthYear = errorEmp_annualSalary = errorEmp_annualBonus = errorEmp_otherIncome = '';

            // Initialize Pets section.
            errorPet_breed = errorPet_weight = '';

            // Initialize Other Applicants.
            errorOA_Other1FirstName = errorOA_Other1LastName = errorOA_Other1Email = errorOA_Other2FirstName = errorOA_Other2LastName = errorOA_Other2Email = '';
            errorOA_Other3FirstName = errorOA_Other3LastName = errorOA_Other3Email = errorOA_Other4FirstName = errorOA_Other4LastName = errorOA_Other4Email = '';

            //Initialize Certification section.
            error_Signature = '';

            // Initialize Payment section.
            errorPay_CardNumber= '';
            errorPay_CardDate= '';
            errorPay_SecurityCode= '';
            errorPay_CardName= '';
            errorPay_CardAddress= '';
            errorPay_CardCity= '';
            errorPay_CardState= '';
            errorPay_CardZip= '';
            errorPay_PromoCode = '';
        }

        public void initializePayment()
        {
            // Initialize Payment section.
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
    /* End - Initialize all error variables */


    /* Start - Validator Methods*/
        /* Validates all the fields on Personal Information section */
            public Boolean validatePersonalInformation()
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
                    if(!integerValidations(ssn1, true))
                    {
                        errorPI_ssn = 'error';
                        return false;
                    }
                    if(!integerValidations(ssn2, true))
                    {
                        errorPI_ssn = 'error';
                        return false;
                    }
                    if(!integerValidations(ssn3, true))
                    {
                        errorPI_ssn = 'error';
                        return false;
                    }

                    // Additional check on SSN number for 9 digits
                    String tempSSN = ssn1 + ssn2 + ssn3;
                    if(tempSSN.length() < 9)
                    {
                        errorPI_ssn = 'error';
                        return false;
                    }

                    if(!dateValidations(dobMonth + '/' + dobDate + '/' + dobYear, true))
                    {
                        errorPI_dob = 'error';
                        return false;
                    }
                    if(!integerValidations(phoneCode, true))
                    {
                        errorPI_phone = 'error';
                        return false;
                    }
                    if(!integerValidations(phoneNumber, true))
                    {
                        errorPI_phone = 'error';
                        return false;
                    }
                    if(!integerValidations(phoneNumber1, true))
                    {
                        errorPI_phone = 'error';
                        return false;
                    }
                    if(!integerValidations(altPhoneCode, false))
                    {
                        errorPI_altPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(altPhoneNumber, false))
                    {
                        errorPI_altPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(altPhoneNumber1, false))
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
                    if(!dateValidations(strDateOfIncorporationM + '/' + strDateOfIncorporationD + '/' + strDateOfIncorporationY, true))
                    {
                        errorPI_DateOfIncorporationD = 'error';
                        return false;
                    }
                    if(!integerValidations(phoneCode, true))
                    {
                        errorPI_CompanyPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(phoneNumber, true))
                    {
                        errorPI_CompanyPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(phoneNumber1, true))
                    {
                        errorPI_CompanyPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(altPhoneCode, false))
                    {
                        errorPI_CompanyAltPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(altPhoneNumber, false))
                    {
                        errorPI_CompanyAltPhone = 'error';
                        return false;
                    }
                    if(!integerValidations(altPhoneNumber1, false))
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
                return true;
            }

            /* Validates all the fields on Current Address section */
            public Boolean validateCurrentAddressInformation()
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
                if(!integerValidations(strZip, true))
                {
                    errorCA_Zip = 'error';
                    return false;
                }
                if(!dateRangeValidations(strFromMonth + '/1/'+ strFromYear, strToMonth + '/1/' + strToYear, true))
                {
                    errorCA_FromTo = 'error';
                    return false;
                }
                return true;
            }

            public Boolean validatePreviousAddressInformation()
            {
                if(!integerValidations(strPrevZip, false))
                {
                    errorPA_PrevZip = 'error';
                    return false;
                }
                if(!dateRangeValidations(strPrevFromMonth + '/1/' + strPrevFromYear, strPrevToMonth + '/1/' + strPrevToYear, false))
                {
                    errorPA_PrevFromTo = 'error';
                    return false;
                }
                return true;
            }

            public Boolean validateBankInformation()
            {
                if(!textValidations(strBankName))
                {
                    errorBI_BankName = 'error';
                    return false;
                }
                return true;
            }

            public Boolean validateEmploymentInformation()
            {
                if(!textValidations(strOccupation))
                {
                    errorEmp_Occupation = 'error';
                    return false;
                }
                if(!textValidations(strPosition))
                {
                    errorEmp_Position = 'error';
                    return false;
                }
                if(!textValidations(strEmployer))
                {
                    errorEmp_Employer = 'error';
                    return false;
                }
                if(!integerValidations(strSupervisorCode, false))
                {
                    errorEmp_SupervisorCodePhone = 'error';
                    return false;
                }
                if(!integerValidations(strSupervisorPhone1, false))
                {
                    errorEmp_SupervisorCodePhone = 'error';
                    return false;
                }
                if(!integerValidations(strSupervisorPhone2, false))
                {
                    errorEmp_SupervisorCodePhone = 'error';
                    return false;
                }
                if(!dateValidations(1 + '/' + strStartMonth + '/' + strStartYear, true))
                {
                    errorEmp_StartMonthYear = 'error';
                    return false;
                }

              /*  if(annualSalary != '0' && annualSalary.contains(','))
                {
                    errorEmp_annualSalary = 'error';
                    return false;
                }
              */

                if(!currencyValidations(annualSalary, true))
                {
                    errorEmp_annualSalary = 'error';
                    return false;
                }

               /* if(annualBonus != '0' && annualBonus.contains(','))
                {
                    errorEmp_annualBonus = 'error';
                    return false;
                }*/

                if(!currencyValidations(annualBonus, false))
                {
                    errorEmp_annualBonus = 'error';
                    return false;
                }

               /* if(otherIncome != '0' && otherIncome.contains(','))
                {
                    errorEmp_otherIncome = 'error';
                    return false;
                }*/

                if(!currencyValidations(otherIncome, false))
                {
                    errorEmp_otherIncome = 'error';
                    return false;
                }
                return true;
            }

            public Boolean validatePets()
            {
                if(textValidations(breed1) && !textValidations(weight1))
                {
                  errorPet_weight = 'error';
                    return false;
                }

                if(textValidations(breed2) && !textValidations(weight2))
                {
                  errorPet_weight = 'error';
                    return false;
                }

                if(textValidations(breed3) && !textValidations(weight3))
                {
                  errorPet_weight = 'error';
                    return false;
                }

                if(textValidations(weight1) && !textValidations(breed1))
                {
                  errorPet_breed = 'error';
                    return false;
                }

                if(textValidations(weight2) && !textValidations(breed2))
                {
                  errorPet_breed = 'error';
                    return false;
                }

                if(textValidations(weight3) && !textValidations(breed3))
                {
                  errorPet_breed = 'error';
                    return false;
                }

                if(textValidations(weight1) && Double.valueOf(weight1) > 50 && !textValidations(weight2) && !textValidations(weight3))
                {
                  errorPet_weight='error';
                    return false;
                }

                else if(textValidations(weight1) && textValidations(weight2) && !textValidations(weight3) && (Double.valueOf(weight1) + Double.valueOf(weight2) > 50))
                {
                  errorPet_weight='error';
                    return false;
                }

                else if(textValidations(weight1) && textValidations(weight2) && textValidations(weight3) && (Double.valueOf(weight1) + Double.valueOf(weight2) + Double.valueOf(weight3) > 50.00))
                {
                    errorPet_weight='error';
                    return false;
                }
                return true;
            }

            public Boolean validateOtherApplicants()
            {
                if(numberOfApplicants == 1)
                {
                    if(!textValidations(other1FirstName))
                    {
                        errorOA_Other1FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other1LastName))
                    {
                        errorOA_Other1LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other1Email))
                    {
                        errorOA_Other1Email = 'error';
                        return false;
                    }
                }
                else if(numberOfApplicants == 2)
                {
                    if(!textValidations(other1FirstName))
                    {
                        errorOA_Other1FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other1LastName))
                    {
                        errorOA_Other1LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other1Email))
                    {
                        errorOA_Other1Email = 'error';
                        return false;
                    }
                    if(!textValidations(other2FirstName))
                    {
                        errorOA_Other2FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other2LastName))
                    {
                        errorOA_Other2LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other2Email))
                    {
                        errorOA_Other2Email = 'error';
                        return false;
                    }
                }
                else if(numberOfApplicants == 3)
                {
                    if(!textValidations(other1FirstName))
                    {
                        errorOA_Other1FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other1LastName))
                    {
                        errorOA_Other1LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other1Email))
                    {
                        errorOA_Other1Email = 'error';
                        return false;
                    }
                    if(!textValidations(other2FirstName))
                    {
                        errorOA_Other2FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other2LastName))
                    {
                        errorOA_Other2LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other2Email))
                    {
                        errorOA_Other2Email = 'error';
                        return false;
                    }
                    if(!textValidations(other3FirstName))
                    {
                        errorOA_Other3FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other3LastName))
                    {
                        errorOA_Other3LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other3Email))
                    {
                        errorOA_Other3Email = 'error';
                        return false;
                    }
                }
                else if(numberOfApplicants == 4)
                {
                    if(!textValidations(other1FirstName))
                    {
                        errorOA_Other1FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other1LastName))
                    {
                        errorOA_Other1LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other1Email))
                    {
                        errorOA_Other1Email = 'error';
                        return false;
                    }
                    if(!textValidations(other2FirstName))
                    {
                        errorOA_Other2FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other2LastName))
                    {
                        errorOA_Other2LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other2Email))
                    {
                        errorOA_Other2Email = 'error';
                        return false;
                    }
                    if(!textValidations(other3FirstName))
                    {
                        errorOA_Other3FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other3LastName))
                    {
                        errorOA_Other3LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other3Email))
                    {
                        errorOA_Other3Email = 'error';
                        return false;
                    }
                    if(!textValidations(other4FirstName))
                    {
                        errorOA_Other4FirstName = 'error';
                        return false;
                    }
                    if(!textValidations(other4LastName))
                    {
                        errorOA_Other4LastName = 'error';
                        return false;
                    }
                    if(!isValidEmail(other4Email))
                    {
                        errorOA_Other4Email = 'error';
                        return false;
                    }
                }
                return true;
            }

            public Boolean validateCertification()
            {
                if(signatureFirst == 'First' || signatureLast == 'Last')
                {
                    error_Signature = 'error';
                    return false;
                }
                else if(!textValidations(signatureFirst) || !textValidations(signatureLast))
                {
                    error_Signature = 'error';
                    return false;
                }
                return true;
            }

            public Boolean validatePayment()
            {
                for(PromoCode__c codes : [Select Code__c From PromoCode__c])
                {
                    setPromoCodes.add(codes.Code__c);
                }
                if(!integerValidations(strCardNumber, true))
                {
                    errorPay_CardNumber = 'error';
                    return false;
                }
                if(!dateValidations(strCardMonth + '/1/' + strCardYear, true))
                {
                    errorPay_CardDate = 'error';
                    return false;
                }

                if(!integerValidations(strSecurityCode, true))
                {
                    errorPay_SecurityCode = 'error';
                    return false;
                }

                if((strPayBy == 'Visa' || strPayBy == 'Master Card') && integerValidations(strSecurityCode, true) && strSecurityCode.length() != 3)
                {
                    errorPay_SecurityCode = 'error';
                    return false;
                }

                if(strPayBy == 'American Express' && integerValidations(strSecurityCode, true) && strSecurityCode.length() != 4)
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
                if(!integerValidations(strCardZip, true))
                {
                    errorPay_CardZip = 'error';
                    return false;
                }
                if(strPromoCode != '' && !setPromoCodes.contains(strPromoCode))
                {
                    errorPay_PromoCode = 'error';
                    return false;
                }

                return true;
            }

    /* End - Validator Methods */

    /*  Method : goToPayment
        Parameters : none
        desc : validates the user information on the page and redirects to the payment section.
    */
    public void goToPayment()
    {
        try
        {
            strSignature = strStartDate = strToDate = strFromDate = '';
            initializeApplicationForm();
            if(validatePersonalInformation() && validateCurrentAddressInformation() &&
               validatePreviousAddressInformation() && validateBankInformation() && validateEmploymentInformation() &&
               validatePets() && validateOtherApplicants() && validateCertification())
            {
                hasError = false;
                isValid = true;

                strSignature = strStartDate = strToDate = strFromDate = '';

                if(!isAdditionalApplicant)
                {
                    // Adding other users information in a map
                    List<String> user1 = new List<String>();
                    user1.add(other1FirstName);
                    user1.add(other1LastName);
                    user1.add(other1Role);
                    mapOtherDetails.put(other1Email,user1);

                    List<String> user2 = new List<String>();
                    user2.add(other2FirstName);
                    user2.add(other2LastName);
                    user2.add(other2Role);
                    mapOtherDetails.put(other2Email,user2);

                    List<String> user3 = new List<String>();
                    user3.add(other3FirstName);
                    user3.add(other3LastName);
                    user3.add(other3Role);
                    mapOtherDetails.put(other3Email,user3);

                    List<String> user4 = new List<String>();
                    user4.add(other4FirstName);
                    user4.add(other4LastName);
                    user4.add(other4Role);
                    mapOtherDetails.put(other4Email,user4);
                }

                strSignature = signatureFirst + ' ' + signatureMiddle + ' ' + signatureLast;
                strStartDate = strStartMonth + '/' + strStartYear;
                strToDate = strToMonth + '/' + strToYear;
                strFromDate = strFromMonth + '/' + strFromYear;
                dateOfBirth = (strAppType == 'Individual') ? date.parse(dobMonth + '/' + dobDate + '/' + dobYear) : null;
                dateOfIncorporation = (strAppType == 'Company') ? date.parse(strDateOfIncorporationM + '/' + strDateOfIncorporationD + '/' + strDateOfIncorporationY) : null;
            }
            else
            {
                hasError = true;
                isValid = false;
            }

        }
        catch(exception e)
        {
            /* Do Nothing */
        }
    }

    /* Start - Validation Functions */
        public Boolean textValidations(String strValue)
        {
            if(strValue == null || strValue == '')
                return false;
            return true;
        }

        public Boolean currencyValidations(String strValue, Boolean isRequired)
        {
            if(isRequired && (strValue == null || strValue == ''))
            {
                return false;
            }

            else if(isRequired && strValue != null && strValue != '')
            {
              try
                {
                    if(strValue.contains(','))
                        strValue = strValue.replaceAll(',', '');
                    Double dblVal = Double.valueOf(strValue);
                }
                catch (Exception e)
                {
                    return false;
                }
            }

            else if(!isRequired && strValue != null && strValue != '')
            {
                try
                {
                    if(strValue.contains(','))
                        strValue = strValue.replaceAll(',', '');
                    Double dblVal = Double.valueOf(strValue);
                }
                catch (Exception e)
                {
                    return false;
                }
            }
            return true;
        }

        public Boolean integerValidations(String strValue, Boolean isRequired)
        {
            if(isRequired && (strValue == null || strValue == ''))
                return false;
            else if(!isRequired && (strValue == null || strValue == ''))
                return true;
            else
            {
                try
                {
                    Long intVal = Long.valueOf(strValue);
                    if(intVal < 0) return false;
                }
                catch (Exception e)
                {
                    return false;
                }
            }
            return true;
        }

        public Boolean doubleValidations(String strValue, Boolean isRequired)
        {
            if(isRequired && (strValue == null || strValue == ''))
                return false;
            else if(!isRequired && (strValue == null || strValue == ''))
                return true;
            else
            {
                try
                {
                    Double dblVal = Double.valueOf(strValue);
                    if(dblVal < 0) return false;
                }
                catch (Exception e)
                {
                    return false;
                }
            }
            return true;
        }

        public Boolean dateValidations(String strDateValue, Boolean isRequired)
        {
            if(isRequired && (strDateValue == null || strDateValue == ''))
                return false;
            else if(!isRequired && (strDateValue == null || strDateValue == ''))
                return true;
            else
            {
                try
                {
                    Date dtValue = date.parse(strDateValue);
                }
                catch (Exception e)
                {
                    return false;
                }
            }
            return true;
        }

        public Boolean dateRangeValidations(String strFromValue, String strToValue, Boolean isRequired)
        {
            if(isRequired && (strFromValue == null || strFromValue == '') && (strToValue == null || strToValue == ''))
                return false;
            else if(!isRequired && (strFromValue == null || strFromValue == '' || strFromValue == 'mm/1/yyyy') && (strToValue == null || strToValue == '' || strToValue == 'mm/1/yyyy'))
                return true;
            else
            {
                try
                {
                    Date dtFromDate = date.parse(strFromValue);
                    Date dtToDate = date.parse(strToValue);
                    if(dtFromDate > dtToDate)
                        return false;
                }
                catch (Exception e)
                {
                    return false;
                }
            }
            return true;
        }
        /*  Method : isValidEmail
        Paramaters : String
        Return : Boolean
        Desc : Returns true if the string is a valid email
        */
        private static boolean isValidEmail(String str)
        {
            String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern MyPattern = Pattern.compile(emailRegex);
            // Then instantiate a new Matcher object "MyMatcher"
            Matcher MyMatcher = MyPattern.matcher(str);
            if (MyMatcher.matches())
            {
                //valid email
                return true;
            }
            else
                return false;
        }
    /* End - Validation Functions */

    public void createOpptyAndContactRole(Account objAccount)
    {
        List<Property__c> propertyName = new List<Property__c>();
        propertyName = [Select Property_Name_Friendly__c From Property__c Where Id = :strProperty AND Property_Name_Friendly__c != NULL];

        // creating Opportunity record
        Opportunity opp = new Opportunity();
        opp.Name = String.escapeSingleQuotes(returnOpportunityName());
        opp.StageName = 'Application Submitted';
        opp.CloseDate = system.today().addDays(15);
        opp.AccountId = objAccount.Id;
        opp.Property__c = strProperty;
        insert opp;

        // creating Property Connector for the Selected Property and the new Opportunity.
        Property_to_Opportunity_Connector__c connector = new Property_to_Opportunity_Connector__c();
        connector.Opportunity__c = opp.Id;
        connector.Property__c = strProperty;
        connector.Name = (propertyName.size() > 0) ? opp.Name + '-' + propertyName[0].Property_Name_Friendly__c : opp.Name;
        insert connector;

        // creating Contact Role record
        Contact_Role__c cr = new Contact_Role__c();
        cr.Opportunity__c = opp.Id;
        cr.Contact__c = objAccount.Id;
        cr.Role__c = 'Tenant';
        insert cr;
        // setting contact role id
        contactRoleId = cr.Id;
        validateAdditionalApplicants(contactRoleId);
    }

    public void convertLeadCreateContactRole(Lead objLead)
    {
        List<Property__c> propertyName = new List<Property__c>();
        propertyName = [Select Property_Name_Friendly__c From Property__c Where Id = :strProperty AND Property_Name_Friendly__c != NULL];

        // converting the matching lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(objLead.id);
        lc.setOpportunityName(String.escapeSingleQuotes(returnOpportunityName()));
        LeadStatus convertstatus = [select Id, MasterLabel from LeadStatus where IsConverted= true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        // update converted Opportunity
        Opportunity opp = new Opportunity(id=lcr.getOpportunityId());
        opp.Property__c = strProperty;
        opp.StageName = 'Appointments';
        update opp;
        isLeadConverted = true;

        // creating Property Connector for the Selected Property and the converted Opportunity.
        Property_to_Opportunity_Connector__c connector = new Property_to_Opportunity_Connector__c();
        connector.Opportunity__c = opp.Id;
        connector.Property__c = strProperty;
        connector.Name = (propertyName.size() > 0) ? opp.Name + '-' + propertyName[0].Property_Name_Friendly__c : opp.Name;
        insert connector;

        //update converted Account
        Account acc = new Account(id=lcr.getAccountId());
        acc.PersonEmail=strEmail;
        update acc;

        // setting contact role id
        contactRoleId = [Select Id From Contact_Role__c Where Opportunity__c =: opp.Id AND Contact__c =: acc.Id AND Role__c = 'Tenant'].Id;
        validateAdditionalApplicants(contactRoleId);
    }

    public void createNewPersonAccount()
    {
        List<Property__c> propertyName = new List<Property__c>();
        propertyName = [Select Property_Name_Friendly__c From Property__c Where Id = :strProperty AND Property_Name_Friendly__c != NULL];

        // creating new person account
        Account acc = new Account();
        acc.LastName = String.escapeSingleQuotes(applicantName + ' ' + applicantLastName);
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_ID;
        acc.PersonEmail = strEmail;
        insert acc;

        // creating Opportunity record
        Opportunity opp = new Opportunity();
        opp.Name = String.escapeSingleQuotes(returnOpportunityName());
        opp.StageName = 'Application Submitted';
        opp.CloseDate = system.today().addDays(15);
        opp.AccountId = acc.Id;
        opp.Property__c = strProperty;
        insert opp;

        // creating Property Connector for the Selected Property and the new Opportunity.
        Property_to_Opportunity_Connector__c connector = new Property_to_Opportunity_Connector__c();
        connector.Opportunity__c = opp.Id;
        connector.Property__c = strProperty;
        connector.Name = (propertyName.size() > 0) ? opp.Name + '-' + propertyName[0].Property_Name_Friendly__c : opp.Name;
        insert connector;

        // creating Contact Role record
        Contact_Role__c cr = new Contact_Role__c();
        cr.Opportunity__c = opp.Id;
        cr.Contact__c = acc.Id;
        cr.Role__c = 'Tenant';
        insert cr;

        // setting contact role id
        contactRoleId = cr.Id;
        validateAdditionalApplicants(contactRoleId);
    }


    public void matchExistingLeads()
    {
        List<Lead> lstMatchingLeads = new List<Lead>();

        // querying for matching leads
        lstMatchingLeads = [Select Id, Name From Lead Where Email =: strEmail AND IsConverted = FALSE order by CreatedDate Desc limit 1];

        // found matching leads
        if(lstMatchingLeads.size() > 0)
        {
            //Convert Lead and Create Contact Role.
            convertLeadCreateContactRole(lstMatchingLeads[0]);
        }
        else
        {
            // Create new Person Account, Opportunity and Contact Role.
            createNewPersonAccount();
        }
    }

    public void matchExistingPersonAccounts()
    {
        List<Account> lstMatchingPersonAccount = new List<Account>();
        Set<String> PersonAccountEmails = new Set<String>();
        List<Contact_Role__c> lstContactRole = new List<Contact_Role__c>();
        List<Account> lstPersonAccounts = new List<Account>();

        // query for a matching person account based on email field
        lstMatchingPersonAccount = [Select Id, Name From Account Where PersonEmail =: strEmail AND RecordTypeId = :ACCOUNT_RECORDTYPE_ID order by CreatedDate Desc limit 1];

        // matching person account record is found
        if(lstMatchingPersonAccount.size() > 0)
        {
            //Create Opportunity and Contact Role Record.
            createOpptyAndContactRole(lstMatchingPersonAccount[0]);
        }
        else
        {
            //Match the existing Leads
            matchExistingLeads();
        }
    }

    public String returnOpportunityName()
    {
        List<Property__c> lstProperty = new List<Property__c>();
        String oppName = (strAppType == 'Individual') ? String.escapeSingleQuotes(applicantName + ' ' + applicantLastName) : String.escapeSingleQuotes(strCompanyName);

        if(strProperty != null && strProperty != '')
        {
            lstProperty = [Select Unit_Number__c, Property_Name_Friendly__c From Property__c Where Id = :strProperty];
            if(!lstProperty.isEmpty())
            {
                if(!isNullOrBlank(lstProperty[0].Property_Name_Friendly__c) && !isNullOrBlank(lstProperty[0].Unit_Number__c))
                    oppName += ' ' + lstProperty[0].Property_Name_Friendly__c + '-' + lstProperty[0].Unit_Number__c;
                else if(isNullOrBlank(lstProperty[0].Property_Name_Friendly__c) && !isNullOrBlank(lstProperty[0].Unit_Number__c))
                    oppName += ' ' + '-' + lstProperty[0].Unit_Number__c;
                else if(isNullOrBlank(lstProperty[0].Unit_Number__c) && !isNullOrBlank(lstProperty[0].Property_Name_Friendly__c))
                    oppName += ' ' + lstProperty[0].Property_Name_Friendly__c;
            }
        }
        return oppName;
    }

    /*  Method Name : submitCardDetails
        Parameters : none
        Return Type : PageReference
        Desc : validates the credit card details, inserts/updates Opportunity, Account & Contact Role and redirects user to Success Page
    */
    public pageReference submitCardDetails()
    {
      String strTempCardYear = '';
        try
        {
          String strPaypalId = '';
          if(strCardYear != null && strCardYear != 'YY' && strCardYear != '')
          {
            strTempCardYear = strCardYear;
            strCardYear = '20' + strCardYear;
          }
            isValid = true;
            payError = false;
            isReadTimedOut = false;
            err = '';
            message = '';
            initializePayment();
            Contact_Role__c objContactRole = new Contact_Role__c();

            //Validate all Inputs.
            if(validatePayment())
            {
                //If any error found in Validations above then blindly assign it to the message.
                if(strPromoCode == '')
                {
                    message = doDirectPayment();
                }

                else if(setPromoCodes.contains(strPromoCode))
                {
                    message = 'Success';

                    //create a paypal transaction object record
                    // transid = objpaypal.Id
                    List<Contact_Role__c> lstContRole = new List<Contact_Role__c>();
                    if(!isNullOrBlank(cid))
                    {
                      lstContRole = [Select Id, Contact__c, Contact__r.FirstName, Contact__r.LastName from Contact_Role__c where Id =: cid ];
                    }
                    else
                    {
                      //matchExistingPersonAccounts();
                      lstContRole = [Select Id, Contact__c, Contact__r.FirstName, Contact__r.LastName from Contact_Role__c where Id =: cid ];
                    }

                    objPayPalTransaction = new PayPal_Transaction__c();
              objPayPalTransaction.Transaction_Results__c = 'Promo code is available so no Transaction done';
              objPayPalTransaction.Browser__c = 'Browser Name : ' + strBrowserName + ' and Version Number : ' + strBrowserVersion;
              objPayPalTransaction.Operating_System__c = strOperatingSystem;
              insert objPayPalTransaction;

                    strPaypalId = objPayPalTransaction.Id;
                }
                // Paypal Authentication Successful
                if (message == 'Success')
                {
                    //  Has Contact Role Id
                    if(!isNullOrBlank(cid))
                    {
                        // E-renter staus to be updated for the Contact_Role__c who has submitted the form
                        objContactRole = new Contact_Role__c(id=cid);
                        objContactRole.Contact_Email__c = strEmail;
                        update objContactRole;

                        //Changes as per StonePII-88
                        strOppId = [Select Opportunity__c, Id From Contact_Role__c where Id=: cid].Opportunity__c;
                        //End Changes

                        // setting contact role id
                        contactRoleId = cid;
                        validateAdditionalApplicants(cid);
                    }
                    else
                    {
                        // Match Existing Person Accounts(or Leads by email).
                        matchExistingPersonAccounts();
                    }
                    isValid = true;
                    payError = false;
                    //Pagereference pr = new Pagereference('https://stonehenge.uat.cs7.force.com/Application/SL_SuccessPage?cid='+contactRoleId+'&strAppType='+strAppType);
                    Pagereference pr = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage?cid='+contactRoleId+'&strAppType='+strAppType+'&ptId='+transid+'&paypalId='+strPaypalId);
                    pr.setredirect(true);
                    return pr;
                }
                else
                {
                    // Paypal Authencitacion Failure
                    hasError = false;
                    payError = true;
                    isValid = true;
                    strCardYear = strTempCardYear;
                    return null;
                }
            }
            else
            {
                // Paypal Authencitacion Failure
                hasError = true;
                payError = false;
                isValid = true;
                strCardYear = strTempCardYear;
                return null;
            }
        }
        catch(exception e)
        {
          system.debug('=====e====='+e);
          strCardYear = strTempCardYear;
            return null;
        }
    }

    /*  Method Name : validateAdditionalApplicants
        Parameters : String Contact_Role Id
        Desc : validates the process for Other Applicants on the Application Form
    */
    public void validateAdditionalApplicants(String cid)
    {
        try
        {
            List<Account> lstMatchingPersonAccount = new List<Account>();
            List<Contact_Role__c> lstContactRole = new List<Contact_Role__c>();
            List<Account> lstPersonAccounts = new List<Account>();
            Set<String> PersonAccountEmails = new Set<String>();
            Contact_Role__c objCR = [Select Opportunity__c, Opportunity__r.Property__c, Contact__c From Contact_Role__c Where Id = :cid];

            // Removing nulls from map
            mapOtherDetails.remove(null);
            mapOtherDetails.remove('');

            //Changes as per StonePII-88
            if(strOppId != null && strOppId != '')
            {
                for(Contact_Role__c obj: [Select Opportunity__c, Contact__r.PersonEmail, Contact__c From Contact_Role__c where  Opportunity__c=: strOppId])
                {
                    if(mapOtherDetails.containsKey(obj.Contact__r.PersonEmail))
                        mapOtherDetails.remove(obj.Contact__r.PersonEmail);
                    else
                        continue;
                }
            }
            //End Changes

            // check for Additional Applicants
            if(numberOfApplicants > 0 && mapOtherDetails.size() > 0)
            {
                // checking for the last modified Matching Person Account Record
                lstMatchingPersonAccount = [Select Name, Id,PersonEmail From Account Where PersonEmail IN :mapOtherDetails.keySet() ORDER BY LastModifiedDate DESC];

                // create a new Contact Role record for the matching Person Account Record
                for(Account acc : lstMatchingPersonAccount)
                {
                    if(!PersonAccountEmails.contains(acc.PersonEmail))
                    {
                        Contact_Role__c cr = new Contact_Role__c();
                        cr.Opportunity__c = objCR.Opportunity__c;
                        cr.Contact__c = acc.Id;
                        cr.Role__c = mapOtherDetails.get(acc.PersonEmail)[2];
                        cr.Status__c = 'Application Sent';
                        cr.isAdditionalApplicant__c = true;
                        PersonAccountEmails.add(acc.PersonEmail);
                        lstContactRole.add(cr);
                    }
                }

                // create new person Account for Applicants who do not already have a person Account
                for(String email : mapOtherDetails.keySet())
                {
                    if(!PersonAccountEmails.contains(email))
                    {
                        Account person = new Account();
                        person.RecordTypeId = ACCOUNT_RECORDTYPE_ID;
                        person.FirstName = mapOtherDetails.get(email)[0];
                        person.LastName = mapOtherDetails.get(email)[1];
                        person.PersonEmail = email;
                        lstPersonAccounts.add(person);
                    }
                }

                // insert all such person accounts
                if(lstPersonAccounts.size() > 0)
                    insert lstPersonAccounts;

                // create Contact roles for new person accounts
                for(Account person :lstPersonAccounts)
                {
                    Contact_Role__c cr = new Contact_Role__c();
                    cr.Opportunity__c = objCr.Opportunity__c;
                    cr.Contact__c = person.Id;
                    cr.Role__c = mapOtherDetails.get(person.PersonEmail)[2];
                    cr.Status__c = 'Application Sent';
                    cr.isAdditionalApplicant__c = true;
                    lstContactRole.add(cr);
                }

                // insert the newly created contact role records
                if(lstContactRole.size() > 0)
                    insert lstContactRole;

                updateFields(objCR);
            }
            // if there are no other applicants
            else
            {
                updateFields(objCR);
            }
        }
        catch(exception e)
        {
            /* Do Nothing */
            system.debug('========================================'+e);
        }
    }

    /*  Method Name : updateFields
        Parameters : Contact Role object
        Desc : inserts/updates Opportunity/Account/ContactRole fields as per values on the Form.
    */
    public void updateFields(Contact_Role__c cr)
    {
        try
        {
            Account objAccount = [Select Id,FirstName From Account Where Id =: cr.Contact__c];
            insertUpdateAccount(objAccount);

            Opportunity opp = [Select Id, StageName, Name From Opportunity Where Id = :cr.Opportunity__c];
            opp.Other_Applicants__c = numberOfApplicants;
            opp.StageName = (isLeadConverted) ? 'Appointments' : 'Application Submitted';
            update opp;

            insertUpdateContactRole(cr);
        }
        catch(exception ex)
        {
            /* Do nothing */
        }
    }

    /*  Method Name : insertUpdateContactRole
        Parameters : Contact Role object
        Desc : inserts/updates the Contact Role based on the field mappings from the Form.
    */
    public void insertUpdateContactRole(Contact_Role__c cr)
    {
        try
        {
            cr.Signature__c = String.escapeSingleQuotes(strSignature);
            cr.Pay_By__c = strPayBy;
            cr.Card_Number__c = String.escapeSingleQuotes(strCardNumber.subString(strCardNumber.length() - 4, strCardNumber.length()));
            cr.Expiration__c = String.escapeSingleQuotes(strCardMonth + '/' + strCardYear);
            cr.Security_Code__c = String.escapeSingleQuotes(strSecurityCode);
            cr.Name_on_Card__c = String.escapeSingleQuotes(strCardName);
            cr.Billing_Address__c = String.escapeSingleQuotes(strCardAddress);
            cr.Billing_City__c = String.escapeSingleQuotes(strCardCity);
            cr.Billing_State__c = String.escapeSingleQuotes(strCardState);
            cr.Billing_Zip__c = String.escapeSingleQuotes(strCardZip);
            cr.Promo_Code__c = String.escapeSingleQuotes(strPromoCode);
            cr.Status__c = 'Submitted Application';
            cr.Authorized__c = (acceptTerms == 'accepted') ? true : false;
            update cr;

            List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
            EmailTemplate objEmailTemplate = [SELECT Id FROM EmailTemplate WHERE  DeveloperName = 'Send_Upload_Docs_Email_VF'];

            List<Contact_Role__c> lstContactRole = [Select Opportunity__r.AccountId, Opportunity__r.OwnerId, Opportunity__c, Contact__r.ContactID__pc,
                                         Contact__c, Contact_Email__c
                                         From Contact_Role__c
                                         where Id =: cr.id];

            User objUser = [SELECT Id, Name, Email FROM User WHERE Id =:lstContactRole[0].Opportunity__r.OwnerId];

            for(Contact_Role__c objContactRole : lstContactRole)
            {
        Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
        objEmail.setWhatId(objContactRole.Id);
        objEmail.setTemplateId(objEmailTemplate.Id);
        objEmail.setTargetObjectId(objContactRole.Contact__r.ContactId__pc);
        objEmail.setSenderDisplayName(objUser.Name);
        objEmail.setReplyTo(objUser.Email);
        lstMail.add(objEmail);
            }

            if(lstMail.size() > 0)
            {
               Messaging.sendEmail(lstMail);
            }



        }
        catch(exception ex)
        {
            /*Do Nothing*/
        }
    }

    /*  Method Name : insertUpdateAccount
        Parameters : Account object
        Desc : inserts/updates the Account based on the field mappings from the Form.
    */
    public void insertUpdateAccount(Account account)
    {
        try
        {
            account.FirstName = String.escapeSingleQuotes((strAppType == 'Individual') ?  applicantName : strCompanyFirst);
            account.Middle_Name__c = String.escapeSingleQuotes((strAppType == 'Individual') ? applicantMiddleInitial:'');
            account.LastName = String.escapeSingleQuotes((strAppType == 'Individual') ? applicantLastName : strCompanyLast);
            account.Suffix__c = strSuffix; 
            if(strCompanyName != null)
                account.Company__c = String.escapeSingleQuotes(strCompanyName);
            account.Tax_ID__c = (strAppType == 'Individual') ? ssn1 + ssn2 + ssn3 : strTaxId;
            account.Incorporation_Date__c = String.valueOf(dateOfIncorporation);
            account.DOB__c = dateOfBirth;
            account.Phone = phoneCode + phoneNumber + phoneNumber1;
            account.PersonOtherPhone = altPhoneCode + altPhoneNumber + altPhoneNumber1;
            account.PersonEmail = strEmail;
            account.Current_Rent_Or_Own__c = strRentOrOwn;
            account.Address__c = (strAddress != null && strAddress != '') ? String.escapeSingleQuotes(strAddress) : '';
            account.Country__c = (strCountry != null && strCountry != '') ? String.escapeSingleQuotes(strCountry) : '';
            account.State1__c = (strState != null && strState != '') ? String.escapeSingleQuotes(strState) : '';
            account.City__c = (strCity != null && strCity != '') ? String.escapeSingleQuotes(strCity) : '';
            account.Postal_Code__c = strZip;
            account.Current_From__c = strFromDate;
            account.Current_To__c = strToDate;
            account.Previous_Address__c = (strPrevAddress != null && strPrevAddress != '') ? String.escapeSingleQuotes(strPrevAddress) : '';
            account.Previous_City__c = (strPrevCity != null && strPrevCity != '') ? String.escapeSingleQuotes(strPrevCity) : '';
            account.Previous_Country__c = (strPrevCountry != null && strPrevCountry != '') ? String.escapeSingleQuotes(strPrevCountry) : '';
            account.Previous_Rent_Or_Own__c = (strPrevAddress != null && strPrevAddress != '') ? strPrevRentOrOwn : '';
            account.Previous_State__c = (strPrevState != null && strPrevState != '') ? String.escapeSingleQuotes(strPrevState) : '';
            account.Previous_Zip__c=strPrevZip;
            account.Bank_Name__c = (strBankName != null && strBankName != '') ? String.escapeSingleQuotes(strBankName) : '';
            account.Employment__c = (strEmployment != null && strEmployment != '') ? String.escapeSingleQuotes(strEmployment) : '';
            account.Occupation__c = (strOccupation != null && strOccupation != '') ? String.escapeSingleQuotes(strOccupation) : '';
            account.Employer__c = (strEmployer != null && strEmployer != '') ? String.escapeSingleQuotes(strEmployer) : '';
            account.PersonTitle = (strPosition != null && strPosition != '') ? String.escapeSingleQuotes(strPosition) : '';
            account.Supervisor__c = (strSupervisorName != null && strSupervisorName != '') ? String.escapeSingleQuotes(strSupervisorName) : '';
            account.Supervisor_Phone__c = strSupervisorCode + strSupervisorPhone1 + strSupervisorPhone2;
            account.Start_Date__c = strStartDate;
            if(annualSalary.contains(','))
                annualSalary = annualSalary.replaceAll(',', '');
            if(annualBonus.contains(','))
                annualBonus= annualBonus.replaceAll(',', '');
            if(otherIncome.contains(','))
                otherIncome= otherIncome.replaceAll(',', '');
            if(annualSalary != null && annualSalary != '')
              account.Annual_Income__c = Double.valueOf(annualSalary);
            if(annualBonus != null && annualBonus != '')
              account.Annual_Bonus__c = Double.valueOf(annualBonus);
            account.Other_Income_Source__c = String.escapeSingleQuotes(strOtherIncomeSource);
            if(otherIncome != null && otherIncome != '')
              account.Other_Income__c =Double.valueOf(otherIncome);
            if(textValidations(weight1) && textValidations(weight2) && textValidations(weight3))
              account.Number_of_Pets__c = 3;
            else if(textValidations(weight1) && textValidations(weight2) && !textValidations(weight3))
              account.Number_of_Pets__c = 2;
            else if(textValidations(weight1) && !textValidations(weight2) && !textValidations(weight3))
              account.Number_of_Pets__c = 1;
            else if(!textValidations(weight1) && !textValidations(weight2) && !textValidations(weight3))
              account.Number_of_Pets__c = 0;
            account.Pet_1_Breed__c = (breed1 != null && breed1 != '') ? String.escapeSingleQuotes(breed1) : '';
            account.Pet_2_Breed__c = (breed2 != null && breed2 != '') ? String.escapeSingleQuotes(breed2) : '';
            account.Pet_3_Breed__c = (breed3 != null && breed3 != '') ? String.escapeSingleQuotes(breed3) : '';
            account.Pet_1_Weight__c = weight1;
            account.Pet_2_Weight__c = weight2;
            account.Pet_3_Weight__c = weight3;
            if(strPrevFromMonth != 'mm' && strPrevFromYear != 'yyyy')
                account.Previous_From__c = strPrevFromMonth + '/' + strPrevFromYear;
            if(strPrevToMonth != 'mm' && strPrevToYear != 'yyyy')
                account.Previous_To__c = strPrevToMonth + '/' + strPrevToYear;
            if(!isNullOrBlank(strIndustry))
                account.Industry = strIndustry;

            update account;
        }
        catch(exception e)
        {
            /* Do Nothing*/
        }
    }

    /*  validates Payment through PayPal    */
    public String doDirectPayment()
    {
        try
        {
          String url;
          String un;
          String pw;
          String sig;
          String amount;
          String endPoint;
          payPalCustomSetting__c paypal;
          isReadTimedOut = false;

          // Get PayPal information from custom setting
          if(test.isRunningTest())
          {
            paypal = [Select endpoint__c, username__c, password__c, signature__c, Amount__c From payPalCustomSetting__c Where Name = 'testCoverage'];
            endPoint = paypal.endpoint__c;
          }
          else
          {
            if(payPalCustomSetting__c.getValues('Sandbox').Active__c)
            {
                paypal = payPalCustomSetting__c.getValues('Sandbox');
                endPoint = 'api-3t.sandbox.paypal.com';
            }
            else if(payPalCustomSetting__c.getValues('Live').Active__c)
            {
                paypal = payPalCustomSetting__c.getValues('Live');
                endPoint = 'api-3t.paypal.com';
            }
            else if(!payPalCustomSetting__c.getValues('Sandbox').Active__c)
            {
                paypal = payPalCustomSetting__c.getValues('Sandbox');
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
              doDirectRequest += '<PayerName><FirstName>' + strCardName + '</FirstName></PayerName>';
              doDirectRequest += '<Address><Street1>' + strCardAddress + '</Street1><CityName>' + strCardCity + '</CityName>';
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
                  system.debug('----------------XML---------' + doDirectRequest);
                  system.debug('----------------Request---------' + req);
                  system.debug('----------------Request body---------' + req.getBody());
                  system.debug('----------------Response---------' + res);
                  system.debug('----------------Response body---------' + res.getBody());
                  String xml = res.getBody();
                  rawResponse = xml;
                  XmlStreamReader reader = res.getXmlStreamReader();
                  result = readXMLResponse(reader,'Ack');
                  reader = res.getXmlStreamReader();
                  err = readXMLResponse(reader, 'LongMessage');

                  if (result == 'Success')
                  {
                    reader = res.getXmlStreamReader();
                    transid = readXMLResponse(reader, 'TransactionID');

                    if(strAppType == 'Individual')
                {
                  createPayPatTransactionRecord(applicantName, applicantLastName, strProperty, result, transid, strOperatingSystem);
                }
                if(strAppType == 'Company')
                {
                  createPayPatTransactionRecord(strCompanyFirst, strCompanyLast, strProperty, result, transid, strOperatingSystem);
                }

                  }
                  else
                  {
                    result = err;

                    if(strAppType == 'Individual')
                {
                  createPayPatTransactionRecord(applicantName, applicantLastName, strProperty, result, null, strOperatingSystem);
                }
                if(strAppType == 'Company')
                {
                  createPayPatTransactionRecord(strCompanyFirst, strCompanyLast, strProperty, result, null, strOperatingSystem);
                }
                  }
              }

              return result;
          }
          else
            return null;
        }
        catch(Exception ex)
        {
            system.debug('----------------Exception ---------' + ex);
            system.debug('----------------Exception Message---------' + ex.getMessage());
            system.debug('----------------Exception Stack Trace String ---------' + ex.getStackTraceString());
            system.debug('----------------Exception Cause---------' + ex.getCause());
            system.debug('----------------Exception Cause---------' + ex.getLineNumber());
            if(String.valueOf(ex).contains('Read timed out'))
              isReadTimedOut = true;

            String strResult = String.valueOf(ex.getMessage());

            if(strAppType == 'Individual')
            {
              createPayPatTransactionRecord(applicantName, applicantLastName, strProperty, strResult, '', strOperatingSystem);
            }
            if(strAppType == 'Company')
            {
              createPayPatTransactionRecord(strCompanyFirst, strCompanyLast, strProperty, strResult, '', strOperatingSystem);
            }

            return null;
        }
    }

    public void createPayPatTransactionRecord(String strParamFirstName, String strParamLastName, String strParamProperty, String strParamresult, String strParamTransactionId, String strParamOS )
    {
      System.debug('---inserting Paypal Trans. record');
      objPayPalTransaction = new PayPal_Transaction__c();
      objPayPalTransaction.First_Name__c = strParamFirstName;
        objPayPalTransaction.Last_Name__c = strParamLastName;
        objPayPalTransaction.Property__c = strParamProperty;
        objPayPalTransaction.Transaction_Results__c = strParamresult;
        objPayPalTransaction.PayPal_Transaction_Id__c = strParamTransactionId;
        objPayPalTransaction.Browser__c = 'Browser Name : ' + strBrowserName + ' and Version Number : ' + strBrowserVersion;
        objPayPalTransaction.Operating_System__c = strParamOS;
        insert objPayPalTransaction;
        System.debug('---Paypal Trans obj----'+objPayPalTransaction);
    }

    /*  Paypal Method   */
    public String readXMLResponse(XmlStreamReader reader, String sxmltag)
    {
        try
        {
          string retValue; // Read through the XML
          while(reader.hasNext())
          {
            if (reader.getEventType() == XmlTag.START_ELEMENT)
            {
              if (reader.getLocalName() == sxmltag) {
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
        catch(Exception ex)
        {
            return null;
        }
    }

    /*  Method : isNullOrBlank
        Paramaters : String
        Return : Boolean
        Desc : Returns true if the string is either null or blank
    */
    private static boolean isNullOrBlank(String str)
    {
        if(str == '' || str == null  )
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /*  Method : checkForDuplicate
        Paramaters : None
        Return : PageReference
        Desc : redirects the applicant to the success page if he has already applied (based on the status)
    */
    public pageReference checkForDuplicate()
    {
        // set contains all the duplicate status
        Set<String> setDuplicateStatus = new Set<String>{'Submitted Application','Application Received','Application Approved','Application Rejected','Application Canceled'};

        if(!isNullOrBlank(cid))
        {
            Contact_Role__c objContactRole = new Contact_Role__c();
            objContactRole = [Select Id, Contact_Email__c,Status__c From Contact_Role__c WHERE Id =: cid];

            // if status of the current contact role is a duplicate one, redirect the user directly to the success page
            if(setDuplicateStatus.contains(objContactRole.Status__c))
            {
                //Pagereference pr = new Pagereference('https://stonehenge.uat.cs7.force.com/Application/SL_SuccessPage');
                Pagereference pr = new Pagereference(Site.getCurrentSiteUrl() + 'SL_SuccessPage');
                pr.setredirect(true);
                return pr;
            }
            else
            {
                return null;
            }
        }

        else
        {
            return null;
        }
        return null;
    }

    @isTest
    private static void testPageLoadMethods()
    {
        Property__c property1 = new Property__c();
        property1.Unit_Status__c = '2. Rent Ready';
        property1.Unit_Number__c = 'Property1';
        insert property1;

        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.getCountry();
        app.getIndustry();
        app.getPrevCountry();
        app.getRole();
        app.getSuffix();
        app.getProperty();
        app.getCardState();
        app.strCountry = 'Algeria';
        app.changeCurrentStateBasedOnCountry();
        app.changePrevStateBasedOnCountry();
        app.strCountry = 'United States';
        app.changeCurrentStateBasedOnCountry();
        app.changePrevStateBasedOnCountry();
    }

    @isTest
    private static void testValidatePersonalInformation()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.strAppType = 'Individual';
        app.applicantName = '';
        app.validatePersonalInformation();
        app.applicantName = 'name';
        app.applicantLastName = '';
        app.validatePersonalInformation();
        app.applicantLastName = 'last';
        app.ssn1 = '';
        app.validatePersonalInformation();
        app.ssn1 = '123';
        app.ssn2 = '';
        app.validatePersonalInformation();
        app.ssn2 = '456';
        app.ssn3 = '';
        app.validatePersonalInformation();
        app.ssn3 = '78';
        app.validatePersonalInformation();
        app.ssn3 = '789';
        app.validatePersonalInformation();
        app.dobDate = '17';
        app.dobMonth = '08';
        app.dobYear = '1985';
        app.validatePersonalInformation();
        app.phoneCode = '000';
        app.validatePersonalInformation();
        app.phoneNumber = '000';
        app.validatePersonalInformation();
        app.phoneNumber1 = '0000';
        app.altPhoneCode = 'abc';
        app.validatePersonalInformation();
        app.altPhoneCode = '000';
        app.altPhoneNumber = 'abc';
        app.validatePersonalInformation();
        app.altPhoneNumber = '000';
        app.altPhoneNumber1 = 'abcd';
        app.validatePersonalInformation();
        app.altPhoneNumber1 = '0000';
        app.validatePersonalInformation();
        app.strEmail = 'test@test.com';
        app.validatePersonalInformation();

        app.strAppType = 'Company';
        app.validatePersonalInformation();
        app.strCompanyName = 'Company';
        app.validatePersonalInformation();
        app.strCompanyFirst = 'First';
        app.validatePersonalInformation();
        app.strCompanyLast = 'Last';
        app.validatePersonalInformation();
        app.strTaxId = '000000000';
        app.validatePersonalInformation();
        app.strDateOfIncorporationD = '15';
        app.strDateOfIncorporationM = '03';
        app.strDateOfIncorporationY = '1992';
        app.validatePersonalInformation();
        app.phoneCode = '';
        app.validatePersonalInformation();
        app.phoneCode = '000';
        app.phoneNumber = '';
        app.validatePersonalInformation();
        app.phoneNumber = '000';
        app.phoneNumber1 = '';
        app.validatePersonalInformation();
        app.phoneNumber1 = '0000';
        app.altPhoneCode = 'abc';
        app.validatePersonalInformation();
        app.altPhoneCode = '000';
        app.altPhoneNumber = 'abc';
        app.validatePersonalInformation();
        app.altPhoneNumber = '000';
        app.altPhoneNumber1 = 'abcd';
        app.validatePersonalInformation();
        app.altPhoneNumber1 = '0000';
        app.strEmail = '';
        app.validatePersonalInformation();
        app.strEmail = 'test@test.com';
        app.validatePersonalInformation();
    }

    @isTest
    private static void testValidateAddressBankEmployment()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.validateCurrentAddressInformation();
        app.strCountry = 'Albania';
        app.validateCurrentAddressInformation();
        app.strState = 'CA';
        app.validateCurrentAddressInformation();
        app.strZip = '0000';
        app.validateCurrentAddressInformation();
        app.strFromYear = '1988';
        app.strFromMonth = '10';
        app.strToMonth = '10';
        app.strToYear = '2015';
        app.validateCurrentAddressInformation();
        app.validatePreviousAddressInformation();
        app.strPrevZip = 'abc';
        app.validatePreviousAddressInformation();
        app.strPrevZip = '123';
        app.strPrevFromYear = '19848';
        app.validatePreviousAddressInformation();
        app.strPrevFromYear = '1988';
        app.strPrevFromMonth = '10';
        app.strPrevToMonth = '10';
        app.strPrevToYear = '2015';
        app.validatePreviousAddressInformation();
        app.validateBankInformation();
        app.strBankName = 'BOA';
        app.validateBankInformation();
        app.validateEmploymentInformation();
        app.strOccupation = 'Service';
        app.validateEmploymentInformation();
        app.strPosition = 'Sales';
        app.validateEmploymentInformation();
        app.strEmployer = 'IBM';
        app.strSupervisorCode = 'abc';
        app.validateEmploymentInformation();
        app.strSupervisorCode = '123';
        app.strSupervisorPhone1 = 'abcd';
        app.strSupervisorPhone2 = 'abcd';
        app.validateEmploymentInformation();
        app.strSupervisorPhone1 = '123';
        app.strSupervisorPhone2 = '123';
        app.validateEmploymentInformation();
        app.strStartMonth = '8';
        app.strStartYear = '10';
        app.validateEmploymentInformation();
        app.annualSalary = '100';
        app.validateEmploymentInformation();
        app.otherIncome = '50';
    }

    @isTest
    private static void testValidatePetsAndOtherApplicants()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.numberOfPets = 1;
        app.validatePets();
        app.breed1 = 'A';
        app.validatePets();
        app.weight1 = '6';
        app.validatePets();
        app.weight1 = '26';
        app.validatePets();
        app.weight1 = '6';

        app.numberOfPets = 2;
        app.validatePets();
        app.breed2 = 'B';
        app.validatePets();
        app.weight2 = '10';
        app.validatePets();
        app.weight2 = '20';
        app.validatePets();
        app.weight2 = '6';

        app.numberOfPets = 3;
        app.breed3 = 'C';
        app.validatePets();
        app.weight3 = '10';
        app.validatePets();
        app.weight3 = '26';
        app.validatePets();

        app.numberOfApplicants = 1;
        app.validateOtherApplicants();
        app.other1FirstName = 'other1';
        app.validateOtherApplicants();
        app.other1LastName = 'last1';
        app.validateOtherApplicants();
        app.other1Email = '1@1.com';
        app.validateOtherApplicants();

        app.numberOfApplicants = 2;
        app.validateOtherApplicants();
        app.other2FirstName = 'other2';
        app.validateOtherApplicants();
        app.other2LastName = 'last2';
        app.validateOtherApplicants();
        app.other2Email = '2@2.com';
        app.validateOtherApplicants();

        app.numberOfApplicants = 3;
        app.other1FirstName = '';
        app.validateOtherApplicants();
        app.other1FirstName = 'first';
        app.other1LastName = '';
        app.validateOtherApplicants();
        app.other1LastName = 'last1';
        app.other1Email = '';
        app.validateOtherApplicants();
        app.other1Email = '1@1.com';
        app.other2FirstName = '';
        app.validateOtherApplicants();
        app.other2FirstName = 'second';
        app.other2LastName = '';
        app.validateOtherApplicants();
        app.other2LastName = 'last2';
        app.other2Email = '';
        app.validateOtherApplicants();
        app.other2Email = '2@2.com';
        app.validateOtherApplicants();

        app.other3FirstName = 'other3';
        app.validateOtherApplicants();
        app.other3LastName = 'last3';
        app.validateOtherApplicants();
        app.other3Email = '3@3.com';
        app.validateOtherApplicants();

        app.numberOfApplicants = 4;
        app.other1FirstName = '';
        app.validateOtherApplicants();
        app.other1FirstName = 'first';
        app.other1LastName = '';
        app.validateOtherApplicants();
        app.other1LastName = 'last1';
        app.other1Email = '';
        app.validateOtherApplicants();
        app.other1Email = '1@1.com';
        app.other2FirstName = '';
        app.validateOtherApplicants();
        app.other2FirstName = 'second';
        app.other2LastName = '';
        app.validateOtherApplicants();
        app.other2LastName = 'last2';
        app.other2Email = '';
        app.validateOtherApplicants();
        app.other2Email = '2@2.com';
        app.other3FirstName = '';
        app.validateOtherApplicants();
        app.other3FirstName = 'third';
        app.other3LastName = '';
        app.validateOtherApplicants();
        app.other3LastName = 'last3';
        app.other3Email = '';
        app.validateOtherApplicants();
        app.other3Email = '3@3.com';
        app.validateOtherApplicants();

        app.other4FirstName = 'other4';
        app.validateOtherApplicants();
        app.other4LastName = 'last4';
        app.validateOtherApplicants();
        app.other4Email = '4@4.com';
        app.validateOtherApplicants();
    }

    @isTest
    private static void testValidateCertificateAndPayment()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.validateCertification();
        app.signatureFirst = 'f';
        app.signatureLast = 'l';
        app.signatureMiddle = '';
        app.validateCertification();
        app.signatureMiddle = 'm';
        app.validateCertification();

        PromoCode__c promos = new PromoCode__c();
        promos.Code__c = 'ABCD';
        promos.Name = 'test';
        insert promos;

        app.validatePayment();
        app.strCardNumber = '123456789';
        app.validatePayment();
        app.strCardMonth = '01';
        app.strCardYear = '2016';
        app.validatePayment();
        app.strSecurityCode = '12';
        app.validatePayment();
        app.strPayBy = 'Visa';
        app.validatePayment();
        app.strSecurityCode = '123';
        app.validatePayment();
        app.strPayBy = 'American Express';
        app.validatePayment();
        app.strSecurityCode = '1234';
        app.validatePayment();
        app.strCardName = 'Test Name';
        app.validatePayment();
        app.strCardAddress = 'address';
        app.validatePayment();
        app.strCardCity = 'city';
        app.validatePayment();
        app.strCardZip = '1234';
        app.validatePayment();
        app.strPromoCode = 'A';
        app.validatePayment();
        app.strPromoCode = 'ABCD';
        app.validatePayment();
    }

    @isTest
    private static void testgoToPayment()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'name';
        app.applicantLastName = 'last';
        app.ssn1 = '123';
        app.ssn2 = '456';
        app.ssn3 = '789';
        app.dobDate = '7';
        app.dobMonth = '8';
        app.dobYear = '1986';
        app.phoneCode = '000';
        app.phoneNumber = '100';
        app.phoneNumber1 = '121';
        app.strEmail = 'user@email.com';
        app.strCountry = 'USA';
        app.strState = 'Denver';
        app.strZip = '12345';
        app.strFromMonth = '8';
        app.strFromYear = '2001';
        app.strToMonth = '12';
        app.strToYear = '2015';
        app.strBankName = 'BOA';
        app.strOccupation = 'Service';
        app.strPosition = 'Manager';
        app.strEmployer = 'IBM';
        app.strStartMonth = '02';
        app.strStartYear = '2011';
        app.annualSalary = '150000';
        app.numberOfApplicants = 0;
        app.numberOfPets = 0;
        app.signatureFirst = 'f';
        app.signatureLast = 'l';
        app.signatureMiddle = 'm';
        app.goToPayment();
    }

    @isTest
    private static void testSubmitCardDetails()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.applicantName = 'test';
        app.applicantLastName = 'last';

        payPalCustomSetting__c pp = new payPalCustomSetting__c();
        pp.Name = 'testCoverage';
        pp.username__c = 'test';
        pp.password__c = 'pwd';
        pp.signature__c = 'sign';
        pp.endpoint__c = 'endpoint';
        pp.Amount__c = 50;
        insert pp;

        Account acc = new Account();
        acc.LastName = 'test';
        acc.PersonEmail = 'account@test.com';
        insert acc;

        Opportunity o = new Opportunity();
        o.Name = 'testOpp1';
        o.StageName = 'Open';
        o.AccountId = acc.Id;
        o.CloseDate = date.today();
        insert o;

        Property__c prop = new Property__c();
        prop.Opportunity__c = o.Id;
        insert prop;

        app.strProperty = prop.Id;

        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardMonth = '01';
        app.strCardYear = '2016';
        app.strPayBy = 'Visa';
        app.strSecurityCode = '123';
        app.strCardName = 'Test Name';
        app.strCardCity = 'city';
        app.strCardAddress = 'address';
        app.strCardZip = '4539';
        app.submitCardDetails();

        PromoCode__c promo = new PromoCode__c();
        promo.Code__c = 'ABCD';
        promo.Name = 'test';
        insert promo;

        app.strPromoCode = 'ABCD';
        app.submitCardDetails();

        app.strEmail = 'account@test.com';
        app.submitCardDetails();

        app.strEmail = 'lead@test.com';

        Lead l = new Lead();
        l.Email = 'lead@test.com';
        l.LastName = 'test';
        l.Property_Name__c = '10 Downing';
        insert l;

        app.submitCardDetails();

        Contact_Role__c cr = new Contact_Role__c();
        cr.Opportunity__c = o.Id;
        cr.Contact__c = acc.Id;
        cr.Status__c = 'Submitted Application';
        insert cr;

        app.cid = cr.Id;
        app.checkForDuplicate();
       // app.setNumberOfPets();

        cr.Status__c = 'New';
        update cr;
        app.checkForDuplicate();

        app.cid = cr.Id;
        app.strCardName = 'test';
        app.strCardAddress = 'address';
        app.strCardCity = 'city';
        app.strCardState = 'Alabama';
        app.strPayBy = 'Visa';
        app.strCardZip = '4534';
        app.strCardNumber = '4444111122223333';
        app.strCardYear = '2016';
        app.strCardMonth = '01';
        app.strSecurityCode = '333';
        app.submitCardDetails();
    }

    @isTest
    private static void testOtherApplicants()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();

        Account acc = new Account();
        acc.PersonEmail = '1@1.com';
        acc.LastName = 'test';
        insert acc;

        payPalCustomSetting__c pp = new payPalCustomSetting__c();
        pp.Name = 'testCoverage';
        pp.username__c = 'test';
        pp.password__c = 'pwd';
        pp.signature__c = 'sign';
        pp.endpoint__c = 'endpoint';
        pp.Amount__c = 50;
        insert pp;

        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'name';
        app.applicantLastName = 'last';
        app.ssn1 = '123';
        app.ssn2 = '456';
        app.ssn3 = '789';
        app.dobDate = '7';
        app.dobMonth = '8';
        app.dobYear = '1986';
        app.phoneCode = '000';
        app.phoneNumber = '100';
        app.phoneNumber1 = '121';
        app.strEmail = 'user@email.com';
        app.strCountry = 'USA';
        app.strState = 'Denver';
        app.strZip = '12345';
        app.strFromMonth = '8';
        app.strFromYear = '2001';
        app.strToMonth = '12';
        app.strToYear = '2015';
        app.strBankName = 'BOA';
        app.strOccupation = 'Service';
        app.strPosition = 'Manager';
        app.strEmployer = 'IBM';
        app.strStartMonth = '02';
        app.strStartYear = '2011';
        app.annualSalary = '150000';
        app.numberOfApplicants = 1;
        app.other1Email = '1@1.com';
        app.other1FirstName = 'first';
        app.other1LastName = 'last1';
        app.other1Role = 'Guarantor';
        app.numberOfPets = 0;
        app.signatureFirst = 'f';
        app.signatureLast = 'l';
        app.signatureMiddle = 'm';
        app.goToPayment();

        Account acc1 = new Account();
        acc1.LastName = 'test';
        acc1.PersonEmail = 'account@test.com';
        insert acc1;

        Opportunity o = new Opportunity();
        o.Name = 'testOpp1';
        o.StageName = 'Open';
        o.AccountId = acc.Id;
        o.CloseDate = date.today();
        insert o;

        Contact_Role__c cr = new Contact_Role__c();
        cr.Opportunity__c = o.Id;
        cr.Contact__c = acc.Id;
        cr.Status__c = 'Application Sent';
        insert cr;

        app.cid = cr.Id;
        app.strCardName = 'test';
        app.strCardAddress = 'address';
        app.strCardCity = 'city';
        app.strCardState = 'Alabama';
        app.strPayBy = 'Visa';
        app.strCardZip = '4534';
        app.strCardNumber = '4444111122223333';
        app.strCardYear = '2016';
        app.strCardMonth = '01';
        app.strSecurityCode = '333';
        app.submitCardDetails();
    }
}