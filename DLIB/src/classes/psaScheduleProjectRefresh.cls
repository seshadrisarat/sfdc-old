/*
 * \author Vladimir Dobrelya
 * \date Feb 7, 2014
 * \see https://silverline.jira.com/browse/SLFF-18
 */
global class psaScheduleProjectRefresh implements Schedulable {
	global void execute( SchedulableContext sc ) {
		Database.executeBatch( new psaBatchProjectRefresh(), 10 );
	}
}