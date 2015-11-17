public class addStandardMilestones {
    String result;
                
    public PageReference init() {
        result = AddStandardMilestones();
        PageReference page = new PageReference('/apex/bulkEditMilestone?id=' + getID());
        page.setRedirect(true);

        return page;
    }
    
    public String getResult() {
        return result;
    }
    
    public String getID() {
        return System.currentPageReference().getParameters().get('id');
    }
        
    public String AddStandardMilestones() {
        String result;
        //get id, existing milestone count 
        String projectID = System.currentPageReference().getParameters().get('id');
        Integer milestonesCount = [select count() from milestones__c where Project__c = :System.currentPageReference().getParameters().get('id')];
              
        // get default list of milestones to insert to Project Milestones
        List<Milestones_Standard_List__c> defaultMilestoneList = [Select Name, Phase__c, Progress__c, Status__c  from Milestones_Standard_List__c order by Order_Sequence__c asc LIMIT 500];   

        //check if milestones already exist
        if (milestonesCount < 1) {      
            //create Milestone records for a Project based on a standard list
            List<Milestones__c> milestonesToInsert = new List<Milestones__c>();
            
            // iterate through each default milestone to add
            for (Milestones_Standard_List__c defaultMilestone : defaultMilestoneList) {
            Milestones__c milestone = new Milestones__c(
                Project__c = projectID,
                Name = defaultMilestone.Name, 
                Status__c = defaultMilestone.Status__c, 
                Phase__c = defaultMilestone.Phase__c, 
                Progress__c = defaultMilestone.Progress__c);
                System.debug('milestone: ' + milestone);
                milestonesToInsert.add(milestone);  // add to list
    }
                System.debug('milestonesToInsert: ' + milestonesToInsert);
       
        if (!milestonesToInsert.isEmpty())
              try {   
                insert milestonesToInsert;
            } catch (exception e) {
                System.debug(e.getMessage());
            }
            result = 'Milestones added.';
        } else {
            result = 'Milestones already exist. None added.';
        }
        return result;
    }
}