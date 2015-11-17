/**
 * Container class for various filtering implementations (for the sake of organization)
 */
public with sharing class MDFLineFilters {

	public class SubscriberOrgFilter implements MDFLineFilter {
		private String subscriberOrgId;
		
		public SubscriberOrgFilter(String subscriberOrgId) {
			this.subscriberOrgId = subscriberOrgId;		
		}
		
		public Boolean matches(MDFDataModel model) {
			if (model == null) {
				return false;
			}
			
			if (subscriberOrgId == null) {
				return subscriberOrgId == model.subscriberOrgId;
			}
			else {
				return subscriberOrgId.equals(model.subscriberOrgId);
			}
		}
		
	}
}