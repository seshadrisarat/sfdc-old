/****************************************************************************************
Name            : psaTimecardAlertSchedule
Author          : CLD
Created Date    : April 17, 2013
Description     : Schedule Timecard Alert process

NOTE TO SCHEDULE THE TIMECARD ALERT PROCESS RUN A SCRIPT LIKE THIS IN THE SYSTEM CONSOLE:

String seconds = '0'; //Execute at Zero Seconds
String minutes = '0'; //Execute at top of every hour (:00 minute)
String hours = '1,13'; // Execute at 1:00am and 1:00pm
String month = '*'; //Execute every month
String dayOfWeek = '?'; //Execute on every day of weeek
String year = '*'; //Execute every year
String sch = seconds + ' ' + minutes + ' ' + hours + ' * ' + month + ' ' + dayOfWeek + year;
psaResourceAvailabilitySchedule ras = new psaTimecardAlertSchedule();
system.schedule('PSA Timecard Alert at 01:00 & 13:00', sch, ras);

******************************************************************************************/
global class psaTimecardAlertSchedule implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        integer BATCH_SIZE = 40;  
        
        psaTimecardAlertBatch psaTimecardAlertBatch = new psaTimecardAlertBatch();
        system.debug('**** psaTimecardAlertSchedule: starting batch exection*****************');
        Id batchId = database.executeBatch(psaTimecardAlertBatch, BATCH_SIZE);    
        
        system.debug('**** psaTimecardAlertSchedule: Batch executed batchId: ' +batchId); 
    }
}