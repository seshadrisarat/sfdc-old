/**************************************************************************************************
Name : Meetings4_DashboardController
Related VF Page: Meetings4_Dashboard
Description : To show the Dashboard view of the Final IC Review Screen
**************************************************************************************************/ 
public class Meetings4_DashboardController {

  public static final String VOTE_VALUE_NA = 'N/A';
  public static final String VOTE_VALUE_1 = '1';
  public static final String VOTE_VALUE_2 = '2';
  public static final String VOTE_VALUE_3 = '3';
  //START Story # S-183841 [hemant 1/17/2014]
  public static final String VOTE_VALUE_4 = '4';
  //END Story # S-183841
  public static List<CompanyVoteData> companyVotesLst{get;set;}
  private String meetingId;
  public Integer maxVoteCountForChart{get;set;}
  
  public Meetings4_DashboardController(){
    meetingId = ApexPages.currentPage().getParameters().get('meetingId');
    loadData();
  }
  
   public static String getBaseURL()
    {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
  public PageReference loadData(){
    maxVoteCountForChart = 1;
    companyVotesLst = getCompanyVotes();
    return null;
  }
  
  
  public List<CompanyVoteData> getCompanyVotes(){
    
    //String mtngId = 'a56J0000000015s';
    Map<Id,CompanyVoteData> compIdCVDMap = new Map<Id,CompanyVoteData>();
    
    if(meetingId == null || meetingId == ''){
      return compIdCVDMap.values();
    }
                                 
    //Group by company Id to find total vote count and average                                           
    for (AggregateResult ar : [SELECT Agenda_Item__r.Deal__r.Related_Company__c cId , count(Id) voteCount, AVG(Numeric_Vote_Value__c) AvgVote FROM Meeting_Note__c
                                 WHERE Agenda_Item__r.Meeting__c =: meetingId
                                 AND Is_Post_IC_Vote__c = true
                                 AND Agenda_Item__r.Deal__c != null AND Agenda_Item__r.Deal__r.Related_Company__c != null
                                 //START Story # S-183841 [hemant 1/17/2014]
                                 //AND (Vote__c like 'N/A%' OR Vote__c like '1%' OR Vote__c like '2%' OR Vote__c like '3%')
                                 //END Story # S-183841
                                 Group By Agenda_Item__r.Deal__r.Related_Company__c]){
      
      compIdCVDMap.put((Id)ar.get('cId'), new CompanyVoteData((String)ar.get('cId'), (Integer)ar.get('voteCount'), (ar.get('AvgVote')) != null ? ((Decimal)ar.get('AvgVote')).setScale(2, RoundingMode.HALF_UP): 0 ));
    }
    
    //Group by company Id, Vote to find vote distribution
    for (AggregateResult ar : [SELECT Agenda_Item__r.Deal__r.Related_Company__c cId , Vote__c vt,  count(Id) voteCount FROM Meeting_Note__c
                                 WHERE Agenda_Item__r.Meeting__c =: meetingId
                                 AND Is_Post_IC_Vote__c = true
                                 //START Story # S-183841 [hemant 1/17/2014]
                                 //AND (Vote__c like 'N/A%' OR Vote__c like '1%' OR Vote__c like '2%' OR Vote__c like '3%')
                                 //END Story # S-183841
                                 AND Agenda_Item__r.Deal__c != null AND Agenda_Item__r.Deal__r.Related_Company__c != null
                                 Group By Agenda_Item__r.Deal__r.Related_Company__c, Vote__c ]){
      //
      if(compIdCVDMap.containsKey((Id)ar.get('cId'))){
        
        if(((String)ar.get('vt')).startsWith(VOTE_VALUE_NA)){
          compIdCVDMap.get((Id)ar.get('cId')).NAVtCount += (Integer)ar.get('voteCount');
        }
        else if(((String)ar.get('vt')).startsWith(VOTE_VALUE_1)){
          compIdCVDMap.get((Id)ar.get('cId')).oneVtCount += (Integer)ar.get('voteCount');
        }
        else if(((String)ar.get('vt')).startsWith(VOTE_VALUE_2)){
          compIdCVDMap.get((Id)ar.get('cId')).twoVtCount += (Integer)ar.get('voteCount');
        }
        else if(((String)ar.get('vt')).startsWith(VOTE_VALUE_3)){
          compIdCVDMap.get((Id)ar.get('cId')).threeVtCount += (Integer)ar.get('voteCount');
        }
        //START Story # S-183841 [hemant 1/17/2014]
        else if(((String)ar.get('vt')).startsWith(VOTE_VALUE_4)){
          compIdCVDMap.get((Id)ar.get('cId')).fourVtCount += (Integer)ar.get('voteCount');
        }
        //END Story # S-183841
        
      }
    }
    
    
    
    //Map<Id, Account> accIdAccMap = new Map<Id, Account>([select id, name, RKCB__Logo__c from Account where Id IN: compIdCVDMap.keySet()]);  
    /*
    for(Account acc : [select id, name, IsPersonAccount, RKCB__Logo__c from Account where Id IN: compIdCVDMap.keySet()]){
      compIdCVDMap.get(acc.Id).company = acc;
      
      //add data for table list (Votes NA-3)
      compIdCVDMap.get(acc.Id).tableDataLst.add(new tableData('NA', compIdCVDMap.get(acc.Id).NAVtCount));
      compIdCVDMap.get(acc.Id).tableDataLst.add(new tableData('No', compIdCVDMap.get(acc.Id).oneVtCount));
      compIdCVDMap.get(acc.Id).tableDataLst.add(new tableData('Yes', compIdCVDMap.get(acc.Id).twoVtCount));
      compIdCVDMap.get(acc.Id).tableDataLst.add(new tableData('Yes!', compIdCVDMap.get(acc.Id).threeVtCount));
      
    }*/
    
    //order companies in the Agenda order Start_Time__c
    List<CompanyVoteData> compIdCVDLst = new List<CompanyVoteData>();
    List<Integer> voteCountLst = new List<Integer>();
    
    for(Meeting_Agenda_Item__c mtngAI : [select id, Deal__r.Related_Company__c, Deal__r.Related_Company__r.Name 
                                          from Meeting_Agenda_Item__c 
                                          where Deal__r.Related_Company__c IN: compIdCVDMap.keySet() 
                                          AND Meeting__c =: meetingId
                                          order by Start_Time__c asc]){
                                            
      CompanyVoteData cvdTemp = compIdCVDMap.get(mtngAI.Deal__r.Related_Company__c);
      cvdTemp.company = new Account(Id = mtngAI.Deal__r.Related_Company__c, Name = mtngAI.Deal__r.Related_Company__r.Name);
      
      //add data for table list (Votes NA-3)
      cvdTemp.tableDataLst.add(new tableData('NA', cvdTemp.NAVtCount));
      //START Story # S-183841 [hemant 1/17/2014]
      /*
      cvdTemp.tableDataLst.add(new tableData('No', cvdTemp.oneVtCount));
      cvdTemp.tableDataLst.add(new tableData('Yes', cvdTemp.twoVtCount));
      cvdTemp.tableDataLst.add(new tableData('Yes!', cvdTemp.threeVtCount));
      */
      cvdTemp.tableDataLst.add(new tableData('No!', cvdTemp.oneVtCount));
      cvdTemp.tableDataLst.add(new tableData('No', cvdTemp.twoVtCount));
      cvdTemp.tableDataLst.add(new tableData('Yes', cvdTemp.threeVtCount));
      cvdTemp.tableDataLst.add(new tableData('Yes!', cvdTemp.fourVtCount));
      //END Story # S-183841
      
      voteCountLst.add(cvdTemp.NAVtCount);
      voteCountLst.add(cvdTemp.oneVtCount);
      voteCountLst.add(cvdTemp.twoVtCount);
      voteCountLst.add(cvdTemp.threeVtCount);
      //START Story # S-183841 [hemant 1/17/2014]
      voteCountLst.add(cvdTemp.fourVtCount);
      //END Story # S-183841
                                                  
      compIdCVDLst.add(cvdTemp);
    }
    voteCountLst.sort();
    if(voteCountLst.size() > 0){
      maxVoteCountForChart = voteCountLst.get(voteCountLst.size()-1);     
    }
    //return compIdCVDMap.values();
    return compIdCVDLst;
                                                                                     
  }
  
  public class CompanyVoteData{
    
    public Account company{get;set;}
    public Integer totalVtCount{get;set;}
    public Decimal voteAvg {get;set;}
    public Integer NAVtCount{get;set;}
    public Integer oneVtCount{get;set;}
    public Integer twoVtCount{get;set;}
    public Integer threeVtCount{get;set;}
    //START Story # S-183841 [hemant 1/17/2014]
    public Integer fourVtCount{get;set;}
    //END Story # S-183841
    
    public List<tableData> tableDataLst {get;set;}
    
    public CompanyVoteData(Id compId, Integer voteCount, Decimal vtavg){
      company = new Account(Id = compId);
      tableDataLst = new List<tableData>();
      totalVtCount = voteCount;
      voteAvg = vtavg;
      NAVtCount = 0;
      oneVtCount = 0;
      twoVtCount = 0;
      threeVtCount = 0;
      //START Story # S-183841 [hemant 1/17/2014]
      fourVtCount = 0;
      //END Story # S-183841
    }
    
  }
  
  public class tableData {
    public String name { get; set; }
    public Integer size { get; set; }

    public tableData(String name, Integer data) {
      this.name = name;
      this.size = data;
    }
  }
}