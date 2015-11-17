/***************************************************************************
Name : loadCompaniesController
Created Date : 8th April , 2013
Created By : Reena Acharya(Appirio Offshore)
Description : Created to load multiple companies and junction records for 
              Story : S-105959
***************************************************************************/
public class loadCompaniesController{
    //Variables
    public List<wrapperClas> objectList {get;set;}
    public Company_Conference_Award__c selectConfAward {get;set;}
    public Boolean companiesUploaded {get;set;}
    public ID recordTypeID ;
    
    //Constructor
    public loadCompaniesController(){
        initializeCompanies();        
    }   
    private List<SelectOption> IndustryList;
    private List<SelectOption> SourceList;
    private List<SelectOption> getIndustryList() {
    List<SelectOption> options = new List<SelectOption>{new SelectOption('','--None--')};
        Schema.DescribeFieldResult fieldResult = Account.Industry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    private List<SelectOption> getSourceList() {
    List<SelectOption> options = new List<SelectOption>{new SelectOption('','--None--')};
        Schema.DescribeFieldResult fieldResult = Account.Source__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }    
    //Initialize list to show on VF page .
    public void initializeCompanies(){
        objectList = new List<wrapperClas>();
        selectConfAward = new Company_Conference_Award__c ();
    IndustryList = getIndustryList();
        SourceList = getSourceList();
        //Accounts to be inserted should be of company type only.
        List<RecordType> recordTypes = new List<RecordType>([Select id from RecordType where sobjectType = 'Account' and Name = 'Company']);
        recordTypeID = recordTypes.get(0).Id;
        
        for(integer i=0;i<50;i++){
            wrapperClas wrap = new wrapperClas(recordTypeID, IndustryList,SourceList);
            objectList.Add(wrap);
        }
        companiesUploaded = false;
    }
    
    //Save companies and its junction objects
    public PageReference UplaodCompanies(){
        //Variables
        Set<String> companyNames = new Set<String>();
        Map<String , Account> existingAccount = new Map<String, Account>(); 
        List<Company_Financial__c> compFinancialsToUpsert = new List<Company_Financial__c>();
        List<Company_Conference_Award__c> compConfAwardsToupsert = new List<Company_Conference_Award__c>();
        Set<String> years = new Set<String>();
        //If award is not selected then send a message and return.
        if(selectConfAward.Conference_Award__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'Please select an award before uploading companies.'));                
            return null ;
        }
        
        //Create a set of account names to be uploaded.  
        //If user fills same name multiple times to upload then show a message to user. 
        for(wrapperClas wrap : objectList ){
          wrap.Account.Name = wrap.companyName;
          wrap.Account.Description = wrap.description; 
         wrap.Account.Industry = wrap.selectedGASector;
         wrap.Account.Source__c = wrap.selectedSource;
            if(wrap.Account.Name != null && wrap.Account.Name.Trim() != ''){
                if(wrap.compConf.Rank__c == null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Rank is required.'));                
                    return null ;
                }
                if(companyNames.Contains(wrap.Account.Name.Trim())){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'You are trying to upload multiple companies with same names.Please remove duplicates.'));                
                    return null ;
                }
                
                
                companyNames.Add(wrap.Account.Name.Trim());
                if(wrap.compFin.Year__c != null)
                    years.add(wrap.compFin.Year__c);
                
            }
            if(wrap.compFin.Data_Source__c ==  'Other (specify)' && wrap.compFin.Data_Source_Other__c == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Please specify a value for "Data Source (Other)"')); 
                return null;
            }
        }
        
        //If there is no company name filled by the user and click on upload then show him a message.
        if(companyNames.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'There is no company to upload.'));                
            return null ;
        }
        
        //Get accounts which already exists in org and user has written a name to upload.
        for(Account acc : [Select id,Description,name,Industry from Account where name in : companyNames and recordTypeId = :recordTypeID ]){
            existingAccount.put(acc.Name.Trim().ToUpperCase() , acc);        
        }
        system.debug('===existingAccount==='+ existingAccount);
        
        //Iterate the wrapper class.
        List<Account> accountsToUpsert = new List<Account>();
        for(wrapperClas wrap : objectList ){
            
            //If user has filled any name of account to upload then only process else not.
            if(wrap.Account.Name != null && wrap.Account.Name.Trim() != ''){
                //Get Name.
                String accName = wrap.Account.Name.Trim().ToUpperCase();
                system.debug('====acc====='+ accName );
                
                //If account already exists then previous Industry,Name should remain as it is.
                if(existingAccount.ContainsKey(accName)){
                    wrap.Account.Id = existingAccount.get(accName).Id;
                    wrap.Account.Name = existingAccount.get(accName).Name;
                    wrap.Account.Industry = existingAccount.get(accName).Industry;
                    
                    //If account exists then update description in a specific format.
                    if(wrap.Account.Description != null && wrap.Account.Description != '' ){
                        wrap.Account.Description = (existingAccount.get(accName).Description != null ? existingAccount.get(accName).Description +'\n ... \n \n' : '' ) + wrap.Account.Description;                
                    }
                    else{
                        wrap.Account.Description = existingAccount.get(accName).Description;                
                    }
                }    
                
                //Add account to insert in a list.           
                accountsToUpsert.Add(wrap.Account);
            }
        }
        
        //Insert accounts
        if(accountsToUpsert.size() > 0)
            upsert accountsToUpsert;
         
         //Get company conferenece awards which already exists for the relative companies.
         Map<ID,Company_Conference_Award__c> confConfAwardExists = new Map<ID ,Company_Conference_Award__c  >();
         for( Company_Conference_Award__c  compConfAward : [Select id ,Company__c from Company_Conference_Award__c  where Conference_Award__c =: selectConfAward.Conference_Award__c and Company__c  in : accountsToUpsert]){
               confConfAwardExists.put(compConfAward.Company__c , compConfAward );
         }
         
         //Get company financials which already exists for the relative companies.
         Map<String,Company_Financial__c> compFinExists = new Map<String,Company_Financial__c >();
         for( Company_Financial__c  compFin : [Select id ,Company__c,Year__c,Data_Source_Other__c,Data_Source__c from Company_Financial__c where Company__c  in : accountsToUpsert and year__c in : years]){
               compFinExists.put(compFin.Company__c +'~'+ compFin.Year__c  , compFin );
         }
         
         system.debug('=========confConfAwardExists====='+ confConfAwardExists);
         
         for(wrapperClas wrap : objectList ){

            //If user has filled any name of account to upload then only process else not.
            if(wrap.Account.Name != null && wrap.Account.Name.Trim() != ''){
                //If Revenue is not null then only insert/update company financials.
                if(wrap.compFin.Revenue_MM__c != null && wrap.compFin.Year__c != null){
                    if(compFinExists.ContainsKey(wrap.Account.Id +'~'+ wrap.compFin.Year__c)){ 
                        wrap.compFin.Id = compFinExists.get(wrap.Account.Id +'~'+ wrap.compFin.Year__c).Id;
                    }
                    else{
                        wrap.compFin.Company__c = wrap.Account.Id;
                    }
                    compFinancialsToUpsert.Add(wrap.compFin);
                }
                
                //If Rank is not null then only insert/update company conference award.
                if(wrap.compConf.Rank__c != null){
                    system.debug('=========wrap.compConf.Company__c====='+ wrap.account.Id);
                    if(confConfAwardExists.ContainsKey(wrap.account.Id)){
                        wrap.compConf.Id = confConfAwardExists.get(wrap.account.Id).Id;
                    }               
                    else{
                        wrap.compConf.Conference_Award__c = selectConfAward.Conference_Award__c;
                        wrap.compConf.Company__c = wrap.Account.Id;
                    }
                    compConfAwardsToUpsert.Add(wrap.compConf);   
                }
                
            }
        } 
        
        //Insert company finance. 
        if(compFinancialsToUpsert.size() > 0)
            upsert compFinancialsToUpsert;
        
        //Insert company conference awards    
        if(compConfAwardsToUpsert.size() > 0)
            upsert compConfAwardsToUpsert;
        
        //After upserting data we should show a message to the user    
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, accountsToUpsert.size() + ' companies has been uploaded successfully.'));                
        companiesUploaded = true;              
        return null;
    }
    
    //If user want to upload more then initialize list again and show tha UI.
    public PageReference UplaodMoreCompanies(){
        companiesUploaded = false;
        initializeCompanies();
        return null;
    }
    
    
    //Wrapper class to show on UI
    public class wrapperClas{
      public String companyName {get;set;}
      public String description {get;set;}
      public String selectedGASector{get;set;} 
      public String selectedSource{get;set;} 
      public List<SelectOption> GASectorList{get;set;}
      public List<SelectOption> sourceList{get;set;}
        public Account account {get;set;}
        public Company_Conference_Award__c compConf {get;set;}
        public Company_Financial__c compFin {get;set;}       
        
        public wrapperClas(Id recordTypeID, List<SelectOption> industryLst, List<SelectOption> srcLst){
          GASectorList = industryLst;
          sourceList =  srcLst;
            account = new Account(RecordTypeId = recordTypeID);
            compConf = new Company_Conference_Award__c();
            compFin = new Company_Financial__c(Type__c = 'Actual' , Year__c = String.valueOf(Date.Today().Year()));
            
        }
        
    }
}