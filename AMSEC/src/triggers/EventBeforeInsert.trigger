trigger EventBeforeInsert on Event (before insert) {
	ActivityUtils.updateIndustryGroupCoverages(trigger.new);
}