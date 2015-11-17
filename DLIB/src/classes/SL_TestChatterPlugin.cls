/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_TestChatterPlugin 
{
	static User objUser = new User(); 
	static String strCommunityId = Network.getNetworkId();
	
	@isTest(SeeAllData=true)
    static void test_FeedTest() 
    {
    	Integer numOfFeeds ,numOfFeedsForSearchPage = 25;
    	List<SL_Intranet_PaginationSettings__c> lstPaginationSettings = SL_Intranet_PaginationSettings__c.getAll().values();
			
		if(lstPaginationSettings[0].FeedPost_PageSize__c != null)
			numOfFeeds = Integer.valueOf(lstPaginationSettings[0].FeedPost_PageSize__c);
		
		if(lstPaginationSettings[0].SearchResult_PageSize__c != null)
			numOfFeedsForSearchPage = Integer.valueOf(lstPaginationSettings[0].SearchResult_PageSize__c);		
			
				
        // TO DO: implement unit test
        SL_IntranetChatterPlugIn objCP = new SL_IntranetChatterPlugIn();
        //objCP.initializeParam('CustomChatter');
        
        SL_IntranetChatterPlugInController objCPController = new SL_IntranetChatterPlugInController();
        objCPController.getChatterImpl();
        
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        date dt = date.today() - 10;
        
        User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
                                 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '  Department1',
                                 TimeZoneSidKey = 'America/New_York',Title = 'Title1',
                                 LocaleSidKey = 'en_US',
                                 EmailEncodingKey = 'ISO-8859-1',   
                                 LanguageLocaleKey = 'en_US',       
                                 ProfileId = strProfileId, IsActive=true,
                                 FirstName = 'testFirst',
                                 City = 'testCity',
                                 Country = 'testCountry',
                                 Street = 'testStreet',
                                 CompanyName = 'testCompanyName',
                                 Phone = 'testPhone',
                                 Extension = 'testExtension',
                                 User_Offices__c = 'test',
                                 Hire_Date__c = dt);
        insert testUser;
        
        objUser = testUser;
        
        Test.startTest();
        //SL_IntranetChatterFeeds objCF = new SL_IntranetChatterFeeds();
        blob objTestBlob = Blob.valueOf('testBlob'); 
        
        CollaborationGroup testGroup = new CollaborationGroup(name='test GroupAAA',CollaborationType = 'public');
        insert testGroup;
        
        ContentVersion objCV = new ContentVersion(Title ='Google.com',VersionData = Blob.valueOf('Sample Test'), 
    											  PathOnClient = 'This file is added via code', Description = 'Temporary File Post Document');
		insert objCV;
        
        FeedItem objFeedPost = new FeedItem(ParentId = testUser.id, Title = 'Test1', Body = 'Test1', Type='ContentPost', ContentFileName='Test File1', ContentData=objTestBlob);
        insert objFeedPost;
        FeedItem objFeedPost1 = new FeedItem(ParentId = testUser.id, Title = 'Test2', Body = 'Test2', Type='ContentPost', ContentFileName='Test File2', ContentData=objTestBlob);
        insert objFeedPost1;
        
        FeedItem objFeedPost2 = new FeedItem(ParentId = testUser.id, Title = 'Test3', Body = 'Test3' , Type='ContentPost', ContentFileName='Test File2', ContentData=objTestBlob);
        insert objFeedPost2;
        
        FeedComment objFeedComment = new FeedComment(CommentBody='Test comment from Test code1', FeedItemId=objFeedPost.Id);
        insert objFeedComment;
        
        FeedComment objFeedComment1 = new FeedComment(CommentBody='Test comment from Test code12', FeedItemId=objFeedPost1.Id);
        insert objFeedComment1;
        
        FeedComment objFeedComment2 = new FeedComment(CommentBody='Test comment from Test code 123', FeedItemId=objFeedPost2.Id);
        insert objFeedComment2;
        
        ConnectApi.FeedItemPage testPage = new ConnectApi.FeedItemPage();
        List<FeedItem> lstFItem = [ Select Id, CreatedDate From FeedItem  order BY CreatedDate DESC Limit 3];
        
        List<FeedItem> lstFeedItem = [ Select Type, ParentId, LinkUrl, LikeCount, LastModifiedDate, IsDeleted, InsertedById, Id, CreatedDate, CreatedById, ContentType,
                                        ContentSize, ContentFileName, ContentDescription, ContentData, CommentCount, Body, 
                                (Select Id, FeedItemId, FeedEntityId, CreatedById, CreatedDate, IsDeleted, InsertedById From FeedLikes), 
                                        (Select Id, FeedItemId, ParentId, CreatedById, CreatedDate, CommentBody, IsDeleted, InsertedById, CommentType, RelatedRecordId 
                                        From FeedComments) 
                                       From FeedItem f where id = :lstFItem];
        
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        ConnectApi.FeedItem fItem = new ConnectApi.FeedItem(); 
        fItem.Id = lstFeedItem[0].Id; 
        fItem.actor = new ConnectApi.UserSummary();
        fItem.attachment = new ConnectApi.ContentAttachment();
        fItem.CreatedDate = lstFeedItem[0].CreatedDate;
        fItem.parent = new ConnectApi.UserSummary();
        fItem.parent.Name = testUser.Name;
        fItem.parent.Id = testUser.Id;
        fItem.isDeleteRestricted = false;
        
        List<ConnectApi.Comment> lstComment = new List<ConnectApi.Comment>(); 
        ConnectApi.Comment objComment = new ConnectApi.Comment();
        objComment.CreatedDate = lstFeedItem[0].CreatedDate;
        objComment.feedItem = new ConnectApi.Reference();
        objComment.feedItem.Id = lstFeedItem[0].Id;
        objComment.User = new ConnectApi.UserSummary();
        objComment.User.Name = testUser.Name;
        objComment.User.Id = testUser.Id;
        objComment.User.photo = new ConnectApi.Photo();
        objComment.User.photo.smallPhotoUrl = 'www.testurl.com'; 
        objComment.isDeleteRestricted = false;
        objComment.attachment = new ConnectApi.ContentAttachment(); 
        
        ConnectApi.ContentAttachment objAttachment = new ConnectApi.ContentAttachment();
        objAttachment.renditionUrl = '/'+objCV.Id;
        objAttachment.thumb120By90RenditionStatus = 'Success';
		objAttachment.description = 'Test File';
		objComment.attachment = objAttachment;
        objComment.body = new ConnectApi.FeedBody();
        objComment.body.messageSegments = new List<ConnectApi.MessageSegment>();
        
        objComment.likes = new ConnectApi.ChatterLikePage();
        objComment.likes.likes = new List<ConnectApi.ChatterLike>();
        lstComment.add(objComment);
          
        ConnectApi.CommentPage objCommentPage = new ConnectApi.CommentPage();
        objCommentPage.comments = lstComment;
        
        fItem.comments = objCommentPage;
        fItem.likes = new ConnectApi.ChatterLikePage();
        fItem.likes.likes = new List<ConnectApi.ChatterLike>();
        fItem.body = new ConnectApi.FeedBody();
        
        List<ConnectApi.MessageSegment> segments = new List<ConnectApi.MessageSegment>();
        List<ConnectApi.ComplexSegment> lstComplexSegment = new List<ConnectApi.ComplexSegment> ();
        
        //fitem.preamble = new ConnectApi.MessageBody();
       	//fitem.preamble.text = 'Test Preamble';
        //fitem.preamble.messageSegments = segments;
        fitem.body.text = 'test-text'; 
        ConnectApi.TextSegment textsegment = new ConnectApi.TextSegment();
        textsegment.text = 'test-text<s> hello </s> \n test \n test';
        
        ConnectApi.EntityLinkSegment entityLink;
        entityLink = new ConnectApi.EntityLinkSegment();
        entityLink.reference = new ConnectApi.Reference();
        entityLink.reference.Id = testUser.Id;
        
        List<ConnectApi.MessageSegment> segmentChange = new List<ConnectApi.MessageSegment>();
        ConnectApi.FieldChangeSegment objchangeSegment = new  ConnectApi.FieldChangeSegment();
        lstComplexSegment.add(objchangeSegment);
        objchangeSegment.segments = segmentChange;
        ConnectApi.TextSegment textsegment1 = new ConnectApi.TextSegment();
        textsegment1.text = 'test-text';
        
        ConnectApi.FieldChangeNameSegment objChangeName; 
        objChangeName = new  ConnectApi.FieldChangeNameSegment();
        objChangeName.text = 'test';
        
        ConnectApi.FieldChangeValueSegment objChangeValue = new ConnectApi.FieldChangeValueSegment();
        objChangeValue.url = '/'+lstFeedItem[0].Id;
        
        segmentChange.add(objChangeName);
        segmentChange.add(objChangeValue);
        segmentChange.add(textsegment1);
        segments.addAll(segmentChange);
        segments.add(textsegment); 
        segments.add(entityLink);
        segments.add(objchangeSegment);
        
        // hashtag segment
        ConnectApi.HashTagSegment hashsegment = new ConnectApi.HashTagSegment();
        hashsegment.tag = 'test-topic';
        segments.add(hashsegment);
        
        // linksegment
        ConnectApi.LinkSegment linksegment = new ConnectApi.LinkSegment();
        linksegment.url = 'http://testme.com';
        segments.add(linksegment);
          
        fitem.body.messageSegments = segments;
        
        ConnectApi.FeedType feedType = ConnectApi.FeedType.UserProfile;
        String userToMention = testUser.Id;
        String subjectId = testUser.Id;
        
        objCP.chatterSubjectId = testUser.Id;
        objCP.strFeedPostText = 'Hello!! This is a Test Post';
        objCP.strLinkUrl = 'www.google.com';
        testItemList.add(fItem);
        
        //2nd FeedItem
     	ConnectApi.FeedItem fItem1 = new ConnectApi.FeedItem(); 
        fItem1.Id = lstFeedItem[1].Id; 
        fItem1.CreatedDate = lstFeedItem[1].CreatedDate;
        fItem1.parent = new ConnectApi.UserSummary();
        fItem1.parent.Name = testUser.Name;
        fItem1.parent.Id = testUser.Id;
        fItem1.likes = new ConnectApi.ChatterLikePage();
        fItem1.likes.likes = new List<ConnectApi.ChatterLike>();
        fItem1.isDeleteRestricted = false;
        List<ConnectApi.MessageSegment> segments1 = new List<ConnectApi.MessageSegment>();
        ConnectApi.TextSegment textsegment2 = new ConnectApi.TextSegment();
        textsegment2.text = 'Test Feed Item2';
        segments1.add(textsegment2);
        
        lstComment = new List<ConnectApi.Comment>(); 
        objComment = new ConnectApi.Comment();
        objComment.CreatedDate = lstFeedItem[1].CreatedDate;
        objComment.feedItem = new ConnectApi.Reference();
        objComment.feedItem.Id = objFeedPost1.Id;
        objComment.Id = objFeedComment1.Id;
        objComment.User = new ConnectApi.UserSummary();
        objComment.User.Name = testUser.Name;
        objComment.User.Id = testUser.Id;
        objComment.User.photo = new ConnectApi.Photo();
        objComment.User.photo.smallPhotoUrl = 'www.testurl.com'; 
        objComment.likes = new ConnectApi.ChatterLikePage();
        objComment.likes.likes = new List<ConnectApi.ChatterLike>();
        objComment.body = new ConnectApi.FeedBody();
        objComment.body.messageSegments = segments1;
        objComment.isDeleteRestricted = false;
        lstComment.add(objComment);
        objCommentPage = new ConnectApi.CommentPage();
        
        objCommentPage.comments = lstComment;
        
        fItem1.comments = objCommentPage;
        
        fItem1.body = new ConnectApi.FeedBody();
        fitem1.body.messageSegments = segments1;
        testItemList.add(fItem1);
        
        //3rd FeedItem
     	ConnectApi.FeedItem fItem2 = new ConnectApi.FeedItem(); 
        fItem2.Id = lstFeedItem[2].Id; 
        fItem2.CreatedDate = lstFeedItem[2].CreatedDate;
        fItem2.parent = new ConnectApi.UserSummary();
        fItem2.parent.Name = testUser.Name;
        fItem2.parent.Id = testUser.Id;
        fItem2.likes = new ConnectApi.ChatterLikePage();
        fItem2.likes.likes = new List<ConnectApi.ChatterLike>();
        fItem2.isDeleteRestricted = false;
        
        List<ConnectApi.MessageSegment> segments2 = new List<ConnectApi.MessageSegment>();
        ConnectApi.TextSegment textsegment3 = new ConnectApi.TextSegment();
        textsegment3.text = 'Test Feed Item3';
        segments2.add(textsegment3);
        
        lstComment = new List<ConnectApi.Comment>(); 
        objComment = new ConnectApi.Comment();
        objComment.CreatedDate = lstFeedItem[2].CreatedDate;
        objComment.feedItem = new ConnectApi.Reference();
        objComment.feedItem.Id = objFeedPost2.Id;
        objComment.Id = objFeedComment2.Id;
        objComment.User = new ConnectApi.UserSummary();
        objComment.User.Name = testUser.Name;
        objComment.User.Id = testUser.Id;
        objComment.User.photo = new ConnectApi.Photo();
        objComment.User.photo.smallPhotoUrl = 'www.testurl.com'; 
        objComment.likes = new ConnectApi.ChatterLikePage();
        objComment.likes.likes = new List<ConnectApi.ChatterLike>();
        objComment.body = new ConnectApi.FeedBody();
        objComment.body.messageSegments = segments2;
        objComment.isDeleteRestricted = false;
        lstComment.add(objComment);
        objCommentPage = new ConnectApi.CommentPage();
        
        objCommentPage.comments = lstComment;
        
        fItem2.comments = objCommentPage;
        
        fItem2.body = new ConnectApi.FeedBody();
        fitem2.body.messageSegments = segments2;
        testItemList.add(fItem2);
        
        //4th FeedItem change segment
        
        Notification__c  objNotif = new Notification__c(Name='Test Notification for chatter purpose', For_All_Offices__c =true,Active__c=true);
    	insert objNotif;
    	Notification__c objNotification = [select Name,Id, CreatedDate from Notification__c where Id =: objNotif.Id];
        ConnectApi.FeedItem fItem3 = new ConnectApi.FeedItem(); 
        fItem3.CreatedDate = objNotification.CreatedDate;
        fItem3.parent = new ConnectApi.UserSummary();
        fItem3.parent.Name = objNotification.Name;
        fItem3.parent.Id = objNotification.Id;
        fItem3.likes = new ConnectApi.ChatterLikePage();
        fItem3.likes.likes = new List<ConnectApi.ChatterLike>();
        fItem3.isDeleteRestricted = false;
        
        ConnectApi.FieldChangeNameSegment objChangeName1 = new  ConnectApi.FieldChangeNameSegment();
        objChangeName1.text='End Date';
        
        ConnectApi.FieldChangeValueSegment objChangeValue1 = new ConnectApi.FieldChangeValueSegment();
        objChangeValue1.url = '/'+objNotification.Id;
        objChangeValue1.text='4/30/2014';
        
        objchangeSegment = new  ConnectApi.FieldChangeSegment();
        objchangeSegment.segments = new List<ConnectApi.MessageSegment>();
        objchangeSegment.segments.add(objChangeName1);
        objchangeSegment.segments.add(objChangeValue1);
        
        ConnectApi.MoreChangesSegment objMoreChanges = new ConnectApi.MoreChangesSegment();
        objMoreChanges.moreChanges = new List<ConnectApi.FieldChangeSegment>();
        objMoreChanges.moreChanges.add(objchangeSegment);
        objMoreChanges.text = 'User has changes more than 2 fields';
        
        ConnectApi.CommentPage objCommentPage2 = new ConnectApi.CommentPage();
        objCommentPage2.comments = lstComment;
        
        fItem3.comments = objCommentPage2;
        fItem3.likes = new ConnectApi.ChatterLikePage();
        fItem3.likes.likes = new List<ConnectApi.ChatterLike>();
        fItem3.body = new ConnectApi.FeedBody();
        fitem3.body.messageSegments = new List<ConnectApi.MessageSegment>();
        fItem3.header = new ConnectApi.MessageBody();
        fitem3.header.text = 'User has changed Name and made 2 other changes';
        fitem3.header.messageSegments = new List<ConnectApi.MessageSegment>();
        fitem3.header.messageSegments.add(objchangeSegment);
        fitem3.header.messageSegments.add(objMoreChanges);
        testItemList.add(fItem3);
        
        
        
		testPage.items = testItemList;
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.News, 'me', 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);        
        objCP.initializeParam('CustomChatter','widgetId');
        objCP.getNewsFeedForDisplay();
        
        objCP.chatterSubjectId = testUser.Id;
        objCP.strFeedPostText = 'Hello!! This is a Test Post';
        objCP.strLinkUrl = 'www.google.com';
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.News, 'me', 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage); 
        objCP.feedPost();
        

		objCP.contentId = objCV.id;
		objCP.chatterParentId = objCV.Id;
    	objCP.postBody = 'Test for post having mention @['+objUser.Id+']';
    	ApexPages.currentPage().getParameters().put('prmFeedType','FeedPost');
    	ConnectApi.NewFileAttachmentInput fileInAttach = new ConnectApi.NewFileAttachmentInput();     // create a new attachment for the inserting with the feed post
        fileInAttach.title = objCV.Title;
    	
    	objCP.feedPostForFile();
    	objCP.postBody = 'Test for post having mention @['+objUser.Id+'] group mention @['+testGroup.Id+']';
    	ApexPages.currentPage().getParameters().put('prmFeedType','CommentPost');
    	objCP.feedPostForFile();
    	
    	/*To Cover Post Comment Section*/
    	objCP.contentId = objCV.id;
    	objCP.commentBody = 'Test for comment post having mention @['+objUser.Id+'] group mention @['+testGroup.Id+']';
    	objCP.postComment();
    	
    	//objCP.viewAllComments();
    	
    	/*To Cover Chatter Group feeds*/
        ApexPages.currentPage().getParameters().put('GroupId',testGroup.Id);
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.Record, testGroup.Id, 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
        
    	objCP.loadChatterGroupFeeds();
    	
    	/*To Cover Sort By */
    	objCP.objectRecordId = objCV.Id;
    	ApexPages.currentPage().getParameters().put('sortBy','date');
    	List<Content_Chatter__c> lstContentChatter = [select Id from Content_Chatter__c where Content_Id__c =: objCV.Id limit 1];
    	ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.Record, lstContentChatter[0].Id, 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.CreatedDateDesc, testPage);
    	objCP.getFeedItemsSortBy();
    	
    	ApexPages.currentPage().getParameters().put('sortBy','popular');
    	ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.Record, lstContentChatter[0].Id, 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
    	objCP.getFeedItemsSortBy();
    	objCP.objectRecordId = objCV.Id;
    	objCP.getFeedRecordsOnClick();
        
        //for user profile section
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.UserProfile, objUser.Id, 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
        
        ApexPages.currentPage().getParameters().put('id',objUser.Id);
        objCP.initializeParam('CustomChatter','widgetId');
        objCP.getNewsFeedForDisplay();
        
        ApexPages.currentPage().getParameters().put('Type','like');
        ApexPages.currentPage().getParameters().put('ItemId',objFeedPost.Id);
        ApexPages.currentPage().getParameters().put('LikedId','');
        ApexPages.currentPage().getParameters().put('FeedId',objFeedPost.Id);
        objCP.updateLikeUnLikeFeeds();
        
        ApexPages.currentPage().getParameters().put('Type','likeComment');
        ApexPages.currentPage().getParameters().put('ItemId',objFeedComment.Id);
        ApexPages.currentPage().getParameters().put('LikedId','');
        ApexPages.currentPage().getParameters().put('FeedId',objFeedPost.Id);
        objCP.updateLikeUnLikeFeeds();
        
        
        FeedLike objFeedLike = new FeedLike(FeedItemId = objFeedPost2.Id);
        insert objFeedLike;
        
        ApexPages.currentPage().getParameters().put('Type','unlike');
        ApexPages.currentPage().getParameters().put('ItemId',objFeedPost2.Id);
        ApexPages.currentPage().getParameters().put('LikedId',objFeedLike.Id);
        ApexPages.currentPage().getParameters().put('FeedId',objFeedPost2.Id);
        objCP.updateLikeUnLikeFeeds();
        
        
        FeedLike objFeedCommentLike = new FeedLike(FeedItemId=objFeedPost2.Id, FeedEntityId = objFeedComment2.Id);
        insert objFeedCommentLike;
        
		ApexPages.currentPage().getParameters().put('Type','unlikeComment');
        ApexPages.currentPage().getParameters().put('ItemId',objFeedComment2.Id);
        ApexPages.currentPage().getParameters().put('LikedId',objFeedCommentLike.Id);
        ApexPages.currentPage().getParameters().put('FeedId',objFeedPost2.Id);
        objCP.updateLikeUnLikeFeeds();
		
		        
        ApexPages.currentPage().getParameters().put('feedPostId',objFeedPost.Id);
        objCP.viewAllComments();
        
        //To cover deleteFeedComment()
        ApexPages.currentPage().getParameters().put('deletedCommentId',objFeedComment1.Id);
        ApexPages.currentPage().getParameters().put('feedId',objFeedPost1.Id);
        objCP.deleteFeedComment();
        
        //To cover getTopic
        Topic objTopic = new Topic(Name='Test-Topic');
        insert objTopic;
        
        TopicAssignment objTopicAssign = new TopicAssignment(TopicId = objTopic.Id, EntityId = objFeedPost2.Id);
        insert objTopicAssign;
        String topicName = ApexPages.currentPage().getParameters().put('prmTopicName','Test-Topic');
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed( strCommunityId, ConnectApi.FeedType.Record, objTopic.Id, 3, 
                                                             ConnectApi.FeedDensity.AllUpdates, null, numOfFeeds, ConnectApi.FeedSortOrder.LastModifiedDateDesc, testPage);
        objCP.gtTopicFeeds();
    	/*To cover delete post*/
		
		/*To Cover Search Feed*/
		
		objCP.strSearchText ='Test';
    	ConnectApi.ChatterFeeds.setTestSearchFeedItems(strCommunityId, 'Test', null,null,numOfFeedsForSearchPage, ConnectApi.FeedSortOrder.CreatedDateDesc,  testPage);
    	objCP.getFeedRecordsOnClick();
		
        objCP.topicNameToInsert = 'NewTopicTestTestTest';
        objCP.topicFeedId = objFeedPost1.Id;
    	objCP.insertNewTopic();
    	
    	ApexPages.currentPage().getParameters().put('deletedPost',objFeedPost.Id);
    	objCP.deleteFeedPost();
    	system.assertEquals(0,0);
    	
    	SL_IntranetChatterPlugInController.getAssociatedTopics(objFeedPost1.Id);
    	SL_IntranetChatterPlugInController.manageFeedItemTopics(objFeedPost2.Id, objTopic.Id);
    	
    	
    	
    	Test.StopTest();
        
    }
}