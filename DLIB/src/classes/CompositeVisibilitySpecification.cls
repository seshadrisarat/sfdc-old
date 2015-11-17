public with sharing class CompositeVisibilitySpecification implements IVisibilitySpecification {
	
	private List<IVisibilitySpecification> specifications = new List<IVisibilitySpecification>();
	
	public Boolean isEmpty() {
		return specifications.isEmpty();
	}
	
	public void add(IVisibilitySpecification s) {
		specifications.add(s);
	}
	
	public Boolean satisfiedBy(SObject candidate) {
		for(IVisibilitySpecification s : specifications) {
			if(!s.satisfiedBy(candidate)) return false;
		}
		return true;		
	}
	
	/*
	* optimization purpose, reduces loop iterations
	*/
	public IVisibilitySpecification compile() {				
		return specifications.size() == 1 ? specifications[0] : this;
	}
}