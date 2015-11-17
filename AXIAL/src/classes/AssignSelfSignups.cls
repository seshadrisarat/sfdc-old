global class AssignSelfSignups implements Schedulable {
	global void execute(SchedulableContext sc) {
		SelfSignupUtility c = new SelfSignupUtility();
		c.assignSelfSignups();
	}
}