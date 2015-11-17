global class F8_ScheduleMain Implements Schedulable
{
/*
    Created by: Alex Romanchuk
    Created Date: 05/22/2014
    Description: Main scheduler. 
        Do not change, leave scheduled job. All modifications to the scheduled apex jobs have to be done in F8_ScheduleImplementation
    If job was unscheduled use:
    
        F8_ScheduleMain s_job = new F8_ScheduleMain();
        //for every hour: 
        //String cron_value = '0 0 * * * ? *'; 
        //for every day: 
        String cron_value = '0 0 1 * * ? *'; 
        String jobID = system.schedule('F8_ScheduleMain', cron_value, s_job);
        system.debug('@@@INFO jobID='+jobID);
*/
  public Interface IF8Schedule
  {
    void execute(SchedulableContext sc);
  }

  global void execute(SchedulableContext sc)
  {
    Type targettype = Type.forName('F8_ScheduleImplementation');
    if(targettype!=null)
    {
      IF8Schedule obj = (IF8Schedule)targettype.NewInstance();
      obj.execute(sc);
    }
  }
}