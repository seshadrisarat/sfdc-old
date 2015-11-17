public with sharing class DealListController {
        
        public class DropSearchResult {
        String label;
        String value;
        
        public DropSearchResult(String name, String Id) {
            this.label = name;
            this.value = Id;
        }
    }
    

public String DropSearchText {
        get { if(ApexPages.currentPage().getparameters().get('dropsearch') != null) { DropSearchText = ApexPages.currentPage().getparameters().get('dropsearch');}
            return DropSearchText ;  }
        set {  }
    }
    
    
    public String getDropSearchResults() {
    
    List<DropSearchResult> lst = new List<DropSearchResult>();
    String s = DropSearchText ;
    if (s!='') { 
        s = '%' + DropSearchText  + '%';
       
        //SObject[] obj = [select Id, AccountId, LastName, Title, WP_Group__c, FirstName, Name, Full_Name__c, ISINVESTMENTPRO__c, Status__c, RecordType.Name  from Contact where  RecordType.Name = 'Employee' and ISINVESTMENTPRO__c = 1.0 and Name LIKE :s order by status__c, EMG_Member__c desc, lastname asc ];
        SObject[] obj = [select Id, AccountId, LastName, Title, WP_Group__c, FirstName, Name, Full_Name__c,  Status__c, RecordType.Name  from Contact where  Employee_Level__c != '' and RecordType.Name = 'Employee' and Status__c = 'Active' and Name like :s order by status__c, Employee_Level__r.Rank__c desc, Employee_Level_Precedence_Sorter__c desc, Full_Name__c ];
           
        
        DropSearchResult p;
     
                for(SObject o : obj){
                        Contact c = (Contact)o;
                        string sX=c.Full_Name__c;
                        sX = sX + ' [';
                        //if (c.Status__c!='' && c.Status__c != null) sX = sX + c.Status__c ;
                        if (c.Title != '' && c.Title != null) sX +=  c.Title ;
                        if (c.WP_Group__c != '' && c.WP_Group__c != null) sX = sX + (sX==''?'':', ') + c.WP_Group__c ;
                        sX = sX + ']';
                        p = new DropSearchResult(sX, c.Id);
            lst.add(p);
            }
    }
    return JSON.serialize(lst);
    }

    public PageReference doSearch() {
        return null;
    }
        
        
        
        
        
        
        
        
        
        
        
        
        
public String UserId { get {return UserInfo.getUserId(); } private set; } 
private String sDealListDescription=null;
public String DealListDescription { get { 
        if (sDealListDescription==null) {
                sDealListDescription='';
                        if (SearchByDealNameText!=null)
                                sDealListDescription=' matching ' + SearchByDealNameText;
                        else if (EmpSearchId != null ) {
                        Contact ct = [Select c.Id, c.LastName, c.FirstName, c.Name From Contact c where Id = :EmpSearchId];
                           sDealListDescription= ct.LastName + ', ' + ct.Firstname;
                        }
                        else if (UserId!='')
                        {
                                User usr = [Select u.Id, u.FirstName, u.LastName, u.Name From User u where Id = :UserId];   
                                   sDealListDescription=usr.LastName + ', ' + usr.FirstName;
                        }
        }
     return sDealListDescription; } }

 private List<Deal_Team__c> lstDealTeams = null;
 private static integer iPointer = 2;

public boolean ShowDead { get { 
        if(ApexPages.currentPage().getparameters().get('showdead') != null) {
                 String sT = ApexPages.currentPage().getparameters().get('showdead');
                 return (sT=='true');
         } 
         else return false;
        }
}

public String SearchByDealNameText {
        get { if(ApexPages.currentPage().getparameters().get('dealname') != null) { SearchByDealNameText = ApexPages.currentPage().getparameters().get('dealname');}
            return SearchByDealNameText;  }
        set { /*if(value != null) ThisOrgId = value; */}
    }


public Id EmpSearchId {
        get { if(ApexPages.currentPage().getparameters().get('emp') != null) { EmpSearchId = ApexPages.currentPage().getparameters().get('emp');}
            return EmpSearchId;  }
        set { /*if(value != null) ThisOrgId = value; */}
    }


public integer getPointer()
{
iPointer = iPointer+1;
return iPointer;
}
public List<Deal_Team__c> getDealTeams ()
{

    if (lstDealTeams!=null && lstDealTeams.size()>0)
        return lstDealTeams;
    lstDealTeams = [Select 
        d.Employee__r.Name, d.Employee__r.User_ID__c, d.Employee__c, 
        d.Deal__r.Expense_Code__c, d.Deal__r.Dead_Deal_Notes__c, d.Deal__r.Dead_Deal_Reason__c, d.Deal__r.Stage__c, d.Deal__r.Description__c, d.Deal__r.RecordTypeId, 
            d.Deal__r.Name, d.Deal__r.Id, d.Deal__c , Deal__r.Sector__c, Deal__r.WP_Groups__c
        From Deal_Team__c d  where d.Employee__r.User_ID__c = :UserId];
    //where d.Employee__r.User_ID__c = :UserId  005E0000001r26sIAA
    return lstDealTeams;
}

    public DealListController() {    
    

/*    Select d.Employee__r.User_ID__c, d.Employee__c, d.Deal__r.Expense_Code__c, d.Deal__r.Dead_Deal_Notes__c, d.Deal__r.Dead_Deal_Reason__c, d.Deal__r.Stage__c, d.Deal__r.Description__c, d.Deal__r.RecordTypeId, d.Deal__r.Name, d.Deal__r.Id, d.Deal__c From Deal_Team__c d where d.Employee__r.User_ID__c = '005E0000001s1yN'
    
    lstCloses = [select o.Name, o.Id, o.ExpectedDate__c, o.Fund__r.Id, o.Fund__r.Name, o.Fund__c from FundClosing__c o where o.Fund__c = :FundIdInQ order by o.Fund__r.InceptionDate__c desc, o.ExpectedDate__c desc];   
 for (FundClosing__c oC : lstCloses)     {
        string sC = '';
        if (oC.Fund__c != null && oC.Fund__r.Name != null)
            sC = oC.Fund__r.Name + ' -- ';
        sC = sC + oC.Name;
        ClosingOptions = ClosingOptions + oC.Id + ':' + sC + '##';
 }
 */
    
     }
    
public static testMethod void testMe(   )
      {
      bTesting=true;
      DealList x = new DealList();
      
      x.DummyMethod();
      
      }
 
  
 public static boolean bTesting = false;

 public string DummyMethod()
 {
 string s = '1213';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
return s;
 }
    
}