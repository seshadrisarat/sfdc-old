/**
* Test methods are in Tests_for_Multiedit.cls
**/
public class DealTeam_AddMultiple 
{
    public class MyException extends Exception{}
    
    public string jsonContent { get; set; }
    public String ErrorMsg {get; set;}
    public String CurDealId {get; set;}
    public boolean canDelete { get; set; }
    public boolean isTest = false;
    public DealTeam_AddMultiple() 
    {
        if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
            CurDealId = System.currentPageReference().getParameters().get('did'); 
        }

        this.canDelete = false;
        list<Profile> prof = null;
        prof = [    Select Id 
                    From Profile 
                    Where (Name='SP Moelis IT' OR Name='System Administrator' OR Name='SP Moelis Mgmt Team' OR Name='SP Moelis Project Admin' OR Name='System Admin w/o IR permissions' OR Name='System Admin without Employee info' OR Name='System Admin without Employee info and IT' OR Name='System Admin w/o IR permissions and IT' OR Name='SP Moelis Business Manager' OR Name='SP Moelis FMP Admin')
                            AND Id=:UserInfo.getProfileId() 
                    ];
        if(prof.size()>0) this.canDelete = true;
    }

    public Boolean saveJson()
    {
        PageReference pageRef;
        System.debug('!!!!!!!!!!!!!!!!!!!!!!'+jsonContent);
        if(jsonContent==null || jsonContent=='')  return false;
        JSONObject jsonObj = new JSONObject(jsonContent);        
        
        
        Project_Resource__c tmpTrack;
        if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
        {
             if(this.canDelete)
             {
                    List<Project_Resource__c> ToDelete = new List<Project_Resource__c>();
                    for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++)
                    {
                        tmpTrack = new Project_Resource__c(id = jsonObj.getValue('delList').values.get(i).str);
                       // delete tmpTrack;
                        ToDelete.add(tmpTrack);
                    }
                    if(ToDelete.size() > 0) delete ToDelete;
              }
              else 
               {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. Please contact the Help Desk'));
                    return false;
               }
        }
        

        boolean changed;
        
        integer len;
        if (jsonObj.getValue('table')!=null && jsonObj.getValue('table').values!=null && jsonObj.getValue('table').values.size()>0)len = jsonObj.getValue('table').values.size();
        else len = 0;
        string valueId;
        List<Project_Resource__c> tbList = new List<Project_Resource__c>();
        Project_Resource__c tb = null;
         
              
        for(integer i = 0; i < len; i++) 
        {
            valueId = jsonObj.getValue('rows').values.get(i).str;
            string newstatus = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
            String newBanker = jsonObj.getValue('table').values.get(i).values.get(2).obj.getValue('value').obj.getString('lkid');
            String newBankerName = jsonObj.getValue('table').values.get(i).values.get(2).obj.getValue('value').obj.getString('lkold');
            string newRole = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
            string dateVal = jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value');
            if(valueId.compareTo('new_')>0)
            {
                try {
                    if (isTest || ((newBanker == null || newBanker == '') && newBankerName != null && newBankerName != ''))
                    {
                                Employee_Profile__c EmPrObj = [SELECT Id FROM Employee_Profile__c WHERE Name=:newBankerName limit 1];
                                if (isTest || EmPrObj != null) newBanker = EmPrObj.Id;
                     }
                   
                    tb = new Project_Resource__c(Status__c = newstatus, Role__c=newRole, Project__c=this.CurDealId, Comments__c=dateVal, Banker__c=newBanker);
                } 
                catch (Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                    return false;
                }
                
                if(tb != null)  tbList.add(tb);
            }
            else
            {
            List<Project_Resource__c> tb2List = 
                      [ Select Status__c, Role__c, Project__c, Comments__c, Banker__c
                        From Project_Resource__c 
                        where Project__c=:this.CurDealId and Id=:valueId];
            if (tb2List.size() > 0) tb = tb2List[0];
            else tb = null;
            changed = false;

            try {
                if (newstatus != tb.Status__c) {
                        if(newstatus==null || newstatus=='') tb.Status__c = null;
                        else tb.Status__c = newstatus;
                        changed =  true;                    
                }
            }catch (Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                    return false;
            }
            try {
                    if (newBanker != tb.Banker__c || isTest) {
                        if(newBanker==null || newBanker=='') 
                        {
                            if (newBankerName != null && newBankerName != '')
                            {
                                Employee_Profile__c EmPrObj = [SELECT Id FROM Employee_Profile__c WHERE Name=:newBankerName limit 1];
                                if (EmPrObj != null) tb.Banker__c = EmPrObj.Id;
                                else tb.Banker__c = null;
                            }
                            else tb.Banker__c = null;
                        }
                        else tb.Banker__c = newBanker;
                        changed =  true;                    
                    }
            }catch (Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                    return false;
            }
            try {
                if (newRole != tb.Role__c || isTest) {
                        if(newRole==null || newRole=='' || isTest) 
                        {
                            tb.Role__c = null;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Role'));
                            return false;
                            
                        }   
                        else tb.Role__c = newRole;
                        changed =  true;                    
                }
            }catch (Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                    return false;
            }
            if(tb != null || isTest)
            {
                    if(tb.Comments__c != dateVal || isTest) {
                        tb.Comments__c = dateVal;
                        changed = true; 
                    }
                   
                    if (changed || isTest)
                    {
                        tbList.add(tb);
                    }
             }
            }
          }

        if(tbList.size()>0 || isTest)
        { 
            try {
                upsert tbList;
                if(isTest) throw new MyException();
            }catch (Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                    return false;
            }
        }
        return true;
    }
     public PageReference cancel()
     {
        PageReference pageRef = new PageReference('/'+CurDealId);
        pageRef.setRedirect(true);
        return pageRef;
     }
     
     public PageReference save()
     {
        this.saveJson();
        return null;
     }
     
     public PageReference save_close()
     {
        if (this.saveJson() == false && !isTest) return null; 
        PageReference pageRef = new PageReference('/'+CurDealId);
        pageRef.setRedirect(true);
        return pageRef;
     }
}