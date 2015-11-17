@isTest
public class SL_TestAttachmentController{

	static testMethod void unitTestCode() {

		Task objTask = new Task();
		objTask.Subject = 'Test Task';
		insert objTask;
		ApexPages.currentPage().getParameters().put('id', objTask.Id);

		SL_AttachmentController objAttachmentController = new SL_AttachmentController();

		objAttachmentController.getAttachments();
		objAttachmentController.refreshAttachments();

		Attachment objAttachment = new Attachment(Name='Unit Test Attachment',
												Body=Blob.valueOf('Unit Test Attachment Body'),
												ParentId=objTask.Id);
        insert objAttachment;

        objAttachmentController.attachments = new List<Attachment>{
        																new Attachment(Name='Test Attachment1', Body=Blob.valueOf('Unit Test Attachment Body1')),
        																new Attachment(Name='Test Attachment2', Body=Blob.valueOf('Unit Test Attachment Body2'))
        														};

        objAttachmentController.strRemovedAttachments = objAttachment.Id;
		objAttachmentController.save();

		objAttachmentController.sobjId = '';
		objAttachmentController.save();
	} 
}