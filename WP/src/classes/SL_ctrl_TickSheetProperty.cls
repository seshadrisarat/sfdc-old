/*
 * \author Vladimir Dobrelya
 * \date July 22, 2013
 * \see https://silverline.jira.com/browse/WP-102
 */
public with sharing class SL_ctrl_TickSheetProperty {
	private SL_model_TickSheetProperty oEngine;
	public List<SL_TickSheet.Section> Sections {
		get { return this.oEngine.aSections; }
	}
	public Contact EmployeeContact {
		get { return this.oEngine.oEmployeeContact; }
	}
	public List<SelectOption> AvailableTicksheets {
		get { return this.oEngine.aAvailableTicksheet; }
	}
	public String CurrentTicksheet {
		get {
			return this.oEngine.sCurrentTicksheet;
		} set {
			this.oEngine.sCurrentTicksheet = value;
		}
	}
	
	public SL_ctrl_TickSheetProperty() {
		this.oEngine = new SL_model_TickSheetProperty();
	}
	
	public PageReference ChangeTicksheet() {
		return this.oEngine.changeTicksheet();
	}
	public PageReference Save() {
		return this.oEngine.Save();
	}
	public PageReference Cancel() {
		return this.oEngine.Cancel();
	}
	public Boolean getButtonDisabled() {
		return this.oEngine.bButtonDisabled;
	}
}