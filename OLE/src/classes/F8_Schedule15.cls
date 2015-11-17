global class F8_Schedule15 Implements Schedulable
{
/*
    Created by: Alex Romanchuk
    Created Date: 06/18/2014
    Description: Main scheduler - every 15 min. 
        Do not change, leave scheduled job. All modifications to the scheduled apex jobs have to be done in F8_Schedule15MinImplementation
    If job was unscheduled use:
    
        F8_Schedule15Min s_job = new F8_Schedule15Min();
        //for every 15 min: 
        String cron_value = '15 * * * * ? *'; 
        String jobID = system.schedule('F8_Schedule15Min', cron_value, s_job);
        system.debug('@@@INFO jobID='+jobID);
*/
  public Interface IF8Schedule
  {
    void execute(SchedulableContext sc);
  }

  global void execute(SchedulableContext sc)
  {
    Type targettype = Type.forName('F8_Schedule15MinImplementation');
    if(targettype!=null)
    {
      IF8Schedule obj = (IF8Schedule)targettype.NewInstance();
      obj.execute(sc);
    }
  }
}