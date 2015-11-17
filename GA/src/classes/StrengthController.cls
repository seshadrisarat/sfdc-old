public class StrengthController
{
    public Id contactId;
    public List<SelectOption> strength;
    public String selectedOption {get;set;}
    public List<Relationship_Strength__c> strengthList {get;set;}

    public StrengthController(ApexPages.StandardController controller) 
    {
        contactId = controller.getRecord().Id;
        strengthList = [select Id, Relationship_Strength__c from Relationship_Strength__c where Contact__r.Id = :contactId and User__r.Id = :UserInfo.getUserId()];
        strength = getStrength();
        selectRelationship(contactId);
    }
    
    public List<SelectOption> getStrength() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('', 'None')); 
        options.add(new SelectOption('Low', 'Low'));
        options.add(new SelectOption('Medium', 'Medium'));
        options.add(new SelectOption('Strong', 'Strong'));
        return options; //return the picklist options
    }
    
    public void selectRelationship(Id contactId)
    {
        //List<Relationship_Strength__c> strength = [select Id, Relationship_Strength__c from Relationship_Strength__c where Contact__r.Id = :contactId and User__r.Id = :UserInfo.getUserId()];
        if(strengthList.size() > 0)
        {
            selectedOption = strengthList[0].Relationship_Strength__c;
        }
    }
    
    public PageReference save()
    {
        //List<Relationship_Strength__c> strength = [select Id, Relationship_Strength__c from Relationship_Strength__c where Contact__r.Id = :contactId and User__r.Id = :UserInfo.getUserId()];
        if(strengthList.size() > 0)
        {
            strengthList[0].Relationship_Strength__c = selectedOption;
        }
        else
        {
            Relationship_Strength__c str = new Relationship_Strength__c(Relationship_Strength__c =selectedOption,
                                                                        Contact__c = contactId, User__c = UserInfo.getUserId() );
            strengthList.add(str);                                                           
        }
        upsert strengthList;
        return null;
    }

}