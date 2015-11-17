/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData = true)
public with sharing class SL_TestApplicationFormController 
{
    static Id customersRecordType = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
    
    static testMethod void testPageLoadMethods()
    {
        Building__c objBuilding = new Building__c();
        objBuilding.Name = 'Test Building';
        objBuilding.Street_Address__c = '23rd';
        objBuilding.Zip_Code__c = '56700';
        insert objBuilding;
        
        Apartment__c property1 = new Apartment__c();
        property1.Apartment_Status__c = '2. Rent Ready';
        property1.Building__c = objBuilding.Id;
        property1.Apartment_Number__c = 'Property1';
        insert property1;
		
		Account objAccount = new Account(FirstName='Test', LastName = 'Account1',RecordTypeId = customersRecordType);
	    insert objAccount;
	    
	    Opportunity objOpportunity = new Opportunity(Name='Test Opportunity',AccountId = objAccount.Id,
	                                                 CloseDate = Date.today(),StageName='Prospecting',Apartment__c = property1.Id);
	    insert objOpportunity;    
	    
	    Contact_Role__c objContactRole = new Contact_Role__c(Person_Account__c = objAccount.Id,
	                                                        Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com', e_Renter__c = 'abc',
	                                                         Current_Address_Country__c = 'United States', SSN_C__c = '000000000');
	                                                         
	    insert objContactRole; // Inserting Contact Role record
	    
	    ApexPages.currentPage().getParameters().put('cid', objContactRole.Id);
	    
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.getCountry(); 
        app.getIndustry();
        app.getRole();
        app.getSuffix();
        app.getProperty();
        app.getCardState();
        app.strCountry = 'Algeria';
        app.changeCurrentStateBasedOnCountry();
        app.strCountry = 'United States';
        app.changeCurrentStateBasedOnCountry();
        app.getOtherIncomeSource1();
        app.getOtherIncomeSource2();
    }

    static testMethod void testValidatePersonalInformation()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = 'Test';
        app.strSuffix = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = 'Test';
        app.strSuffix = 'mr';
        app.ssn = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = 'Test';
        app.ssn = '123-123-123';
        app.strSuffix = 'mr';
        app.dob = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = 'Test';
        app.ssn = '123-123-123';
        app.dob = '12/12/2014';
        app.strSuffix = 'mr';
        app.phone = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = 'Test';
        app.ssn = '123-123-123';
        app.dob = '12/12/2014';
        app.phone = '123-123-123';
        app.strSuffix = 'mr';
        app.altPhone = '';
        app.goToPayment();
        app.strAppType = 'Individual';
        app.applicantName = 'Test';
        app.applicantLastName = 'Test';
        app.ssn = '123-123-123';
        app.dob = '12/12/2014';
        app.phone = '123-123-123';
        app.altPhone = '678-678-678';
        app.strSuffix = 'mr';
        app.strEmail = '';
        app.goToPayment();
        
        
        app.strAppType = 'Company';
        app.goToPayment();
        app.strCompanyName = 'Company';
        app.goToPayment();
        app.strCompanyFirst = 'First';
        app.goToPayment();
        app.strCompanyLast = 'Last';
        app.goToPayment();
        app.strTaxId = '000000000';
        app.goToPayment();
        app.strCompanyName = 'Company';
        app.strCompanyFirst = 'First';
        app.strCompanyLast = 'Last';
        app.strTaxId = '000000000';
        app.strDateOfIncorporation = '12/12/2014';
        app.goToPayment();
        app.phone = '123-456-789';
        app.goToPayment();
        app.altPhone = '123-456-789';
        app.goToPayment();
        app.strEmail = 'test@test.com';
        app.goToPayment();
    }

    static testMethod void testValidateAddressBankEmployment()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.goToPayment();
        app.strAddress = 'Address';
        app.goToPayment();
        app.strAddress = 'Address';
        app.strCountry = 'US';
        app.goToPayment();
        app.strAddress = 'Address';
        app.strCountry = 'US';
        app.strCity = 'Bangalore';
        app.goToPayment();
        app.strAddress = 'Address';
        app.strCountry = 'US';
        app.strCity = 'Bangalore';
        app.strCity = 'Texas';
        app.goToPayment();
        app.strAddress = 'Address';
        app.strCountry = 'US';
        app.strCity = 'Bangalore';
        app.strCity = 'Texas';
        app.strZip = '0000';
        app.goToPayment();
        app.strAddress = 'Address';
        app.strCountry = 'US';
        app.strCity = 'Bangalore';
        app.strCity = 'Texas';
        app.strZip = '0000';
        app.moveInDate = '12/12/2014';
        app.goToPayment();
        app.strAddress = 'Address';
        app.strCountry = 'US';
        app.strCity = 'Bangalore';
        app.strCity = 'Texas';
        app.strZip = '0000';
        app.moveInDate = '12/12/2014';
        app.leaseEndDate = '12/12/2014';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.strSupervisorPhone = '123-456-789';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.strSupervisorPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.strSupervisorPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.annualSalary = '123';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.strSupervisorPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.annualSalary = '123';
        app.strIndustry = 'Software';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.strSupervisorPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.annualSalary = '123';
        app.strIndustry = 'Software';
        app.strSupervisorName = 'test';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition= 'Sen Dev';
        app.strEmployer = 'Test';
        app.strSupervisorPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.annualSalary = '123';
        app.strIndustry = 'Software';
        app.strSupervisorName = 'test';
        app.strTotalIncome = '123';
        app.goToPayment();

    }

    static testMethod void testValidatePetsAndOtherApplicants()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.strAppType = 'Individual';
        app.applicantName = 'Test Name';
        app.applicantLastName = 'Test Last';
        app.strSuffix = 'Senior';
        app.strRentOrOwn = 'Rent';
        app.ssn = '123-456-789';
        app.dob = '12/12/2014';
        app.phone = '123-456-789';
        app.strEmail = 'sa@sa.com';
        app.moveInDate = '12/12/2014';
        app.strAddress = '23rd';
        app.strCountry = 'United states';
        app.strCity = 'Newyork';
        app.strZip = '560040';
        app.strCompany =  'test';
        app.strPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.strDateOfIncorporation  = '12/12/2014';
        app.strEmployer = 'test';
        app.strPosition = 'dev';
        app.strIndustry = 'test';
        app.annualSalary = '1000';
        app.strTotalIncome = '10000';
        app.strOccupation = 'dev';
        app.strSupervisorName = 'test';
        app.strSupervisorPhone = '123-456-789';
        app.weight1 = 'S';
        app.goToPayment();
        app.weight2 = 'S';
        app.goToPayment();
    }

    static testMethod void testValidateEmploymentInformation()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sendev';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sen dev';
        app.strEmployer = 'test';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sen dev';
        app.strEmployer = 'test';
        app.strSupervisorPhone = '123-235.0-345';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sen dev';
        app.strEmployer = 'test';
        app.strSupervisorPhone = '123-234-345';
        app.strEmploymentStartDate = '12/12/2014';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sen dev';
        app.strEmployer = 'test';
        app.strSupervisorPhone = '123-234-345';
        app.strEmploymentStartDate = '55/12/2014';
        app.annualSalary = '123';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sen dev';
        app.strEmployer = 'test';
        app.strSupervisorPhone = '123-234-345';
        app.strEmploymentStartDate = '12/12/2014';
        app.annualSalary = 'SA.3';
        app.strIndustry = 'test';
        app.goToPayment();
        app.strOccupation = 'Dev';
        app.strPosition = 'Sen dev';
        app.strEmployer = 'test';
        app.strSupervisorPhone = '123-234-345';
        app.strEmploymentStartDate = '12/12/2014';
        app.annualSalary = '123';
        app.strIndustry = 'test';
        app.strSupervisorName = 'test';
        app.goToPayment();
        
    }
    
    
    static testMethod void testgoToPayment()
    {
        Building__c objBuilding = new Building__c();
        objBuilding.Name = 'Test Building';
        objBuilding.Street_Address__c = '23rd';
        objBuilding.Zip_Code__c = '56700';
        insert objBuilding;
        
        SL_PayPalCustomSetting__c pp = new SL_PayPalCustomSetting__c();
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
		
		Promo_Code__c objPromoCode = new  Promo_Code__c();
		objPromoCode.Active__c = true;
		objPromoCode.Name = '123';
		insert objPromoCode;
		
        Opportunity o = new Opportunity();
        o.Name = 'testOpp1';
        o.StageName = 'Open';
        o.AccountId = acc.Id;
        o.CloseDate = date.today();
        o.Promo_Code__c = objPromoCode.Id;
        test.startTest();
        insert o;
        test.stopTest();
        
        Apartment__c prop = new Apartment__c();
        prop.Opportunity__c = o.Id;
        prop.Building__c = objBuilding.Id;
        insert prop;
        
        Contact_Role__c objContactRole = new Contact_Role__c();
        objContactRole.Opportunity__c  = o.Id;
        objContactRole.Person_Account__c  = acc.Id;
        insert objContactRole;
         
        ApexPages.currentPage().getParameters().put('cid', objContactRole.Id);
        ApexPages.currentPage().getParameters().put('oid', o.Id);
        
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.strAppType = 'Individual';
        app.applicantName = 'Test Name';
        app.applicantLastName = 'Test Last';
        app.strSuffix = 'Senior';
        app.strRentOrOwn = 'Rent';
        app.ssn = '123-456-789';
        app.dob = '12/12/2014';
        app.phone = '123-456-789';
        app.strEmail = 'sa@sa.com';
        app.moveInDate = '12/12/2014';
        app.strAddress = '23rd';
        app.strCountry = 'United states';
        app.strCity = 'Newyork';
        app.strZip = '560040';
        app.strCompany =  'test';
        app.strPhone = '123-456-789';
        app.strEmploymentStartDate = '12/12/2014';
        app.strDateOfIncorporation  = '12/12/2014';
        app.strEmployer = 'test';
        app.strPosition = 'dev';
        app.strIndustry = 'test';
        app.annualSalary = '1000';
        app.strTotalIncome = '10000';
        app.strOccupation = 'dev';
        app.strSupervisorName = 'test';
        app.strSupervisorPhone = '123-456-789';
        app.strProperty = prop.Id;
        app.goToPayment();
    }

    static testMethod void testSubmitCardDetails()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();
        app.applicantName = 'test';
        app.applicantLastName = 'last';
        
        Building__c objBuilding = new Building__c();
        objBuilding.Name = 'Test Building';
        objBuilding.Street_Address__c = '23rd';
        objBuilding.Zip_Code__c = '56700';
        insert objBuilding;
        
        SL_PayPalCustomSetting__c pp = new SL_PayPalCustomSetting__c();
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

        Apartment__c prop = new Apartment__c();
        prop.Opportunity__c = o.Id;
        prop.Building__c = objBuilding.Id;
        insert prop;

        app.strProperty = prop.Id;

        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.strSecurityCode = '123';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.strSecurityCode = '123';
        app.strPayBy = 'Visa';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.strSecurityCode = '123';
        app.strPayBy = 'Visa';
        app.strCardName = 'Test Name';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.strSecurityCode = '123';
        app.strPayBy = 'Visa';
        app.strCardName = 'Test Name';
        app.strCardCity = 'city';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.strSecurityCode = '123';
        app.strPayBy = 'Visa';
        app.strCardName = 'Test Name';
        app.strCardCity = 'city';
        app.strCardAddress = 'address';
        app.submitCardDetails();
        app.strCardNumber = '123456789';
        app.strCardDate = '01/2014';
        app.strSecurityCode = '123';
        app.strPayBy = 'Visa';
        app.strCardName = 'Test Name';
        app.strCardCity = 'city';
        app.strCardAddress = 'address';
        app.strCardZip = '4539';
        app.submitCardDetails();

        Promo_Code__c promo = new Promo_Code__c();
        promo.Name = 'ABCD';
        promo.Active__c = true;
        insert promo;

        app.strPromoCode = 'ABCD';
        app.submitCardDetails();

        app.strEmail = 'account@test.com';
        app.submitCardDetails();

        app.strEmail = 'lead@test.com';

        Lead l = new Lead();
        l.Email = 'lead@test.com';
        l.LastName = 'test';
        insert l;

        app.submitCardDetails();

        Contact_Role__c cr = new Contact_Role__c();
        cr.Opportunity__c = o.Id;
        cr.Person_Account__c = acc.Id;
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
        app.strCardDate = '2016';
        app.strSecurityCode = '333';
        app.submitCardDetails();
    }

    static testMethod void testOtherApplicants()
    {
        SL_ApplicationForm_Controller app = new SL_ApplicationForm_Controller();

        Account acc = new Account();
        acc.PersonEmail = '1@1.com';
        acc.LastName = 'test';
        insert acc;

        SL_PayPalCustomSetting__c pp = new SL_PayPalCustomSetting__c();
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
        app.ssn = '123';
        app.dob = '12/12/2014';
        app.phone = '000-123-123';
        app.strEmail = 'user@email.com';
        app.strCountry = 'USA';
        app.strState = 'Denver';
        app.strZip = '12345';
        app.strOccupation = 'Service';
        app.strPosition = 'Manager';
        app.strEmployer = 'IBM';
        app.annualSalary = '150000';
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
        cr.Person_Account__c = acc.Id;
        cr.Status__c = 'Application Sent';
        insert cr;
        
        ApexPages.currentPage().getParameters().put('cid', cr.Id);
        ApexPages.currentPage().getParameters().put('oid', o.Id);
        app.cid = cr.Id;
        app.strCardName = 'test';
        app.strCardAddress = 'address';
        app.strCardCity = 'city';
        app.strCardState = 'Alabama';
        app.strPayBy = 'Visa';
        app.strCardZip = '4534';
        app.strCardNumber = '4444111122223333';
        app.strCardDate = '2016';
        app.strSecurityCode = '333';
        app.submitCardDetails();
        app.showHideRentOrOwn();
        app.strRentOrOwn = 'Own';
        app.showHideRentOrOwn();
        
        app.showHideEmploymentFields();
        app.strEmployed = 'Employed';   
        app.showHideEmploymentFields();
        app.strEmployed = 'Self-Employed';
        app.showHideEmploymentFields();
        app.strEmployed = 'Unemployed';
        app.showHideEmploymentFields();
        app.strEmployed = 'Student';
        app.showHideEmploymentFields();
		        
    }
}