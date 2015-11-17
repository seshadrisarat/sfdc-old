public with sharing class SROC_GetUserTimeZone {

	public Timezone userTimezone {get;private set;}	//To store Time Zone of the context user

	//Constructor
	public SROC_GetUserTimeZone(ApexPages.StandardController controller) {

		userTimezone = UserInfo.getTimeZone();
	}
}