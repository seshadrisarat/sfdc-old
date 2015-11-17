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

		Attachment objAttachment=new Attachment(Name='Unit Test Attachment',
												Body=Blob.valueOf('Unit Test Attachment Body'),
												ParentId=objTask.Id);
        insert objAttachment;

        objAttachmentController.attachment = new Attachment(Name='Test Attachment',
        													Body=Blob.valueOf('Unit Test Attachment Body'));
        objAttachmentController.strRemovedAttachments = objAttachment.Id;
		objAttachmentController.save();

		objAttachmentController.sobjId = '';
		objAttachmentController.save();
	}
}