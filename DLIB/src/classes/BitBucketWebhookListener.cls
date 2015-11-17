/**
 * \author Vladimir Dobrelya
 * \date Mar 20, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief The BitBucket webhook listener class
 */
@RestResource(urlMapping='/BitBucketWebhookListener/*')
global without sharing class BitBucketWebhookListener {

    @HttpPost
    global static void doPost() {
        handlePost();
    }

    global static void handlePost() {
            RestContext.response.addHeader( 'Content-type', 'application/json' );
            System.debug( LoggingLevel.INFO, '#### request : \n' + RestContext.request.params.get( 'payload' ) );
            try { 
                BitBucketWrappers.REST_Response oResponse = ( BitBucketWrappers.REST_Response )JSON.deserialize( RestContext.request.params.get( 'payload' ), BitBucketWrappers.REST_Response.class );
                BitbucketMethods.setRepository( oResponse.repository.name, oResponse.commits );
                BitbucketMethods.createRecords( oResponse.commits );
            } catch ( Exception e ) {
                psaUtils.debug( e );
                RestContext.response.responseBody = Blob.valueOf( '{success:false,exception:' + e.getMessage() + ', line:' + e.getLineNumber() + '}' );
                RestContext.response.statusCode = 500; 
                return;
            }

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf( '{success:true}' );
    }
}

/*
{
   "repository":{
      "website":"",
      "fork":false,
      "name":"SLFF",
      "scm":"git",
      "owner":"silverline",
      "absolute_url":"/silverline/slff/",
      "slug":"slff",
      "is_private":true
   },
   "truncated":false,
   "commits":[
      {
         "node":"57368247a2af",
         "files":[
            {
               "type":"modified",
               "file":"src/classes/BitBucketWebhookListener.cls"
            }
         ],
         "branches":[

         ],
         "raw_author":"Vladimir Dobrelya <dobrelya@silverlinecrm.com>",
         "utctimestamp":"2014-03-24 15:33:37+00:00",
         "author":"vladimir_dobrelya",
         "timestamp":"2014-03-24 16:33:37",
         "raw_node":"57368247a2af217eaf5fefa25206173f89dc15f7",
         "parents":[
            "89c118c3cf99"
         ],
         "branch":null,
         "message":"SLFF-42\n",
         "revision":null,
         "size":-1
      },
      {
         "node":"f350da326935",
         "files":[
            {
               "type":"modified",
               "file":"src/classes/JiraWrappers.cls"
            }
         ],
         "raw_author":"Vladimir Dobrelya <dobrelya@silverlinecrm.com>",
         "utctimestamp":"2014-03-24 15:33:50+00:00",
         "author":"vladimir_dobrelya",
         "timestamp":"2014-03-24 16:33:50",
         "raw_node":"f350da326935b7bccc2d146932628a7f236533ed",
         "parents":[
            "57368247a2af"
         ],
         "branch":"master",
         "message":"SLFF-43\n",
         "revision":null,
         "size":-1
      }
   ],
   "canon_url":"https://bitbucket.org",
   "user":"vladimir_dobrelya"
}
*/


/*
{ "canon_url" : "https://bitbucket.org",
  "commits" : [ { "author" : "vladimir_dobrelya",
        "branch" : null,
        "branches" : [  ],
        "files" : [ { "file" : "src/classes/BitbucketMethods.cls",
              "type" : "modified"
            } ],
        "message" : "SLFF-42\n",
        "node" : "9a8c6d8962a7",
        "parents" : [ "27d4a5870bb6" ],
        "raw_author" : "Vladimir Dobrelya <dobrelya@silverlinecrm.com>",
        "raw_node" : "9a8c6d8962a7f6d6d46f845688def1945fe71c0d",
        "revision" : null,
        "size" : -1,
        "timestamp" : "2014-03-26 15:06:39",
        "utctimestamp" : "2014-03-26 14:06:39+00:00"
      },
      { "author" : "vladimir_dobrelya",
        "branch" : "master",
        "files" : [ { "file" : "src/classes/JiraMethods.cls",
              "type" : "modified"
            } ],
        "message" : "SLFF-43\n",
        "node" : "1133680de40d",
        "parents" : [ "9a8c6d8962a7" ],
        "raw_author" : "Vladimir Dobrelya <dobrelya@silverlinecrm.com>",
        "raw_node" : "1133680de40d748dbf6015a76ff30450a079b212",
        "revision" : null,
        "size" : -1,
        "timestamp" : "2014-03-26 15:06:48",
        "utctimestamp" : "2014-03-26 14:06:48+00:00"
      }
    ],
  "repository" : { "absolute_url" : "/silverline/slff/",
      "fork" : false,
      "is_private" : true,
      "name" : "SLFF",
      "owner" : "silverline",
      "scm" : "git",
      "slug" : "slff",
      "website" : ""
    },
  "truncated" : false,
  "user" : "vladimir_dobrelya"
}
*/