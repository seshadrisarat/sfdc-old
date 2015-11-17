/**
 * @Author      : Edward Rivera
 * @ClassName   : SL_Opportunity_Error
 * @CreatedOn   : 23 Oct 2014
 * @Test        : SL_Test_Opportunity_Error
 * @Description : This is a package of data linking an opportunity to an error message when it fails to validate properly
 */
public with sharing class SL_Opportunity_Error {
	
	private ID id;
	private String error;
	private String opportunityName;

	public SL_Opportunity_Error(ID id, String error, String opportunityName) {
		this.id = id;
		this.error = error;
		this.opportunityName = opportunityName;
	}

	public ID getId (){ return id; }
	public String getError (){ return error; }
	public String getName (){ return opportunityName; }
}