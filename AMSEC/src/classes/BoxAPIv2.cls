public with sharing class BoxAPIv2 {
  private static string endpoint = 'https://www.box.com/api/2.0';
  private static boolean syncState = false;
  private static String getBoxResponse(String method, String request) {
    return getBoxResponse(method, request, null,null);
  }
    
  private static String getBoxResponse(String method, String request, String payload, String asUser) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    system.debug('CALLINGOUT');
    /*** Commented this by Harsh as causing Issues
    if(payload != null)
      payload = EncodingUtil.urlEncode(payload, 'UTF-8');
    */
    
    req.setEndpoint(endpoint + request);
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);

    if(asUser!=''&&asUser!=null)
    {
      req.setHeader('As-User', asUser); // David Bard's Box Id..*/
    }

    req.setMethod(method);
    if (payload != null) {
      req.setBody(payload);
    }
    
    HttpResponse res = h.send(req); 
    System.debug('==========>>>' +res.getBody());
    if (res.getStatusCode() > 299 ) {
        error = (BoxObject2.Error)JSON.deserialize(res.getBody(), BoxObject2.Error.class);
        //throw new BoxException(error.message);
    }

    // Now that we are done with callouts, we can update the oauth tokens if they changed.
    //upsert BoxAuth.authInfo;

    String jsonString = res.getBody();
    // The Box API returns some reserved words. Find and replace them so we can deserialize
    jsonString = jsonString.replace('"limit":', '"limit_x":');
    return jsonString;
  }

  public static BoxObject2.Error error;
  
  public static BoxObject2.FolderFile getFolder(String folderId, Boolean isTrashed) {
    String path = '/folders/' + folderId;
    if (isTrashed) {
      path = path + '/trash';
    }
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('GET', path), BoxObject2.FolderFile.class);
  }
   public static BoxObject2.ItemCollection getFolderCollection(String folderId, Boolean isTrashed) {
    String path = '/folders/' + folderId;
    if (isTrashed) {
      path = path + '/trash';
    }
    return (BoxObject2.ItemCollection)JSON.deserialize(getBoxResponse('GET', path), BoxObject2.ItemCollection.class);
  }
  public static BoxObject2.FolderFile getFolder(String folderId) {
    return getFolder(folderId, false);  
  }

  public static BoxObject2.FolderFile createFolder(String name, String parentId) {
    name = replaceSpecialChars(name);       // REPALCING ALL THE CHARS NOT CAUSING ERROR...
    String payload = '{"name":"' + name + '", "parent": {"id": "' + parentId + '"}}';
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('POST', '/folders', payload,''), BoxObject2.FolderFile.class);    
  }


  public static List<BoxObject2.FolderFile> getSubFolders(String folderID) {
    String payload = '';
    return (List<BoxObject2.FolderFile>)JSON.deserialize(getBoxResponse('GET', '/folders/'+folderID, payload,''), BoxObject2.FolderFile.class);    
  }

  // To Copy the folders.......
  public static BoxObject2.FolderFile copyFolder(String folderId, String strParentId, String folderName) {
    folderName = replaceSpecialChars(folderName);   // REPALCING ALL THE CHARS NOT CAUSING ERROR...

    String payload = '{"parent": {"id" : ' +strParentId+ '}, "name" : "' +folderName+ '"}'; 
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('POST', '/folders/'+folderId+ '/copy', payload,''), BoxObject2.FolderFile.class);    
  }
  
  /*
    Developer: Harsh
    Description: Repalcing the DOUBLE_QUOTE, back and forward slashes, to _ which were causing issues for Folder moving....
    Parameters:  String strName
    Return: 
  */
  public static String replaceSpecialChars(String strName) {
      // replacing the  \  with _
      if(strName.contains('\\'))
        strName = strName.replace('\\', '_');
      // replacing the  /  with _
      if(strName.contains('/'))
        strName = strName.replace('/', '_');
      // replacing the  "  with \"
      if(strName.contains('\"'))
        strName = strName.replace('\"', '\\"');
      return strName;
  }

  /*
    Developer: Harsh
    Description: Moving the folder in box.com based on the folder Id and the parentId.
    Parameters:  String ParentId, String folderId, String strNewFolderName
    Return: 
  */
   public static BoxObject2.FolderFile moveFolder(String strParentId, String folderId, String strNewFolderName) {
    strNewFolderName = replaceSpecialChars(strNewFolderName); 
    String payload = '';
    // Checking whether to move the parent or only Name is enough...
    if(strParentId != '')
    {
        payload = '{"parent": {"id" : ' +strParentId+ '}, "name" : "' +strNewFolderName+ '"}'; 
    } 
    else{
        payload = '{"name":"' +strNewFolderName+ '"}';
    }
    system.debug('==========>> payload==>>' +payload);
      
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('PUT', '/folders/'+folderId, payload,''), BoxObject2.FolderFile.class);    
  }
  //public static BoxObject2.FolderFile moveFolder(String strParentId, String folderId, String strNewFolderName, boolean sync_State) {
  //  strNewFolderName = replaceSpecialChars(strNewFolderName); 
  
  //  if(sync_State)
  //    syncState = true;

  //  String payload = '';
  //  // Checking whether to move the parent or only Name is enough...
  //  if(strParentId != '')
  //  {
  //    if(sync_State)
  //      payload = '{"parent": {"id" : ' +strParentId+ '}, "name" : "' +strNewFolderName+ '", "sync_state" : "synced"}'; 
  //    else
  //      payload = '{"parent": {"id" : ' +strParentId+ '}, "name" : "' +strNewFolderName+ '"}'; 
  //  } 
  //  else{
  //    if(sync_State)
  //      payload = '{"name":"' +strNewFolderName+ '", "sync_state" : "synced"}';
  //    else
  //      payload = '{"name":"' +strNewFolderName+ '"}';
  //  }
  //  system.debug('==========>> payload==>>' +payload);
      
  //  return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('PUT', '/folders/'+folderId, payload,''), BoxObject2.FolderFile.class);    
  //}
 

  public static void syncFolder(String boxFolderID, String boxUserId)
  {
     String payload = '';
    // Checking whether to move the parent or only Name is enough...
    if(boxFolderID != '')
    {
        payload = '{"sync_state" : "synced"}'; 
    } 
    system.debug('==========>> payload==>>' +payload); 
    BoxObject2.FolderFile objBoxFile = BoxAPIv2.getFolder(boxfolderID);
    for(BoxObject2.MiniFolderFile objMiniFolderFile : objBoxFile.item_collection.entries) {
            getBoxResponse('PUT', '/folders/'+objMiniFolderFile.id, payload, boxUserId);
    }
  }

  public static void unSyncFolder(String boxFolderID, String boxUserId)
  {
     String payload = '';
    // Checking whether to move the parent or only Name is enough...
    if(boxFolderID != '')
    {
        payload = '{"sync_state" : "not_synced"}'; 
    } 
    system.debug('==========>> payload==>>' +payload);
    //BoxObject2.FolderFile objBoxFile = BoxAPIv2.getFolder(boxfolderID);
    //for(BoxObject2.MiniFolderFile objMiniFolderFile : objBoxFile.item_collection.entries) {
            getBoxResponse('PUT', '/folders/'+boxfolderID, payload, boxUserId);
    //}
  }

  public static void deleteFolder(String folderId) {
    getBoxResponse('DELETE', '/folders/' + folderId + '?recursive=true');
  }

  public static BoxObject2.FolderFile getFile(String fileId) {
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('GET', '/file/' + fileId), BoxObject2.FolderFile.class);    
  }

  public static void deleteFile(String fileId) {
    getBoxResponse('DELETE', '/files/' + fileId);
  }
  
  public static BoxObject2.UserCollection getUsers(){
    return (BoxObject2.UserCollection)JSON.deserialize(getBoxResponse('GET', '/users', null,null), BoxObject2.UserCollection.class);
  }
  public static BoxObject2.Collaboration addCollaboration(String folderId, String email, String role) {
    String payload = '{"item": { "id": "' + folderId + '", "type": "folder"}, "accessible_by": { "login": "' + email + '", "type": "user" }, "role": "' + role + '"}';
    return (BoxObject2.Collaboration)JSON.deserialize(getBoxResponse('POST', '/collaborations', payload,''), BoxObject2.Collaboration.class);
  }

  // Addded to create Colloboration for GROUP.....
  public static BoxObject2.Collaboration addCollaborationForGroup(String folderId, String groupId, String role) {
    String payload = '{"item": { "id": "' + folderId + '", "type": "folder"}, "accessible_by": { "id": "' + groupId + '", "type": "group" }, "role": "' + role + '"}';
    return (BoxObject2.Collaboration)JSON.deserialize(getBoxResponse('POST', '/collaborations', payload,''), BoxObject2.Collaboration.class);
  }

  public static BoxObject2.CollaborationCollection getFolderCollaboration(String folderId) {
    return (BoxObject2.CollaborationCollection)JSON.deserialize(getBoxResponse('GET', '/folders/' + folderId + '/collaborations'), BoxObject2.CollaborationCollection.class); 
  }

  public static BoxObject2.User getCurrentUser() {
    return (BoxObject2.User)JSON.deserialize(getBoxResponse('GET', '/users/me'), BoxObject2.User.class); 
  }

  public static PageReference getFileDownloadLink(String fileId) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint + '/files/' + fileId + '/content');
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);
    req.setMethod('GET');

    HttpResponse res = h.send(req);
    PageReference pr;
    // Box returns a redirect to download the file
    if (res.getStatusCode() == 302) {
      pr = new PageReference(res.getHeader('Location'));
    }
    return pr;
  }
}