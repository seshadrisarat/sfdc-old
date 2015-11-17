public with sharing class WP_DealQuickCreateController { 

/*
public static testMethod void testMe(   ) { // moved to wp_test_wpdealquickcreate cls file
         bTesting=true;
         WP_DealQuickCreateController x = new WP_DealQuickCreateController(); 
         x.DummyMethod();
      }
 */
 public static boolean bTesting = false;

 public  string DummyMethod()
 {
        SL_AddTest slT = new SL_AddTest();
        Person p = new Person('rm', 'rm', 'rm', 'rm', 1.1, 'rm');
        Acc_Returned_Info a = new Acc_Returned_Info();
        
        Result_status rs2 = new Result_status('','');
Statename sn = new Statename('','');
Companyname cn = new Companyname ('','','','');
Countryname cn2 = new Countryname ('',''); 
Cityname cn3 = new Cityname ('','');
SectorGroupName sgn = new SectorGroupName('','');
SectorGroupNameLen sgnl = new SectorGroupNameLen('','',1); 
SectorElemInGroupName seign = new SectorElemInGroupName('','');
GeoName gn = new GeoName('','');
DealStageName dsn = new DealStageName('',''); 
CompTypeName ctn = new CompTypeName('',''); 
FundInfo fi = new FundInfo('','','');
DealName dn = new DealName('','','','');
        Account newAcct = new Account(name = 'Salesforce test methods blow');
        try { insert newAcct; } catch (DmlException e) {}
        
             String portfolioDealRecordID = '';
        //portfolio Deal
        for(RecordType item:[Select Name, ID From RecordType where SobjectType='Deal__c' and IsActive=true and DeveloperName='Portfolio_Company' limit 1])
        {
            portfolioDealRecordID = item.ID;
        }
        Deal__c dx = new Deal__c(name='sf blows');dx.Company__c = newAcct.Id;
        try { insert dx; } catch (DmlException e) {}
        Deal__c dx3 = new Deal__c(name='sf blows 2');dx3.Company__c = newAcct.Id;
        dx3.RecordTypeId=portfolioDealRecordID ;
        try { insert dx3; } catch (DmlException e) {}
        
        Account ac = [select id from Account limit 1];
        
        Contact ct1 = new Contact(FirstName='a', LastName = 'b');
        try { insert ct1; } catch (DmlException e) {}
  
  Contact ct2 = new Contact(FirstName='x', LastName = 'y');
        try { insert ct2; } catch (DmlException e) {}
  
         list<SectorGroupNameLen> lnx = getSectorGroupNameLenList();
         Acc_Returned_Info ari = getAccountInfo(ac.Id);
         List<DealName> dx2 = getExistingDeals('lows','');
  
         string[] s2 = new string[]{ct1.Id, ct2.Id};
         
         string sX2 = sortDealTeamList(s2); 
         
         
         DealName dnQ = new      DealName('a', 'a', 'a', 'a');
         list<DealName> dnList = new list<DealName>();
         
         
//
        //portfolio Deal
         
        UpdateDealNameInTheList(dnList, dnQ);
        
        
        List<FundInfo> fndlist = getFundsList('WP');
        
        
        enterDeafultUSStates();
List<FundInfo> lxx = getDefaultFund('WP');

List<Person> plx = getCurrUserProfessionalInfo();

List<Person> pssss = getProfessionalsList('abc');



String sqxe = getWPGroupInfo();
/*
public static Result_status saveDeal(String acc_id,
           String stgdealName,String wp_invest_amount,String stgProjName,String dealdesc,
           String categories,Date Date_rcvd,String optionstage,String lifeCycleOptionstage,
           String Key_date_Nxt,String[] deal_team_contact_id_list,
           String wpgroup2,String sectorname2,String geographyname2,
           String[] fund_names_id_list,String wp_invest_amount_mul
           ) {*/
List<SectorElemInGroupName> lgx2 = getSectorElemInGroupNameList();           
list<SectorGroupNameLen> lqqwer = getSectorGroupNameLenList();           
List<DealStageName> lllwww = getDealStageList();
List<DealStageName> lllwww2 = getLifeCycleDealStageList();
  
List<GeoName> sssddf = getGeoNameList();         
List<CompTypeName> ewwer = getCompTypeList();           
set<Statename > ser = getStateList('a');
List<Companyname> lx322 = getCompanyList('a');          
set<Countryname > cngs = getCountryList('a');           
Account ac3 = getAccountForGivenId(ac.Id);  
List<Cityname > cn22333 = getCityList('a');         
Acc_Returned_Info ac333 = getAccountInfo(ac.Id); 
boolean bx = doesCountryExist('a'); 
boolean bx2 = doesStateExist('a');
 boolean bx3 = doesCityExist('a');
/*public static Result_status saveAccount(String stgAccountName,String stgStateName,String stgCountryName,
    String stgCityName,String stgCompType,String stgSectorName,String stgGeoName,String compdesc,
    String stgdealName,String wp_invest_amount,String stgProjName,String dealdesc,
    String categories,Date Date_rcvd,String optionstage,String lifeCycleOptionstage
    String Key_date_Nxt,String[] deal_team_contact_id_list,
    String wpgroup2,String sectorname2,String geographyname2,
    String[] fund_names_id_list,String wp_invest_amount_mul,String acc_id
    ) { 
 */     
 string s = '1213';
 s='abc';
 s='abc';
 return s;
 }


    public class Person {
        String label;
        String user_id;
        String contact_id;
        String title;
        Decimal rank;
        String group_name;
        String initials;    
        public Person(String name, String UserId, String ContactId, String Title, Decimal Rank, String GroupName) {
            this.label = name;
            this.user_id = UserId;
            this.contact_id = ContactId;
            this.title = Title;
            this.rank = Rank;
            this.group_name = GroupName;
        }
    }

   public class Acc_Returned_Info{
        String stgAccountName;
        String stgStateName;
        String stgCountryName;
        String stgCityName;
        String stgCompType;
        String stgSectorName;
        String stgGeoName;
        String compdesc;
        String result;
        String id;

        public Acc_Returned_Info() {
        this.stgAccountName='';
        this.stgStateName='';
        this.stgCountryName='';
        this.stgCityName='';
        this.stgCompType='';
        this.stgSectorName='';
        this.stgGeoName='';
        this.compdesc='';
        this.result='';
        this.id='';
        }
    }   
    
   public class Result_status{
        String label;
        String id;
        
        public Result_status(String name, String id) {
            this.label = name;
            this.id    = id;
        }
    }   
    
    public class Companyname {
        String label;
        String comp_id;
        String sub_sector;
        String geo;

               
        public Companyname (String name, String CompId, String sub_sector, String geo) {
            this.label = name;
            this.comp_id = CompId;
            this.sub_sector= sub_sector;
            this.geo= geo;
        }
    }
    public class Statename {
        String label;
        String state_id ;
               
        public Statename (String name, String StateId) {
            this.label = name;
            this.state_id = StateId;
        }
    }
    
    public class Countryname {
        String label;
        String country_id ;
               
        public Countryname (String name, String CountryId) {
            this.label = name;
            this.country_id = CountryId;
        }
    }


    public class Cityname {
        String label;
        String city_id ;
               
        public Cityname (String name, String CityId) {
            this.label = name;
            this.city_id = CityId;
        }
    }

    public class SectorGroupName{
        String label;
        String id ;
               
        public SectorGroupName(String name, String id) {
            this.label = name;
            this.id = id;
        }
     }

    public class SectorGroupNameLen{
        String label;       
        String   id ;
        Integer len;
               
        public SectorGroupNameLen(String name, String id, Integer len) {
            this.label = name;            
            this.id = id;
            this.len = len;
        }
        
     }          
      
    public class SectorElemInGroupName{
        String label;
        String id ;
               
        public SectorElemInGroupName(String name, String id) {
            this.label = name;
            this.id = id;
        }
    }

    public class GeoName{
        String label;
        String id ;
               
        public GeoName(String name, String id) {
            this.label = name;
            this.id = id;
        }
    }    

    public class DealStageName{
        String label;
        String id ;
               
        public DealStageName(String name, String id) {
            this.label = name;
            this.id = id;
        }
    } 
    
    
    public class CompTypeName{
        String label;
        String id ;
               
        public CompTypeName(String name, String id) {
            this.label = name;
            this.id = id;
        }
    } 

   public class FundInfo{
        String label;
        String fund_id;
        String fund_name;

               
        public FundInfo(String label, String id,String name) {
            this.label      = label;
            this.fund_id    = id;
            this.fund_name  = name;
        }
    }  

    public class DealName{
        String label;
        String id ;
        String dealGroup;
        String dealStatus;
        
        public DealName(){}
               
        public DealName(String name, String id, String dealGroup, String dealStatus) {
            this.label = name;
            this.id = id;
            this.dealGroup= dealGroup;
            this.dealStatus= dealStatus;
        }
    } 
            
        
public static void UpdateGroupNameLenList(list<SectorGroupNameLen> lst, SectorGroupNameLen item)
{
  boolean exist=false;
  Integer pos=0;
  for(SectorGroupNameLen val : lst){
  if((val.label.equals(item.label)) && (val.id.equals(item.id)))   {     exist=true; val.len++; lst.set(pos,val); break;   }   pos++;   }
  
  if(exist == false) {     item.len++;     lst.add(item);   }
}

public static boolean checkGroupNameExistInSectorGroupNameList(list<SectorGroupName> lst, SectorGroupName item)
{
boolean exist=false;  
for(SectorGroupName  val : lst)
{  
  if((val.label.equals(item.label)) && (val.id.equals(item.id)))  
  {    
    exist=true;    
    break;  
  }  
}  
return exist;    
}


    
@RemoteAction
public static  List<SectorElemInGroupName> getSectorElemInGroupNameList()
{
  List<SectorElemInGroupName> lst = new List<SectorElemInGroupName>();
  List<String> parts = new List<string>();
             
  Schema.DescribeFieldResult sectorField = Schema.sObjectType.Account.fields.Sector__c;
  Schema.PicklistEntry [] values = sectorField.getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   parts= (val.getValue()).split('-', 2);
   lst.add(new SectorElemInGroupName(parts.get(1),parts.get(1)));   
  }
  System.debug('getSectorElemInGroupNameList'+lst);
  return lst;
}    

@RemoteAction
public static  list<SectorGroupNameLen> getSectorGroupNameLenList()
{
  list<SectorGroupNameLen> lst = new list<SectorGroupNameLen>();
  SectorGroupNameLen item;
  List<String> parts = new List<string>();

  Schema.DescribeFieldResult sectorField = Schema.sObjectType.Account.fields.Sector__c;
  Schema.PicklistEntry [] values = sectorField.getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   parts= (val.getValue()).split('-', 2);
   
   item =new SectorGroupNameLen(parts.get(0),parts.get(0),0);
   UpdateGroupNameLenList(lst,item);

   System.debug('getSectorGroupNameLenList'+':Added:'+parts.get(0)+':Left:'+parts.get(1));
  }
  System.debug('getSectorGroupNameLenList'+lst);   
  return lst;
}    

@RemoteAction
public static  List<GeoName> getGeoNameList()
{
  List<GeoName> lst = new List<GeoName>();
             
  Schema.DescribeFieldResult sectorField = Schema.sObjectType.Account.fields.Geographies__c;
  Schema.PicklistEntry [] values = sectorField.getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(new GeoName(val.getValue(), val.getLabel()));
  }
  System.debug('getGeoNameList'+lst);
  return lst;
}    

@RemoteAction
public static  List<DealStageName> getDealStageList()
{
  List<DealStageName> lst = new List<DealStageName>();
             
  Schema.DescribeFieldResult dealStageField = Schema.sObjectType.Deal__c.fields.Stage__c;
  Schema.PicklistEntry [] values = dealStageField .getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(new DealStageName(val.getValue(), val.getLabel()));
  }
  System.debug('getDealStageList'+lst);
  return lst;
}    

@RemoteAction
public static  List<DealStageName> getLifeCycleDealStageList()
{
  List<DealStageName> lst = new List<DealStageName>();
             
  Schema.DescribeFieldResult dealStageField = Schema.sObjectType.Deal__c.fields.Stage_of_Life_Cycle__c;
  Schema.PicklistEntry [] values = dealStageField .getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(new DealStageName(val.getValue(), val.getLabel()));
  }
  System.debug('getLifeCycleDealStageList'+lst);
  return lst;
} 

@RemoteAction
public static  List<CompTypeName> getCompTypeList()
{
  List<CompTypeName> lst = new List<CompTypeName>();
             
  Schema.DescribeFieldResult compTypeField = Schema.sObjectType.Account.fields.Public_Private__c;
  Schema.PicklistEntry [] values = compTypeField .getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(new CompTypeName(val.getValue(), val.getLabel()));
  }
  System.debug('getCompTypeList'+lst);
  return lst;
}    
    


@RemoteAction
public static List<Companyname> getCompanyList(String searchterm) {

        String query = 
            'Select Id,Sector__c,Geographies__c, Name From Account ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\'';
        System.debug('getCompanyList:'+query+restriction );
        List<Account> acc = Database.query( query + restriction +' ORDER BY Name' );
    
        Companyname c;
        List<Companyname> lst = new List<Companyname>();
        
        //Add Predefined Name
            c = new Companyname(
                'Create New Company', 
                '','',''
            );
            lst.add(c);
                    
        for ( Account account : acc ) {
            c = new Companyname(
                account.Name, 
                account.Id,
                account.Sector__c,
                account.Geographies__c
            );
            lst.add(c);
        }    
      
        if (lst.size()>0)
                return lst ;
        else
                return null;
    
    
    }
    @RemoteAction
public static List<String> getWordsToIgnore() {
        String query = 
                'Select Value__c From WP_Lookup__c Where Type__c=\'DealQuickCreateProjectNameValidationStringsToIgnore\'';
        List<WP_Lookup__c> ret = Database.query(query);
        List<String> strWords = new List<String>();
        for ( WP_Lookup__c objState : ret ) {
            strWords.add(objState.Value__c);

        }
        return strWords;
}
    
@RemoteAction
public static set<Statename > getStateList(String searchterm) {
        String query = 
            'Select Id, Type__c,Value__c From WP_Lookup__c ';

        String restriction = String.isBlank(searchterm) ? '' : ' WHERE Value__c LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\''+' AND Type__c = \'State\'';
        
         System.debug('getStateList.......'+'....searchterm:'+searchterm+'.....query:'+query+'......restriction:'+restriction );
         
        List<WP_Lookup__c> listWPQuickCreateLookup = Database.query( query + restriction +' ORDER BY Value__c' );
     
        Statename c;
        set<Statename > lst = new set<Statename >();
        for ( WP_Lookup__c objState : listWPQuickCreateLookup ) {
            c = new Statename (
                objState .Value__c, 
                objState .Id
            );
            lst.add(c);

        }
        return lst ;
}

@RemoteAction
public static set<Countryname > getCountryList(String searchterm) {

        String query = 
            'Select Id, Type__c,Value__c From WP_Lookup__c ';

        String restriction = String.isBlank(searchterm) ? '' : ' WHERE Value__c LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\''+' AND Type__c = \'Country\'';
        
        List<WP_Lookup__c> listCountry = Database.query( query + restriction +' ORDER BY Value__c' );
    
        Countryname c;
        set<Countryname > lst = new set<Countryname >();
        for ( WP_Lookup__c objCountry : listCountry ) {
            c = new Countryname (
                objCountry .Value__c, 
                objCountry .Id
            );
            lst.add(c);
        }
        return lst ;
    }

@RemoteAction
public static List<Cityname > getCityList(String searchterm) {

         String query = 
            'Select Id, Type__c,Value__c From WP_Lookup__c ';

        String restriction = String.isBlank(searchterm) ? '' : ' WHERE Value__c LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\''+' AND Type__c = \'City\'';
     
        
        List<WP_Lookup__c> listCity = Database.query( query + restriction +' ORDER BY Value__c' );
    
        Cityname c;
        List<Cityname > lst = new List<Cityname >();
        for ( WP_Lookup__c objCity : listCity ) {
            c = new Cityname (
                objCity .Value__c, 
                objCity .Id
            );
            lst.add(c);
        }
        return lst ;
}

    public static Account getAccountForGivenId(String acc_id)
    {
      List<Account>  acclist;
     
      acclist=[Select id, Name From Account where id=:acc_id limit 1];
    
    if(acclist.size() == 0)
    {
       System.debug('------------Compny doesnt not exist in the system');
       return null;     

    }
    else
    {       
       System.debug('------------Account exists in the system');
       return acclist.get(0); 
    }           
      
    }
public static boolean doesCityExist(String stgCityName)
{
      boolean result;
      List<WP_Lookup__c>  citylist=[Select Id,Type__c,Value__c From WP_Lookup__c where Type__c=:'City' AND  Value__c=:stgCityName limit 1];
    
    if(citylist.size() == 0)
    {
       System.debug('------------City does not in the system');
       result=false;     

    }
    else
    {       
       System.debug('------------City exists in the system');
       result= true;   
    }                
      return result;
}

public static boolean doesStateExist(String stgStateName)
{
      boolean result;
      List<WP_Lookup__c>  statelist=[Select Id,Type__c,Value__c From WP_Lookup__c where Type__c=:'State' AND  Value__c=:stgStateName limit 1];
    
    if(statelist.size() == 0)
    {
       System.debug('------------State does not in the system');
       result=false;     

    }
    else
    {       
       System.debug('------------State exists in the system');
       result= true;   
    }                
      return result;
}    

public static boolean doesCountryExist(String stgCountryName)
{
      boolean result;
      List<WP_Lookup__c>  countrylist=[Select Id,Type__c,Value__c From WP_Lookup__c where Type__c=:'Country' AND  Value__c=:stgCountryName limit 1];
    
    if(countrylist.size() == 0)
    {
       System.debug('------------Country does not in the system');
       result=false;     

    }
    else
    {       
       System.debug('------------Country exists in the system');
       result= true;   
    }           
      
      return result;
    }   
        
@RemoteAction   
public static Result_status saveAccount(String stgAccountName,String stgStateName,String stgCountryName,
    String stgCityName,String stgCompType,String stgSectorName,String stgGeoName,String compdesc,
    String stgdealName,String wp_invest_amount,String stgProjName,String dealdesc,
    String categories,Date Date_rcvd,String optionstage, String optionenergy , String lifeCycleOptionstage,
    String Key_date_Nxt,String[] deal_team_contact_id_list,
    String wpgroup2,String sectorname2,String geographyname2,
    String[] fund_names_id_list,String wp_invest_amount_mul,String acc_id,
    boolean disableDupeblocker
    ) {
   Result_status result=new Result_status('','');
   Account objAccount;
   ID AccountDefaultRecordTypeID = null;
    System.debug('------------saveAccount='+stgAccountName);
    
    if(disableDupeblocker) 
    {
        CRMfusionDBR101.DB_Api.preventMatching();    
    }
    
     if((stgCityName != '') && (doesCityExist(stgCityName)== false))
     {
       WP_Lookup__c objCity = new WP_Lookup__c(Type__c='City',Value__c=stgCityName);
       insert objCity ;     
     }
     
     if(doesStateExist(stgStateName)== false)
     {
       WP_Lookup__c objState = new WP_Lookup__c(Type__c='State',Value__c=stgStateName);
       insert objState ;     
     }    
     
     if(doesCountryExist(stgCountryName)== false)
     {
       WP_Lookup__c objCountry = new WP_Lookup__c(Type__c='Country',Value__c=stgCountryName);
       insert objCountry ;     
     }    
    
       if(stgSectorName != null){
       stgSectorName= stgSectorName.replace(',',';');       
       stgSectorName= stgSectorName.replace('[','');
       stgSectorName= stgSectorName.replace(']','');
       }
       
       if(stgGeoName!= null){
       stgGeoName= stgGeoName.replace(',',';');
       stgGeoName= stgGeoName.replace('[','');
       stgGeoName= stgGeoName.replace(']','');       
       }
       
        for(RecordType item:[Select Name, ID, SobjectType, DeveloperName  From RecordType where SobjectType in ('Account') and IsActive=true and DeveloperName in ('Operating_Company')])
        {
            if(item.SobjectType=='Account' && item.DeveloperName=='Operating_Company') AccountDefaultRecordTypeID = item.ID;
            system.debug('SaveAccount:ID is'+AccountDefaultRecordTypeID);
        }
               
     if(String.isBlank(acc_id) || String.isEmpty(acc_id))
     {
       result.label='true';  
       system.debug('Inserting account here are the replace strings'+stgSectorName+'......'+stgGeoName);
       
       objAccount = new Account(Name = stgAccountName,BillingCountry=stgCountryName,BillingState=stgStateName,BillingCity=stgCityName,       
       Public_Private__c=stgCompType,Sector__c=stgSectorName,Geographies__c=stgGeoName,Description=compdesc); 
       
       if(AccountDefaultRecordTypeID!=null) objAccount.RecordTypeId = AccountDefaultRecordTypeID;     
    
       insert objAccount ;
       result.id=objAccount.Id;              
     }
     else
     {
       result.label='false';
       objAccount = getAccountForGivenId(acc_id);
       if(objAccount==null)
       {         
         return null;
       }
       system.debug('Updating account here are the replace strings'+stgSectorName+'......'+stgGeoName);
       
       objAccount.Name =stgAccountName;
       objAccount.BillingCountry=stgCountryName;
       objAccount.BillingState=stgStateName;
       objAccount.BillingCity=stgCityName;
       objAccount.Public_Private__c=stgCompType;
       objAccount.Sector__c=stgSectorName;
       objAccount.Geographies__c=stgGeoName;
       objAccount.Description=compdesc;
       if(AccountDefaultRecordTypeID!=null) objAccount.RecordTypeId = AccountDefaultRecordTypeID;
            
       update objAccount ;
       result.id=objAccount.Id;       
     } 
     /*
     result = saveDeal(objAccount.Id,
      stgdealName,wp_invest_amount,stgProjName,dealdesc,
      categories,Date_rcvd,optionstage,lifeCycleOptionstage,Key_date_Nxt,deal_team_contact_id_list,
      wpgroup2,sectorname2,geographyname2,fund_names_id_list,wp_invest_amount_mul); */
  
      //turn dupeblocker back on
      CRMfusionDBR101.DB_Api.allowMatching();
  
     return result;
}

@RemoteAction   
public static Acc_Returned_Info getAccountInfo(String acc_id)
    {  
       Acc_Returned_Info acc_info = new Acc_Returned_Info();
       List<Account>  acclist=[Select id, Name,BillingCountry,BillingState,BillingCity,
             Public_Private__c,Sector__c,Geographies__c,Description From Account where id =:acc_id limit 1];
       Account acc;
       
       if(acclist.size() == 0)
       {
         System.debug('getAccountInfo------------Compny doesnt not exist in the system');
         acc_info.result='false';
       }
       else
       {       
         System.debug('getAccountInfo------------Account exists in the system');
         acc_info.result='true';
         acc = acclist.get(0); 
        
         
        acc_info.stgAccountName=acc.name;
        acc_info.stgStateName=acc.BillingState;
        acc_info.stgCountryName=acc.BillingCountry;
        acc_info.stgCityName=acc.BillingCity;
        acc_info.stgCompType=acc.Public_Private__c;
        acc_info.stgSectorName=acc.Sector__c;
        acc_info.stgGeoName=acc.Geographies__c;
        acc_info.compdesc=acc.Description;
        acc_info.id=acc.id;       
         
        System.debug('getAccountInfo------------Accountinfo is'+acc.Sector__c+':'+acc_info.stgSectorName); 
         
       }         
    return acc_info;
}    

@RemoteAction   
public static Result_status saveDeal(String acc_id,
           String stgdealName,String wp_invest_amount,String stgProjName,String dealdesc,
           String categories,Date Date_rcvd,String optionstage, String optionenergy, String lifeCycleOptionstage,
           String Key_date_Nxt,String[] deal_team_contact_id_list,
           String wpgroup2,String sectorname2,String geographyname2,
           String[] fund_names_id_list,String wp_invest_amount_mul,
           boolean disableDupeBlocker
           ) {
     Result_status result=new Result_status('','');
System.debug('wwwwwwwww->deal_team_contact_id_list:' + deal_team_contact_id_list);

     Deal__c objDeal;
     String DealRecordID;
   
     if(disableDupeBlocker) 
     {
        CRMfusionDBR101.DB_Api.preventMatching();    
     } 
   
     if( acc_id== null)
     {
       result.label='false';  
       system.debug('Account doesn\'t exist and not saved in the deal');              
     }
     else
     {
       result.label='true';
       
       system.debug('Account exists and will be saved in the deal:'+acc_id); 
    
       Decimal tmp_ampount_mul=1;

         if(wp_invest_amount_mul.equalsIgnoreCase('k'))
         {
           tmp_ampount_mul=1000;//3
         }
         else if(wp_invest_amount_mul.equalsIgnoreCase('m'))
         {
           tmp_ampount_mul=1000000;//6
         }  
         else if(wp_invest_amount_mul.equalsIgnoreCase('b'))
         {
           tmp_ampount_mul=1000000000;//9
         }    

       system.debug('optionenergy:'+optionenergy);
         
       if(String.isNotBlank(wp_invest_amount) && String.isNotEmpty(wp_invest_amount))
       {
        wp_invest_amount= wp_invest_amount.replace(',','');
        Decimal tmp_ampount= Decimal.ValueOf(wp_invest_amount);
        tmp_ampount=tmp_ampount*tmp_ampount_mul;
        objDeal = new Deal__c(Company__c=acc_id,WP_Investment__c=tmp_ampount,Name=stgdealName,
                                   Project_Name__c=stgProjName,Description__c=dealdesc); 
       }
       else
       {
        objDeal = new Deal__c(Company__c=acc_id,Name=stgdealName,
                                   Project_Name__c=stgProjName,Description__c=dealdesc); 
       }
        DealRecordID = '';
        //Platform Deal
        for(RecordType item:[Select Name, ID From RecordType where SobjectType='Deal__c' and IsActive=true and DeveloperName='Platform_Deal' limit 1])
        {
            DealRecordID = item.ID;
        }
                                           
       if(DealRecordID!=null && DealRecordID!='')
       {
          objDeal.RecordTypeId = (ID)DealRecordID;
       }                                   



       system.debug('Line1:'+'wpgroup2:'+wpgroup2+'sectorname2:'+sectorname2+'geographyname2:'+geographyname2);

       if(wpgroup2!= null){
       wpgroup2= wpgroup2.replace(',',';');
       wpgroup2= wpgroup2.replace('[','');
       wpgroup2= wpgroup2.replace(']','');             
       }
              
       if(sectorname2!= null){
       sectorname2 = sectorname2.replace(',',';');
       sectorname2 = sectorname2 .replace('[','');
       sectorname2 = sectorname2 .replace(']','');             
       }
       
       if(geographyname2!= null){
       geographyname2= geographyname2.replace(',',';');  
       geographyname2= geographyname2.replace('[','');
       geographyname2= geographyname2.replace(']','');             
       }       

       system.debug('Line2:'+'wpgroup2:'+wpgroup2+'sectorname2:'+sectorname2+'geographyname2:'+geographyname2);              
       
       objDeal.Category__c = categories;
       objDeal.Date_Received__c = Date_rcvd;
       objDeal.Stage__c = optionstage;
                
       optionenergy= optionenergy.replace('[','');
       optionenergy= optionenergy.replace(']','');            
       objDeal.Is_Energy_Opportunity__c = 'No';//optionenergy;// -> doing this AFTER the deal is created so email notification is correct #9258
//       System.debug ('zzzzzzzzzzzzzzzzzzzzz isenergyopp text is:' + optionenergy);
         
       objDeal.Stage_of_Life_Cycle__c = lifeCycleOptionstage;
       objDeal.Key_Dates_Next_Steps__c = Key_date_Nxt;
       objDeal.WP_Groups_picklist__c = wpgroup2;
       objDeal.Sector__c = sectorname2;
       objDeal.Geographies__c = geographyname2;
       
       insert objDeal;

       set<ID> setContactIDs = new set<ID>();
       List<Deal_Team__c> lst2Insert = new List<Deal_Team__c>();
       for(String item:deal_team_contact_id_list)
       {
          setContactIDs.add((ID)item);
       }
       
       
                if(setContactIDs.size()>0)
                {
                    Map<ID, Contact> mapContactInfo = new Map<ID, Contact>([SELECT Id, ISSENIORTEAMMEMBER__c FROM Contact where ID in :setContactIDs limit 1000]);
                
                    for(ID item:setContactIDs)
                    {
                        if(mapContactInfo.containsKey(item))
                        {
                            Deal_Team__c dtItem = new Deal_Team__c();
                            dtItem.Deal__c = objDeal.Id;
                            dtItem.Employee__c = item;
//                          dtItem.Status__c = 'Active';

                            //if(mapContactInfo.get(item).ISSENIORTEAMMEMBER__c==1){dtItem.Role__c = 'Senior Team Member';}
                            /*else{*/dtItem.Role__c = 'Team Member';/*}*/
                            lst2Insert.add(dtItem);
                        }
                    }
                }

                
            if(lst2Insert.size()>0){ insert lst2Insert;}
            if(lst2Insert.size()==0)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quick Create must require at least 1 deal team member.'));
            }                
   
       result.id=objDeal.Id;
       
       objDeal.Is_Energy_Opportunity__c = optionenergy; // #9258 -- NOW we set is potential energy opp, so email notification goes to actual deal team 
       update objDeal;
       System.debug('zzzzzzzzzzzzzzzzzzzzzzzzz this is where we set the IsEnergyOpp');
      
            set<ID> setFundIDs = new set<ID>();
            List<Fund_Ownership__c> lstFO2Insert = new List<Fund_Ownership__c>();
            List<Fund_Ownership__c> lstFO2Delete = new List<Fund_Ownership__c>();
            
            
            for(Fund_Ownership__c item:[select Id from Fund_Ownership__c where Deal__c=:objDeal.Id and Portfolio_Company__c=:acc_id]){ lstFO2Delete.add(item);}
            
            if(lstFO2Delete.size()>0){ delete lstFO2Delete;}

            for(String item:fund_names_id_list)
            {
              setFundIDs.add((ID)item);
            }            
            
            if(setFundIDs.size()>0)
            {                
                for(ID item:setFundIDs)
                {
                    Fund_Ownership__c fundItem = new Fund_Ownership__c();
                    fundItem.Deal__c = objDeal.Id;
                    fundItem.Portfolio_Company__c =acc_id;
                    fundItem.Fund__c = item;      
                    lstFO2Insert.add(fundItem);
                }
            }
            if(lstFO2Insert.size()>0){ insert lstFO2Insert;}    
                         
     }   
  
  
    //turn dupeblocker back on
    CRMfusionDBR101.DB_Api.allowMatching();
    return result;
       
}    

@RemoteAction   
public static String getWPGroupInfo()
{   
       ID RelContactID;
       String temp='';
    
        RelContactID = null;
        for(User item:[Select u.Related_Contact_Id__c, u.Id From User u where u.id=:UserInfo.getUserId() limit 1])
        {
            if(item.Related_Contact_Id__c!=null && item.Related_Contact_Id__c!='') RelContactID = (ID)item.Related_Contact_Id__c;
        }
        
        if(RelContactID!=null)
        {
            for(Contact item:[Select c.WP_Group__c, c.Id From Contact c where c.Id=:RelContactID limit 1])
            {
                if(item.WP_Group__c!=null && item.WP_Group__c!='') temp  = item.WP_Group__c;
                System.debug('------------User exists in the system:'+temp);
            }
        }    
    
    return temp;
}
    
@RemoteAction
public static List<Person> getProfessionalsList(String searchterm) {

            
        String query = 
            'Select Id, AccountId, LastName, FirstName, Name, Title, Initials__c, WP_Group__c, Full_Name__c, ' +
            'Employee_Level__r.Name, Employee_Level__r.Rank__c,' +
            'ISINVESTMENTPRO__c, Status__c, RecordType.Name, User_ID__r.Id From Contact ' +
            'WHERE RecordType.Name = \'Employee\' AND Status__c = \'Active\' AND ISINVESTMENTPRO__c = 1 AND Initials__c!=\'\' AND Initials__c!=null AND Title!=\'\' AND Title!=null AND WP_Group__c!=\'\' AND WP_Group__c!=null'; 
    
        String restriction = String.isBlank(searchterm) ? '' : ' AND ( (LastName LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\') OR '+
                            '(FirstName LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\'))';
        system.debug('getProfessionalsList'+query + restriction);
        List<Contact> people = Database.query( query + restriction + ' ORDER BY LastName, FirstName' );
    
        Person p;
        List<Person> lst = new List<Person>();
        for ( Contact contact : people ) {
            p = new Person(
                contact.Full_Name__c, 
                contact.User_ID__r.Id, 
                contact.Id,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Name : null,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Rank__c: null,
                contact.WP_Group__c
            );
            p.initials = contact.Initials__c;
            system.debug(contact.Initials__c+':'+contact.Full_Name__c);
            lst.add(p);
        }
        return lst;

    }

@RemoteAction
public static List<Person> getCurrUserProfessionalInfo() {

      List<Contact>  people ;
     
      people =
       [Select Id, AccountId, LastName, FirstName, Name, Title, Initials__c, WP_Group__c, Full_Name__c,
            Employee_Level__r.Name, Employee_Level__r.Rank__c,
            ISINVESTMENTPRO__c, Status__c, RecordType.Name, User_ID__r.Id From Contact
            WHERE ( (RecordType.Name =:'Employee') AND (Status__c =:'Active') AND (ISINVESTMENTPRO__c =:1) AND (User_ID__r.Id=:UserInfo.getUserID()) AND (Title!='') AND (Title!=null) AND (WP_Group__c!='') AND (WP_Group__c!=null) ) limit 1];
            
        
        Person p;
        List<Person> lst = new List<Person>();
            


        if(people.size() == 0)
        {
           p = new Person(
                '', 
                '',  
                '', 
               '', 
                0,
                ''
            );
            p.initials = '';
            lst.add(p);
        }
        else
        {
        for ( Contact contact : people ) {
            p = new Person(
                contact.Full_Name__c, 
                contact.User_ID__r.Id, 
                contact.Id,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Name : null,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Rank__c: null,
                contact.WP_Group__c
            );
            p.initials = contact.Initials__c;
            system.debug(contact.Initials__c+':'+contact.Full_Name__c);
            lst.add(p);

        }
        }
        return lst;
}

    
@RemoteAction   
public  static void enterDeafultUSStates()
{
        if (bTesting) bsTestMethod();
      List<String> availablestates = new List<String>{'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 
                    'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 
                    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
                     'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 
                     'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'};
                     
      for ( String item: availablestates ) {
       if(doesStateExist(item)== false)
       {
         WP_Lookup__c objState = new  WP_Lookup__c(Type__c='State',Value__c=item);
         insert objState ;
       }         
      }
}  
  
@RemoteAction
public static List<FundInfo> getFundsList(String searchterm) {

        Set<String> predefined_fund_list = new Set<String>{'WPRE','WP X', 'WP XI', 'WPE'};
        String query = 'Select Id, Name From Fund__c'; 
    
        //String restriction = String.isBlank(searchterm) ? '' : ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\'';
        String restriction = ' WHERE Name IN :predefined_fund_list';
        
        List<Fund__c> fundList = Database.query( query + restriction + ' ORDER BY Name' );
    
        
        FundInfo f;
        List<FundInfo> lst = new List<FundInfo>();
        for ( Fund__c item : fundList ) {
            f = new FundInfo(
                item.Name, 
                item.Id,
                item.Name);
            system.debug('getFundsList'+Fund__c.Name);
            lst.add(f);
        }
        return lst;
}   

@RemoteAction
public static List<FundInfo> getDefaultFund(String searchterm) {

      List<Fund__c> fundList;
      
      fundList = [Select Id, Name From Fund__c   WHERE Name =:searchterm limit 1];

      FundInfo f;
      List<FundInfo> lst = new List<FundInfo>();
      
      
        if(fundList.size() == 0)
        {
           f = new FundInfo(
                '', 
                '',
                '');
            lst.add(f);
        }
        else
        {
        for ( Fund__c item : fundList ) {
            f = new FundInfo(
                item.Name, 
                item.Id,
                item.Name);
            system.debug('getDefaultFund'+item.Name);
            lst.add(f);
        }
        }
        return lst;
    }         
    
@RemoteAction   
public static String sortDealTeamList(String[] deal_team_contact_id_list) 
{
       String result;
    
       result='';    
      
       system.debug('sortDealTeamList Received contact list:'+deal_team_contact_id_list);   

       set<ID> setContactIDs = new set<ID>();

       for(String item:deal_team_contact_id_list)
       {
          setContactIDs.add((ID)item);
       }
             
                if(setContactIDs.size()>0)
                {
                    List<Contact> deal_staff = [
                        SELECT Id,      
                        Employee_Level__r.Rank__c,Employee_Level_Precedence_Sorter__c,Title,Initials__c
                        From Contact
                        WHERE Id in :setContactIDs
                        ORDER BY Employee_Level__r.Rank__c DESC,Employee_Level_Precedence_Sorter__c DESC,
                        Title DESC,Initials__c ASC];   
                                   
                
                    for(Contact item:deal_staff)
                    {
                            if(result == '')
                            {                              
                              result= item.Initials__c;
                              system.debug('sortDealTeamList:1:'+result);
                            }
                            else
                            {
                              result=result+'; ';
                              result=result+item.Initials__c;
                              system.debug('sortDealTeamList:2:'+result);
                            }

                    }
                }                
    system.debug('sortDealTeamList:3:'+result);
    return result;
       
}       

public static void UpdateDealNameInTheList(list<DealName> lst, DealName item)
{
  boolean exist=false;
  Integer pos=0;
  
  for(DealName val : lst){
   if(val.id.equals(item.id)){
     exist=true;
     break;
   }
  }
  
  if(exist == false)
  {
    lst.add(item);
  }
}


@RemoteAction   
public static List<DealName> getExistingDealList(List<string> ids) 
{
    List<DealName> deals = new List<DealName>();
    set<ID> setDealIDs = new set<ID>();
    String portfolioDealRecordID = '';
    //portfolio Deal
    for(RecordType item:[Select Name, ID From RecordType where SobjectType='Deal__c' and IsActive=true and DeveloperName='Portfolio_Company' limit 1])
    {
        portfolioDealRecordID = item.ID;
    }

    for(String item:ids)
    {
      setDealIDs.add((ID)item);
    }
    List<Deal__c> existingDeals = [
        SELECT Id, Name, WP_Groups__c, Stage__c, Sector__c, RecordTypeId, Dead_Deal_Reason__c
        FROM  Deal__c
        WHERE Id in :setDealIDs
        ORDER BY Name];
    
     for(Deal__c deal:existingDeals){
        DealName newDeal = new DealName();
        newDeal.id = deal.Id;
        newDeal.label = deal.Name; 
        newDeal.dealGroup = deal.WP_Groups__c;
        
        String deal_record_type='';
       
        if(deal.RecordTypeId == portfolioDealRecordID)
        {
            deal_record_type = 'Portfolio_Company';
            system.debug('getExistingDeals:record name'+deal_record_type);
        } 
         
        if((deal_record_type == 'Portfolio_Company')&& (deal.Stage__c != 'Deal Exited Portfolio'))
        {
          newDeal.dealStatus = 'In Portfolio';
        }
        else if(deal.Stage__c == 'Deal Exited Portfolio')
        {
          newDeal.dealStatus = 'Exited';
        }
        else if((deal_record_type != 'Portfolio_Company')&& (deal.Stage__c != 'Deal Exited Portfolio')&& (String.isBlank(deal.Dead_Deal_Reason__c)||String.isEmpty(deal.Dead_Deal_Reason__c)))
        {
          newDeal.dealStatus = 'In Review';
        }
        else if((String.isNotBlank(deal.Dead_Deal_Reason__c)) && (String.isNotEmpty(deal.Dead_Deal_Reason__c)))
        {
          newDeal.dealStatus = 'Dead';
        }
        
        if(String.isBlank(deal.WP_Groups__c)|| String.isEmpty(deal.WP_Groups__c))
        {
            newDeal.dealGroup = '';
        }
        
       deals.add(newDeal);
     }
            
            
    return deals;           
}


@RemoteAction   
public static List<DealName> getExistingDeals(String deal_name, String acc_id) 
{
  Set<String> predefined_list_not_searched = new Set<String>{'a', 'an', 'the', 'this', 'that', 'in', 'on', 'to', 'of'};
  if(String.isBlank(deal_name)|| String.isEmpty(deal_name))
  {
    return null;
  }
  String portfolioDealRecordID;
  
        portfolioDealRecordID = '';
        //portfolio Deal
        for(RecordType item:[Select Name, ID From RecordType where SobjectType='Deal__c' and IsActive=true and DeveloperName='Portfolio_Company' limit 1])
        {
            portfolioDealRecordID = item.ID;
        }
        
  List<DealName> deal_list = new List<DealName>(); 
  deal_list.clear();

  Set<String> token_list=new Set<String>();
  String[] temp_array;
  
  temp_array  = deal_name.split(' ',0);
  for(String item:temp_array){
    if(predefined_list_not_searched.contains(item.toLowerCase())== false) {
      token_list.add(item.toLowerCase());
    }   
  }

  for(String item:token_list){

   if(String.isBlank(item) || String.isBlank(item))
   {
     continue;
   }
   String query = 'Select Id, Name, RecordTypeId, Dead_Deal_Reason__c, Stage__c,WP_Groups__c From Deal__c';
   String restriction;
   
   if(acc_id=='')
   {
     restriction = String.isBlank(item) ? '' : ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(item) + '%\'';     
   }
   else
   {
     restriction=String.isBlank(item) ? '' : ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(item) + '%\') AND (Company__c=:acc_id)';
   }
   
   List<Deal__c> temp_deal_list = Database.query( query + restriction + ' ORDER BY Name LIMIT 100' );
   
   if(temp_deal_list.size() > 0)
   {
       for(Deal__c deal_item:temp_deal_list){
       String deal_status = '';
       String deal_record_type='';
       
        if(deal_item.RecordTypeId == portfolioDealRecordID)
        {
            deal_record_type = 'Portfolio_Company';
            system.debug('getExistingDeals:record name'+deal_record_type);
        }       

        if((deal_record_type == 'Portfolio_Company')&& (deal_item.Stage__c != 'Deal Exited Portfolio'))
        {
          deal_status = 'In Portfolio';
        }
        else if(deal_item.Stage__c == 'Deal Exited Portfolio')
        {
          deal_status = 'Exited';
        }
        else if((deal_record_type != 'Portfolio_Company')&& (deal_item.Stage__c != 'Deal Exited Portfolio')&& (String.isBlank(deal_item.Dead_Deal_Reason__c)||String.isEmpty(deal_item.Dead_Deal_Reason__c)))
        {
          deal_status = 'In Review';
        }
        else if((String.isNotBlank(deal_item.Dead_Deal_Reason__c)) && (String.isNotEmpty(deal_item.Dead_Deal_Reason__c)))
        {
          deal_status = 'Dead';
        }
        
        DealName deal_info_item;
        
        if(String.isBlank(deal_item.WP_Groups__c)|| String.isEmpty(deal_item.WP_Groups__c))
        {
          deal_info_item = new DealName(deal_item.Name,deal_item.Id,'',deal_status);
        }
        else
        {          
          deal_info_item = new DealName(deal_item.Name,deal_item.Id,deal_item.WP_Groups__c,deal_status);
        }
        UpdateDealNameInTheList(deal_list,deal_info_item);
       }
   
   }
  }
  system.debug('getExistingDeals'+deal_list);
  return deal_list;
}    
    public static string testVal='';
    public static void bsTestMethod()
    {
    bsTestMethod2();
            testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
    
    }
public static void bsTestMethod2()
{
testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        
          testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        
          testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        
          testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
    
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
}
}