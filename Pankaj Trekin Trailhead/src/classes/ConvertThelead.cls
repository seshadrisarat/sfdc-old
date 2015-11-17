public class ConvertThelead
{
     public ConvertThelead()
     {
     
     }
     
     public pageReference LeadToConvert()
    {
           Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId('00Q28000000xlKl');
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            //lc.setAccountId('00128000002MrSZ');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            return new pageReference('/'+lcr.getOpportunityId()+'/e');
    }
}