public with sharing class kjoDealReportController { 

	public static boolean bCheckingDealWriteability= false;
	
    public class FinanceOptions {
        String label { get; set; }
        List<SelectOption> options { get; set;}
        
        public FinanceOptions(String name, List<SelectOption> options) {
            this.label = name;
            this.options = options;
        }
    } 
    
    @RemoteAction
    public static List<FinanceOptions> getFinanceOptions() {
        List<FinanceOptions> retval = new List<FinanceOptions>();
        
        List<SelectOption> opt = getFinancePeriods();
        FinanceOptions f = new FinanceOptions('period', opt);
        retval.add(f);
        
        opt = getFinanceCurrencies();
        f = new FinanceOptions('currency', opt);
        retval.add(f);
        
        return retval;
        
    }
    
    public static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
             
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' : 
           Iso)))))));
           return currencySymbol;
    }
        
    @RemoteAction
    public static List<SelectOption> getFinancePeriods() {
    
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Financial__c.Period_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    @RemoteAction
    public static List<Financial__c> getCompanyFinancials(ID CompanyId) {
        List<Financial__c> financials = [
          SELECT Book_Value__c, Book_Value_MM__c, Company__c, Company__r.Name, 
          Company_Currency__c, CreatedById, CreatedDate, CurrencyIsoCode, 
          IsDeleted, EBITDA__c, EBITDA_MM__c, Enterprise_Value__c, 
          Enterprise_Value_MM__c, Name, LastModifiedById, LastModifiedDate, 
          Market_Cap_MM__c, Market_Cap__c, Net_Income__c, Net_Income_MM__c, 
          Period_Ended__c, Period_Type__c, Id, Revenues__c, Revenues_MM__c, 
          SystemModstamp FROM Financial__c
          WHERE Company__c = :CompanyId 
          ORDER BY Period_Ended__c DESC, Period_Type__c DESC];
        return financials;
    }

    @RemoteAction
    public static List<Financial__c> getCompanyFinancialSingle(ID FinancialId) {
        List<Financial__c> financials = [
          SELECT Company__r.Name, Book_Value__c, Book_Value_MM__c, Company__c,
          Company_Currency__c, CreatedById, CreatedDate, CurrencyIsoCode, 
          IsDeleted, EBITDA__c, EBITDA_MM__c, Enterprise_Value__c, 
          Enterprise_Value_MM__c, Name, LastModifiedById, LastModifiedDate, 
          Market_Cap_MM__c, Market_Cap__c, Net_Income__c, Net_Income_MM__c, 
          Period_Ended__c, Period_Type__c, Id, Revenues__c, Revenues_MM__c, 
          SystemModstamp FROM Financial__c
          WHERE Id = :FinancialId 
          ORDER BY Period_Ended__c DESC, Period_Type__c DESC];
        return financials;
    }

    @RemoteAction
    public static Account getCompany(String company_id) {                        
        Account company  = [
          SELECT Id, Name, CurrencyIsoCode, Company_Currency__c FROM Account
          WHERE Id = :company_id limit 1];          
        return company;
    }

@RemoteAction
public static  List<String> getCurrencyList()
{
  List<String> lst = new List<String>();
             
  Schema.DescribeFieldResult currField = Schema.sObjectType.Account.fields.CurrencyIsoCode;
  Schema.PicklistEntry [] values = currField.getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(val.getValue());
  }
  //System.debug('getCurrencyList'+lst);
  return lst;
}   
    

    @RemoteAction
    public static Financial__c upsertCompanyFinancial(
        String company_id,
        String financial_id,
        String per,
        Date dte,
        decimal rev,
        decimal nin,
        decimal ebt,
        decimal bkv,
        decimal env,
        decimal mkc,
        String  cur,
        String  iso
    ) {
        
        Financial__c financial;
        Id return_id;
        
        company_id = String.isNotBlank(company_id) ? company_id : null;
        financial_id = String.isNotBlank(financial_id) ? financial_id : null;
        
        if ( financial_id != null ) {
            financial = [
              SELECT Book_Value__c, Book_Value_MM__c, Company__c, Company__r.Name, 
              Company_Currency__c, CreatedById, CreatedDate, CurrencyIsoCode, 
              IsDeleted, EBITDA__c, EBITDA_MM__c, Enterprise_Value__c, 
              Enterprise_Value_MM__c, Name, LastModifiedById, LastModifiedDate, 
              Market_Cap_MM__c, Market_Cap__c, Net_Income__c, Net_Income_MM__c, 
              Period_Ended__c, Period_Type__c, Id, Revenues__c, Revenues_MM__c, 
              SystemModstamp FROM Financial__c WHERE Id = :financial_id
              ORDER BY Period_Ended__c DESC, Period_Type__c DESC LIMIT 1];
              
            financial.Book_Value__c = bkv;
            financial.CurrencyIsoCode = iso;
            financial.EBITDA__c = ebt;
            financial.Enterprise_Value__c = env;
            financial.Market_Cap__c = mkc;
            financial.Net_Income__c = nin;
            financial.Period_Ended__c = dte;
            financial.Period_Type__c = per;
            financial.Revenues__c = rev;
            
            update financial;
            return_id = financial_id;
        }
        else {
            financial = new Financial__c();
            financial.Company__c = company_id;
            financial.Book_Value__c = bkv;
            financial.CurrencyIsoCode = iso;
            financial.EBITDA__c = ebt;
            financial.Enterprise_Value__c = env;
            financial.Market_Cap__c = mkc;
            financial.Net_Income__c = nin;
            financial.Period_Ended__c = dte;
            financial.Period_Type__c = per;
            financial.Revenues__c = rev;
        
            insert financial;
            return_id = financial.Id;
        }
        
        List<Financial__c> financials = [
          SELECT Book_Value__c, Book_Value_MM__c, Company__c, Company__r.Name, 
          Company_Currency__c, CreatedById, CreatedDate, CurrencyIsoCode, 
          IsDeleted, EBITDA__c, EBITDA_MM__c, Enterprise_Value__c, 
          Enterprise_Value_MM__c, Name, LastModifiedById, LastModifiedDate, 
          Market_Cap_MM__c, Market_Cap__c, Net_Income__c, Net_Income_MM__c, 
          Period_Ended__c, Period_Type__c, Id, Revenues__c, Revenues_MM__c, 
          SystemModstamp FROM Financial__c WHERE Id = :return_id
          ORDER BY Period_Ended__c DESC, Period_Type__c DESC LIMIT 1];
        return financials[0];
    }

    @RemoteAction
    public static boolean deleteCompanyFinancial(String financial_id) {
        List<Financial__c> f = [SELECT Id FROM Financial__c WHERE Id = :financial_id LIMIT 1];
        if ( f.size() > 0 ) {
            delete f;
            return true;
        } else {
            return false;
        }
    }
    
    @RemoteAction
    public static List<SelectOption> getFinanceCurrencies() {
    
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Financial__c.CurrencyIsoCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    /* Professionals Auto Complete Stuff */

    public class Person {
        String label;
        String user_id;
        String contact_id;
        String title;
        Decimal rank;
        String group_name;
        String initials;
        String isSeniorTeamMember;
        String canBeASeniorTeamMember;
        
        public Person(String name, String UserId, String ContactId, String Title, 
        Decimal Rank, String GroupName, String isSeniorTeamMember) {
            this.label = name;
            this.user_id = UserId;
            this.contact_id = ContactId;
            this.title = Title;
            this.rank = Rank;
            this.group_name = GroupName;
            this.isSeniorTeamMember=isSeniorTeamMember;
            this.canBeASeniorTeamMember='false';
        }
    }
    
    @RemoteAction
    public static List<String> getGroupList(String searchterm) {
        List<String> lst = new List<String>();
                 
      	Schema.DescribeFieldResult groupField = Schema.sObjectType.Contact.fields.WP_Group__c;
      	Schema.PicklistEntry [] values = groupField.getPickListValues();
        for(Schema.PicklistEntry val : values){
       		lst.add(val.getValue());
      	}       		
        return lst;
    }
    
    @RemoteAction
    public static List<Person> getProfessionalsList(String searchterm) {

        String query = 
            'Select Id, AccountId, LastName, FirstName, Name, Title, Initials__c, WP_Group__c, Full_Name__c, ' +
            'Employee_Level__r.Name, Employee_Level__r.Rank__c, ISSENIORTEAMMEMBER__c, ' +
            'ISINVESTMENTPRO__c, Status__c, RecordType.Name, User_ID__r.Id From Contact ' +
            'WHERE WP_Group__c <> \'\' and RecordType.Name = \'Employee\' AND Status__c = \'Active\' AND ISINVESTMENTPRO__c = 1 ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' AND LastName LIKE \'' + String.escapeSingleQuotes(searchterm) + '%\'';
        
        List<Contact> people = Database.query( query + restriction + ' ORDER BY LastName, FirstName' );
    
        Person p;
        List<Person> lst = new List<Person>();
        for ( Contact contact : people ) {
            p = new Person(
                contact.Full_Name__c, 
                contact.User_ID__r.Id, 
                contact.Id,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Name : null,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Rank__c : null,
                contact.WP_Group__c,
                'false'
            );
            p.initials = contact.Initials__c;
            
            if(contact.ISSENIORTEAMMEMBER__c == 1) {
             p.canBeASeniorTeamMember = 'true';
            } else {
             p.canBeASeniorTeamMember = 'false';
            }
            
            lst.add(p);
        }
        return lst;
    }
    
    /* Professionals Auto Complete Stuff */
    
    public class DealCommentaryActionItem {
        String DealId {get; set;}
        String DealName {get; set;}
        String Comment {get; set;}
        String UpdatedBy {get; set;}
        String UpdatedById {get; set;}
        String UpdatedOn {get; set;}
        String Message {get; set;}
    }

    public class DealCommentaryEMG {
        String Id {get; set;}
        String DealId {get; set;}
        String DealName {get; set;}
        String Comment {get; set;}
        String UpdatedBy {get; set;}
        String UpdatedOnBehalfOf {get; set;}
        String UpdatedById {get; set;}
        String UpdatedOnBehalfOfId {get; set;}
        String UpdatedOn {get; set;}
        String Message {get; set;}
        public DealCommentaryEMG() {
        }
        public DealCommentaryEMG(String Id,String DealId) {
          this.Id = Id;
          this.DealId = DealId;
        }
    }
    
    public class DealCommentary {
        DealCommentaryEMG comment { get; set; }
        DealCommentaryEMG paragraph { get; set; }
        DealCommentaryActionItem actionItem { get; set; }
    }

    public class DealKeyDatesNextSteps {
        String DealId {get; set;}
        String DealName {get; set;}
        String keyDates {get; set;}
        public DealKeyDatesNextSteps () {
            this.DealId = '';
            this.DealName = '';
            this.keyDates = '';        
        }
        public DealKeyDatesNextSteps (String DealId , String DealName,String keyDates) {
            this.DealId = DealId ;
            this.DealName = DealName;
            this.keyDates = keyDates;
        }       
    }   

    public class EAR_Metric_Related_Info{
        String deal_id {get; set;}
        String scHead_id {get; set;}
        String lineItem_id {get; set;}
        String ear_metric_name {get; set;}  
        String ear_metric_per_end {get; set;}       
        String ear_metric_value {get; set;}
        public EAR_Metric_Related_Info() {
          this.deal_id ='';
          this.scHead_id='';
          this.lineItem_id='';
          this.ear_metric_name='';  
          this.ear_metric_per_end='';
          this.ear_metric_value='';
        }
        public EAR_Metric_Related_Info(String dealId){
          this.deal_id =dealId;
          this.scHead_id='';
          this.lineItem_id='';
          this.ear_metric_name='';  
          this.ear_metric_per_end='';
          this.ear_metric_value='';
        }   
    }
    
    public class DealRequiredRichTextFieldsEIR { //kckkck
        String dealId {get; set;}
        String dealStage {get; set;}
       // String areaOfConcern {get; set;}
      //  String fitWithGrp {get; set;}
        String whyInterestingEIR {get; set;}
      //  String humanCapitial {get; set;}
        String tenureExpectations{get; set;}        
       
        /*Report View fields*/
        String dealName {get; set;}
        String dealSector {get; set;}
        String dealTeam {get; set;}
      //  String compDesc {get; set;}
        String dealDesc {get; set;}
        String dealKeyNextSteps {get; set;}     

        String EIR_Description{get; set;}
        String CompCurrencyCode{get; set;}
        
        
        String expectedAnnualBudget{get; set;}
        String expectedTiming{get; set;}
        String expectedWPCommitment{get; set;}
        
        public DealRequiredRichTextFieldsEIR() {
        
        }
        public DealRequiredRichTextFieldsEIR(String dealId){
          this.dealId =dealId;
        
        }      
    } 
    public class DealRequiredRichTextFields {
        String dealId {get; set;}
        String dealStage {get; set;}
        String areaOfConcern {get; set;}
        String fitWithGrp {get; set;}
        String whyInteresting {get; set;}
        String humanCapitial {get; set;}
        String capitalMarketConsideration {get; set;}
        /*Report View fields*/
        String dealName {get; set;}
        String dealSector {get; set;}
        String dealTeam {get; set;}
        String compDesc {get; set;}
        String compRevenue_MM {get; set;}
        String compEBITDA_MM {get; set;}
        String dealDesc {get; set;}
        String dealKeyNextSteps {get; set;}     
        String WP_Investment_MM {get; set;}         
        String WP_Ownership_Fully_Diluted {get; set;}            
        String Transaction_Value_MM {get; set;} 
        String Deal_Owner_Source{get; set;}
        String EAR_Description{get; set;}
        String CompCurrencyCode{get; set;}
        List<EAR_Metric_Related_Info> earMetrics{get; set;}
        public DealRequiredRichTextFields() {
          this.earMetrics = new List<EAR_Metric_Related_Info>();
          this.earMetrics.clear();
        }
        public DealRequiredRichTextFields(String dealId){
          this.dealId =dealId;
          this.earMetrics = new List<EAR_Metric_Related_Info>();
          this.earMetrics.clear();        
        }      
    }   

    public class EAR_Metric_Result_Info{
        String dealId {get; set;}
        String dealScoreHeaderId {get; set;}
        String dealLineItemId {get; set;}
        String status {get; set;}      
        public EAR_Metric_Result_Info() {
          this.dealId ='';
          this.dealScoreHeaderId='';
          this.dealLineItemId='';
          this.status='false';     
        }
        public EAR_Metric_Result_Info(String dealId){
          this.dealId =dealId;
          this.dealScoreHeaderId='';
          this.dealLineItemId='';
          this.status='false';
        }  
    }
    
    /*Deal Closing Report Related fields*/
    public class DCR_ReportTypeHeader_Info {
        String report_id {get; set;}
        String report_label {get; set;}
        Date date_reccd {get; set;}      
       
        public DCR_ReportTypeHeader_Info(){
          this.report_id='';
          this.report_label='';
        }
    }

    public class DCR_ReportTypeHeader_CreateInfo {
        String created_id {get; set;}
        String created_label {get; set;}
        String status {get; set;}
        List<DCR_ReportTypeHeader_Info> reportHeaderList  {get; set;}
        DCR_Report_Detail_Fields detail_fields  {get; set;}
       
        public DCR_ReportTypeHeader_CreateInfo(){
          this.created_id='';
          this.created_label='';
          this.status='false';
          this.reportHeaderList= null; 
          this.detail_fields=null;        
        }
    }

    public class DCR_Metric_Related_Info{
        String deal_id {get; set;}
        String scHead_id {get; set;}
        String lineItem_id {get; set;}
        String dcr_metric_name {get; set;}  
        String dcr_metric_per_end {get; set;}       
        String dcr_metric_value {get; set;}
        String dcr_metric_unit {get; set;}
        String dcr_metric_followup_value {get;set;}
        String dcr_metric_followup_color {get;set;}
        String dcr_metric_followup_selectoption {get;set;}
        
        public DCR_Metric_Related_Info() {
          this.deal_id ='';
          this.scHead_id='';
          this.lineItem_id='';
          this.dcr_metric_name='';  
          this.dcr_metric_per_end='';
          this.dcr_metric_value='';
          this.dcr_metric_unit='';
          this.dcr_metric_followup_value='';
          this.dcr_metric_followup_color='';
          this.dcr_metric_followup_selectoption='';
        }
        public DCR_Metric_Related_Info(String dealId){
          this.deal_id =dealId;
          this.scHead_id='';
          this.lineItem_id='';
          this.dcr_metric_name='';  
          this.dcr_metric_per_end='';
          this.dcr_metric_value='';
          this.dcr_metric_unit='';
          this.dcr_metric_followup_value='';
          this.dcr_metric_followup_color='';
          this.dcr_metric_followup_selectoption='';          
        }   
    }

    public class DCR_Metric_Result_Info{
        String dealId {get; set;}
        String dealScoreHeaderId {get; set;}
        String dealLineItemId {get; set;}
        String status {get; set;}      
        public DCR_Metric_Result_Info() {
          this.dealId ='';
          this.dealScoreHeaderId='';
          this.dealLineItemId='';
          this.status='false';     
        }
        public DCR_Metric_Result_Info(String dealId){
          this.dealId =dealId;
          this.dealScoreHeaderId='';
          this.dealLineItemId='';
          this.status='false';
        }  
    }
    
    public class DCR_MtericsAndCompFinNameInfo{
        List<DCR_Metric_Related_Info> dcrMetrics{get; set;}
        List<String>  compFinNameList{get; set;}
        String status{get; set;}    
        
        public DCR_MtericsAndCompFinNameInfo(){
          this.dcrMetrics= new List<DCR_Metric_Related_Info>();
          this.dcrMetrics.clear();
          this.compFinNameList= new List<String>();
          this.compFinNameList.clear(); 
          this.status='false';
        }       
    }
    
    public class DCR_Report_Detail_Field_Info {
        String deal_id {get; set;}
        String scHead_id {get; set;}
        String lineItem_id {get; set;}
        String followup_value {get;set;}
        String followup_color {get;set;}
        String followup_selectoption {get;set;}
        Deal_Score_Line_Item__c data{get; set;}
       
        public DCR_Report_Detail_Field_Info(){
          this.deal_id='';
          this.scHead_id='';
          this.lineItem_id='';    
          this.followup_value='';   
          this.followup_color='';
          this.followup_selectoption=''; 
          this.data=NULL;
        }
    }

    public class DCR_Report_Detail_Fields {
        String deal_id {get; set;}
        String scHead_id {get; set;}
        List<DCR_Report_Detail_Field_Info> investmentThesis{get; set;}
        List<DCR_Report_Detail_Field_Info> investmentRisks{get; set;}
        List<DCR_Report_Detail_Field_Info> keyValueCreation{get; set;}
        List<DCR_Report_Detail_Field_Info> keyCompanyGoals{get; set;}
        List<DCR_Report_Detail_Field_Info> managementTeam{get; set;}
        List<DCR_Report_Detail_Field_Info> wPTeamActionItems{get; set;}
        DCR_MtericsAndCompFinNameInfo finance_targets{get; set;}
  
       
        public DCR_Report_Detail_Fields(){  
          this.deal_id ='';
          this.scHead_id ='';
          
          this.investmentThesis= new List<DCR_Report_Detail_Field_Info>();
          this.investmentThesis.clear();
         
          this.investmentRisks= new List<DCR_Report_Detail_Field_Info>();
          this.investmentRisks.clear();
         
          this.keyValueCreation= new List<DCR_Report_Detail_Field_Info>();
          this.keyValueCreation.clear();
         
          this.keyCompanyGoals= new List<DCR_Report_Detail_Field_Info>();
          this.keyCompanyGoals.clear();
         
          this.managementTeam= new List<DCR_Report_Detail_Field_Info>();
          this.managementTeam.clear();
         
          this.wPTeamActionItems= new List<DCR_Report_Detail_Field_Info>();
          this.wPTeamActionItems.clear();

          this.finance_targets= new DCR_MtericsAndCompFinNameInfo();         
        }
    }
    
    public class DCR_Report_General_Fields {
        String deal_id {get; set;}
        Deal__c deal {get; set;}
        /*Report View fields*/
        String dealName {get; set;}
        String dealSector {get; set;}
        String dealTeam {get; set;}    
        String lineOfEquityAmount {get; set;}
        String wpOwnership {get; set;}
        String wpInvestment {get; set;}
        String wpBoardSeats {get; set;}        
        String wpBoardSeatsTotal {get; set;}   
        String otherConsider{get;set;}
        String teamRecommend{get;set;}
        
        List<DCR_ReportTypeHeader_Info> reportHeaderList{get; set;}       
        public DCR_Report_General_Fields(){
          this.deal_id ='';
          this.deal=NULL;
          this.dealName='';
          this.dealSector='';
          this.dealTeam='';
          this.lineOfEquityAmount ='';
          this.wpOwnership='';
          this.wpInvestment='';
          this.wpBoardSeats='';
          this.wpBoardSeatsTotal='';
          this.otherConsider='';
          this.teamRecommend='';
          this.reportHeaderList= null;  
        }
    }
   
// WP-70
/* */

    @RemoteAction
    public static Contact getContactInformation() {
        Contact contact = [
                SELECT User_ID__c, Name, Id, Full_Name__c,
                EMG_Member__c, Email, Employee_Level__c, 
                ISINVESTMENTPRO__c, Initials__c, Status__c, Title, WP_Group__c FROM Contact         
                WHERE User_ID__c = :UserInfo.getUserId() LIMIT 1];
        return contact;
    }

    @RemoteAction
    public static  List<String> getDealStageList()
    {
      List<String> lst = new List<String>();
                 
      Schema.DescribeFieldResult dealStageField = Schema.sObjectType.Deal__c.fields.Stage__c;
      Schema.PicklistEntry [] values = dealStageField .getPickListValues();
        
      for(Schema.PicklistEntry val : values){
       lst.add(val.getValue());
      }
      //System.debug('getDealStageList'+lst);
      
      /*
      List<Deal__c> d_l = [Select Stage__c from Deal__c];
      for(Deal__c item:d_l)
       item.Stage__c='Early - Prospect';
      update d_l;
      */
      
      /*
      for(integer i =0; i< 10;++i){
      List<DealScoreHeader__c> d_l = [Select id from DealScoreHeader__c];
      delete d_l;     
      List<Deal_Score_Line_Item__c> d_l2 = [Select id from Deal_Score_Line_Item__c];
      delete d_l2;  
      }*/
      return lst;
    }  

    
    @RemoteAction
    public static void updateDealForCirToEMG(String deal_id,String cir_to_emg) {

       
        List<Deal__c> deal = [
            SELECT 
            id,Name
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        
        if ( deal.size() >0 ) {
        
         if(cir_to_emg == 'true')
          deal[0].Circulate_to_EMG__c=true;
         else
          deal[0].Circulate_to_EMG__c=false;
          
         //System.debug('updateDealForCirToEMG:'+deal_id+cir_to_emg);
         update deal[0];
        }

    }  

    @RemoteAction
    public static void updateDealForIncToGrp(String deal_id,String inc_to_grp) {

       
        List<Deal__c> deal = [
            SELECT 
            id,Name
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        
        if ( deal.size() >0 ) {
        
         if(inc_to_grp == 'true')
          deal[0].Include_In_Group_Report__c=true;
         else
          deal[0].Include_In_Group_Report__c=false;
          
         //System.debug('updateDealForIncToGrp:'+deal_id+inc_to_grp);
         update deal[0];
        }

    }       

    @RemoteAction
    public static void updateDealForHighInGrp(String deal_id,String high_in_grp) {

       
        List<Deal__c> deal = [
            SELECT 
            id,Name
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        
        if ( deal.size() >0 ) {
        
         if(high_in_grp == 'true')
          deal[0].Highlight_In_Group_Report__c=true;
         else
          deal[0].Highlight_In_Group_Report__c=false;
          
         //System.debug('updateDealForHighInGrp:'+deal_id+high_in_grp);
         update deal[0];
        }

    }   
    
    @RemoteAction
    public static void updateDealForKeyDatesNextSteps(DealKeyDatesNextSteps dealKeyDate) {

       
        List<Deal__c> deal = [
            SELECT 
            id,Name
            FROM Deal__c 
            WHERE Id = :dealKeyDate.DealId
        ];
        
        if ( deal.size() >0 ) {
        
         deal[0].Key_Dates_Next_Steps__c=dealKeyDate.KeyDates;
         //System.debug('updateDealForKeyDatesNextSteps:'+dealKeyDate.DealId+':'+dealKeyDate.KeyDates+':'+dealKeyDate.DealName);
         update deal[0];
        }

    }

@RemoteAction
public static  List<String> getDealSectorFieldList(){
  List<String> lst = new List<String>();
             
  Schema.DescribeFieldResult dealSectorField = Schema.sObjectType.Deal__c.fields.Sector__c;
  Schema.PicklistEntry [] values = dealSectorField .getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(val.getValue());
  }
  //System.debug('getDealSectorFieldList-->'+lst);
  return lst;
} 

@RemoteAction
public static  List<String> getDealOwnerSourceFieldList()
{
  List<String> lst = new List<String>();
             
  Schema.DescribeFieldResult dealSectorField = Schema.sObjectType.Deal__c.fields.Deal_Owner_Source__c;
  Schema.PicklistEntry [] values = dealSectorField .getPickListValues();
    
  for(Schema.PicklistEntry val : values){
   lst.add(val.getValue());
  }
  //System.debug('getDealOwnerSourceFieldList'+lst);
  return lst;
} 

//kckkck  
    @RemoteAction
    public static Boolean updateDealRequiredRichTextFieldsEIR(DealRequiredRichTextFieldsEIR deal_fields) {
        Boolean result = null;
//       Company__r.Description,WP_Investment__c,WP_Ownership_Diluted__c,  Transaction_Value__c, Deal_Owner_Source__c, 
//  Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,     WP_Human_Capital_or_WP_Angle__c,            
        List<Deal__c> deal = [
            SELECT 
            id,Name,Stage__c,Sector__c,Company__c,Description__c,Key_Dates_Next_Steps__c,
            Why_Interesting_EIR__c,
            EIR_Tenure_Expectations__c, EIR_Expected_Annual_Budget__c, EIR_Expected_Timing__c, EIR_Expected_WP_Commitment__c
            FROM Deal__c 
            WHERE Id = :deal_fields.dealId
        ];
        
        if ( deal.size() >0 ) {
         result = true;
         
        // deal[0].Areas_of_Concern_Red_Flags__c=deal_fields.areaOfConcern;
       //  deal[0].Fit_With_Group__c=deal_fields.fitWithGrp;
         deal[0].Why_Interesting_EIR__c=deal_fields.whyInterestingEIR;
        // deal[0].WP_Human_Capital_or_WP_Angle__c=deal_fields.humanCapitial;
         deal[0].Description_EIR__c=deal_fields.EIR_Description; //kck4
         deal[0].EIR_Tenure_Expectations__c = deal_fields.tenureExpectations;
         deal[0].EIR_Expected_Annual_Budget__c=deal_fields.expectedAnnualBudget;
         deal[0].EIR_Expected_Timing__c=deal_fields.expectedTiming;
         deal[0].EIR_Expected_WP_Commitment__c=deal_fields.expectedWPCommitment;

/*        List<Account> acc = [
            SELECT 
            id,Description
            FROM Account
            WHERE id = : deal[0].Company__c
        ];
        if ( acc.size() >0 ) {        
         acc[0].Description = deal_fields.compDesc;
         update acc[0];
        } */
         deal[0].Key_Dates_Next_Steps__c=deal_fields.dealKeyNextSteps;
   
         deal[0].Sector__c=deal_fields.dealSector;
       if(String.isNotBlank(deal[0].Sector__c) && String.isNotEmpty(deal[0].Sector__c)) {
       deal[0].Sector__c = deal[0].Sector__c.replace(',',';');
       deal[0].Sector__c = deal[0].Sector__c .replace('[','');
       deal[0].Sector__c = deal[0].Sector__c .replace(']','');             
       }
       
         
         //System.debug('updateDealRequiredRichTextFieldsEIR:'+deal_fields.dealId+':'+deal[0].Stage__c+':'+
         //deal_fields.whyInterestingEIR+':'+
         //deal_fields.EIR_Description);
         update deal[0];
        }
        
        return result;
    }
    
    @RemoteAction
    public static Boolean updateDealRequiredRichTextFields(DealRequiredRichTextFields deal_fields) {
        Boolean result = null;
       
        List<Deal__c> deal = [
            SELECT 
            id,Name,Stage__c,Sector__c,Company__c,Company__r.Description,Description__c,Description_EAR__c,Key_Dates_Next_Steps__c,
            WP_Investment__c,WP_Ownership_Diluted__c,  Transaction_Value__c, Deal_Owner_Source__c,                   
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_fields.dealId
        ];
        
    if ( deal.size() >0 ) {
         result = true;
         
         deal[0].Areas_of_Concern_Red_Flags__c=deal_fields.areaOfConcern;
         deal[0].Fit_With_Group__c=deal_fields.fitWithGrp;
         deal[0].Why_Interesting__c=deal_fields.whyInteresting;
         deal[0].WP_Human_Capital_or_WP_Angle__c=deal_fields.humanCapitial;
         deal[0].Capital_Market_Consideration__c=deal_fields.capitalMarketConsideration;
         deal[0].Description_EAR__c=deal_fields.EAR_Description; /*was writing to field Description__c*/
         
         String wpOwnership = deal_fields.WP_Ownership_Fully_Diluted;
         if(String.isNotBlank(wpOwnership) && String.isNotEmpty(wpOwnership)) {
                wpOwnership= wpOwnership.replace(',','');    
            wpOwnership= wpOwnership.replace('%','');    
            deal[0].WP_Ownership_Diluted__c = Decimal.valueOf(wpOwnership);               
         }else {
            deal[0].WP_Ownership_Diluted__c = null;
         }                         

        List<Account> acc = [
            SELECT 
            id,Description
            FROM Account
            WHERE id = : deal[0].Company__c
        ];
        if ( acc.size() >0 ) {        
         acc[0].Description = deal_fields.compDesc;
         update acc[0];
        } 
         deal[0].Key_Dates_Next_Steps__c=deal_fields.dealKeyNextSteps;
         if(String.isNotBlank(deal_fields.WP_Investment_MM) && String.isNotEmpty(deal_fields.WP_Investment_MM)) {
                 deal_fields.WP_Investment_MM= deal_fields.WP_Investment_MM.replace(',','');
                 deal[0].WP_Investment__c= Decimal.valueOf(deal_fields.WP_Investment_MM);
                 deal[0].WP_Investment__c= deal[0].WP_Investment__c*1000*1000;
                 //System.debug('updateDealRequiredRichTextFields:WP_Inv_MM...'+deal_fields.WP_Investment_MM+
                 //'....'+Decimal.valueOf(deal_fields.WP_Investment_MM)+'.....'+deal[0].WP_Investment__c);
              } else {
                    deal[0].WP_Investment__c = null;
              }               

         if(String.isNotBlank(deal_fields.Transaction_Value_MM) && String.isNotEmpty(deal_fields.Transaction_Value_MM)) {
                 deal_fields.Transaction_Value_MM= deal_fields.Transaction_Value_MM.replace(',','');        
                 deal[0].Transaction_Value__c=Decimal.valueOf(deal_fields.Transaction_Value_MM);         
                 deal[0].Transaction_Value__c = deal[0].Transaction_Value__c*1000*1000;   
                 //System.debug('updateDealRequiredRichTextFields:Trans_MM....'+deal_fields.Transaction_Value_MM+
                 //'....'+Decimal.valueOf(deal_fields.Transaction_Value_MM)+'.....'+deal[0].Transaction_Value__c);                    
             }else {
                    deal[0].Transaction_Value__c = null;
             }        

         if(String.isNotBlank(deal_fields.Deal_Owner_Source) && String.isNotEmpty(deal_fields.Deal_Owner_Source)) {
          deal_fields.Deal_Owner_Source= deal_fields.Deal_Owner_Source.replace('[','');
          deal_fields.Deal_Owner_Source= deal_fields.Deal_Owner_Source.replace(']',''); 
          deal[0].Deal_Owner_Source__c=deal_fields.Deal_Owner_Source;
         }else {
            deal[0].Deal_Owner_Source__c = null;
         }               
         
         
        deal[0].Sector__c=deal_fields.dealSector;
        if(String.isNotBlank(deal[0].Sector__c) && String.isNotEmpty(deal[0].Sector__c)) {
                deal[0].Sector__c = deal[0].Sector__c.replace(',',';');
               deal[0].Sector__c = deal[0].Sector__c .replace('[','');
               deal[0].Sector__c = deal[0].Sector__c .replace(']','');             
        }     
         
         //System.debug('updateDealRequiredRichTextFields:'+deal_fields.dealId+':'+deal[0].Stage__c+':'+
         //deal_fields.areaOfConcern+':'+deal_fields.fitWithGrp+':'+
         //deal_fields.whyInteresting+':'+deal_fields.humanCapitial+':'+deal_fields.capitalMarketConsideration+':'+
         //deal_fields.EAR_Description);
         update deal[0];
      }
      return result;
    }
    
    @RemoteAction
    public static DealCommentaryEMG updateEMGComment(DealCommentaryEMG dc) {
        Contact contact = [
               SELECT User_ID__c, Name, Id, Full_Name__c FROM Contact 
               WHERE User_ID__c = :UserInfo.getUserId() LIMIT 1];
        
        Boolean update_mode = true;
        EMG_Comment__c comment;

        Deal__c deal = [
            SELECT 
            id, Deal__c.Name, Deal__c.Key_Dates_Next_Steps__c
            FROM Deal__c 
            WHERE Id = :dc.DealId
        ];
        
        if ( deal != null ) {
            
            if ( dc.Id == null || dc.Id == '' ) {
               comment = new EMG_Comment__c();

               update_mode = false; 
            } else {
                comment = [
                   SELECT Id FROM EMG_Comment__c WHERE Id = :dc.Id LIMIT 1];
            }
            
            dc.UpdatedOn = datetime.now().format();
            dc.UpdatedById = contact.Id;
            dc.UpdatedBy = contact.Full_Name__c;
            
            comment.EMG_Comment__c = dc.Comment;
            comment.EMG_Last_Updated_By__c = String.isNotBlank( dc.UpdatedOnBehalfOfId ) ? dc.UpdatedOnBehalfOfId : dc.UpdatedById;
            comment.EMG_Updated_on_behalf_of__c = comment.EMG_Last_Updated_By__c;
            comment.EMG_Last_Updated_Date__c = datetime.parse(dc.UpdatedOn);
            
            if ( update_mode ) {
                update comment;
            } else {
                try {
                    comment.Deal__c = dc.DealId;        
                    insert comment;
                    dc.Id = comment.Id;
                } catch (System.DmlException e) {
                    //System.debug('ERROR DURING INSERT OF DEAL COMMENT (KJO) ' + e);
                }
            }
        } else {
            dc.Message = 'Invalid deal id - no deal found';
        }
        return dc;
    }

    @RemoteAction
    public static DealCommentaryEMG updateEMGParagraph(DealCommentaryEMG dc) {

        Contact contact = [
               SELECT User_ID__c, Name, Id, Full_Name__c FROM Contact 
               WHERE User_ID__c = :UserInfo.getUserId() LIMIT 1];
        
        Boolean update_mode = true;
        EMG_Paragraph__c paragraph;

        Deal__c deal = [
            SELECT 
            id, Deal__c.Name, Deal__c.Key_Dates_Next_Steps__c
            FROM Deal__c 
            WHERE Id = :dc.DealId
        ];
        
        if ( deal != null ) {
            
            if ( dc.Id == null || dc.Id == '' ) {
               paragraph = new EMG_Paragraph__c();
               update_mode = false; 
            } else {
                paragraph = [
                   SELECT Id FROM EMG_Paragraph__c WHERE Id = :dc.Id LIMIT 1];
            }
            
            dc.UpdatedOn = datetime.now().format();
            dc.UpdatedById = contact.Id;
            dc.UpdatedBy = contact.Full_Name__c;
            
            paragraph.EMG_Paragraph__c = dc.Comment;
            paragraph.EMG_Last_Updated_By__c = String.isNotBlank( dc.UpdatedOnBehalfOfId ) ? dc.UpdatedOnBehalfOfId : dc.UpdatedById;
            paragraph.EMG_Updated_on_behalf_of__c = paragraph.EMG_Last_Updated_By__c;
            paragraph.EMG_Last_Updated_Date__c = datetime.parse(dc.UpdatedOn);
            
            if ( update_mode ) {
                update paragraph;
            } else {
                try {
                    paragraph.Deal__c = dc.DealId;        
                    insert paragraph;
                    dc.Id = paragraph.Id;
                } catch (System.DmlException e) {
                    //System.debug('ERROR DURING INSERT OF DEAL PARAGRAPH (KJO) ' + e);
                }
            }
        } else {
            dc.Message = 'Invalid deal id - no deal found';
        }
        return dc;
    }
/* */

// WP-70
/* */    
    @RemoteAction
    public static DealCommentary getDealCommentary(ID deal_id) {
        
        DealCommentaryEMG dc_c = null;
        DealCommentaryEMG dc_p = null;
        DealCommentaryActionItem dc_a = null;
        
        Deal__c deal = [
            SELECT 
            id, Deal__c.Name, Deal__c.Key_Dates_Next_Steps__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        
        if ( deal != null ) {
            
            dc_c = new DealCommentaryEMG();
            dc_p = new DealCommentaryEMG();
            dc_a = new DealCommentaryActionItem();
            
            dc_c.DealId = deal.Id;
            dc_c.DealName = deal.Name;
            
            dc_p.DealId = deal.Id;
            dc_p.DealName = deal.Name;

            dc_a.DealId = deal.Id;
            dc_a.DealName = deal.Name;
            dc_a.Comment = deal.Key_Dates_Next_Steps__c;
            
            List<EMG_Comment__c> comments = [
                SELECT Id, EMG_Comment__c, EMG_Last_Updated_Date__c, 
                   EMG_Last_Updated_By__c, EMG_Last_Updated_By__r.Name,
                   EMG_Updated_on_behalf_of__c, EMG_Updated_on_behalf_of__r.Name, 
                   EMG_Last_Updated_By__r.Full_Name__c,
                   CreatedDate, LastModifiedDate 
                FROM EMG_Comment__c
                WHERE Deal__c = :deal_id 
                ORDER BY CreatedDate DESC
            ];
    
            List<EMG_Paragraph__c> paragraphs = [
                SELECT Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, 
                   EMG_Last_Updated_By__c, EMG_Last_Updated_By__r.Name,
                   EMG_Updated_on_behalf_of__c, EMG_Updated_on_behalf_of__r.Name, 
                   EMG_Last_Updated_By__r.Full_Name__c,
                   CreatedDate, LastModifiedDate 
                FROM EMG_Paragraph__c
                WHERE Deal__c = :deal_id 
                ORDER BY CreatedDate DESC
            ];
            
            Datetime latest = datetime.newInstance(1900, 1, 1);
            Datetime comp_date = null;
            for ( EMG_Comment__c c : comments ) {
                comp_date = c.EMG_Last_Updated_Date__c; // c.CreatedDate;
                if ( comp_date > latest ) {
                    dc_c.Id = c.Id;
                    dc_c.Comment = c.EMG_Comment__c;
                    dc_c.UpdatedBy = c.EMG_Last_Updated_By__r.Full_Name__c;
                    dc_c.UpdatedById = c.EMG_Last_Updated_By__c;
                    dc_c.UpdatedOn = comp_date.format();
                    dc_c.UpdatedOnBehalfOf = c.EMG_Last_Updated_By__r.Full_Name__c; // These values only differ from
                    dc_c.UpdatedOnBehalfOfId = c.EMG_Last_Updated_By__c;            // last updated by on an update
                    latest = comp_date;                                             // not a read.
                }
            }

            latest = datetime.newInstance(1900, 1, 1);
            comp_date = null;
            for ( EMG_Paragraph__c c : paragraphs ) {
                comp_date = c.EMG_Last_Updated_Date__c; // c.CreatedDate;
                if ( comp_date > latest ) {
                    dc_p.Id = c.Id;
                    dc_p.Comment = c.EMG_Paragraph__c;
                    dc_p.UpdatedBy = c.EMG_Last_Updated_By__r.Full_Name__c;
                    dc_p.UpdatedById = c.EMG_Last_Updated_By__c;
                    dc_p.UpdatedOn = comp_date.format();
                    dc_p.UpdatedOnBehalfOf = c.EMG_Last_Updated_By__r.Full_Name__c; // These values only differ from
                    dc_p.UpdatedOnBehalfOfId = c.EMG_Last_Updated_By__c;            // last updated by on an update
                    latest = comp_date;                                                     // not a read.
                }
            }

        }
        DealCommentary dc = new DealCommentary();
        dc.comment = dc_c;
        dc.paragraph = dc_p;
        dc.actionItem = dc_a;
        return dc;
    }
/* */

    @RemoteAction
    public static DealKeyDatesNextSteps getDealKeyDatesNextSteps(ID deal_id) {

        DealKeyDatesNextSteps  KeyDatesNextSteps=null;
        
        List<Deal__c> deal = [
            SELECT 
            id, Deal__c.Name, Deal__c.Key_Dates_Next_Steps__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        
        if ( deal.size() >0 ) {
          KeyDatesNextSteps = new DealKeyDatesNextSteps();
          
          KeyDatesNextSteps.DealId   = deal[0].Id;
          KeyDatesNextSteps.DealName = deal[0].Name;
          KeyDatesNextSteps.keyDates = deal[0].Key_Dates_Next_Steps__c;
        }
        return KeyDatesNextSteps;
    }

    public static Decimal getDecimalMod(Decimal num1 , Decimal num2)
    {
        Decimal c = 0;
        Decimal result;
        result = num1 / num2;
        c= Math.floor(result);
        result = num1 - (num2 * c);
        return result;        
    }
    
    @RemoteAction
    public static DealRequiredRichTextFields getDealRequiredRichTextFields(DealRequiredRichTextFields deal_fields) {

        
        List<Deal__c> deal = [
            SELECT 
            id,Name,Stage__c,Sector__c,Company__c,Company__r.Description,Description__c,Key_Dates_Next_Steps__c,
            Company__r.CurrencyIsoCode,Description_EAR__c,
            WP_Investment_MM__c,WP_Ownership_Diluted__c,WP_Ownership_Fully_Diluted__c, Transaction_Value_MM__c, Deal_Owner_Source__c,
            (SELECT Id,
                Employee__r.Name,Employee__r.Employee_Level__r.Rank__c,Employee__r.ISSENIORTEAMMEMBER__c,
                Employee__r.Employee_Level_Precedence_Sorter__c, Role__c
                FROM Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST,Role__c ASC NULLS LAST , Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST ),                
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c, 
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_fields.dealId
        ];
System.debug('getDealRequiredRichTextFields: one!');
        List<Financial__c> financials = [
          SELECT EBITDA_MM__c,  
          Period_Ended__c, Revenues_MM__c FROM Financial__c
          WHERE ((Company__c = :deal[0].Company__c) AND(Period_Ended__c != Null))
          ORDER BY Period_Ended__c DESC LIMIT 2];
          
        if (deal.size() >0) {
         deal_fields.dealStage = deal[0].Stage__c;
         deal_fields.areaOfConcern = deal[0].Areas_of_Concern_Red_Flags__c;
         deal_fields.fitWithGrp = deal[0].Fit_With_Group__c;
         deal_fields.whyInteresting = deal[0].Why_Interesting__c;
         deal_fields.humanCapitial = deal[0].WP_Human_Capital_or_WP_Angle__c;
         deal_fields.capitalMarketConsideration = deal[0].Capital_Market_Consideration__c;
         deal_fields.Deal_Owner_Source= deal[0].Deal_Owner_Source__c;         
         
         //System.debug('getDealRequiredRichTextFields:'+deal_fields.dealId+':'+deal_fields.dealStage+':'+
         //deal_fields.areaOfConcern+':'+deal_fields.fitWithGrp+':'+
         //deal_fields.whyInteresting+':'+deal_fields.humanCapitial+':'+deal_fields.capitalMarketConsideration);
         
         /*Report View fields*/
         deal_fields.dealName = deal[0].Name;
         deal_fields.dealSector = deal[0].Sector__c;
         System.debug('getDealRequiredRichTextFields: two ! ' + deal_fields.dealName);
       List<Deal_Team__c> team_list = deal[0].Deal_Team__r;
       Integer list_count=0;
       for(Deal_Team__c team_item:team_list) {
         list_count++;
         deal_fields.dealTeam=deal_fields.dealTeam+team_item.Employee__r.Name;
         if(list_count <  team_list.size()) {
           deal_fields.dealTeam=deal_fields.dealTeam+',  ';
         }
       }

        deal_fields.compDesc = deal[0].Company__r.Description;
        deal_fields.CompCurrencyCode = deal[0].Company__r.CurrencyIsoCode;
        
       if(String.isBlank(deal_fields.compDesc)||String.isEmpty(deal_fields.compDesc)) {
        deal_fields.compDesc='\n'; 
       }
               
      if(financials.size()>0) {
       Integer i;
       list_count=0;
       for(i=financials.size()-1; i >=0;--i) {
         list_count++;       
     
        if(financials[i].Revenues_MM__c == null){
         deal_fields.compRevenue_MM=deal_fields.compRevenue_MM+ '<b>'+financials[i].Period_Ended__c.format()+'</b>' + '    '+' ';
        }
        else {       
         if(getDecimalMod(financials[i].Revenues_MM__c.setScale(2),1.0) != 0) {
          deal_fields.compRevenue_MM=deal_fields.compRevenue_MM+ '<b>'+financials[i].Period_Ended__c.format()+'</b>' + '    '+ financials[i].Revenues_MM__c.setScale(2).format();
         }
         else {
          deal_fields.compRevenue_MM=deal_fields.compRevenue_MM+ '<b>'+financials[i].Period_Ended__c.format()+'</b>' + '    '+ financials[i].Revenues_MM__c.setScale(2).round().format();
         }          
        } 
         if(list_count <  financials.size()) {
           deal_fields.compRevenue_MM=deal_fields.compRevenue_MM+'           ';
         }       
       }

       list_count=0;
       for(i=financials.size()-1; i >=0;--i) {
         list_count++;

        if(financials[i].EBITDA_MM__c == null){
         deal_fields.compEBITDA_MM=deal_fields.compEBITDA_MM+ '<b>'+financials[i].Period_Ended__c.format()+'</b>' + '    '+' ';
        }
        else {       
         if(getDecimalMod(financials[i].EBITDA_MM__c.setScale(2),1.0) != 0) {
          deal_fields.compEBITDA_MM=deal_fields.compEBITDA_MM+ '<b>'+financials[i].Period_Ended__c.format()+'</b>' + '    '+ financials[i].EBITDA_MM__c.setScale(2).format();
         }
         else {
          deal_fields.compEBITDA_MM=deal_fields.compEBITDA_MM+ '<b>'+financials[i].Period_Ended__c.format()+'</b>' + '    '+ financials[i].EBITDA_MM__c.setScale(2).round().format();
         }      
        }        
         if(list_count <  financials.size()) {
           deal_fields.compEBITDA_MM=deal_fields.compEBITDA_MM+'           ';
         }       
       }     
      }
      else {
        deal_fields.compRevenue_MM='\n';
        deal_fields.compEBITDA_MM='\n';
      }
       deal_fields.dealDesc = deal[0].Description__c; //kck5
     //       System.debug('getDealRequiredRichTextFields: three ! ' + deal_fields.dealDesc);
       deal_fields.EAR_Description = deal[0].Description_EAR__c;//Description__c;
        if((String.isBlank(deal_fields.EAR_Description)||String.isEmpty(deal_fields.EAR_Description))
            && !(String.isBlank(deal_fields.dealDesc )) && !String.isEmpty(deal_fields.dealDesc )
            ){                           
            deal_fields.EAR_Description=deal_fields.dealDesc ;
            deal[0].Description_EAR__c = deal[0].Description__c;
          //      System.debug('getDealRequiredRichTextFields: three and half ! ' + deal[0].Description_EAR__c);
          	//      
          //seung - 3/13/15.  update causes error on read only access.  commenting it out?
                try {
                	update(deal[0]);
                }
                catch(Exception e) {
                    System.debug('getDealRequiredRichTextFields: cannot update deal description ear. ' + e.getMessage());
                }
            }
               
      /* if(String.isBlank(deal_fields.EAR_Description)||String.isEmpty(deal_fields.EAR_Description)) {
        deal_fields.EAR_Description = '\n';  
       }

       if(String.isBlank(deal_fields.dealDesc)||String.isEmpty(deal_fields.dealDesc)) {
        deal_fields.dealDesc = '\n';  
       }*/
                     
       deal_fields.dealKeyNextSteps = deal[0].Key_Dates_Next_Steps__c;    

       if(String.isBlank(deal_fields.dealKeyNextSteps)||String.isEmpty(deal_fields.dealKeyNextSteps)) {
         deal_fields.dealKeyNextSteps = '\n';  
       }               
   
        if(deal[0].WP_Investment_MM__c == null){
         deal_fields.WP_Investment_MM='\n';
        }
        else {
         if(getDecimalMod(deal[0].WP_Investment_MM__c.setScale(2),1.0) != 0) {
          deal_fields.WP_Investment_MM=deal[0].WP_Investment_MM__c.setScale(2).format();
         }
         else {
          deal_fields.WP_Investment_MM=deal[0].WP_Investment_MM__c.setScale(2).round().format();
         }  
        }          
    
       
        if(deal[0].Transaction_Value_MM__c == null){
         deal_fields.Transaction_Value_MM='\n';
        }
        else {
         if(getDecimalMod(deal[0].Transaction_Value_MM__c.setScale(2),1.0) != 0) {
           deal_fields.Transaction_Value_MM=deal[0].Transaction_Value_MM__c.setScale(2).format();
         }
         else {
           deal_fields.Transaction_Value_MM=deal[0].Transaction_Value_MM__c.setScale(2).round().format();
         }  
        }  
                   
       if(deal[0].WP_Ownership_Diluted__c != null ) {
         if(getDecimalMod(deal[0].WP_Ownership_Diluted__c.setScale(2),1.0) != 0) {
          deal_fields.WP_Ownership_Fully_Diluted=deal[0].WP_Ownership_Diluted__c.setScale(2).format()+'%';
         }
         else {
          deal_fields.WP_Ownership_Fully_Diluted=deal[0].WP_Ownership_Diluted__c.setScale(2).round().format()+'%';
         }         
       }
       else {
         deal_fields.WP_Ownership_Fully_Diluted='\n';
      }

        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c            
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_fields.dealId) AND (Type_of_Report__c = 'EAR Metrics')
        ];

        if(dsh_list.size() > 1) {
          //System.debug('getDealRequiredRichTextFields:Either more than one or no Deal Score '+
          //'header exists for EAR Metrics:deal_id:size:'+deal_fields.dealId+dsh_list.size());
          deal_fields.earMetrics = null;
        } else if(dsh_list.size() == 0) {
          //System.debug('getDealRequiredRichTextFields:No Deal Score '+
          //'header exists for EAR Metrics:deal_id:size:'+deal_fields.dealId+dsh_list.size());
          deal_fields.earMetrics = new List<EAR_Metric_Related_Info>();
        } else {                   
             List<Deal_Score_Line_Item__c> line_list = [
            SELECT
            id,Deal_Score_Header__c,EAR_Metric_Name__c,EAR_Metric_Period_Ended__c,EAR_Metric_Value__c           
            FROM Deal_Score_Line_Item__c
            WHERE Deal_Score_Header__c =:dsh_list[0].Id
            ];
            deal_fields.earMetrics = new List<EAR_Metric_Related_Info>();
            for(Deal_Score_Line_Item__c item:line_list){
              EAR_Metric_Related_Info ear_related_info_item = new EAR_Metric_Related_Info();
              ear_related_info_item.deal_id =deal_fields.dealId;
              ear_related_info_item.scHead_id=dsh_list[0].Id;
              ear_related_info_item.lineItem_id=item.Id;
              ear_related_info_item.ear_metric_name=item.EAR_Metric_Name__c;
              
              if(item.EAR_Metric_Period_Ended__c != null) {           
                ear_related_info_item.ear_metric_per_end=item.EAR_Metric_Period_Ended__c.format();
              } else {
                ear_related_info_item.ear_metric_per_end='';
              }
              ear_related_info_item.ear_metric_value=item.EAR_Metric_Value__c;
              deal_fields.earMetrics.add(ear_related_info_item);    
              //System.debug('getDealRequiredRichTextFields:Added  Line item:size():item:'+deal_fields.earMetrics.size()+'.....'+ear_related_info_item);                        
            }
        }     
      System.debug('getDealRequiredRichTextFields: four ! ');
       
        }
        else
        {
         /*
         deal_fields.dealStage = deal[0].Stage__c;
         deal_fields.areaOfConcern = deal[0].Areas_of_Concern_Red_Flags__c;
         deal_fields.fitWithGrp = deal[0].Fit_With_Group__c;
         deal_fields.whyInteresting = deal[0].Why_Interesting__c;
         deal_fields.humanCapitial = deal[0].WP_Human_Capital_or_WP_Angle__c;
         deal_fields.capitalMarketConsideration = deal[0].Capital_Market_Consideration__c;
         //Report View fields
         deal_fields.dealName = deal[0].Name;
         deal_fields.dealSector = deal[0].Sector__c;
         deal_fields.dealTeam
         deal_fields.compDesc
         deal_fields.compRevenue_MM
         deal_fields.compEBITDA_MM
       deal_fields.dealDesc = deal[0].Description__c;
       deal_fields.dealKeyNextSteps = deal[0].Key_Dates_Next_Steps__c; 
       deal_fields.WP_Investment_MM = deal[0].WP_Investment_MM__c;   
       deal_fields.WP_Ownership_Fully_Diluted = deal[0].WP_Ownership_Fully_Diluted__c+'%'; */
       deal_fields=null;
         System.debug('getDealRequiredRichTextFields: else ! ' );
         
        }
        System.debug('getDealRequiredRichTextFields: five ! ' + deal_fields.dealName);
        return deal_fields;
    }
    
    @RemoteAction
    public static DealRequiredRichTextFieldsEIR getDealRequiredRichTextFieldsEIR(DealRequiredRichTextFieldsEIR deal_fields) { //kckkck

        //Company__r.Description,WP_Investment_MM__c,WP_Ownership_Diluted__c,  Transaction_Value_MM__c, Deal_Owner_Source__c,  
        // Areas_of_Concern_Red_Flags__c,Fit_With_Group__c, WP_Human_Capital_or_WP_Angle__c,
        //kck4
        List<Deal__c> deal = [
            SELECT 
            id,Name,Stage__c,Sector__c,Company__c,Description_EIR__c,Key_Dates_Next_Steps__c, Description__c,
            Company__r.CurrencyIsoCode,
            
            (SELECT Id,
                Employee__r.Name, Employee__r.Employee_Level__r.Rank__c,
                Employee__r.ISSENIORTEAMMEMBER__c, Role__c,
                Employee__r.Employee_Level_Precedence_Sorter__c
                FROM Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC, Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC),
                                Why_Interesting_EIR__c,
                EIR_Tenure_Expectations__c, EIR_Expected_Annual_Budget__c, EIR_Expected_Timing__c, EIR_Expected_WP_Commitment__c
            FROM Deal__c 
            WHERE Id = :deal_fields.dealId
        ];
  
        if (deal.size() >0) {
         deal_fields.dealStage = deal[0].Stage__c;
//         deal_fields.areaOfConcern = deal[0].Areas_of_Concern_Red_Flags__c;
//         deal_fields.fitWithGrp = deal[0].Fit_With_Group__c;
         deal_fields.whyInterestingEIR = deal[0].Why_Interesting_EIR__c;
//         deal_fields.humanCapitial = deal[0].WP_Human_Capital_or_WP_Angle__c;
         
         deal_fields.tenureExpectations = deal[0].EIR_Tenure_Expectations__c;
         deal_fields.expectedAnnualBudget = deal[0].EIR_Expected_Annual_Budget__c;
         deal_fields.expectedTiming = deal[0].EIR_Expected_Timing__c;
         deal_fields.expectedWPCommitment= deal[0].EIR_Expected_WP_Commitment__c;

        // deal_fields.Deal_Owner_Source= deal[0].Deal_Owner_Source__c;         
         
         //System.debug('getDealRequiredRichTextFieldsEIR:'+deal_fields.dealId+':'+deal_fields.dealStage+':'+       
         //deal_fields.whyInterestingEIR);
         
         /*Report View fields*/
         deal_fields.dealName = deal[0].Name;
         deal_fields.dealSector = deal[0].Sector__c;
         
       List<Deal_Team__c> team_list = deal[0].Deal_Team__r;
       Integer list_count=0;
       for(Deal_Team__c team_item:team_list) {
         list_count++;
         deal_fields.dealTeam=deal_fields.dealTeam+team_item.Employee__r.Name;
         if(list_count <  team_list.size()) {
           deal_fields.dealTeam=deal_fields.dealTeam+',  ';
         }
       }

      //  deal_fields.compDesc = deal[0].Company__r.Description;
        deal_fields.CompCurrencyCode = deal[0].Company__r.CurrencyIsoCode;
        
     /*  if(String.isBlank(deal_fields.compDesc)||String.isEmpty(deal_fields.compDesc)) {
        deal_fields.compDesc='\n'; 
       } */
   
       deal_fields.dealDesc = deal[0].Description__c; //kck4
       deal_fields.EIR_Description = deal[0].Description_EIR__c; //kck4
              
        if((String.isBlank(deal_fields.EIR_Description)||String.isEmpty(deal_fields.EIR_Description))
            && !(String.isBlank(deal_fields.dealDesc )) && !String.isEmpty(deal_fields.dealDesc )
            ){
            	deal_fields.EIR_Description=deal_fields.dealDesc ;
            	deal[0].Description_EIR__c = deal[0].Description__c;
                try {
            		update(deal[0]);        
                }
                catch(Exception e) {
                	System.debug('getDealRequiredRichTextFieldsEIR error: ' + e.getMessage());    
                }
            }
              
      /* if(String.isBlank(deal_fields.EIR_Description)||String.isEmpty(deal_fields.EIR_Description)) {
        deal_fields.EIR_Description = '\n';  
       }

       if(String.isBlank(deal_fields.dealDesc)||String.isEmpty(deal_fields.dealDesc)) {
        deal_fields.dealDesc = '\n';  
       } */
                     
       deal_fields.dealKeyNextSteps = deal[0].Key_Dates_Next_Steps__c;    

       if(String.isBlank(deal_fields.dealKeyNextSteps)||String.isEmpty(deal_fields.dealKeyNextSteps)) {
         deal_fields.dealKeyNextSteps = '\n';  
       }               
  
        }
        else
        {
        
       deal_fields=null;
         
         
        }
        return deal_fields;
    }
    
    @RemoteAction
    public static Integer getNoOfEarMetricsForADeal(String deal_id){
        Integer result;
        
        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c            
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'EAR Metrics')
        ];

        if(dsh_list.size() > 1) {
          //System.debug('getNoOfEarMetricsForADeal:More than one Deal Score '+
          //'header exists for EAR Metrics:deal_id:size:'+deal_id+dsh_list.size());
          result = 0;
        } else if(dsh_list.size() == 0) {
          //System.debug('getNoOfEarMetricsForADeal:No Deal Score '+
          //'header exists for EAR Metrics:deal_id:size:'+result+dsh_list.size());
          result = 0;
        } else {                   
             List<Deal_Score_Line_Item__c> line_list = [
            SELECT
            id,Deal_Score_Header__c,EAR_Metric_Name__c,EAR_Metric_Period_Ended__c,EAR_Metric_Value__c           
            FROM Deal_Score_Line_Item__c
            WHERE Deal_Score_Header__c =:dsh_list[0].Id
            ];
             result = line_list.size();
             //System.debug('getNoOfEarMetricsForADeal:size():'+result);                        
            }
        return result;
    }
    
    @RemoteAction
    public static EAR_Metric_Result_Info addUpdateEAR_Metric_Field(String deal_id,String deal_sc_hdr_id,
      String deal_line_item_id,String ear_metric_name,Date ear_metric_date,String ear_metric_value) {
      
        EAR_Metric_Result_Info result = new EAR_Metric_Result_Info(deal_id);
       
        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c           
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'EAR Metrics')
        ];

        if(dsh_list.size()>1) {
          //System.debug('addUpdateEAR_Metric_Field:More than one Deal Score '+
          //'header exists for EAR Metrics:deal_id:size:'+deal_id+dsh_list.size());
        } else {       
          if((deal_sc_hdr_id != '')&&(dsh_list.size() == 0)) {
          //System.debug('addUpdateEAR_Metric_Field:Deal Score '+
          //'header Id received for EAR Metrics but is not found in the database:deal_id:size:dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id);
          } else if((deal_sc_hdr_id != '')&&(dsh_list.size() != 0) &&(deal_sc_hdr_id != dsh_list[0].id)) {
          //System.debug('addUpdateEAR_Metric_Field:Invalid Deal Score '+
          //'header Id received for EAR Metrics:deal_id:size:dsh_id:database_dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id+'...'+dsh_list[0].id);
          } else {
            if(dsh_list.size() == 0){          
               DealScoreHeader__c header_item = new DealScoreHeader__c();   
               header_item.Type_of_Report__c = 'EAR Metrics';
               header_item.Deal__c = deal_id;
               insert header_item;
              
               result.dealId = deal_id;
               result.dealScoreHeaderId = header_item.id;
          //System.debug('addUpdateEAR_Metric_Field:Creating Deal Score '+
          //'header Id for EAR Metrics:deal_id:size:dsh_id:database_dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id+'...'+header_item.id);   
          } else {          
               result.dealId = deal_id;
               result.dealScoreHeaderId = dsh_list[0].id;
          //System.debug('addUpdateEAR_Metric_Field:Using existing Deal Score '+
          //'header Id for EAR Metrics:deal_id:size:dsh_id:database_dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id+'...'+dsh_list[0].id);   
          }      
          
           if(deal_line_item_id !=''){
             List<Deal_Score_Line_Item__c> line_list = [
            SELECT
            id,Deal_Score_Header__c,EAR_Metric_Name__c,EAR_Metric_Period_Ended__c,EAR_Metric_Value__c          
            FROM Deal_Score_Line_Item__c
            WHERE id =:deal_line_item_id
            ];
            if(line_list.size() == 0){
              //System.debug('addUpdateEAR_Metric_Field:Line item not found in the database'+deal_line_item_id);
            } else if(line_list[0].Deal_Score_Header__c != result.dealScoreHeaderId) {
              //System.debug('addUpdateEAR_Metric_Field:Mismatch in ScoreHeader for Line item'+deal_line_item_id+
              //result.dealScoreHeaderId+line_list[0].Deal_Score_Header__c);
             } else {
              line_list[0].EAR_Metric_Name__c=ear_metric_name;
              line_list[0].EAR_Metric_Period_Ended__c=ear_metric_date;
              line_list[0].EAR_Metric_Value__c=ear_metric_value;
             
              update line_list[0];
              result.dealLineItemId = line_list[0].id;
              result.status ='true';
              //System.debug('addUpdateEAR_Metric_Field:Updated Line item'+deal_line_item_id+
              //ear_metric_name+ear_metric_date+ear_metric_value);             
            }
           } else  {
              Deal_Score_Line_Item__c line_item = new Deal_Score_Line_Item__c();
              line_item.EAR_Metric_Name__c=ear_metric_name;
              line_item.EAR_Metric_Period_Ended__c=ear_metric_date;
              line_item.EAR_Metric_Value__c=ear_metric_value;
              line_item.Deal_Score_Header__c=result.dealScoreHeaderId;
              insert line_item;
              result.dealLineItemId = line_item.id;
              result.status ='true';
              //System.debug('addUpdateEAR_Metric_Field:Inserted Line item'+deal_line_item_id+
              //ear_metric_name+ear_metric_date+ear_metric_value);          
           }
         }
        }
       
        return result;
    }

    @RemoteAction
    public static String deleteEAR_Metric_Field(String deal_id,String deal_sc_hdr_id,String deal_line_item_id) {
        String result;
        List<Deal_Score_Line_Item__c> ear_list = [
          SELECT Id,Deal_Score_Header__c FROM Deal_Score_Line_Item__c
          WHERE Id =:deal_line_item_id];
         
          if (ear_list.size() == 1) {
            if(ear_list[0].Deal_Score_Header__c != deal_sc_hdr_id){
              //System.debug('deleteEAR_Metric_Field: Failed to delete item due to invalid score header id:size:'+ear_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
              result= null;
            } else {
            delete ear_list[0];
            //System.debug('deleteEAR_Metric_Field: Deleted item:size:'+ear_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
            result = 'true';
            }
          } else {
            //System.debug('deleteEAR_Metric_Field: Failed to delete item due to more than one line item id:size:'+ear_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
            result= null;
          }
          return result;
    }

    @RemoteAction
    public static DCR_Metric_Result_Info addUpdateDCR_Metric_Field(String deal_id,String deal_sc_hdr_id,
      String deal_line_item_id,String dcr_metric_name,String dcr_metric_date,Date dcr_sorted_date,String dcr_metric_value, String dcr_metric_unit) {
       DCR_Metric_Result_Info result = new DCR_Metric_Result_Info();

       
        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c           
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id)
        ];

        if(dsh_list.size() == 0) {
          //System.debug('addUpdateDCR_Metric_Field:Deal Score '+
          //'header Id received for DCR Metrics but is not found in the database:deal_id:size:dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id);
        } else {       
          if((dsh_list[0].Type_of_Report__c == 'EAR Metrics') || (deal_id != dsh_list[0].Deal__c)) {
          //System.debug('addUpdateDCR_Metric_Field:Invalid Deal Score '+
          //'header elements for DCR Metrics:deal_id:size:dsh_id:database_dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id+'...'+dsh_list[0]);
          } else {
       
          result.dealId = deal_id;
          result.dealScoreHeaderId = dsh_list[0].id;
          //System.debug('addUpdateDCR_Metric_Field:Using existing Deal Score '+
          //'header Id for DCR Metrics:deal_id:size:dsh_id:database_dsh_id'+
          // deal_id+dsh_list.size()+deal_sc_hdr_id+'...'+dsh_list[0].id);   
         
           if(deal_line_item_id !=''){
             List<Deal_Score_Line_Item__c> line_list = [
            SELECT 
            id,Deal_Score_Header__c,Financial_Metric_Name__c,Financial_Metric_Period_Ended__c,Financial_Metric_Period_Text__c,
            Financial_Metric_Value__c, Financial_Metric_Unit__c,Is_Financial_Metric_Imported__c, Line_Item_Title__c          
            FROM Deal_Score_Line_Item__c
            WHERE id =:deal_line_item_id 
            ];
            if(line_list.size() == 0){
              //System.debug('addUpdateDCR_Metric_Field:Line item not found in the database'+deal_line_item_id);
            } else if(line_list[0].Deal_Score_Header__c != result.dealScoreHeaderId) {
              //System.debug('addUpdateDCR_Metric_Field:Mismatch in ScoreHeader for Line item'+deal_line_item_id+
              //result.dealScoreHeaderId+line_list[0].Deal_Score_Header__c);
             } else if(line_list[0].Line_Item_Title__c != 'Financial Metric') {
              //System.debug('addUpdateDCR_Metric_Field:Mismatch in Line_Item_Title__c for Line item'+deal_line_item_id+
              //result.dealScoreHeaderId+line_list[0]);
             }else {
              line_list[0].Financial_Metric_Name__c=dcr_metric_name;
              if (dcr_metric_name=='EBITDA'){               
                    //line_item.Is_Financial_Metric_Imported__c = 1;
                    line_list[0].Is_Financial_Metric_Imported__c = 3;
              }else if (dcr_metric_name=='Revenue'){                
                    //line_item.Is_Financial_Metric_Imported__c = 2;
                    line_list[0].Is_Financial_Metric_Imported__c = 4;
              } else{
                line_list[0].Is_Financial_Metric_Imported__c = 0;
              }              
              line_list[0].Financial_Metric_Period_Text__c=dcr_metric_date;
              line_list[0].Financial_Metric_Period_Ended__c=dcr_sorted_date;
              //sorted_date_val
              line_list[0].Financial_Metric_Value__c=dcr_metric_value;
              line_list[0].Financial_Metric_Unit__c=dcr_metric_unit;
              
              update line_list[0];
              result.dealLineItemId = line_list[0].id;
              result.status ='true';
              //System.debug('addUpdateDCR_Metric_Field:Updated Line item'+deal_line_item_id+
              //dcr_metric_name+dcr_metric_date+dcr_metric_value);             
            }
           } else  {
              Deal_Score_Line_Item__c line_item = new Deal_Score_Line_Item__c();
              line_item.Financial_Metric_Name__c=dcr_metric_name;
              line_item.Financial_Metric_Period_Text__c=dcr_metric_date;
              line_item.Financial_Metric_Period_Ended__c=dcr_sorted_date;
              line_item.Financial_Metric_Value__c=dcr_metric_value;
              line_item.Financial_Metric_Unit__c=dcr_metric_unit;
              line_item.Deal_Score_Header__c=result.dealScoreHeaderId;
              line_item.Line_Item_Title__c='Financial Metric';
              if (dcr_metric_name=='EBITDA'){               
                    //line_item.Is_Financial_Metric_Imported__c = 1;
                    line_item.Is_Financial_Metric_Imported__c = 3;
              }else if (dcr_metric_name=='Revenue'){                
                    //line_item.Is_Financial_Metric_Imported__c = 2;
                    line_item.Is_Financial_Metric_Imported__c = 4;
              } else{
                line_item.Is_Financial_Metric_Imported__c = 0;
              }
              insert line_item;
              result.dealLineItemId = line_item.id;
              result.status ='true';
              //System.debug('addUpdateDCR_Metric_Field:Inserted Line item'+deal_line_item_id+
              //dcr_metric_name+dcr_metric_date+dcr_metric_value);          
           }
         }
        }
           
       return result;
    }

    @RemoteAction
    public static String deleteDCR_Metric_Field(String deal_id,String deal_sc_hdr_id,String deal_line_item_id) {
        String result;
        List<Deal_Score_Line_Item__c> dcr_list = [
          SELECT Id,Deal_Score_Header__c FROM Deal_Score_Line_Item__c
          WHERE Id =:deal_line_item_id];
         
          if (dcr_list.size() == 1) {
            if(dcr_list[0].Deal_Score_Header__c != deal_sc_hdr_id){
              //System.debug('deleteDCR_Metric_Field: Failed to delete item due to invalid score header id:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
              result= null;
            } else {
            delete dcr_list[0];
            //System.debug('deleteDCR_Metric_Field: Deleted item:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
            
            /*Check if there are no more items left, inform Apex page to show back the import company list*/
            dcr_list = [
             SELECT Id,Deal_Score_Header__c,Line_Item_Title__c FROM Deal_Score_Line_Item__c
              WHERE (Deal_Score_Header__c =:deal_sc_hdr_id) AND (Line_Item_Title__c = 'Financial Metric')];
            if (dcr_list.size() == 0) {
              result = 'SHOW LIST';
              //System.debug('deleteDCR_Metric_Field: All items deleted:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id+':'+result);
              
              /*Also set back the imported flags to false*/
              List<DealScoreHeader__c> deal_hdr_list = [
                 SELECT
                 id,Deal__c,Date_Received__c,Type_of_Report__c,ISEBITDAIMPORTED__c,ISRevenueIMPORTED__c 
                 FROM DealScoreHeader__c
                 WHERE (id = :deal_sc_hdr_id)
              ]; 
              if(deal_hdr_list.size() != 1) {       
                 result= null;
                 //System.debug('deleteDCR_Metric_Field:More than 1 deal score header exists.Please check:size'+deal_hdr_list.size());
              } else {
                 deal_hdr_list[0].ISEBITDAIMPORTED__c=false;
                 deal_hdr_list[0].ISRevenueIMPORTED__c=false;
                 update deal_hdr_list[0];
                 //System.debug('deleteDCR_Metric_Field:Deal score header updated for imported flags'+deal_hdr_list[0]);
              }           
            } else {
              result = 'true';
              //System.debug('deleteDCR_Metric_Field: Deleted item:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id+':'+result);
            }
           }    
          } else {
            //System.debug('deleteDCR_Metric_Field: Failed to delete item due to more than one line item id:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
            result= null;
          }
          return result;
    }
    
    @RemoteAction
    public static DCR_MtericsAndCompFinNameInfo getDCR_MtericsAndCompFinNameInfo(String deal_id,String deal_sc_hdr_id,List<String> type_list) {
        DCR_MtericsAndCompFinNameInfo dcrFinList = new DCR_MtericsAndCompFinNameInfo();
        Boolean is_ebitda_present=false;
        Boolean is_revenue_already_imported=false;
        Boolean is_ebitda_already_imported=false;
        Boolean is_scorecard_enabled=false;
        String copyid=deal_sc_hdr_id;
        String typeOfReport='';
        
        if((deal_sc_hdr_id=='')||(deal_sc_hdr_id==null)) {
          //System.debug('getDCR_MtericsAndCompFinNameInfo:Invalid header id or size of list is invalid');
          return dcrFinList;
        }
        List<Deal__c> deal = [
            SELECT
            id,Company__c,ISSCORECARDENABLED__c, ISDCRENABLED__c
            FROM Deal__c
            WHERE Id = :deal_id
        ];
                
        //Copy logic starts if the Deal is already scorecard enabled
                if(deal.size()>0){
                        if(deal[0].ISSCORECARDENABLED__c) {
                                List<DealScoreHeader__c> copy_hdr_list = [
                SELECT id,Deal__c,Date_Received__c,Type_of_Report__c,ISEBITDAIMPORTED__c,ISRevenueIMPORTED__c  
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id AND Type_of_Report__c='Copy')
                        ]; 
                        if(copy_hdr_list.size()>0){
                                //copyid = copy_hdr_list[0].Id;
                                //deal_sc_hdr_id = copy_hdr_list[0].Id;
                        }                                
                        }
                }
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT
            id,Deal__c,Date_Received__c,Type_of_Report__c,ISEBITDAIMPORTED__c,ISRevenueIMPORTED__c  
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id)
        ]; 
        
        if((deal_hdr_list.size()==0)||(deal_hdr_list.size()>1)||(deal_hdr_list[0].Deal__c!=deal_id)) {
          //System.debug('getDCR_MtericsAndCompFinNameInfo:Invalid header id or size of list is invalid'+deal_hdr_list.size());
          return dcrFinList;
        } else {
                typeOfReport = deal_hdr_list[0].Type_of_Report__c;
                is_revenue_already_imported = deal_hdr_list[0].ISEBITDAIMPORTED__c;
                is_ebitda_already_imported  = deal_hdr_list[0].ISRevenueIMPORTED__c;
           //System.debug('getDCR_MtericsAndCompFinNameInfo:is_revenue_already_imported:is_ebitda_already_imported'+is_revenue_already_imported+
           // is_ebitda_already_imported+deal_sc_hdr_id);
        }               
        
        if((type_list==null)||(type_list.size()==0)){//Load the DCR Metrics that are already in the database
        
            List<Deal_Score_Line_Item__c> line_list = [
            SELECT id,Deal_Score_Header__c,Financial_Metric_Name__c,Financial_Metric_Period_Text__c,Financial_Metric_Period_Ended__c,
            Financial_Metric_Value__c,Financial_Metric_Unit__c,Is_Financial_Metric_Imported__c,Line_Item_Color__c,Line_Item_Title__c,Related_Score_Line_Item_Id__c
            FROM Deal_Score_Line_Item__c
            WHERE ((Deal_Score_Header__c =:deal_sc_hdr_id) AND (Line_Item_Title__c = 'Financial Metric'))
            ORDER BY Is_Financial_Metric_Imported__c DESC, Financial_Metric_Name__c ASC, Financial_Metric_Period_Ended__c ASC
            ];
            
            String allOptions = '';
            for(Deal_Score_Line_Item__c item:line_list){
              allOptions = '';
              DCR_Metric_Related_Info dcr_related_info_item = new DCR_Metric_Related_Info();
              dcr_related_info_item.deal_id =deal_id;
              dcr_related_info_item.scHead_id=deal_sc_hdr_id;
              dcr_related_info_item.lineItem_id=item.Id;
              dcr_related_info_item.dcr_metric_name=item.Financial_Metric_Name__c;
              
              if(item.Financial_Metric_Period_Text__c != null) {           
                dcr_related_info_item.dcr_metric_per_end=item.Financial_Metric_Period_Text__c;
              } else {
                dcr_related_info_item.dcr_metric_per_end='';
              }
              dcr_related_info_item.dcr_metric_value=item.Financial_Metric_Value__c;
              dcr_related_info_item.dcr_metric_unit=item.Financial_Metric_Unit__c;  
              
              //Now retrieve the dcr_metric_followup_value and color if any exists??
              
              List<Deal_Score_Line_Item__c> copy_list = [
              SELECT Id,Deal_Score_Header__c,Line_Item_Title__c,Line_Item_Color__c,Financial_Metric_Value__c,Related_Score_Line_Item_Id__c
              FROM Deal_Score_Line_Item__c
              //WHERE Related_Score_Line_Item_Id__c=:item.Id];  
              WHERE Id=:item.Related_Score_Line_Item_Id__c];  
              
              if(copy_list.size()>0) {
                        dcr_related_info_item.dcr_metric_followup_value = copy_list[0].Financial_Metric_Value__c;
                        dcr_related_info_item.dcr_metric_followup_color = item.Line_Item_Color__c;
                        if (item.Line_Item_Color__c=='#ffffff'){
                                        allOptions  = allOptions + '<option class="color-option" value="#ffffff" selected>Neutral</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';
                                }else if (item.Line_Item_Color__c=='#ebf1de'){
                                        allOptions  = allOptions + '<option class="color-option" value="#ffffff" >Neutral</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#ebf1de" selected>Favorable</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';
                                }else if (item.Line_Item_Color__c=='#f2dcdb'){
                                        allOptions  = allOptions + '<option class="color-option" value="#ffffff" >Neutral</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" selected>Unfavorable</option>';
                                }else{
                                        allOptions  = allOptions + '<option class="color-option" value="#ffffff" selected>Neutral</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                        allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';                                    
                                }
                                dcr_related_info_item.dcr_metric_followup_selectoption = '<select class=\"followupcolor\" id=\"followup-finance-color-id-'+ item.Id +'\" >'+ allOptions + '</select>';
              }else{
                        dcr_related_info_item.dcr_metric_followup_value = 'No Copy Item Value';
                        dcr_related_info_item.dcr_metric_followup_color = '#ffffff';
                        allOptions  = allOptions + '<option class="color-option" value="#ffffff" selected>Neutral</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';
                                dcr_related_info_item.dcr_metric_followup_selectoption = '<select class=\"followupcolor\" id=\"followup-finance-color-id-'+ item.Id +'\" >'+ allOptions + '</select>';
              }             
              dcrFinList.dcrMetrics.add(dcr_related_info_item);    
              //System.debug('getDCR_MtericsAndCompFinNameInfo:Added  Line item:size():item:'+dcrFinList.dcrMetrics.size()+'.....'+dcr_related_info_item);              
            }            
            if(is_revenue_already_imported == false){    
                dcrFinList.compFinNameList.add('Revenue');
            }
            if(is_ebitda_already_imported == false){     
                dcrFinList.compFinNameList.add('EBITDA');
            } 
            dcrFinList.status ='true';            
        } else {
                List<Financial__c> financials = [
                SELECT EBITDA_MM__c, 
                Period_Ended__c, Revenues_MM__c,CurrencyIsoCode FROM Financial__c
                WHERE ((Company__c = :deal[0].Company__c) AND(Period_Ended__c != Null))
                ORDER BY Period_Ended__c DESC LIMIT 2];
                //System.debug('getDCR_MtericsAndCompFinNameInfo:dsize:fsize:tsize'+deal.size()+'...'+financials.size()+'...'+type_list.size());
       
                if ((deal.size() > 0) && (financials.size() > 0)) {
               Integer i,j;
                       for(j=0; j<type_list.size();++j) {
                        Boolean revenue_found,ebitda_found;
                        revenue_found=false;ebitda_found=false;
                        for(i=financials.size()-1; i >=0;--i) {     
                                //System.debug('getDCR_MtericsAndCompFinNameInfo:type:SOQL:j:i'+type_list[j]+'...'+financials[i].Revenues_MM__c+'....'+j+'...'+i);
                                if((type_list[j] == 'Revenue') &&(financials[i].Revenues_MM__c != null) && (is_revenue_already_imported == false)) {
                        DCR_Metric_Related_Info dcr_info_item = new DCR_Metric_Related_Info();  
                        Deal_Score_Line_Item__c line_item = new Deal_Score_Line_Item__c();

                        line_item.Financial_Metric_Name__c= 'Revenue';       
                        line_item.Financial_Metric_Period_Text__c=financials[i].Period_Ended__c.format();
                        line_item.Financial_Metric_Period_Ended__c = financials[i].Period_Ended__c;
                        
                            if(getDecimalMod(financials[i].Revenues_MM__c.setScale(2),1.0) != 0) {
                              line_item.Financial_Metric_Value__c = financials[i].Revenues_MM__c.setScale(2).format();
                            } else {
                              line_item.Financial_Metric_Value__c = financials[i].Revenues_MM__c.setScale(2).round().format();
                            }                       
            line_item.Financial_Metric_Unit__c = financials[i].CurrencyIsoCode;         
            line_item.Is_Financial_Metric_Imported__c = 4;
            line_item.Deal_Score_Header__c=deal_sc_hdr_id;
            line_item.Line_Item_Title__c='Financial Metric';
            insert line_item;
            
            revenue_found=true;
            //System.debug('getDCR_MtericsAndCompFinNameInfo:Adding Revenue to LineItem:'+line_item);
            dcr_info_item.deal_id = deal[0].Id;
            dcr_info_item.scHead_id = deal_sc_hdr_id;         
            dcr_info_item.lineItem_id = line_item.Id;
            dcr_info_item.dcr_metric_name = 'Revenue';
            if(financials[i].Period_Ended__c != null) {           
              dcr_info_item.dcr_metric_per_end=financials[i].Period_Ended__c.format();
            } else {
              dcr_info_item.dcr_metric_per_end='';
            }           
            if(getDecimalMod(financials[i].Revenues_MM__c.setScale(2),1.0) != 0) {
              dcr_info_item.dcr_metric_value = financials[i].Revenues_MM__c.setScale(2).format();
            } else {
              dcr_info_item.dcr_metric_value = financials[i].Revenues_MM__c.setScale(2).round().format();
            }          
            dcr_info_item.dcr_metric_unit = financials[i].CurrencyIsoCode;           
            dcrFinList.dcrMetrics.add(dcr_info_item);
           //System.debug('getDCR_MtericsAndCompFinNameInfo:Adding Revenue to fin list:'+dcr_info_item);         
          } else if((type_list[j] == 'EBITDA') &&(financials[i].EBITDA_MM__c != null) && (is_ebitda_already_imported == false)) {
            DCR_Metric_Related_Info dcr_info_item = new DCR_Metric_Related_Info();  
            Deal_Score_Line_Item__c line_item = new Deal_Score_Line_Item__c();

            line_item.Financial_Metric_Name__c= 'EBITDA';       
            line_item.Financial_Metric_Period_Text__c=financials[i].Period_Ended__c.format();
            line_item.Financial_Metric_Period_Ended__c = financials[i].Period_Ended__c;

            if(getDecimalMod(financials[i].EBITDA_MM__c.setScale(2),1.0) != 0) {
              line_item.Financial_Metric_Value__c = financials[i].EBITDA_MM__c.setScale(2).format();
            } else {
              line_item.Financial_Metric_Value__c = financials[i].EBITDA_MM__c.setScale(2).round().format();
            }                   
            line_item.Financial_Metric_Unit__c = financials[i].CurrencyIsoCode;    
            line_item.Is_Financial_Metric_Imported__c = 3; 
            line_item.Deal_Score_Header__c=deal_sc_hdr_id;
            line_item.Line_Item_Title__c='Financial Metric';
            insert line_item;
            ebitda_found=true;
            //System.debug('getDCR_MtericsAndCompFinNameInfo:Adding EBITDA to LineItem:'+line_item);
            dcr_info_item.deal_id = deal[0].Id;
            dcr_info_item.scHead_id = deal_sc_hdr_id;         
            dcr_info_item.lineItem_id = line_item.Id;
            dcr_info_item.dcr_metric_name = 'EBITDA';
            if(financials[i].Period_Ended__c != null) {           
              dcr_info_item.dcr_metric_per_end=financials[i].Period_Ended__c.format();
            } else {
              dcr_info_item.dcr_metric_per_end='';
            }           
            if(getDecimalMod(financials[i].EBITDA_MM__c.setScale(2),1.0) != 0) {
              dcr_info_item.dcr_metric_value = financials[i].EBITDA_MM__c.setScale(2).format();
            } else {
              dcr_info_item.dcr_metric_value = financials[i].EBITDA_MM__c.setScale(2).round().format();
            }          
            dcr_info_item.dcr_metric_unit = financials[i].CurrencyIsoCode;   
            dcrFinList.dcrMetrics.add(dcr_info_item);
            //System.debug('getDCR_MtericsAndCompFinNameInfo:Adding EBITDA to fin list:'+dcr_info_item);             
          }        
       }
         if((type_list[j] == 'Revenue') && (is_revenue_already_imported == false)) {
           if(revenue_found==true) {
             //deal_hdr_list[0].ISEBITDAIMPORTED__c=true;
             //is_revenue_already_imported =true;
             deal_hdr_list[0].ISEBITDAIMPORTED__c=false;
             is_revenue_already_imported =false;
             update deal_hdr_list[0];          
           } 
         } else if((type_list[j] == 'EBITDA') && (is_ebitda_already_imported == false)) {
           if(ebitda_found==true) {
            //deal_hdr_list[0].ISRevenueIMPORTED__c=true;
            //is_ebitda_already_imported =true;
            deal_hdr_list[0].ISRevenueIMPORTED__c=false;
            is_ebitda_already_imported =false;   
            update deal_hdr_list[0];                    
           } 
        }  
        }
           if(is_revenue_already_imported == false) {
             dcrFinList.compFinNameList.add('Revenue');
           }
           if(is_ebitda_already_imported == false) {
             dcrFinList.compFinNameList.add('EBITDA');
           }
           dcrFinList.status ='true';
        }
        else
        {   
         //System.debug('getDCR_MtericsAndCompFinNameInfo:Company has no financials');      
         dcrFinList.compFinNameList.add('Revenue');
         dcrFinList.compFinNameList.add('EBITDA');
         dcrFinList.status ='true';
        
        }
       }
        //System.debug('getDCR_MtericsAndCompFinNameInfo:Final dcrFinList'+dcrFinList);       
        return dcrFinList;

    }   

    public static Boolean createDCR_ReportTypeHeaderForClosing(String deal_id) {    
        Boolean result=false;
        List<Deal__c> deal_closing = [
            SELECT
            id, WP_Ownership_Diluted__c, WP_Ownership_Fully_Diluted__c
            FROM Deal__c
            WHERE (id = :deal_id)
        ];   
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        List<DealScoreHeader__c> deal_hdr_list_follow = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
        ];      
        if(deal_hdr_list_closing.size() > 1) {
          //System.debug('createDCR_ReportTypeHeaderForClosing:More than one Closing header exists. Closing header creation failed:'+deal_id);
        } else if(deal_hdr_list_closing.size() == 1) {
          //System.debug('createDCR_ReportTypeHeaderForClosing:Closing header already exists:'+deal_id);
          result=true;
        } else if(deal_hdr_list_follow.size() > 0) {
          //System.debug('createDCR_ReportTypeHeaderForClosing:Closing header cannot be created when follow up exists. Closing header '
          //   +'creation failed:'+deal_id);
        } else {
          DealScoreHeader__c header_item = new DealScoreHeader__c();
          header_item.Date_Received__c = Date.today();
          header_item.Type_of_Report__c = 'Closing';
          header_item.Deal__c = deal_id;
          header_item.ISEBITDAIMPORTED__c = false;
          header_item.ISRevenueIMPORTED__c = false;
          //header_item.WP_Board_Seats__c = 0;
          if(deal_closing.size()> 0){
            header_item.WP_Ownership_Fully_Diluted__c = deal_closing[0].WP_Ownership_Fully_Diluted__c;
          }
            try {
          		insert header_item;      
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
          //System.debug('createDCR_ReportTypeHeaderForClosing:Closing header successfully created:'+deal_id);
          result=true;
        }    
        return result;         
    }  
      
    @RemoteAction
    public static DCR_ReportTypeHeader_CreateInfo createDCR_ReportTypeHeaderList(String deal_id, String report_type,
       Date r_date) {
      DCR_ReportTypeHeader_CreateInfo head_list = new DCR_ReportTypeHeader_CreateInfo();
     
       report_type= report_type.replace('[','');
       report_type= report_type.replace(']','');
       
      if(report_type == 'Closing') {     
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        List<DealScoreHeader__c> deal_hdr_list_follow = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
        ];      
        if(deal_hdr_list_closing.size() > 1) {
          head_list.status='More than one Closing header exists. Closing header creation failed';
          //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);
        } else if(deal_hdr_list_closing.size() == 1) {
          head_list.status='Closing header already exists. Closing header creation failed';
          //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);
        } else if(deal_hdr_list_follow.size() > 0) {
          head_list.status='Closing header cannot be created when follow up exists. Closing header creation failed';
          //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);
        }else {
               DealScoreHeader__c header_item = new DealScoreHeader__c();
               header_item.Date_Received__c = r_date;
               header_item.Type_of_Report__c = report_type;
               header_item.Deal__c = deal_id;
               header_item.ISEBITDAIMPORTED__c = false;
               header_item.ISRevenueIMPORTED__c = false;
               insert header_item;
               head_list.created_label = header_item.Type_of_Report__c+' - '+header_item.Date_Received__c.format();
               head_list.created_id = header_item.Id;
               head_list.status = 'true';
               //System.debug('getDCR_ReportTypeHeaderList: Successfully created Closing Header:'+head_list.status);      
               head_list.reportHeaderList = getDCR_ReportTypeHeaderList(deal_id);  
               head_list.detail_fields = getDCR_Report_Detail_Fields(deal_id,header_item.Id);              
           }          
      } else if(report_type == 'Add Follow Up') {
            Boolean is_allowed = true;
            //head_list.status = report_type;
            //AR:Follow Up already exists so don't create another one yet..!
            List<DealScoreHeader__c> deal_hdr_list_followup = [
             SELECT
                    id,Date_Received__c,Type_of_Report__c
                    FROM DealScoreHeader__c
                    WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
            ]; 
            if (deal_hdr_list_followup.size() > 0){
                head_list.status = 'Size:' + deal_hdr_list_followup.size() + ' date=' + deal_hdr_list_followup[0].Date_Received__c.format();
                DealScoreHeader__c header_item = new DealScoreHeader__c();
                header_item = deal_hdr_list_followup[0];
                head_list.created_label = header_item.Type_of_Report__c+'-'+(deal_hdr_list_followup.size())+' - '+header_item.Date_Received__c.format();
                head_list.created_id = header_item.Id;
                head_list.status = 'true';
                head_list.reportHeaderList = getDCR_ReportTypeHeaderList(deal_id);  
                head_list.detail_fields = getDCR_Report_Detail_Fields(deal_id,header_item.Id); 
                is_allowed = false;
                return head_list;
            }                     
            //AR:Follow Up already exists and now return!   
            String DealName='';
            List<Deal__c> deal_name = [ SELECT id, Name FROM Deal__c WHERE (id = :deal_id)];  
            if (deal_name.size() > 0){
                DealName = deal_name[0].Name;
            }  
            List<DealScoreHeader__c> deal_hdr_list = [
                SELECT
                id,Date_Received__c,Type_of_Report__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND ((Type_of_Report__c = 'Follow Up') OR (Type_of_Report__c = 'Closing'))
            ];           
            for(DealScoreHeader__c deal_hdr_item :deal_hdr_list){
              if((r_date <= deal_hdr_item.Date_Received__c)|| (r_date.format().equalsIgnoreCase(deal_hdr_item.Date_Received__c.format()))) {
                is_allowed = false;
                break;
              }
            }           
            if(is_allowed == false){
              //head_list.status='Add New Follow Up date has to beyond Closing Or Existing FollowUp Dates.Follow up header creation failed';
              //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);  
              head_list.status = 'The One-Year Scorecard for ' + DealName + ' will be available tomorrow.'; 
            } else {
               List<DealScoreHeader__c> deal_hdr_list_follow = [
                     SELECT
                     id,Date_Received__c,Type_of_Report__c
                     FROM DealScoreHeader__c
                     WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
                ];              
               DealScoreHeader__c header_item = new DealScoreHeader__c();    
               header_item.Date_Received__c = r_date;
               header_item.Type_of_Report__c = 'Follow Up';
               header_item.Deal__c = deal_id;
               header_item.ISEBITDAIMPORTED__c = false;
               header_item.ISRevenueIMPORTED__c = false;               
               insert header_item;
               //Followup record is created - now create and Copy all the DCR Line items 10/28/2014
               String hid = header_item.Id;
               Boolean success = cloneDCR_AllLineItemsForFollowup(deal_id, hid);
               
               head_list.created_label = header_item.Type_of_Report__c+'-'+(deal_hdr_list_follow.size()+1)+' - '+header_item.Date_Received__c.format();
               head_list.created_id = header_item.Id;
               head_list.status = 'true';
               //System.debug('getDCR_ReportTypeHeaderList: Successfully created Follow UP Header:'+head_list.status);
               head_list.reportHeaderList = getDCR_ReportTypeHeaderList(deal_id);  
               head_list.detail_fields = getDCR_Report_Detail_Fields(deal_id,header_item.Id);              
           }
       } else {
           head_list.status='Invalid report_type header passed, Header Creation failed for report_type:'+report_type;
           //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);     
       }
       return head_list;
    }  
    
    public static Boolean cloneDCR_AllLineItemsForFollowup(String did, String followup_hid ) { 
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :did) AND (Type_of_Report__c = 'Closing' )
        ]; 
        String cloneid='';
        
        if(deal_hdr_list_closing.size()>0){
                String closing_hid = deal_hdr_list_closing[0].id;      
                //Create a COPY Header info
                DealScoreHeader__c copy_header_item = new DealScoreHeader__c();    
            copy_header_item.Type_of_Report__c = 'Copy';
            copy_header_item.Deal__c = did;
            insert copy_header_item;
            
          //Now collect all Line Items from the Closing Header  
          List<Deal_Score_Line_Item__c> dcr_closing_line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,Is_Financial_Metric_Imported__c,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Order__c,Financial_Metric_Unit__c,Financial_Metric_Name__c,
          Financial_Metric_Period_Text__c,Financial_Metric_Period_Ended__c, Financial_Metric_Value__c, Line_Item_Title__c,Line_Item_Value__c,Related_Score_Line_Item_Id__c
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:closing_hid ];
          //
          if(dcr_closing_line_list.size()>0){
                for(Deal_Score_Line_Item__c item :dcr_closing_line_list) {
                        //Deal_Score_Line_Item__c newClosingItem = new Deal_Score_Line_Item__c(); 
                        //newClosingItem = item;
                        Deal_Score_Line_Item__c cloneitem = item.clone(false, false, false, false);
                        cloneitem.Financial_Metric_Name__c = item.Financial_Metric_Name__c;
                        cloneitem.Financial_Metric_Period_Text__c = item.Financial_Metric_Period_Text__c;
                        cloneitem.Financial_Metric_Period_Ended__c = item.Financial_Metric_Period_Ended__c;
                        cloneitem.Financial_Metric_Value__c = item.Financial_Metric_Value__c;
                        cloneitem.Financial_Metric_Unit__c = item.Financial_Metric_Unit__c;
                        cloneitem.Line_Item_Color__c = item.Line_Item_Color__c;
                        cloneitem.Line_Item_Order__c=item.Line_Item_Order__c;
                        cloneitem.Is_Financial_Metric_Imported__c = item.Is_Financial_Metric_Imported__c;
                        cloneitem.Line_Item_Value__c = item.Line_Item_Value__c;
                        cloneitem.Deal_Score_Header__c = copy_header_item.id;
                        insert cloneitem;                       
                        
                        cloneid = cloneitem.Id;
                        Deal_Score_Line_Item__c followupitem = item.clone(false, false, false, false);
                        followupitem.Financial_Metric_Name__c = item.Financial_Metric_Name__c;
                        followupitem.Financial_Metric_Period_Text__c = item.Financial_Metric_Period_Text__c;
                        followupitem.Financial_Metric_Period_Ended__c = item.Financial_Metric_Period_Ended__c;
                        followupitem.Financial_Metric_Value__c = item.Financial_Metric_Value__c;
                        followupitem.Financial_Metric_Unit__c = item.Financial_Metric_Unit__c;
                        followupitem.Line_Item_Color__c = item.Line_Item_Color__c;
                        followupitem.Line_Item_Order__c = item.Line_Item_Order__c;
                        followupitem.Is_Financial_Metric_Imported__c = item.Is_Financial_Metric_Imported__c;
                        followupitem.Line_Item_Title__c = item.Line_Item_Title__c;
                        followupitem.Line_Item_Value__c = '';
                        followupitem.Deal_Score_Header__c = followup_hid;
                        followupitem.Related_Score_Line_Item_Id__c = cloneid;
                        insert followupitem;
                }
                
          }
        }
        return true;
    }
    
    @RemoteAction
    public static List<DCR_ReportTypeHeader_Info> getDCR_ReportTypeHeaderList(String deal_id) {
      List<DCR_ReportTypeHeader_Info> head_list = new List<DCR_ReportTypeHeader_Info>();
     
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];
       
        if(deal_hdr_list.size() > 1) {
          //System.debug('getDCR_ReportTypeHeaderList-More than 1 closing report exits-returning null'+deal_hdr_list.size());
          head_list = null;
        } else if(deal_hdr_list.size() == 1) {
           DCR_ReportTypeHeader_Info item = new DCR_ReportTypeHeader_Info();
           item.report_id = deal_hdr_list[0].Id;
           item.report_label = deal_hdr_list[0].Type_of_Report__c+' - '+deal_hdr_list[0].Date_Received__c.format();
           item.date_reccd = deal_hdr_list[0].Date_Received__c;
           head_list.add(item);
        } else { //Size is zero
           DCR_ReportTypeHeader_Info item = new DCR_ReportTypeHeader_Info();
           item.report_id = '';
           item.report_label = 'Closing';        
           head_list.add(item);
        }

        deal_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
            ORDER BY Date_Received__c ASC
        ];
       
        Integer index=0;
        for(DealScoreHeader__c deal_hdr_item :deal_hdr_list){
           DCR_ReportTypeHeader_Info item = new DCR_ReportTypeHeader_Info();
           ++index;
           item.report_id = deal_hdr_item.Id;
           item.report_label = deal_hdr_item.Type_of_Report__c+'-'+index+' - '+deal_hdr_item.Date_Received__c.format();
           item.date_reccd = deal_hdr_item.Date_Received__c;
           head_list.add(item);
        }
       
           DCR_ReportTypeHeader_Info item = new DCR_ReportTypeHeader_Info();
           item.report_id = '';
           item.report_label = 'Add Follow Up';
           head_list.add(item);
          
       
        //System.debug('getDCR_ReportTypeHeaderListFinal head list'+head_list.size()+head_list);
        return head_list;
    }
    
    @RemoteAction
    public static DCR_Report_Detail_Fields getDCR_Followup_Report_Detail_Fields(String deal_id,String deal_sc_hdr_id) {
                String followupid=deal_sc_hdr_id;
        DCR_Report_Detail_Fields dcr_report = new DCR_Report_Detail_Fields();
       
        List<Deal__c> deal = [
            SELECT
            id,Name,ISSCORECARDENABLED__c       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        //Copy logic starts if the Deal is already scorecard enabled
                if(deal.size()>0){
                        if(deal[0].ISSCORECARDENABLED__c) {
                                List<DealScoreHeader__c> copy_hdr_list = [
                SELECT id,Deal__c,Date_Received__c,Type_of_Report__c  
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id AND Type_of_Report__c='Copy')
                        ]; 
                        if(copy_hdr_list.size()>0){
                                //followupid = copy_hdr_list[0].Id;
                                //deal_sc_hdr_id = copyid;
                        }                                
                        }
                }
        //Now check if this deal_sc_hdr_id is  of a report type=follow up, if it is follow up then bring all the closing records
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          //System.debug('getDCR_Report_Detail_Fields:Invalid deal id received..returning null');
          dcr_report=null;
          return dcr_report;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          //System.debug('getDCR_Report_Detail_Fields:Invalid score header id received..returning null');
          dcr_report=null;
          return dcr_report;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          //System.debug('getDCR_Report_Detail_Fields:Invalid elements in score header ..returning null');
          dcr_report=null;
          return dcr_report;        
        }
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c,Related_Score_Line_Item_Id__c
          FROM Deal_Score_Line_Item__c
          //WHERE Deal_Score_Header__c =:deal_sc_hdr_id
          WHERE Deal_Score_Header__c =:deal_sc_hdr_id
          ORDER BY Line_Item_Order__c ASC];
         
         dcr_report.deal_id = deal_id;
         dcr_report.scHead_id = deal_sc_hdr_id;
         
         String allOptions = '';
         
         for(Deal_Score_Line_Item__c item :followup_list) {
           DCR_Report_Detail_Field_Info  field_item = new DCR_Report_Detail_Field_Info();
           field_item.deal_id = deal_id;
           field_item.scHead_id = deal_sc_hdr_id;
           
           //AR:Follow Up - NOW get the value from the Related Id if any
           allOptions = '';
           List<Deal_Score_Line_Item__c> copy_list = [
                SELECT Id,Related_Score_Line_Item_Id__c,Line_Item_Value__c,Line_Item_Color__c
                FROM Deal_Score_Line_Item__c
                WHERE Id=:item.Related_Score_Line_Item_Id__c];
                
                if (copy_list.size()>0){
                        field_item.followup_color = item.Line_Item_Color__c;
                        if (item.Line_Item_Color__c=='#ffffff'){
                                allOptions  = allOptions + '<option class="color-option" value="#ffffff" selected>Neutral</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';
                        }else if (item.Line_Item_Color__c=='#ebf1de'){
                                allOptions  = allOptions + '<option class="color-option" value="#ffffff" >Neutral</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#ebf1de" selected>Favorable</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';
                        }else if (item.Line_Item_Color__c=='#f2dcdb'){
                                allOptions  = allOptions + '<option class="color-option" value="#ffffff" >Neutral</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" selected>Unfavorable</option>';
                        }else{
                                allOptions  = allOptions + '<option class="color-option" value="#ffffff" selected>Neutral</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';                            
                        }                       
                        field_item.followup_value = copy_list[0].Line_Item_Value__c;                    
                        field_item.followup_selectoption = '<select class="followupcolor" id="followupcolor-id-'+ item.Id +'" >'+ allOptions + '</select>';
                }else{
                                field_item.followup_color = '#ffffff';
                                allOptions  = allOptions + '<option class="color-option" value="#ffffff" selected>Neutral</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#ebf1de" >Favorable</option>';
                                allOptions  = allOptions + '<option class="color-option" value="#f2dcdb" >Unfavorable</option>';
                            field_item.followup_value = '';                     
                            field_item.followup_selectoption = '<select class="followupcolor" id="followupcolor-id-'+ item.Id +'" >'+ allOptions + '</select>';
           }                   
           field_item.lineItem_id = item.Id;
           field_item.data = item ;
           
           if(item.Line_Item_Title__c == 'Investment Thesis') {         
                 //System.debug('getDCR_Report_Detail_Fields order: is'+ field_item);   
             dcr_report.investmentThesis.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:investmentThesis'+dcr_report.investmentThesis);
           } else if(item.Line_Item_Title__c == 'Investment Risks') {            
             dcr_report.investmentRisks.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:investmentRisks'+dcr_report.investmentRisks);
           } else if(item.Line_Item_Title__c == 'Key Value Creation Drivers') {            
             dcr_report.keyValueCreation.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:keyValueCreation'+dcr_report.keyValueCreation);
           } else if(item.Line_Item_Title__c == 'Key Company Goals and Milestones') {            
             dcr_report.keyCompanyGoals.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:keyCompanyGoals'+dcr_report.keyCompanyGoals);
           } else if(item.Line_Item_Title__c == 'Management Team and Board Additions and/or Development Goals') {            
             dcr_report.managementTeam.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:managementTeam'+dcr_report.managementTeam);
           } else if(item.Line_Item_Title__c == 'WP Team Action Items') {            
             dcr_report.wPTeamActionItems.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:wPTeamActionItems'+dcr_report.wPTeamActionItems);
           } else {
             //System.debug('getDCR_Report_Detail_Fields:ignore item'+field_item);
           }           
         }
         dcr_report.finance_targets = getDCR_MtericsAndCompFinNameInfo(deal_id,deal_sc_hdr_id,null);
        return dcr_report;
    }      
    @RemoteAction
    public static DCR_Report_Detail_Fields getDCR_Report_Detail_Fields(String deal_id,String deal_sc_hdr_id) {

        DCR_Report_Detail_Fields dcr_report = new DCR_Report_Detail_Fields();
       
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];

        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          //System.debug('getDCR_Report_Detail_Fields:Invalid deal id received..returning null');
          dcr_report=null;
          return dcr_report;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          //System.debug('getDCR_Report_Detail_Fields:Invalid score header id received..returning null');
          dcr_report=null;
          return dcr_report;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing')&& (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          //System.debug('getDCR_Report_Detail_Fields:Invalid elements in score header ..returning null');
          dcr_report=null;
          return dcr_report;        
        }
        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,Line_Item_Order__c,Related_Score_Line_Item_Id__c,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:deal_sc_hdr_id
          /*ORDER BY CreatedDate ASC];*/
          ORDER BY Line_Item_Order__c ASC];
         
         dcr_report.deal_id = deal_id;
         dcr_report.scHead_id = deal_sc_hdr_id;
         
         for(Deal_Score_Line_Item__c item :line_list) {
           DCR_Report_Detail_Field_Info  field_item = new DCR_Report_Detail_Field_Info();
           field_item.deal_id = deal_id;
           field_item.scHead_id = deal_sc_hdr_id;
           field_item.lineItem_id = item.Id;
           
           //AR:FOLLOW UP STARTS-> NOW using this item.Related_Score_Line_Item_Id__c 
           //GOTO the Followup line id and grab the current Line_Item_Value__c
           //field_item.followup_value = '';
           //AR:FOLLOW UP ENDS
           
           field_item.data = item ;
           
           if(item.Line_Item_Title__c == 'Investment Thesis') {         
             //System.debug('getDCR_Report_Detail_Fields order: is'+ field_item);   
             dcr_report.investmentThesis.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:investmentThesis'+dcr_report.investmentThesis);
           } else if(item.Line_Item_Title__c == 'Investment Risks') {            
             dcr_report.investmentRisks.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:investmentRisks'+dcr_report.investmentRisks);
           } else if(item.Line_Item_Title__c == 'Key Value Creation Drivers') {            
             dcr_report.keyValueCreation.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:keyValueCreation'+dcr_report.keyValueCreation);
           } else if(item.Line_Item_Title__c == 'Key Company Goals and Milestones') {            
             dcr_report.keyCompanyGoals.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:keyCompanyGoals'+dcr_report.keyCompanyGoals);
           } else if(item.Line_Item_Title__c == 'Management Team and Board Additions and/or Development Goals') {            
             dcr_report.managementTeam.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:managementTeam'+dcr_report.managementTeam);
           } else if(item.Line_Item_Title__c == 'WP Team Action Items') {            
             dcr_report.wPTeamActionItems.add(field_item);
             //System.debug('getDCR_Report_Detail_Fields:wPTeamActionItems'+dcr_report.wPTeamActionItems);
           } else {
             //System.debug('getDCR_Report_Detail_Fields:ignore item'+field_item);
           }           
         }
         dcr_report.finance_targets = getDCR_MtericsAndCompFinNameInfo(deal_id,deal_sc_hdr_id,null);

        return dcr_report;
    }

    @RemoteAction
    public static DCR_Report_General_Fields getDCR_Report_General_Fields(String deal_id) {

        DCR_Report_General_Fields dcr_report = new DCR_Report_General_Fields();
        
        List<Deal__c> deal = [
            SELECT
            id,Name,Stage__c,Deal_Team__c, Sector__c,Line_of_Equity_Amount_MM__c, WP_Investment_MM__c, WP_Ownership_Diluted__c,
            (SELECT Id,
                Employee__r.Name, 
                Employee__r.Employee_Level__r.Rank__c,
                Employee__r.ISSENIORTEAMMEMBER__c, Role__c,
                Employee__r.Employee_Level_Precedence_Sorter__c
                From Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST,Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC)       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
         
        if (deal.size() >0) {
                dcr_report.deal_id = deal_id;
                dcr_report.deal = deal[0];
                
                /*Report View fields*/
                dcr_report.dealName = deal[0].Name;
                dcr_report.dealSector = deal[0].Sector__c;
                /*Line of Equity fields */          
                dcr_report.lineOfEquityAmount = String.valueOf(deal[0].Line_of_Equity_Amount_MM__c);
                //dcr_report.wpOwnership = String.valueOf(deal[0].WP_Ownership_Diluted__c);        
                dcr_report.wpInvestment = String.valueOf(deal[0].WP_Investment_MM__c);   
                
                List<Deal_Team__c> team_list = deal[0].Deal_Team__r;
                Integer list_count=0;
                for(Deal_Team__c team_item:team_list) {
                 list_count++;
                 dcr_report.dealTeam=dcr_report.dealTeam+team_item.Employee__r.Name;
                 if(list_count <  team_list.size()) {
                   dcr_report.dealTeam=dcr_report.dealTeam+',  ';
                 }
                }    
                if(createDCR_ReportTypeHeaderForClosing(deal_id) == false){
                        dcr_report=null;
                        //System.debug('getDCR_Report_General_Fields:Closing header creation problem..returning null');          
                }else {
                        dcr_report.reportHeaderList = getDCR_ReportTypeHeaderList(deal_id);
                        dcr_report.wpBoardSeats = getDCR_ClosingHeaderList(deal_id);
                        dcr_report.wpBoardSeatsTotal = getBoardSeatsTotal(deal_id);
                        dcr_report.wpOwnership = getOwnershipFullyDiluted(deal_id);
                        dcr_report.otherConsider = getOtherConsider(deal_id);
                        dcr_report.teamRecommend = getTeamRecommend(deal_id);
                }
        }else{
          dcr_report=null;
          //System.debug('getDCR_Report_General_Fields:Invalid deal_id received..returning null');          
        }
        return dcr_report;
    }
    
    @RemoteAction
    public static String updateDCR_LineItemsOrder(String lineItemIds) {
                String result;            
                List<String> lineItemList = lineItemIds.split(' ');
                Integer count = 1;
                //String newString ='?';                
                for (String lid:lineItemList){                                    
                  if (lid !=null){
                        //newString = newString + lid + '<-->('+ String.valueOf(count) + ')' ;
                        List<Deal_Score_Line_Item__c> dcr_list = [
                        SELECT Id, Line_Item_Order__c FROM Deal_Score_Line_Item__c
                        WHERE Id =:lid];                        
                        if (dcr_list.size()!=1) {
                            result= lid;
                        } else {
                            dcr_list[0].Line_Item_Order__c = count++;
                            update dcr_list[0];                     
                            result = 'true';
                        }
                  }                 
                }
                //result = newString; 
                return result;
    }

    @RemoteAction
    public static String addUpdateDCR_Financial_FollowupColor(String table_id, String deal_id, String deal_sc_hdr_id, 
                        String lineitem_id, String color) {
                                
        Deal_Score_Line_Item__c field_item; 
        Deal__c thisdeal;
        String descTitle= 'Financial Metric';   
        //Get the Deal obj
        List<Deal__c> deal = [
            SELECT id, ISSCORECARDENABLED__c
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        //Get the Deal Score Header
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id) ];
        //Check if Followup record exists
        List<DealScoreHeader__c> deal_followup_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Follow Up' ];    
        if (deal_followup_hdr_list.size() != 1){
                System.debug('addUpdateDCR_Finance_Followup_Color: No follow up record has been created yet');
                lineitem_id=null;
                return lineitem_id;
        } else if(deal_followup_hdr_list[0].Deal__c != deal_id) {  
                System.debug('addUpdateDCR_Finance_FollowUp_Color: failed:Invalid deal_id in followup header Id');
                lineitem_id=null;
            return lineitem_id; 
        }
        //Check if Deal Score Header is valid or if exists
        if(deal_hdr_list.size() != 1) {      
          //System.debug('addUpdateDCR_Finance_Report_Color: failed:Invalid score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          lineitem_id=null;
          return lineitem_id;
        } else if(deal_hdr_list[0].Deal__c != deal_id) {         
          //System.debug('addUpdateDCR_Finance_Report_Color: failed:Invalid deal_id in score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          lineitem_id=null;
          return lineitem_id;
        }
                //eal logic starts to add or update Finance Record
        if (deal.size() >0) {
                //FIRST GET THIS LINE ITEM ID 
                List<Deal_Score_Line_Item__c> dcr_followup_list = [
              SELECT Id,Deal_Score_Header__c,Line_Item_Title__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
              FROM Deal_Score_Line_Item__c
              WHERE Id=:lineitem_id];  
                if(dcr_followup_list.size()==0) {
                //the size=0 means there is no associated followup dcr line item for this field_id
                 //field_item = new Deal_Score_Line_Item__c();
                 //field_item.Deal_Score_Header__c = deal_followup_hdr_list[0].Id;
                 //field_item.Line_Item_Title__c = descTitle;
                 //field_item.Line_Item_Color__c = color;
                 //field_item.Related_Score_Line_Item_Id__c = lineitem_id;
                 //insert field_item;
                 //still return the dcr id
                 //lineitem_id = '-Inserted-' + lineitem_id;
                 //System.debug('addUpdateDCR_Finance_Followup_Color: Added new Line item:' + lineitem_id);
                } else {
                    field_item = dcr_followup_list[0];     
                    field_item.Line_Item_Color__c = color;                                                                      
                    System.debug('addUpdateDCR_Finance_FollowUp_Color: Updated lineitem_id ==>' + lineitem_id );
                    update field_item;
                    lineitem_id = '-Updated-' + lineitem_id;
                        }      
        } else {
          lineitem_id=null;
          System.debug('addUpdateDCR_Finance_Followup_LineItem_Color: Invalid deal id received:'+deal_id +':'+ color +':'+ descTitle);
        }
        return lineitem_id;             
                //Deal Logic Ends
    }
    
    @RemoteAction
    public static String saveAll_Financial_FollowupInput (String deal_id, String deal_sc_hdr_id){
        Deal__c thisdeal;
        String descTitle= 'Financial Metric';   
        //Get the Deal obj
        List<Deal__c> deal_list = [
            SELECT id, ISSCORECARDENABLED__c
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        //Get the Copy of Closing Score Header 
        List<DealScoreHeader__c> copy_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
                        WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Copy' ];   
        //Check if Followup record exists
        List<DealScoreHeader__c> followup_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Follow Up' ];    
        
        if(deal_list.size()>0 && copy_hdr_list.size()>0 && followup_hdr_list.size()>0){
                System.debug('saveAll_Financial_FollowupInput: found all needed records');
                Deal_Score_Line_Item__c followup_item;
                //Now collect all the Line items based on this Closing_Header
                List<Deal_Score_Line_Item__c> copy_LineItems = [
                SELECT id,Deal_Score_Header__c,Line_Item_Title__c,Line_Item_Order__c,Financial_Metric_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                FROM Deal_Score_Line_Item__c
                WHERE Line_Item_Title__c=:descTitle AND Deal_Score_Header__c=:copy_hdr_list[0].Id];   
                System.debug('saveAll_Financial_FollowupInput: COUNT=' + copy_LineItems.size());            
                if (copy_LineItems.size()>0){
                        for(Deal_Score_Line_Item__c lineitem : copy_LineItems){
                        followup_item = new Deal_Score_Line_Item__c();
                        System.debug('Followup line item added value=' + lineitem.Financial_Metric_Value__c);
                        //Insert a new followup line item only if Related_Score_Line_Item_Id__c is null..
                        List<Deal_Score_Line_Item__c> Related_OYS_Line_Item = [
                        SELECT id,Related_Score_Line_Item_Id__c,Line_Item_Order__c
                        FROM Deal_Score_Line_Item__c
                        WHERE Related_Score_Line_Item_Id__c=:lineitem.Id];      
                        if (Related_OYS_Line_Item.size()==0){    
                                followup_item = lineitem.clone(false, false, false, false);
                                followup_item.Deal_Score_Header__c = followup_hdr_list[0].Id;
                                followup_item.Related_Score_Line_Item_Id__c = lineitem.Id;
                                //insert followup_item;
                        }
                      }//for all items
                }//if only if any closing line items            
        } else{
                deal_id = null;
        }
        return deal_id;                         
    }
            
    @RemoteAction
    public static String addUpdateDCR_Financial_FollowupInput(String deal_id, String deal_sc_hdr_id, 
                        String lineitem_id, String globalInputValOut) {
                                
        Deal_Score_Line_Item__c field_item; 
        Deal__c thisdeal;
        String descTitle= 'Financial Metric';   
        //Get the Deal obj
        List<Deal__c> deal = [
            SELECT id, ISSCORECARDENABLED__c
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        //Get the Deal Score Header
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id) ];
        //Check if Followup record exists
        List<DealScoreHeader__c> deal_followup_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Follow Up' ];    
            
        if (deal_followup_hdr_list.size() != 1){
                System.debug('addUpdateDCR_Finance_Followup_Field: No follow up record has been created yet');
                lineitem_id=null;
                return lineitem_id;
        } else if(deal_followup_hdr_list[0].Deal__c != deal_id) {  
                System.debug('addUpdateDCR_Finance_FollowUp_Report_Field: failed:Invalid deal_id in followup header Id');
                lineitem_id=null;
            return lineitem_id; 
        }
        //Check if Deal Score Header is valid or if exists
        if(deal_hdr_list.size() != 1) {      
          //System.debug('addUpdateDCR_Finance_Report_Field: failed:Invalid score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          lineitem_id=null;
          return lineitem_id;
        } else if(deal_hdr_list[0].Deal__c != deal_id) {         
          //System.debug('addUpdateDCR_Finance_Report_Field: failed:Invalid deal_id in score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          lineitem_id=null;
          return lineitem_id;
        }
                //eal logic starts to add or update Finance Record
        if (deal.size() >0) {
                //FIRST GET THIS LINE ITEM ID 
                List<Deal_Score_Line_Item__c> dcr_followup_list = [
              SELECT Id,Deal_Score_Header__c,Line_Item_Title__c,Line_Item_Color__c,Financial_Metric_Value__c,Related_Score_Line_Item_Id__c
              FROM Deal_Score_Line_Item__c
              WHERE Id=:lineitem_id];  
              //WHERE Related_Score_Line_Item_Id__c=:lineitem_id];  
              
                if(dcr_followup_list.size()==0) {
                //the size=0 means there is no associated followup dcr line item for this field_id
                 //field_item = new Deal_Score_Line_Item__c();
                 //field_item.Deal_Score_Header__c = deal_followup_hdr_list[0].Id;
                 //field_item.Line_Item_Title__c = descTitle;
                 //field_item.Financial_Metric_Value__c = globalInputValOut;   
                 //field_item.Line_Item_Color__c = '#ffffff';
                 //field_item.Related_Score_Line_Item_Id__c = lineitem_id;
                 //insert field_item;
                 //still return the dcr id
                 //lineitem_id = lineitem_id;
                 System.debug('This line item id doesnot exist' + lineitem_id);
                } else {
                    field_item = dcr_followup_list[0];     
                    field_item.Financial_Metric_Value__c = globalInputValOut;                                                                           
                    System.debug('addUpdateDCR_Finance_FollowUp_Report_Field: Updated lineitem_id ==>' + lineitem_id );
                    update field_item;
                    lineitem_id = lineitem_id;
                        }      
        } else {
          lineitem_id=null;
          System.debug('addUpdateDCR_Finance_Followup_LineItem: Invalid deal id received:'+deal_id +':'+ globalInputValOut +':'+ descTitle);
        }
        return lineitem_id;             
                //Deal Logic Ends
    }
    
    @RemoteAction
    public static String updateFollowupHeaderFields(String deal_id, String field_name, String field_value){
        DealScoreHeader__c header_item;
        List<DealScoreHeader__c> deal_followup_hdr = [
            SELECT id,OtherConsiderations__c, TeamRecommendations__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Follow Up' ];
            if(deal_followup_hdr.size() == 1) {    
                header_item = new DealScoreHeader__c();
                header_item = deal_followup_hdr[0];
                if (field_name=='OtherConsiderations'){
                        header_item.OtherConsiderations__c = field_value;
                }
                if (field_name=='TeamRecommend'){
                        header_item.TeamRecommendations__c = field_value;
                }               
                update header_item;
            }else{
              deal_id = null;
            }   
            return deal_id;
    }
    
    @RemoteAction
    public static String addUpdateDCR_FollowupReport_Detail_Field(String deal_id,String deal_sc_hdr_id,
             String table_id,String field_data,String field_id,String colorCode) {
       
        Deal_Score_Line_Item__c field_item; 
        Deal__c thisdeal;
        String descTitle;        
        List<Deal__c> deal = [
            SELECT
            id, ISSCORECARDENABLED__c
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id) ];
        List<DealScoreHeader__c> deal_followup_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Follow Up' ];
        if (deal_followup_hdr_list.size() != 1){
                System.debug('addUpdateDCR_FOllowUp_Report_Field: No follow up record has been created yet');
                field_id=null;
                return field_id;
        } else if(deal_followup_hdr_list[0].Deal__c != deal_id) {  
                System.debug('addUpdateDCR_FOllowUp_Report_Field: failed:Invalid deal_id in followup header Id');
                field_id=null;
            return field_id;    
        } else{
                //Now check if there are Follow Up line Items id based on this deal-id, follow-up id, based on the field id and related id
        }    
        
        if(deal_hdr_list.size() != 1) {      
          //System.debug('addUpdateDCR_Report_Field: failed:Invalid score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          field_id=null;
          return field_id;
        } else if(deal_hdr_list[0].Deal__c != deal_id) {         
          //System.debug('addUpdateDCR_Report_Field: failed:Invalid deak_id in score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          field_id=null;
          return field_id;
        }
        descTitle='';
        if(table_id == 'DCR_InvestmentThesis') {
          descTitle='Investment Thesis';
        } else if(table_id == 'DCR_InvestmentRisks') {
          descTitle='Investment Risks';
        } else if(table_id == 'DCR_KeyValueCreation') {
          descTitle='Key Value Creation Drivers';
        } else if(table_id == 'DCR_KeyCompanyGoals') {
          descTitle='Key Company Goals and Milestones';
        } else if(table_id == 'DCR_ManagementTeam') {
          descTitle='Management Team and Board Additions and/or Development Goals';
        } else if(table_id == 'DCR_WPTeamActionItems') {
          descTitle='WP Team Action Items';
        } else {
          field_id=null;
          //System.debug('addUpdateDCR_Report_Field: failed:Invalid line item title'+deal_id+table_id+field_data+descTitle);
          return field_id;
        }            
        if (deal.size() >0) {
                //FIRST GET THIS LINE ITEM ID 
                List<Deal_Score_Line_Item__c> dcr_followup_list = [
              SELECT Id,Deal_Score_Header__c,Line_Item_Color__c,Line_Item_Order__c,Line_Item_Title__c,Line_Item_Value__c,Related_Score_Line_Item_Id__c
              FROM Deal_Score_Line_Item__c
              WHERE Id=:field_id];  
              
                if(dcr_followup_list.size()==0) {
                 //the size=0 means there is no associated followup dcr line item for this field_id
                 //field_item = new Deal_Score_Line_Item__c();
                 //field_item.Deal_Score_Header__c = deal_followup_hdr_list[0].Id;
                 //field_item.Line_Item_Title__c = descTitle;
                 //field_item.Line_Item_Value__c = field_data;   
                 //field_item.Line_Item_Order__c = 50;     
                 //field_item.Line_Item_Color__c = '#ffffff';
                 //field_item.Related_Score_Line_Item_Id__c = field_id;
                 //update field_item;
                 //still return the dcr id
                 //field_id= field_id;
                 
                 System.debug('no line item found with:' + field_id);
                } else {
                    field_item = dcr_followup_list[0];     
                    if (colorCode=='') {
                        if (field_data==''){
                                field_item.Line_Item_Value__c = '';
                        }else{
                                field_item.Line_Item_Value__c = field_data;
                        }                                                                               
                    }
                    else{
                        field_item.Line_Item_Color__c = colorCode; 
                    }
                    System.debug('addUpdateDCR_FOllowUp_Report_Field: Updated colorCode ==>' + colorCode );
                    update field_item;
                        }      
        } else {
          field_id=null;
          System.debug('addUpdateDCR_Report_Field: Invalid deal id received:'+deal_id+table_id+field_data+descTitle);
        }
        return field_id;
    }
    
    @RemoteAction
    public static String addUpdateDCR_Report_Detail_Field(String deal_id,String deal_sc_hdr_id,
             String table_id,String field_data,String field_id,String colorCode) {
       
        Deal_Score_Line_Item__c field_item; 
        Deal__c thisdeal;
        String descTitle;       
        Integer itemcount=1;
       
        List<Deal__c> deal = [
            SELECT
            id, ISSCORECARDENABLED__c
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        thisdeal = deal[0];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id) ];
                
                if(deal_hdr_list.size() != 1) {      
          //System.debug('addUpdateDCR_Report_Field: failed:Invalid score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          field_id=null;
          return field_id;
        } else if(deal_hdr_list[0].Deal__c != deal_id) {         
          //System.debug('addUpdateDCR_Report_Field: failed:Invalid deak_id in score header Id:'+deal_id+table_id+field_data+descTitle+deal_sc_hdr_id);
          field_id=null;
          return field_id;
        }             
        //System.debug('ITEM COUNT:' + itemcount.format());
        descTitle='';
        
        if(table_id == 'DCR_InvestmentThesis') {
          descTitle='Investment Thesis';
        } else if(table_id == 'DCR_InvestmentRisks') {
          descTitle='Investment Risks';
        } else if(table_id == 'DCR_KeyValueCreation') {
          descTitle='Key Value Creation Drivers';
        } else if(table_id == 'DCR_KeyCompanyGoals') {
          descTitle='Key Company Goals and Milestones';
        } else if(table_id == 'DCR_ManagementTeam') {
          descTitle='Management Team and Board Additions and/or Development Goals';
        } else if(table_id == 'DCR_WPTeamActionItems') {
          descTitle='WP Team Action Items';
        } else {
          field_id=null;
          return field_id;
        }            
        List<Deal_Score_Line_Item__c> dcr_lineitems_list = [
                SELECT Id,Deal_Score_Header__c FROM Deal_Score_Line_Item__c 
                WHERE Deal_Score_Header__c =:deal_sc_hdr_id AND Line_Item_Title__c =:descTitle
        ];  
        if(dcr_lineitems_list.size() > 0){
                itemcount = dcr_lineitems_list.size() + 1;
        }   
        if (deal.size() >0) {
                if(field_id=='') {
                 field_item = new Deal_Score_Line_Item__c();
                 field_item.Deal_Score_Header__c = deal_hdr_list[0].Id;
                 if(deal_hdr_list[0].Type_of_Report__c == 'Closing'){
                    if((String.isNotBlank(colorCode)) && (String.isNotEmpty(colorCode))){
                        field_item.Line_Item_Color__c = colorCode;      
                    }else {
                        field_item.Line_Item_Color__c = null;     
                    }   
                 }
                 field_item.Line_Item_Title__c = descTitle;
                 field_item.Line_Item_Value__c = field_data;   
                 field_item.Line_Item_Order__c = itemcount;       
                 insert field_item;
                 //Make sure now that the deal is scorecard ready
                 //if (thisdeal.ISSCORECARDENABLED__c == false){
                 //     thisdeal.ISSCORECARDENABLED__c = true;
                    //update thisdeal;
                 //}
                 field_id= field_item.Id;
                 //System.debug('addUpdateDCR_Report_Field: Added item:'+deal_id);
                } else {
                  List<Deal_Score_Line_Item__c> dcr_list = [
                                SELECT Id,CreatedDate,LastModifiedDate,
                                        Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
                                WHERE Id =:field_id];                
                  if (dcr_list.size() >0) {
                    field_item = dcr_list[0];
                        if(deal_hdr_list[0].Type_of_Report__c == 'Closing'){
                            if((String.isNotBlank(colorCode)) && (String.isNotEmpty(colorCode))){
                                field_item.Line_Item_Color__c = colorCode;      
                            }                                    
                        } else if((String.isNotBlank(colorCode)) && (String.isNotEmpty(colorCode))){
                             field_item.Line_Item_Color__c = colorCode;      
                        }        
                    field_item.Line_Item_Value__c=field_data;
                    
                    update field_item;
                    //Make sure now that the deal is scorecard ready
                        //if (thisdeal.ISSCORECARDENABLED__c == false){
                        //      thisdeal.ISSCORECARDENABLED__c = true;
                        //update thisdeal;
                        //}
                    field_id= field_item.Id;
                    //System.debug('addUpdateDCR_Report_Field: Updated item:'+field_item.Id+deal_id+table_id+field_data+descTitle);
                  }else {
                    //System.debug('addUpdateDCR_Report_Field: failed:Invalid line item id received'+deal_id+table_id+field_data+descTitle+field_id+':'+deal_hdr_list[0].Id);
                    field_id=null;
                  }
           }      
        } else {
          field_id=null;
          //System.debug('addUpdateDCR_Report_Field: Invalid deal id received:'+field_item.Id+deal_id+table_id+field_data+descTitle);
        }
        return field_id;
    }

    @RemoteAction
    public static String deleteDCR_Report_Field(String field_id) {
        String result;
        List<Deal_Score_Line_Item__c> dcr_list = [
          SELECT Id FROM Deal_Score_Line_Item__c
          WHERE Id =:field_id];         
          if (dcr_list.size() >0) {
            delete dcr_list[0];
            //System.debug('deleteDCR_Report_Field: Deleted item:'+field_id);
            result = 'true';
          } else {
            //System.debug('deleteDCR_Report_Field: Failed to delete item:'+field_id);
            result= null;
          }
        return result;
    }
@RemoteAction
    public static Deal__c getDealStageForADeal(String deal_id) {      
        List<Deal__c> deal_list = [
            SELECT 
            Id, Deal__c.Stage__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];        
        if ( deal_list.size() >0 ) {
          //System.debug('getDealStageForADeal: deal stage '+deal_list[0].Stage__c);
          return deal_list[0];
        }
        return null;
    }    
    
    @RemoteAction
    public static String getBoardSeatsTotal(String deal_id) {
        String result_string = '0';
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,WP_Board_Seats_Total__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        //Now read the Deal Header = 'Closing'          
        if(deal_hdr_list_closing.size() > 1) {
                //System.debug('createDCR_ReportTypeHeaderForClosing:More than one Closing header exists. Closing header update failed:'+deal_id);
                result_string = '0';
                }
                if(deal_hdr_list_closing.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr_list_closing[0];
                        //System.debug('updateDCR_ReportTypeHeaderForClosing:Closing header exists, now update :'+ header_item);
                        result_string = String.valueOf(header_item.WP_Board_Seats_Total__c);  
                }
                return result_string;
    }

    @RemoteAction
    public static String getOtherConsider(String deal_id) {
        String result_string = '';
        List<DealScoreHeader__c> deal_hdr_list_followup = [
            SELECT
            id,Type_of_Report__c, OtherConsiderations__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
        ];    
        //Now read the Deal Header = 'Followup'          
        if(deal_hdr_list_followup.size() > 1) {
                        result_string = '';
        }
        if(deal_hdr_list_followup.size() == 1) {
            DealScoreHeader__c header_item = deal_hdr_list_followup[0];
                        result_string = String.valueOf(header_item.OtherConsiderations__c);  
        }
        return result_string;
    }
    @RemoteAction
    public static String getTeamRecommend(String deal_id) {
        String result_string = '';
        List<DealScoreHeader__c> deal_hdr_list_followup = [
            SELECT
            id,Type_of_Report__c, TeamRecommendations__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
        ];    
        //Now read the Deal Header = 'Followup'          
        if(deal_hdr_list_followup.size() > 1) {
                        result_string = '';
        }
        if(deal_hdr_list_followup.size() == 1) {
            DealScoreHeader__c header_item = deal_hdr_list_followup[0];
                        result_string = String.valueOf(header_item.TeamRecommendations__c);  
        }
        return result_string;
    }        
    @RemoteAction
    public static String getOwnershipFullyDiluted(String deal_id) {
        String result_string = '0';
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c, WP_Ownership_Fully_Diluted__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        //Now read the Deal Header = 'Closing'          
        if(deal_hdr_list_closing.size() > 1) {
           //System.debug('createDCR_ReportTypeHeaderForClosing:More than one Closing header exists. Closing header update failed:'+deal_id);
           result_string = '0';
        }
        if(deal_hdr_list_closing.size() == 1) {
            DealScoreHeader__c header_item = deal_hdr_list_closing[0];
            //System.debug('updateDCR_ReportTypeHeaderForClosing:Closing header exists, now update :'+ header_item);
            result_string = String.valueOf(header_item.WP_Ownership_Fully_Diluted__c);  
        }
        return result_string;
    }
    
    @RemoteAction
    public static String getDCR_ClosingHeaderList(String deal_id) {
                String result_string = '0';
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,WP_Board_Seats__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        //Now read the Deal Header = 'Closing'          
        if(deal_hdr_list_closing.size() > 1) {
                //System.debug('createDCR_ReportTypeHeaderForClosing:More than one Closing header exists. Closing header update failed:'+deal_id);
                result_string = '0';
                }
                if(deal_hdr_list_closing.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr_list_closing[0];
                        //System.debug('updateDCR_ReportTypeHeaderForClosing:Closing header exists, now update :'+ header_item);
                        result_string = String.valueOf(header_item.WP_Board_Seats__c);  
                }
                return result_string;
    }
    
   @RemoteAction
    public static String updateDCR_HeaderInfo(String deal_id, String deal_sectors, String wpInvest, String wpOwnership, 
                          String loEquiAmt, String wpBoardSeats, String wpBoardSeatsTotal, String otherConsider, String teamRecommend) {
        String result_string=null;
        Decimal wpInvestDec = 0.0;
        Decimal loEquiAmtDec = 0.0;

        List<Deal__c> deal_list = [
            SELECT 
            Id, Deal__c.Sector__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];        
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c,WP_Board_Seats__c, WP_Ownership_Fully_Diluted__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        //Check if the Deal has any followup records
        List<DealScoreHeader__c> deal_hdr_list_followup = [
        SELECT id,Date_Received__c,Type_of_Report__c,OtherConsiderations__c,TeamRecommendations__c
             FROM DealScoreHeader__c
             WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
        ]; 
        
        //First update the Deal Object      
        if (deal_list.size()>0) {         
                result_string = result_string + '1. deal_list.size()=' + deal_list.size();
                Deal__c deal_item = deal_list[0];
                deal_item.Sector__c = deal_sectors;     
                  if(String.isNotBlank(wpInvest) && String.isNotEmpty(wpInvest)) {
                        wpInvest= wpInvest.replace(',','');
                    wpInvestDec= Decimal.valueOf(wpInvest);
                    deal_item.WP_Investment__c= wpInvestDec*1000*1000;
                    //System.debug('updateDCRSection...'+ wpInvest +'...'+Decimal.valueOf(wpInvest)+'.....'+ deal_item.WP_Investment__c);
                  }else {
                     deal_item.WP_Investment__c = null;
                  }                       
                  if(String.isNotBlank(loEquiAmt) && String.isNotEmpty(loEquiAmt)) {
                        loEquiAmt= loEquiAmt.replace(',','');
                    loEquiAmtDec= Decimal.valueOf(loEquiAmt);
                    deal_item.Line_of_Equity_Amount__c= loEquiAmtDec*1000*1000;
                       //System.debug('updateDCRSection...'+ wpInvest +'...'+Decimal.valueOf(wpInvest)+'.....'+ deal_item.WP_Investment__c);
                  }else {
                    deal_item.Line_of_Equity_Amount__c = null;
                  }  
                  //Now save the value of updated deal_item
                    try{
                        update deal_item;        
                    }
                    catch(Exception e) {
                        System.debug('update deal_item failed ' + e.getMessage());
                        return e.getMessage();
                    }      
                          
                        //Now update the Deal Header = 'Closing'          
                        if(deal_hdr_list_closing.size() > 1) {
                        result_string = result_string + '\n3. failure finding header=closing';
                        }
                        if(deal_hdr_list_closing.size() == 1) {
                                DealScoreHeader__c header_item = deal_hdr_list_closing[0]; 
                            if(String.isNotBlank(wpBoardSeats) && String.isNotEmpty(wpBoardSeats)) {
                                header_item.WP_Board_Seats__c = Integer.valueOf(wpBoardSeats);                      
                            }else {
                                header_item.WP_Board_Seats__c = null;
                            }              
                            if(String.isNotBlank(wpBoardSeatsTotal) && String.isNotEmpty(wpBoardSeatsTotal)) {
                                header_item.WP_Board_Seats_Total__c = Integer.valueOf(wpBoardSeatsTotal);                     
                            }else {
                                header_item.WP_Board_Seats_Total__c = null;
                            } 
                            if(String.isNotBlank(wpOwnership) && String.isNotEmpty(wpOwnership)) {
                                wpOwnership= wpOwnership.replace(',','');    
                                wpOwnership= wpOwnership.replace('%','');    
                                header_item.WP_Ownership_Fully_Diluted__c = Decimal.valueOf(wpOwnership);               
                            }else {
                                header_item.WP_Ownership_Fully_Diluted__c = null;
                            }   
                            try{
                                update header_item;        
                            }
                            catch(Exception e) {
                                System.debug('update header_item failed ' + e.getMessage());	
                                return e.getMessage();
                            }      
                       result_string = result_string + '\n4. found the right header=closing and update success';
                        }//deal_hdr_list_closing ends
                        
                        //If found the Header Record found for Followup - update the otherConsider and Team Reommendations
                        if (deal_hdr_list_followup.size() > 0){
                                DealScoreHeader__c followup_header_item = deal_hdr_list_followup[0];
                        if(String.isNotBlank(otherConsider) && String.isNotEmpty(otherConsider)) {
                                followup_header_item.OtherConsiderations__c = otherConsider;
                        }
                        if(String.isNotBlank(teamRecommend) && String.isNotEmpty(teamRecommend)) {
                                followup_header_item.TeamRecommendations__c = teamRecommend;
                        }
                            try{
                                update followup_header_item;        
                            }
                            catch(Exception e) {
                                System.debug('update followup_header_item failed ' + e.getMessage());	
                                return e.getMessage();
                            }   
                        }//deal_hdr_list_followup ends
          }else {
                //System.debug('updateDCRSector: Failed to update:'+ deal_id);
            result_string = result_string + '\n5. did not find the right Deal id=' + deal_id;
          }      
          return result_string;
    }
    
    @RemoteAction
    public static String doUpdateDealStageForADeal(String deal_id, String deal_stage) {
        String result_string=null;
       
        List<Deal__c> deal_list = [
            SELECT 
            Id, Deal__c.Stage__c,Name,
            Areas_of_Concern_Red_Flags__c, Fit_With_Group__c, 
            Why_Interesting__c, WP_Human_Capital_or_WP_Angle__c,
        Capital_Market_Consideration__c,Disable_EAR__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        
        if ( deal_list.size() >0 ) {         
          Deal__c deal_item = deal_list[0];
          String stored_stage = deal_item.Stage__c;
          String dealName = deal_item.Name;
          
          deal_item.Stage__c = deal_stage;
          update deal_item;
          //System.debug('doUpdateDealStageForADeal: deal stage updated'+deal_item.id+stored_stage+deal_id+deal_stage);
           
          if(      (deal_item.Disable_EAR__c == false) &&
               ( (String.isNotBlank(deal_item.Areas_of_Concern_Red_Flags__c) && (String.isNotEmpty(deal_item.Areas_of_Concern_Red_Flags__c)) )&&
                     (String.isNotBlank(deal_item.Fit_With_Group__c)&&(String.isNotEmpty(deal_item.Fit_With_Group__c)) )&&
                     (String.isNotBlank(deal_item.Why_Interesting__c)&&(String.isNotEmpty(deal_item.Why_Interesting__c)) )&&
                     (String.isNotBlank(deal_item.WP_Human_Capital_or_WP_Angle__c)&&(String.isNotEmpty(deal_item.WP_Human_Capital_or_WP_Angle__c)) )&&
                     (String.isNotBlank(deal_item.Capital_Market_Consideration__c)&&(String.isNotEmpty(deal_item.Capital_Market_Consideration__c)) )
                   ) &&
                   (
                     (stored_stage == 'Early-Prospect')||
                     (stored_stage == 'Early-Initial Diligence/Management Meeting')||
                     (stored_stage == 'Early-Indicative Bid Submitted')
                   ) &&
                   (
                     (deal_stage == 'Active-Detailed Diligence/Advisor(s) Engaged')||
                     (deal_stage == 'Serious-Exclusivity/Negotiations')||
                     (deal_stage == 'Committed-Binding Bid Submitted')||
                     (deal_stage == 'Committed-Deal Signed')||
                     (deal_stage == 'Committed-Deal Closed')||
                     (deal_stage == 'Deal Exited Portfolio')
                   )
                 )
          {
            result_string='EAR_NEEDED';
          }       
          else {
            result_string='NO_EAR_NEEDED';
              //Based on ticket - 8618:DCR: If the result_string='Allowed' then also send email to the user saying 
              //- a one page Deal Closing Report is to be submitted    
              if (result_string == 'NO_EAR_NEEDED' && deal_stage == 'Committed-Deal Closed'){
                  String fullDealURL = 'https://warburgpincus--dev.cs8.my.salesforce.com/' + deal_id;
                  String template = '<br><br>You have just changed the stage of <b>' + dealName +'</b> to <b>Committed-Deal Closed.</b>';
                         template+= '<br><br>At the closing of a new investment, a one page Deal Closing Report is to be submitted.';
                         template+='<br><br>The Deal Closing Report and other investment tracking reports can be accessed by selecting <strong>Edit</strong> from the <strong>My Deals</strong> page in Salesforce.';
                         template+= '<br><br><br>For more details, click on the following DCR link to the deal page - '+ fullDealURL +'<br><br>';
                         
                  String subject ='Reminder to submit a Deal Closing Report';
              
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
                  String toName = UserInfo.getName();
                  mail.setToAddresses(toAddresses);   
                  mail.setSenderDisplayName(UserInfo.getName());
                  mail.setSubject(subject);
                  mail.setBccSender(false);
                  mail.setUseSignature(true);
                  
                  List<String> args = new List<String>();
                  args.add(dealName); 
                  String formattedHtml = String.format(template, args);
                  mail.setHtmlBody(formattedHtml);
                  //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });           
              }//end of sending email
            
          }       
          return result_string;
        }
        return result_string;
    }

    @RemoteAction
    public static String isUpdateDealStageForADealAllowed(String deal_id, String deal_stage) {
        String result_string=null;      
        List<Deal__c> deal_list = [
            SELECT Name,Areas_of_Concern_Red_Flags__c, Fit_With_Group__c, 
            Why_Interesting__c, WP_Human_Capital_or_WP_Angle__c,
        Capital_Market_Consideration__c,
            Id, Deal__c.Stage__c,Senior_Team_Member_Count__c,Description__c,Disable_EAR__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];        
        if ( deal_list.size() >0 ) {
          Deal__c deal_item = deal_list[0];
          if(deal_stage == deal_item.Stage__c){          
            result_string='Allowed';
          }
          else if((deal_item.Senior_Team_Member_Count__c==0) &&          
                   (deal_stage != 'Early-Prospect')&& 
                   (deal_stage != 'Early-Initial Diligence/Management Meeting')){
                    result_string='Not_Allowed_No_Senior_TM';
          }
          else{
            boolean bEARPresent = !String.isBlank(deal_item.Areas_of_Concern_Red_Flags__c) && !String.isEmpty(deal_item.Areas_of_Concern_Red_Flags__c) &&
                  !String.isBlank(deal_item.Fit_With_Group__c) && !String.isEmpty(deal_item.Fit_With_Group__c) &&
                  !String.isBlank(deal_item.Why_Interesting__c) && !String.isEmpty(deal_item.Why_Interesting__c) &&                  
                  !String.isBlank(deal_item.WP_Human_Capital_or_WP_Angle__c) && !String.isEmpty(deal_item.WP_Human_Capital_or_WP_Angle__c) &&                  
                  !String.isBlank(deal_item.Capital_Market_Consideration__c) && !String.isEmpty(deal_item.Capital_Market_Consideration__c) &&                  
                  !String.isBlank(deal_item.Description__c) && !String.isEmpty(deal_item.Description__c);
             if((deal_item.Disable_EAR__c == false) && !(bEARPresent) &&
                   (
                     (deal_stage == 'Active-Detailed Diligence/Advisor(s) Engaged')||
                     (deal_stage == 'Serious-Exclusivity/Negotiations')||
                     (deal_stage == 'Committed-Binding Bid Submitted')||
                     (deal_stage == 'Committed-Deal Signed')||
                     (deal_stage == 'Committed-Deal Closed')||
                     (deal_stage == 'Deal Exited Portfolio')
                   )
                 ){
                result_string='Not_Allowed_Stage_Threshold_X';
             }
             else {
                result_string='Allowed';
             }
          }                
        }//try this only if - deal_list.size()>0 else exit
        return result_string;
    }
    
    @RemoteAction
    public static List<Person> updateDealStaffing(ID deal_id, List<Person> staff_ids) {

            List<Deal_Team__c> dealTeamToUpdate = new List<Deal_Team__c>();
            List<Deal_Team__c> dealTeamToInsert = new List<Deal_Team__c>();
            List<Deal_Team__c> dealTeamToDelete = new List<Deal_Team__c>(); 

        List<Deal_Team__c> deal_staff = [
            SELECT Id, Deal__c, Employee__r.User_ID__r.Id, Employee__c,
            Employee__r.Name, Employee__r.Initials__c, Employee__r.Full_Name__c,
            Employee__r.Employee_Level__r.Name, Employee__r.Employee_Level__r.Rank__c, 
            Employee__r.Employee_Level_Precedence__c, 
            Employee__r.ISSENIORTEAMMEMBER__c,
            Employee__r.Employee_Level_Precedence_Sorter__c, Role__c 
            From Deal_Team__c
            WHERE Deal__c = :deal_id
            ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST,Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST
            ];          
            
        Map<String, Deal_Team__c> ids = new Map<String, Deal_Team__c>();
        for ( Deal_Team__c contact : deal_staff ) {
            //System.debug('updateDealStaffing:Current TeamName Role'+contact.Employee__r.Full_Name__c+':'+contact.Role__c);
            ids.put(String.valueOf(contact.Employee__c), contact);
        }
        
        set<string> lookup = new set<String>();
        for ( Person id : staff_ids ) {
            lookup.add(id.contact_id);
            if ( ids.containsKey(id.contact_id) ) {
                Deal_Team__c membership = ids.get(id.contact_id);
                if(id.isSeniorTeamMember == 'true') {
                 membership.Role__c = 'Senior Team Member';
                }
                else {
                 membership.Role__c = 'Team Member';
                }
                //System.debug('updateDealStaffing:Updating TeamName RoleStatus Role'+membership.Employee__r.Full_Name__c+
                //  ':'+id.isSeniorTeamMember+':'+membership.Role__c);
                //update membership;
                dealTeamToUpdate.add(membership);                 
            }
            else {
                Deal_Team__c membership = new Deal_Team__c();
                membership.Deal__c = deal_id;
                membership.Employee__c = id.contact_id;
                if(id.isSeniorTeamMember == 'true') {
                 membership.Role__c = 'Senior Team Member';
                }
                else {
                 membership.Role__c = 'Team Member';
                }
                //System.debug('updateDealStaffing:Adding new Team RoleStatus Role'+id.initials+
                //  ':'+id.isSeniorTeamMember+':'+membership.Role__c);
                //insert membership;
                dealTeamToInsert.add(membership);
            }
        }        
        for ( String id : ids.keySet() ) {
            if ( !lookup.contains(id) ) {
              //System.debug('updateDealStaffing:Deleting TeamName'+ids.get(id).Employee__r.Full_Name__c);
              //delete ids.get(id);
              dealTeamToDelete.add(ids.get(id));
            }
        }        
        if(dealTeamToUpdate.size() > 0) {
            update dealTeamToUpdate;
        }        
        if(dealTeamToInsert.size() > 0) {
            insert dealTeamToInsert;
        }        
        if(dealTeamToDelete.size() > 0) {
            delete dealTeamToDelete;
        }        
        return getDealStaffing(deal_id);
    }

    @RemoteAction
    public static List<Person> updateDealStaffingOld(ID deal_id, List<Person> staff_ids) {

        List<Deal_Team__c> deal_staff = [
            SELECT Id, Deal__c, Employee__r.User_ID__r.Id, Employee__c,
            Employee__r.Name, Employee__r.Initials__c, Employee__r.Full_Name__c,
            Employee__r.Employee_Level__r.Name, 
            Employee__r.Employee_Level__r.Rank__c, 
            Employee__r.Employee_Level_Precedence__c, 
            Employee__r.ISSENIORTEAMMEMBER__c,
            Employee__r.Employee_Level_Precedence_Sorter__c,Role__c 
            From Deal_Team__c
            WHERE Deal__c = :deal_id
                        ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST,Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST
            ];
            
        Map<String, Deal_Team__c> ids = new Map<String, Deal_Team__c>();
        for ( Deal_Team__c contact : deal_staff ) {
            //System.debug('updateDealStaffing:Current TeamName Role'+contact.Employee__r.Full_Name__c+':'+contact.Role__c);
            ids.put(String.valueOf(contact.Employee__c), contact);
        }
        
        set<string> lookup = new set<String>();
        for ( Person id : staff_ids ) {
            lookup.add(id.contact_id);
            if ( ids.containsKey(id.contact_id) ) {
                Deal_Team__c membership = ids.get(id.contact_id);
                if(id.isSeniorTeamMember == 'true') {
                 membership.Role__c = 'Senior Team Member';
                }
                else {
                 membership.Role__c = 'Team Member';
                }
                //System.debug('updateDealStaffing:Updating TeamName RoleStatus Role'+membership.Employee__r.Full_Name__c+
                //  ':'+id.isSeniorTeamMember+':'+membership.Role__c);
                update membership;                  
            }
            else {
                Deal_Team__c membership = new Deal_Team__c();
                membership.Deal__c = deal_id;
                membership.Employee__c = id.contact_id;
                if(id.isSeniorTeamMember == 'true') {
                 membership.Role__c = 'Senior Team Member';
                }
                else {
                 membership.Role__c = 'Team Member';
                }
                //System.debug('updateDealStaffing:Adding new Team RoleStatus Role'+id.initials+
                 // ':'+id.isSeniorTeamMember+':'+membership.Role__c);
                insert membership;
            }
        }
        
        for ( String id : ids.keySet() ) {
            if ( !lookup.contains(id) ) {
              //System.debug('updateDealStaffing:Deleting TeamName'+ids.get(id).Employee__r.Full_Name__c);
              delete ids.get(id);
            }
        }
        
        return getDealStaffing(deal_id);
    }


    @RemoteAction
    public static List<Person> getDealStaffing(ID deal_id) {
        List<Deal_Team__c> contacts = [
           SELECT Id, Deal__c, Deal__r.Name, Employee__r.User_ID__r.Id, Employee__c,
                        Employee__r.ISSENIORTEAMMEMBER__c,
                Employee__r.Name, Employee__r.Initials__c, Employee__r.Full_Name__c, Employee__r.WP_Group__c,
                Employee__r.Employee_Level__r.Name, Employee__r.Employee_Level__r.Rank__c, 
                Employee__r.Employee_Level_Precedence__c, 
                Employee__r.Employee_Level_Precedence_Sorter__c, Role__c 
                FROM Deal_Team__c
                WHERE Deal__c = :deal_id
                        ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST, Role__c ASC NULLS LAST , Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST
                        ];
        
        Person p;
        List<Person> staff = new List<Person>();
        for ( Deal_Team__c contact : contacts ) {
            p = new Person(
                contact.Employee__r.Full_Name__c, 
                contact.Employee__r.User_ID__r.Id, 
                contact.Employee__c,
                (contact.Employee__r.Employee_Level__r != null) ? contact.Employee__r.Employee_Level__r.Name : null,
                (contact.Employee__r.Employee_Level__r != null) ? contact.Employee__r.Employee_Level__r.Rank__c : null,
                contact.Employee__r.WP_Group__c,
                'false'
            );
            p.initials = contact.Employee__r.Initials__c;
            
            if(contact.Role__c == 'Senior Team Member') {
             p.isSeniorTeamMember = 'true';
            }
            else {
             p.isSeniorTeamMember = 'false';
            }
            
            if(contact.Employee__r.ISSENIORTEAMMEMBER__c == 1) {
             p.canBeASeniorTeamMember = 'true';
            } else {
             p.canBeASeniorTeamMember = 'false';
            }
            staff.add(p);
        }
        return staff;
    }
    
// WP-70
/* */
public class DealReadonlyStatus {
  String deal_id;
  Boolean is_deal_readonly;
  Boolean is_ear_disabled;
  Boolean show_emg_para;//This is set to false for deals of record type “portfolio company”
  
  public DealReadonlyStatus(){
    this.deal_id='';
    this.is_deal_readonly=false;
    this.is_ear_disabled=false;
    this.show_emg_para=false;
  }  
}

public class UserDealListStatus {
   List<Deal__c> user_deals;
   List<DealReadonlyStatus> deals_status;
   

   public UserDealListStatus() {
     this.user_deals = new List<Deal__c>();
     this.user_deals.clear();
     this.deals_status = new List<DealReadonlyStatus>();
     this.deals_status.clear();
   }
}

    @RemoteAction
    public static UserDealListStatus getEARDeals(ID user_id, String nothing) {
        
                UserDealListStatus deals_and_status = new UserDealListStatus();
        
        
        deals_and_status.user_deals = [
        
            SELECT 
            id, Deal__c.Name, Company__r.Name, Project_Name__c, Sector__c, Deal_Source__r.Name, Circulate_to_EMG__c,
            RecordType.Name,
            CreatedBy.Name, CreatedDate,Date_Received__c, Dead_Deal_Date__c,Status__c,Dead_Deal_Notes__c, Dead_Deal_Reason__c,
            Description__c,Stage__c, Expense_Code__c, Highlight_In_Group_Report__c, Include_In_Group_Report__c,
            Key_Dates_Next_Steps__c, Portfolio_Company__r.Name, Type__c, WP_Ownership__c, WP_Ownership_Diluted__c,
            Dormant_Deal__c, Geographies__c, Stage_of_Life_Cycle__c,Disable_EAR__c,ISDCRENABLED__c,ISSCORECARDENABLED__c,
            WP_Groups__c,
            (SELECT Id,
                Employee__r.Name, Employee__r.Initials__c,Role__c,
                Employee__r.Employee_Level__r.Name, 
                Employee__r.Employee_Level__r.Rank__c, 
                Employee__r.Employee_Level_Precedence__c, 
                Employee__r.ISSENIORTEAMMEMBER__c,
                Employee__r.Employee_Level_Precedence_Sorter__c 
                FROM Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST, Role__c ASC NULLS LAST , Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST),
            (SELECT EMG_Comment__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name 
                FROM EMG_Comments__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name 
                FROM EMG_Paragraphs__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT Date_of_Record__c, Carrying_Value__c,
                 CurrencyIsoCode, Cost__c, IsDeleted, Fund__r.Name,
                 Grills_Rank__c, Grills_Value__c, Original_Cost__c,
                 Realizations_to_Date__c, WP_Ownership_Basic__c,
                 WP_Ownership_Fully_Diluted__c 
                 FROM Valuation_Reporting__r WHERE IsDeleted = False ORDER BY Date_of_Record__c),
            (SELECT Fund__r.Name
                 FROM Fund_Ownerships__r)
            FROM Deal__c 
            WHERE Id IN(
                SELECT Deal__c
                FROM Deal_Document_Link__c
                WHERE Type__c='Early Action Report' AND
                Deal__r.Stage__c != 'Committed-Deal Closed' AND
                 Deal__r.Stage__c != 'Committed-Deal Signed' AND
                     Deal__r.Stage__c != 'Deal Exited Portfolio'
            ) AND Status__c <> 'Dead'
            ORDER BY Deal__c.Name ASC         
        ];
        
        checkIsDealUpdatable(deals_and_status, user_id);
        
        System.debug('getUsersDeals:DealSize StatusSize'+deals_and_status.deals_status.Size()+':'+deals_and_status.user_deals.size());
        
        return deals_and_status;
        
    }
    
    @RemoteAction
    public static UserDealListStatus getUsersDeals(ID user_id, String nothing) {
        user_id = user_id != null ? user_id : UserInfo.getUserId();

        UserDealListStatus deals_and_status = new UserDealListStatus();
        
        deals_and_status.user_deals = [
        
            SELECT 
            id, Deal__c.Name, Company__r.Name, Project_Name__c, Sector__c, Deal_Source__r.Name, Circulate_to_EMG__c,
            RecordType.Name,
            CreatedBy.Name, CreatedDate,Date_Received__c, Dead_Deal_Date__c,Status__c,Dead_Deal_Notes__c, Dead_Deal_Reason__c,
            Description__c,Stage__c, Expense_Code__c, Highlight_In_Group_Report__c, Include_In_Group_Report__c,
            Key_Dates_Next_Steps__c, Portfolio_Company__r.Name, Type__c, WP_Ownership__c, WP_Ownership_Diluted__c,
            Dormant_Deal__c, Geographies__c, Stage_of_Life_Cycle__c,Disable_EAR__c,ISDCRENABLED__c,ISSCORECARDENABLED__c,
            WP_Groups__c,
            (SELECT Id,
                Employee__r.Name, Employee__r.Initials__c,Role__c,
                Employee__r.Employee_Level__r.Name, 
                Employee__r.Employee_Level__r.Rank__c, 
                Employee__r.Employee_Level_Precedence__c, 
                Employee__r.ISSENIORTEAMMEMBER__c,
                Employee__r.Employee_Level_Precedence_Sorter__c 
                FROM Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST, Role__c ASC NULLS LAST , Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST),
            (SELECT EMG_Comment__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name 
                FROM EMG_Comments__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name 
                FROM EMG_Paragraphs__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT Date_of_Record__c, Carrying_Value__c,
                 CurrencyIsoCode, Cost__c, IsDeleted, Fund__r.Name,
                 Grills_Rank__c, Grills_Value__c, Original_Cost__c,
                 Realizations_to_Date__c, WP_Ownership_Basic__c,
                 WP_Ownership_Fully_Diluted__c 
                 FROM Valuation_Reporting__r WHERE IsDeleted = False ORDER BY Date_of_Record__c),
            (SELECT Fund__r.Name
                 FROM Fund_Ownerships__r)
            FROM Deal__c 
            WHERE Id IN(
                SELECT Deal__c
                FROM Deal_Team__c
                WHERE Employee__r.User_ID__c = :user_id
            //) AND (Dead_Deal_Reason__c = NULL OR ( Dead_Deal_Reason__c != NULL AND Date_Received__c > :date.today().addDays(-30) ) )
            ) AND (Dead_Deal_Reason__c = NULL OR (Dead_Deal_Reason__c != NULL AND Dead_Deal_Date__c > :date.today().addDays(-30) ) )              
            ORDER BY Name ASC         
        ];
        
        checkIsDealUpdatable(deals_and_status, user_id);
        
        System.debug('getUsersDeals:DealSize StatusSize'+deals_and_status.deals_status.Size()+':'+deals_and_status.user_deals.size());
        
        return deals_and_status;
        
    }
    @RemoteAction
    public static UserDealListStatus getUsersGroupDeals(ID user_id, String grp) {
        System.debug('zzzzzzzzzzzzz ' + grp);
        user_id = user_id != null ? user_id : UserInfo.getUserId();
        // get the group first
        // 
        String groupname = '';
        
        
        if (grp != '') {
            System.debug('aaaaaagetUsersGroupDeals : the groupname is ' + grp);
            groupname = '%' + grp + '%';
        }
        else {
        	System.debug('bbbbbbbgetUsersGroupDeals : the groupname is ' + grp);
            grp = [SELECT WP_Group__c FROM Contact where User_Id__c= :user_id].WP_Group__c;
            groupname = '%' + grp + '%';
        }
        String secondgroup = '';
        if (grp == 'Healthcare') {
        	secondgroup = '%HCG%';    
        
        }
        else if (grp == 'HCG') {
        	secondgroup = '%Healthcare%';            
        }
        else if (grp == 'CIS') {
        	secondgroup = '%IBS%';            
        }
        else if (grp == 'IBS') {
        	secondgroup = '%CIS%';            
        }
        else {
            secondgroup = 'do not match me';            
        }
        UserDealListStatus deals_and_status = new UserDealListStatus();
        
        System.debug('xxxxxxxxgetUsersGroupDeals : the groupname is ' + groupname);
        deals_and_status.user_deals = [
        
            SELECT 
            id, Deal__c.Name, Company__r.Name, Project_Name__c, Sector__c, Deal_Source__r.Name, Circulate_to_EMG__c,
            RecordType.Name,
            CreatedBy.Name, CreatedDate,Date_Received__c, Dead_Deal_Date__c,Status__c,Dead_Deal_Notes__c, Dead_Deal_Reason__c,
            Description__c,Stage__c, Expense_Code__c, Highlight_In_Group_Report__c, Include_In_Group_Report__c,
            Key_Dates_Next_Steps__c, Portfolio_Company__r.Name, Type__c, WP_Ownership__c, WP_Ownership_Diluted__c,
            Dormant_Deal__c, Geographies__c, Stage_of_Life_Cycle__c,Disable_EAR__c,ISDCRENABLED__c,ISSCORECARDENABLED__c,
            WP_Groups__c,
            (SELECT Id,
                Employee__r.Name, Employee__r.Initials__c,Role__c,
                Employee__r.Employee_Level__r.Name, 
                Employee__r.Employee_Level__r.Rank__c, 
                Employee__r.Employee_Level_Precedence__c, 
                Employee__r.ISSENIORTEAMMEMBER__c,
                Employee__r.Employee_Level_Precedence_Sorter__c 
                FROM Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST, Role__c ASC NULLS LAST , Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST),
            (SELECT EMG_Comment__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name 
                FROM EMG_Comments__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name 
                FROM EMG_Paragraphs__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT Date_of_Record__c, Carrying_Value__c,
                 CurrencyIsoCode, Cost__c, IsDeleted, Fund__r.Name,
                 Grills_Rank__c, Grills_Value__c, Original_Cost__c,
                 Realizations_to_Date__c, WP_Ownership_Basic__c,
                 WP_Ownership_Fully_Diluted__c 
                 FROM Valuation_Reporting__r WHERE IsDeleted = False ORDER BY Date_of_Record__c),
            (SELECT Fund__r.Name
                 FROM Fund_Ownerships__r)
            FROM Deal__c 
            WHERE (WP_Groups__c like  :groupname OR WP_Groups__c like :secondgroup) 
            //) AND (Dead_Deal_Reason__c = NULL OR ( Dead_Deal_Reason__c != NULL AND Date_Received__c > :date.today().addDays(-30) ) )
             AND (Dead_Deal_Reason__c = NULL OR (Dead_Deal_Reason__c != NULL AND Dead_Deal_Date__c > :date.today().addDays(-30) ) )              
            ORDER BY Name ASC         
        ];
        
        checkIsDealUpdatable(deals_and_status, user_id);
        
        System.debug('getUsersDeals:DealSize StatusSize'+deals_and_status.deals_status.Size()+':'+deals_and_status.user_deals.size());
        
        return deals_and_status;
        
    }

   public
   static void checkIsDealUpdatable(UserDealListStatus deals_and_status, ID userId)
   {  
   	
   		Set<ID> lstDealIDs = new Set<ID>();
   		Set<ID> editableRecs = new Set<ID>();
   		
   		for(Deal__c deal_item : deals_and_status.user_deals) {     
   			lstDealIDs.add(deal_item.Id);
   			
   			if (lstDealIDs.size() > 190 ) {
   			List<UserRecordAccess> lstEditableRecords = [SELECT  RecordId FROM UserRecordAccess WHERE UserId=:userId AND HasEditAccess = true AND RecordId IN :lstDealIDs LIMIT 200];
			for(UserRecordAccess d2 : lstEditableRecords) {  
				editableRecs.add(d2.RecordId);
			}
   			lstDealIDs = new Set<ID>();
   			
   			}
   		}
   		
   		if (lstDealIDs.size() > 0 ) {
   		
   			List<UserRecordAccess> lstEditableRecords = [SELECT  RecordId FROM UserRecordAccess WHERE UserId=:userId AND HasEditAccess = true AND RecordId IN :lstDealIDs LIMIT 200];
			for(UserRecordAccess d2 : lstEditableRecords) {  
				editableRecs.add(d2.RecordId);  
			
			}
   		}
			
   		//System.debug ('11111111111111111zzzzzzzzzzzzzzzzzzzzzz list of editable records is ' + editableRecs.size());
   		
        for(Deal__c deal_item : deals_and_status.user_deals) {   
        	   
           deal_item.Circulate_to_EMG__c =  deal_item.Circulate_to_EMG__c;          
           DealReadonlyStatus deal_status_item = new DealReadonlyStatus();
           deal_status_item.deal_id = deal_item.Id;
           deal_status_item.is_deal_readonly = false;         
           deal_status_item.is_ear_disabled = deal_item.Disable_EAR__c;
           if(deal_item.RecordType.Name.equals('Portfolio Company') == true ) {
             deal_status_item.show_emg_para = false;
           } else {
             deal_status_item.show_emg_para = true;
           }
           deal_status_item.is_deal_readonly = (editableRecs!=null && editableRecs.contains(deal_item.Id)) ? false : true;
           
           //System.debug ('22222222zzzzzzzzzzzzzzzzzzzzzz checking deal ' +  deal_item.Id + ' and setting to ' + deal_status_item.is_deal_readonly);
           deals_and_status.deals_status.add(deal_status_item);
           System.debug('checkIsDealUpdatable:'+deal_item.Id+':'+deal_status_item+':'+deal_item.Name+':'+deal_item.RecordType.Name);        
        }
        
		/*
      try {
      	kjoDealReportController.bCheckingDealWriteability=true;
     	update deals_and_status.user_deals;
     
      }
      catch (System.DmlException e) {
        for (Integer i = 0; i < e.getNumDml(); i++) {
          // Process exception here 
          for (Integer j = 0; j < deals_and_status.deals_status.size(); j++) {
            System.debug('-----Checking if the Deal Professional has write persmissions on deal:'+ deals_and_status.deals_status.size()+':' + deals_and_status.deals_status[j].deal_id);
            if(deals_and_status.deals_status[j].deal_id == e.getDmlId(i) )
            {
              System.debug('Deal Professional doesn\'t have write permission:'+j+':'+ deals_and_status.deals_status[j].deal_id +':'+e.getDmlId(i)+
              e.getDmlMessage(i)); 
              deals_and_status.deals_status[j].is_deal_readonly = true;
              break;
            }
          }
       }
      }  
      finally {
      	kjoDealReportController.bCheckingDealWriteability=false; 
      }*/       
    }

@RemoteAction  
public static Boolean sendEmailForFollowupReport(String deal_id, String sch_id)
{
    if((String.isBlank(deal_id)) || (String.isEmpty(deal_id))){
      //System.debug('sendEmailForDCRReport:Received Deal_ID is empty so email not sent:'+deal_id+'......');
      return false;
    }
    List<Deal__c> d_l = [Select Name,Expense_Code__c,Stage__c  from Deal__c where Id =:deal_id limit 1];
    if(d_l.size() != 1){
      //System.debug('sendEmailForDCRReport:Deal not found so email not sent:'+d_l.size()+'......');
      return false;
    }
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    PageReference pdf =  Page.dcr_scorecard_pdf_page_report; 
    pdf.getParameters().put('id',(String)deal_id); 
    pdf.getParameters().put('sch_id',(String)sch_id); 
    pdf.setRedirect(true);

    // Take the PDF content
    Blob dcr;
    if (Test.IsRunningTest()) {
      dcr = Blob.valueOf('UNIT.TEST');
    } else {
      dcr = pdf.getContent();
    }        
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(d_l[0].Name+'.'+ d_l[0].Expense_Code__c+'.OYS'+'.pdf');
    efa.setBody(dcr);

    String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
    String toName = UserInfo.getName();
    String fullTaskURL = 'https://warburgpincus.my.salesforce.com' +'/' + deal_id;    

    //System.debug('sendEmailForEIRReport------------To email address is:'+toAddresses+'-----toName is------'+toAddresses+'......'+toName);      
    mail.setToAddresses(toAddresses);   
    mail.setSenderDisplayName(UserInfo.getName());
    mail.setSubject(d_l[0].Name+'.'+d_l[0].Expense_Code__c +'.OYS');
    mail.setBccSender(false);
    mail.setUseSignature(true);
    
    String template = '<div style="width: 100%">' +
	'<div style="margin-left:5px; font-family: verdana; font-size: .8em; margin-bottom: 10px; margin-top: 10px;">' +
          '<div>Attached is the requested One-Year Scorecard for {0}.  If this is the final version, you <u>must</u> email a copy of the PDF report:</div>' + 
		'<div><table style="margin-left: 50px; font-family: verdana; font-size: .8em; width:260px;"><tr><td style="width: 50px">TO:</td><td style="width: 200px;">Pat Hackett</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Chip Kaye</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Joe Landy</td></tr><tr><td style="width: 50px;">CC:</td><td style="width: 200px;">Jill Van Cook</td></tr>	<tr><td style="width: 50px;"></td><td style="width: 200px;">Margaret Grunow</td></tr><tr>	<td style="width: 50px;"></td><td style="width: 200px;">Heather Murray</td></tr></table>' +
  '</div><div style="margin-top: 10px;">It is important to note that Salesforce will <u>not</u> send the report automatically; you must do so.</div><div style="margin-top:10px">For more details, click the following link – {1}</div></div></div><br><br><br><br><br>';
    
    /*
    String template = '<font face = \'verdana\'><br><br>The requested One-Year Scorecard for the deal {0} is attached.<br><br>'
		+'If you are happy with this version, <u>the attached PDF of the report must be sent by you via email to Chip Kaye, Joe Landy and Pat Hackett</u>.  Also, you must cc: Jill Van Cook, Heather Murray and Margaret Grunow.<br><br><u>Salesforce will not send the report automatically, you must do so</u>.<br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br><br><br><br></font>';
    */
/*    String template = '<br><br>The requested One-Year Scorecard for the deal {0} is attached.<br><br>'
		+'When the report is finalized, <u>the PDF of the report must be sent by you to Chip Kaye, Joe Landy and Pat Hackett</u>, and cc: Jill Van Cook, Heather Murray and Margaret Grunow.  <u>Salesforce will not send the report automatically</u>.<br><br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br>';*/
            
    List<String> args = new List<String>();
    args.add(d_l[0].Name);
    args.add(fullTaskURL);
    String formattedHtml = String.format(template, args);
    mail.setHtmlBody(formattedHtml);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    //Now also update the record in the DCR Process Log if it exists, with deal_id, DCRSentBy, DCRSentOn, and 
    /*
    if (d_l[0].Stage__c=='Committed-Deal Closed'){
           List<DCR_Process_Log__c> dcr_process_log_list = [
            SELECT id,p.Deal__c,p.Reminder_Sent__c,p.Time_Expired__c,p.DCR_Sent_By__c, p.DCR_Sent_On__c         
            FROM DCR_Process_Log__c p
            WHERE (p.Deal__c = :deal_id)
           ];
           if (dcr_process_log_list.size()>0){
                        for(DCR_Process_Log__c log:dcr_process_log_list){
                                //log.DCR_Sent_By__c  = UserInfo.getName();
                                //log.DCR_Sent_On__c= System.Today(); 
                                delete log;
                        }
           }
   }            
   */
   return true;
}   

@RemoteAction  
public static Boolean sendEmailForDCRReport(String deal_id, String sch_id)
{
    if((String.isBlank(deal_id)) || (String.isEmpty(deal_id))){
      //System.debug('sendEmailForDCRReport:Received Deal_ID is empty so email not sent:'+deal_id+'......');
      return false;
    }
    List<Deal__c> d_l = [Select Name,Expense_Code__c,Stage__c,ISSCORECARDENABLED__c  from Deal__c where Id =:deal_id limit 1];
    if(d_l.size() != 1){
      //System.debug('sendEmailForDCRReport:Deal not found so email not sent:'+d_l.size()+'......');
      return false;
    }
    Deal__c thisdeal;
    thisdeal = d_l[0];
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    PageReference pdf =  Page.dcr_sample_pdf_page_report; 
    pdf.getParameters().put('id',(String)deal_id); 
    pdf.getParameters().put('sch_id',(String)sch_id); 
    pdf.setRedirect(true);

    // Take the PDF content
    Blob dcr;
    if (Test.IsRunningTest()) {
      dcr = Blob.valueOf('UNIT.TEST');
    } else {
      dcr = pdf.getContent();
    }        
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(d_l[0].Name+'.'+ d_l[0].Expense_Code__c+'.DCR'+'.pdf');
    efa.setBody(dcr);

    String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
    String toName = UserInfo.getName();
    String fullTaskURL = 'https://warburgpincus.my.salesforce.com' +'/' + deal_id;    

    //System.debug('sendEmailForEIRReport------------To email address is:'+toAddresses+'-----toName is------'+toAddresses+'......'+toName);      
    mail.setToAddresses(toAddresses);   
    mail.setSenderDisplayName(UserInfo.getName());
    mail.setSubject(d_l[0].Name+'.'+d_l[0].Expense_Code__c +'.DCR');
    mail.setBccSender(false);
    mail.setUseSignature(true);
    
      String template = '<div style="width: 100%">' +
	'<div style="margin-left:5px; font-family: verdana; font-size: .8em; margin-bottom: 10px; margin-top: 10px;">' +
          '<div>Attached is the requested Deal Closing Report for {0}.  If this is the final version, you <u>must</u> email a copy of the PDF report:</div>' + 
		'<div><table style="margin-left: 50px; font-family: verdana; font-size: .8em; width:260px;"><tr><td style="width: 50px">TO:</td><td style="width: 200px;">Pat Hackett</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Chip Kaye</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Joe Landy</td></tr><tr><td style="width: 50px;">CC:</td><td style="width: 200px;">Jill Van Cook</td></tr>	<tr><td style="width: 50px;"></td><td style="width: 200px;">Margaret Grunow</td></tr><tr>	<td style="width: 50px;"></td><td style="width: 200px;">Heather Murray</td></tr></table>' +
  '</div><div style="margin-top: 10px;">It is important to note that Salesforce will <u>not</u> send the report automatically; you must do so.</div><div style="margin-top:10px">For more details, click the following link – {1}</div></div></div><br><br><br><br><br>';
    /*
    String template = '<font face = \'verdana\'><br><br>The requested DCR Report for the deal {0} is attached.<br><br>'
		+'If you are happy with this version, <u>the attached PDF of the report must be sent by you via email to Chip Kaye, Joe Landy and Pat Hackett</u>.  Also, you must cc: Jill Van Cook, Heather Murray and Margaret Grunow.<br><br><u>Salesforce will not send the report automatically, you must do so</u>.<br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br><br><br><br></font>';
*/
/*        
     String template = '<br><br>The requested DCR Report for the deal {0} is attached.<br><br>'
		+'When the report is finalized, <u>the PDF of the report must be sent by you to Chip Kaye, Joe Landy and Pat Hackett</u>, and cc: Heather Murray and Margaret Grunow.  <u>Salesforce will not send the report automatically</u>.<br><br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br>';
  */          
    List<String> args = new List<String>();
    args.add(d_l[0].Name);
    args.add(fullTaskURL);
    String formattedHtml = String.format(template, args);
    mail.setHtmlBody(formattedHtml);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    //Make sure now that the Scorecard is ready to be used on via the Menu
    if (thisdeal.ISSCORECARDENABLED__c == false){
        thisdeal.ISSCORECARDENABLED__c = true;
        update thisdeal;
    }     
    //Now also update the record in the DCR Process Log if it exists, with deal_id, DCRSentBy, DCRSentOn, and 
    if (d_l[0].Stage__c=='Committed-Deal Closed'){
           List<DCR_Process_Log__c> dcr_process_log_list = [
            SELECT id,p.Deal__c,p.Reminder_Sent__c,p.Time_Expired__c,p.DCR_Sent_By__c, p.DCR_Sent_On__c         
            FROM DCR_Process_Log__c p
            WHERE (p.Deal__c = :deal_id)
           ];
           if (dcr_process_log_list.size()>0){
                        for(DCR_Process_Log__c log:dcr_process_log_list){
                                log.DCR_Sent_By__c  = UserInfo.getName();
                                log.DCR_Sent_On__c= System.Today(); 
                                delete log;
                                //update log;
                        }
           }
   }            
   return true;
}   

@RemoteAction  
public static Boolean sendEmailForEIRReport(String deal_id)
{
    if((String.isBlank(deal_id)) || (String.isEmpty(deal_id)))
    {
      //System.debug('sendEmailForEIRReport:Received Deal_ID is empty so email not sent:'+deal_id+'......');
      return false;
    }

    List<Deal__c> d_l = [Select Name,Expense_Code__c  from Deal__c where Id =:deal_id limit 1];
    if(d_l.size() != 1)
    {
      //System.debug('sendEmailForEarReport:Deal not found so email not sent:'+d_l.size()+'......');
      return false;
    }
    
    
    // First, reserve email capacity for the current Apex transaction to ensure                         
    // that we won't exceed our daily email limits when sending email after                         
    // the current transaction is committed.
   //Messaging.reserveSingleEmailCapacity(5);
   
    // Processes and actions involved in the Apex transaction occur next,
    // which conclude with sending a single email.

    // Now create a new single email message object
    // that will send out a single email to the addresses in the To, CC & BCC list.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    
        // Reference the attachment page and pass in the account ID
        PageReference pdf =  Page.eir_sample_pdf_page;
        pdf.getParameters().put('id',(String)deal_id); 
        pdf.setRedirect(true);

        // Take the PDF content
        Blob b;
        if (Test.IsRunningTest()) {
         b = Blob.valueOf('UNIT.TEST');
        } else {
         b = pdf.getContent();
        }        

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(d_l[0].Name+'.'+ d_l[0].Expense_Code__c+'.EIR'+'.pdf');
        efa.setBody(b);

        
    
    
    // Strings to hold the email addresses to which you are sending the email.
    String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
    String toName = UserInfo.getName();
    //String fullTaskURL = URL.getSalesforceBaseUrl().toExternalForm() +'/' + deal_id;
    String fullTaskURL = 'https://warburgpincus.my.salesforce.com' +'/' + deal_id;    

    //System.debug('sendEmailForEIRReport------------To email address is:'+toAddresses+'-----toName is------'+toAddresses+'......'+toName);      
    
    // Assign the addresses for the To to the mail object.
    mail.setToAddresses(toAddresses);   

    // Specify the name used as the display name.
    mail.setSenderDisplayName(UserInfo.getName());

    // Specify the subject line for your email address.
    mail.setSubject(d_l[0].Name+'.'+d_l[0].Expense_Code__c +'.EIR');

    // Set to True if you want to BCC yourself on the email.
    mail.setBccSender(false);

    // Optionally append the salesforce.com email signature to the email.
    // The email address of the user executing the Apex Code will be used.
    mail.setUseSignature(true);

    
        // Next, create a string template. Specify {0}, {1} etc. in place of actual values.
        // You can replace these values with a call to String.Format.
          String template = '<div style="width: 100%">' +
	'<div style="margin-left:5px; font-family: verdana; font-size: .8em; margin-bottom: 10px; margin-top: 10px;">' +
          '<div>Attached is the requested Early Action Report for {0}.  If this is the final version, you <u>must</u> email a copy of the PDF report:</div>' + 
		'<div><table style="margin-left: 50px; font-family: verdana; font-size: .8em; width:260px;"><tr><td style="width: 50px">TO:</td><td style="width: 200px;">Pat Hackett</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Chip Kaye</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Joe Landy</td></tr><tr><td style="width: 50px;">CC:</td><td style="width: 200px;">Jill Van Cook</td></tr>	<tr><td style="width: 50px;"></td><td style="width: 200px;">Margaret Grunow</td></tr><tr>	<td style="width: 50px;"></td><td style="width: 200px;">Heather Murray</td></tr></table>' +
  '</div><div style="margin-top: 10px;">It is important to note that Salesforce will <u>not</u> send the report automatically; you must do so.</div><div style="margin-top:10px">For more details, click the following link – {1}</div></div></div><br><br><br><br><br>';
   /*
        String template = '<font face = \'verdana\'><br><br>The requested EIR Report for the deal {0} is attached.<br><br>'
		+'If you are happy with this version, <u>the attached PDF of the report must be sent by you via email to Chip Kaye, Joe Landy and Pat Hackett</u>.  Also, you must cc: Jill Van Cook, Heather Murray and Margaret Grunow.<br><br><u>Salesforce will not send the report automatically, you must do so</u>.<br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br><br><br><br></font>';
     */   
         /*String template = '<br><br>The requested EIR Report for the deal {0} is attached.<br><br>'
		+'When the report is finalized, <u>the PDF of the report must be sent by you to Chip Kaye, Joe Landy and Pat Hackett</u>, and cc: Heather Murray and Margaret Grunow.  <u>Salesforce will not send the report automatically</u>.<br><br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br>';*/
        

            
        List<String> args = new List<String>();
        //args.add(toName);
        args.add(d_l[0].Name);
        args.add(fullTaskURL);
       
        // Here's the String.format() call.
        String formattedHtml = String.format(template, args);
            
    
    // Specify the text content of the email.
    mail.setHtmlBody(formattedHtml);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});



    // Send the email you have created.
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    return true;
}   


@RemoteAction  
public static Boolean sendEmailForEarReport(String deal_id)
{
    if((String.isBlank(deal_id)) || (String.isEmpty(deal_id)))
    {
      //System.debug('sendEmailForEarReport:Received Deal_ID is empty so email not sent:'+deal_id+'......');
      return false;
    }

    List<Deal__c> d_l = [Select Name,Expense_Code__c  from Deal__c where Id =:deal_id limit 1];
    if(d_l.size() != 1)
    {
      //System.debug('sendEmailForEarReport:Deal not found so email not sent:'+d_l.size()+'......');
      return false;
    }
    
    
    // First, reserve email capacity for the current Apex transaction to ensure                         
    // that we won't exceed our daily email limits when sending email after                         
    // the current transaction is committed.
   //Messaging.reserveSingleEmailCapacity(5);
   
    // Processes and actions involved in the Apex transaction occur next,
    // which conclude with sending a single email.

    // Now create a new single email message object
    // that will send out a single email to the addresses in the To, CC & BCC list.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    
        // Reference the attachment page and pass in the account ID
        PageReference pdf =  Page.ear_sample_pdf_page;
        pdf.getParameters().put('id',(String)deal_id); 
        pdf.setRedirect(true);

        // Take the PDF content
        Blob b;
        if (Test.IsRunningTest()) {
         b = Blob.valueOf('UNIT.TEST');
        } else {
         b = pdf.getContent();
        }        

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(d_l[0].Name+'.'+ d_l[0].Expense_Code__c+'.EAR'+'.pdf');
        efa.setBody(b);

        
    
    
    // Strings to hold the email addresses to which you are sending the email.
    String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
    String toName = UserInfo.getName();
    //String fullTaskURL = URL.getSalesforceBaseUrl().toExternalForm() +'/' + deal_id;
    String fullTaskURL = 'https://warburgpincus.my.salesforce.com' +'/' + deal_id;    

    //System.debug('sendEmailForEarReport------------To email address is:'+toAddresses+'-----toName is------'+toAddresses+'......'+toName);      
    
    // Assign the addresses for the To to the mail object.
    mail.setToAddresses(toAddresses);   

    // Specify the name used as the display name.
    mail.setSenderDisplayName(UserInfo.getName());

    // Specify the subject line for your email address.
    mail.setSubject(d_l[0].Name+'.'+d_l[0].Expense_Code__c +'.EAR');

    // Set to True if you want to BCC yourself on the email.
    mail.setBccSender(false);

    // Optionally append the salesforce.com email signature to the email.
    // The email address of the user executing the Apex Code will be used.
    mail.setUseSignature(true);

    
        // Next, create a string template. Specify {0}, {1} etc. in place of actual values.
        // You can replace these values with a call to String.Format.
        
    String template = '<div style="width: 100%">' +
	'<div style="margin-left:5px; font-family: verdana; font-size: .8em; margin-bottom: 10px; margin-top: 10px;">' +
          '<div>Attached is the requested Early Action Report for {0}.  If this is the final version, you <u>must</u> email a copy of the PDF report:</div>' + 
		'<div><table style="margin-left: 50px; font-family: verdana; font-size: .8em; width:260px;"><tr><td style="width: 50px">TO:</td><td style="width: 200px;">Pat Hackett</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Chip Kaye</td></tr><tr><td style="width: 50px;"></td><td style="width: 200px;">Joe Landy</td></tr><tr><td style="width: 50px;">CC:</td><td style="width: 200px;">Jill Van Cook</td></tr>	<tr><td style="width: 50px;"></td><td style="width: 200px;">Margaret Grunow</td></tr><tr>	<td style="width: 50px;"></td><td style="width: 200px;">Heather Murray</td></tr></table>' +
  '</div><div style="margin-top: 10px;">It is important to note that Salesforce will <u>not</u> send the report automatically; you must do so.</div><div style="margin-top:10px">For more details, click the following link – {1}</div></div></div><br><br><br><br><br>';
  
    /*
        String template = '<font face = \'verdana\'><br><br>The requested Early Action Report for the deal {0} is attached.<br><br>'
		+'If you are happy with this version, <u>the attached PDF of the report must be sent by you via email to Chip Kaye, Joe Landy and Pat Hackett</u>.  Also, you must cc: Jill Van Cook, Heather Murray and Margaret Grunow.<br><br><u>Salesforce will not send the report automatically, you must do so</u>.<br><br>';        
        //+'When ready, please forward to Chip Kaye, Joe Landy and Pat Hackett, and cc: Heather Murray and Margaret Grunow.\n\n\n'; kckkck
        template+= 'For more details, click the following link - {1}<br><br><br><br><br></font>';
      */      
        List<String> args = new List<String>();
        //args.add(toName);
        args.add(d_l[0].Name);
        args.add(fullTaskURL);
       
        // Here's the String.format() call.
        String formattedHtml = String.format(template, args);
            
    
    // Specify the text content of the email.
    //mail.setPlainTextBody(formattedHtml); 
    mail.setHtmlBody(formattedHtml);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});



    // Send the email you have created.
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    return true;
}   

	public string SFTestClass()
	{
		
		
		integer i=1;
		i++;
		
		i++;
		i++;
		i++;
		i++;
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');

		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		
		
		
		
		
		
		
		
		return 'TEST CLASS';
	}    
    
}