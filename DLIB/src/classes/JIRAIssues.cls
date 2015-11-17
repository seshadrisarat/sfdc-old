public class JIRAIssues {

  public integer total;
  public list<Issue> issues;
  
  public String fields;
  public String jql;
  public Boolean isMigration = false;
  public Integer maxResults;
  public Integer startAt;

  public JIRAIssues(String fields, String jql) {
    this.fields = fields;
    this.jql = jql;
  }

  public JIRAIssues(String fields, String jql, Boolean isMigration, Integer maxResults, Integer startAt) {
    this.fields = fields;
    this.jql = jql;
    this.isMigration = isMigration;
    this.maxResults = maxResults;
    this.startAt = startAt;
  }

  public void getIssues() {
    HttpResponse res;
    system.debug(jql);
    JIRARequest jr = new JIRARequest(fields,jql,maxResults,startAt);
    jr.TEST_FLAG = 1;
    jr.sendrequest();
    try {
      res = jr.res;
          JIRAIssues obj = (JIRAIssues) System.JSON.deserialize(res.getBody(), JIRAIssues.class);
          List<SF_Issue__c> lstIssues = new List<SF_Issue__c>();
          SF_Issue__c curIssue;
          set<string> setProjectJIRANames = new set<string>();
          map<string,Id> mapProjectName2Ids = new map<string,Id>();
          map<string,Id> mapJIRAUserName2Ids = new map<string,Id>();
          map<string,string> mapIssue2Assignee = new map<string,string>();
          map<string,string> mapIssue2Reporter = new map<string,string>();
          map<string,string> mapIssue2OATaskId = new map<string,string>();
          if (obj!=null) {
            for (Issue iss:obj.issues) {
              curIssue = new SF_Issue__c(Worklogs_Needed__c = true);
                    curIssue.Name = iss.key;
                    curIssue.Id__c = iss.id;
                    curIssue.Subject__c = iss.fields.summary == null ? null : iss.fields.summary.left(254);
                    curIssue.Description__c = iss.fields.description == null ? null : iss.fields.description.left(32767);
                    curIssue.Time_Spent_JIRA__c = iss.fields.timetracking.timeSpentSeconds;
                    curIssue.Original_Estimate__c = iss.fields.timetracking.originalEstimateSeconds;
                    curIssue.Remaining_Estimate__c = iss.fields.timetracking.remainingEstimateSeconds;
                    curIssue.OA_Task_Id__c = iss.fields.customfield_10233;
                    curIssue.Jira_Issue_Name__c = iss.key;

                    setProjectJIRANames.add(iss.key.substring(0,iss.key.indexOf('-')));
                    lstIssues.add(curIssue);
                    
                    if (iss.fields.assignee!=null) mapIssue2Assignee.put(iss.id,iss.fields.assignee.name);
                    if (iss.fields.reporter!=null) mapIssue2Reporter.put(iss.id,iss.fields.reporter.name);
            }
          }


          for (pse__Proj__c item:[Select Id, JIRA_Project_Name__c FROM pse__Proj__c WHERE JIRA_Project_Name__c IN :setProjectJIRANames])
            {
              mapProjectName2Ids.put(item.JIRA_Project_Name__c, item.Id);
            }
            
            for (Contact item:[Select Id, JIRA_User_Name__c FROM Contact WHERE RecordType.DeveloperName = 'Employee' AND 
                    (JIRA_User_Name__c IN :mapIssue2Assignee.values() OR JIRA_User_Name__c IN :mapIssue2Reporter.values()) limit 10000]) {
              mapJIRAUserName2Ids.put(item.JIRA_User_Name__c, item.Id);     
            }

            if(isMigration) {
              for(project_task__c p : [select project__r.jira_project_name__c, OA_Project_Id__c, OA_Project_Task_Id__c, OA_Project_Task_Id_Number__c 
                                      from Project_Task__c 
                                      where project__r.jira_project_name__c in :setProjectJIRANames]) {
                mapIssue2OATaskId.put(p.project__r.jira_project_name__c + '-' + p.OA_Project_Task_Id_Number__c, p.OA_Project_Task_Id__c);
              }
              
            }     

            string projectname;
            for (SF_Issue__c item:lstIssues)
            {
              projectname = item.Name.substring(0,item.Name.indexOf('-'));
              if (mapProjectName2Ids.containsKey(projectname)) {
                item.Project__c = mapProjectName2Ids.get(projectname);
              }
              if (mapJIRAUserName2Ids.containsKey(mapIssue2Assignee.get(item.Id__c))) item.Assignee__c = mapJIRAUserName2Ids.get(mapIssue2Assignee.get(item.Id__c));
              if (mapJIRAUserName2Ids.containsKey(mapIssue2Reporter.get(item.Id__c))) item.Reporter__c = mapJIRAUserName2Ids.get(mapIssue2Reporter.get(item.Id__c));
              if(isMigration) {
                if (mapIssue2OATaskId.containsKey(projectname + '-' + item.OA_Task_Id__c)) item.Milestone__r = new pse__Milestone__c(Legacy_OA_Project_Task_Id__c = mapIssue2OATaskId.get(projectname + '-' + item.OA_Task_Id__c));
              }
            }

      
            if (lstIssues.size()>0) upsert lstIssues Id__c;
        
        } catch (System.CalloutException e) {
            System.debug(res.toString());
      }
  }

  public static Integer createSFIssues( String sJQL, Integer nMaxResults, Integer nStartAt ) {
      JiraWrappers.HTTP_Response oResponse;
      try {
          String sBody = new JIRARequest( sJQL, nMaxResults, nStartAt ).sendRequest().getBody();
          oResponse = getResponse( sBody );
          JiraMethods.upsertWorklogs( oResponse.issues );
          return oResponse.total;
      } catch ( Exception e ) {
          System.debug(
              '### Exception: ' + e.getMessage() + '; line: ' + e.getLineNumber() + 
              '\n### oResponse : ' + oResponse
          );
      }
      return -1;
  }

  private static JiraWrappers.HTTP_Response getResponse( String sBody ) {
      if ( Test.isRunningTest() ) {
          JiraWrappers.HTTP_Response oResult = new JiraWrappers.HTTP_Response();
      }

      return ( JiraWrappers.HTTP_Response )System.JSON.deserialize( sBody, JiraWrappers.HTTP_Response.class );
  }
  
  public class Issue {
      public String id;
      public String key;
      public Field fields;
    }
  
    public class Field {
      public String description;
      public String summary;
      public Comment comment;
      public Timetracking timetracking;
      public JIRAUser reporter;
      public JIRAUser assignee;
      public list<Version> versions;
      public String customfield_10233;
    }
  
    public class Comment {
      public integer total;
        public list<Comments> comments;
    }
  
   public class Comments {
        public String id;
        public String self;
        public String body;
        public String created;
        public String updated;
   }
   
   public class Timetracking {
        public String remainingEstimate;
        public String timeSpent;
        public integer originalEstimateSeconds;
        public integer remainingEstimateSeconds;
        public integer timeSpentSeconds;
   }
   
   public class JIRAUser {
      public String name;
        public String emailAddress;
        public String displayName;
    }
    
    public class Version {
      public String id;
        public String name;
    }
}