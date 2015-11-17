/**
 * \author Vladimir Dobrelya
 * \date Mar 20, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief The wrappers container. This class contains wrappers for webhook results from BitBucket
 */
public without sharing class BitBucketWrappers {

    public class REST_Response { 
        public List<REST_Commit> commits;
        public REST_Repository repository;
    }

    public class REST_Commit extends Abs_Commit {
        //public String author;
        //public String branch;
        //public List<REST_File> files;
        public String message;
        //public String node;
        public String raw_author;
        public String raw_node;
        //public Integer revision;
        //public String timestamp;

        public override String getHash() {
            return this.raw_node;
        }
        public override String getMessage() {
            return this.message;
        }
        public override String getAuthor() {
            return this.raw_author;
        }
    }

    /*public class REST_File {
        public String file;
        public String type;
    }*/

    public class REST_Repository {
        public String name;
    }

    public class HTTP_Response {
        public List<HTTP_Commit> values;
        public String next;
    }

    public class HTTP_Commit extends Abs_Commit {
        public String hash;
        public String message;
        public HTTP_Author author;

        public override String getHash() {
            return this.hash;
        }
        public override String getMessage() {
            return this.message;
        }
        public override String getAuthor() {
            return this.author.raw;
        }
    }

    public class HTTP_Author {
        public String raw;
    }

    public abstract class Abs_Commit {
        public REST_CommentLinks links;
        public REST_Repository repository;
        public DateTime xdate;
        
        public abstract String getHash();
        public abstract String getMessage();
        public abstract String getAuthor();
    }


    /* --- PULL REQUEST --- */

    public class REST_PRResponse {
        public REST_Approval pullrequest_approve;
        public REST_Approval pullrequest_unapprove;
        public REST_PullRequest pullrequest_created;
        public REST_PullRequest pullrequest_updated;
        public REST_PullRequest pullrequest_merged;
        public REST_PullRequest pullrequest_declined;
        public REST_Comment pullrequest_comment_created;
        public REST_Comment pullrequest_comment_updated;
        public REST_Comment pullrequest_comment_deleted;
    }

    public class HTTP_PRResponse {
        public Integer page;
        public Integer size;
        public Integer pagelen;
        public List<REST_PullRequest> values;
    }

    public class HTTP_RPCommits {
        public Integer page;
        public Integer size;
        public Integer pagelen;
        public List<HTTP_Commit> values;
    }

    public class HTTP_PRLinks {
        public List<REST_CommentLink> commits;
    }

    public class REST_Approval {
        public DateTime xdate;
        public REST_PRUser user;
    }

    public class REST_PullRequest {
        public String description;
        public String title;
        //public List<REST_PRUser> reviewers;
        public REST_PRSource destination;
        public String state;
        public Long id;
        public REST_PRSource source;
        public String reason;
        public REST_PRUser author;
        public DateTime created_on;
        public List<REST_PRParticipant> participants;
        public DateTime updated_on;
        public DateTime xdate;
        //public List<HTTP_PRLinks> links;
    }

    public class REST_Comment {
        public Long id;
        public REST_CommentContent content;
        public REST_PRUser user;
        public DateTime created_on;
        public DateTime updated_on;
        public REST_CommentInline inline;
        public REST_CommentLinks links;
    }

    public class REST_CommentLinks {
        public REST_CommentLink self;
    }

    public class REST_CommentLink {
        public String href;
    }

    public class REST_CommentContent {
        public String raw;
        public String markup;
        public String html;
    }

    public class REST_CommentInline {
        public String xfrom;
        public String to;
        public String path;
    }

    public class REST_PRUser {
        public String username;
    }

    public class REST_PRSource {
        public REST_PRCommit xcommit;
        public REST_PRBranch branch;
        public REST_PRRepository repository;
    }

    public class REST_PRCommit {
        public String hash;
    }

    public class REST_PRBranch {
        public String name;
    }

    public class REST_PRRepository {
        public String name;
    }

    public class REST_PRParticipant {
        public String role;
        public REST_PRUser user;
        public Boolean approved;
    }

    public static String prepareJSON( String sJSON ) {
        if ( String.isBlank( sJSON ) ) {
            return sJSON;
        }

        system.debug( LoggingLevel.INFO, '### sJSON : ' + sJSON );

        for ( String sItem : aJSONMapping.keySet() ) {
            sJSON = sJSON.replace( sItem, aJSONMapping.get( sItem ) );
        }

        system.debug( LoggingLevel.INFO, '### sJSON : ' + sJSON );

        return sJSON;
    }

    private static Map<String, String> aJSONMapping {
        get {
            if ( aJSONMapping == null ) {
                aJSONMapping = new Map<String, String>{
                    '"date": '   => '"xdate": ',
                    '"from": '   => '"xfrom": ',
                    '"commit": ' => '"xcommit": '/*,
                    '+00:00"'    => '"'*/
                };
            }
            return aJSONMapping;
        } private set;
    }


/*
  {
  "pullrequest_created":{
      "description": "Added description",
      "links": {
        "decline": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/decline"
        },
        "commits": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/commits"
        },
        "self": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24"
        },
        "comments": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/comments"
        },
        "patch": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/patch"
        },
        "merge": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/merge"
        },
        "html": {
          "href": "https://bitbucket.org/evzijst/bitbucket2/pull-request/24"
        },
        "activity": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/activity"
        },
        "diff": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/diff"
        },
        "approve": {
          "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/pullrequests/24/approve"
        }
      },
      "title": "PR title",
      "close_source_branch": true,
      "reviewers": [
        {
          "username": "nvenegas",
          "display_name": "Nicolas Venegas",
          "links": {
            "self": {
              "href": "https://api.bitbucket.org/2.0/users/nvenegas"
            },
            "avatar": {
              "href": "http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e?d=&s=32"
            }
          }
        }
      ],
      "destination": {
        "commit": {
          "hash": "82d48819e5f7",
          "links": {
            "self": {
              "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/commit/82d48819e5f7"
            }
          }
        },
        "branch": {
          "name": "staging"
        },
        "repository": {
          "full_name": "evzijst/bitbucket2",
          "links": {
            "self": {
              "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2"
            },
            "avatar": {
              "href": "https://bitbucket.org/m/bf1e763db20f/img/language-avatars/default_16.png"
            }
          },
          "name": "bitbucket2"
        }
      },
      "state": "OPEN",
      "id": 24,
      "source": {
        "commit": {
          "hash": "325625d47b0a",
          "links": {
            "self": {
              "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2/commit/325625d47b0a"
            }
          }
        },
        "branch": {
          "name": "mfrauenholtz/inbox"
        },
        "repository": {
          "full_name": "evzijst/bitbucket2",
          "links": {
            "self": {
              "href": "https://api.bitbucket.org/2.0/repositories/evzijst/bitbucket2"
            },
            "avatar": {
              "href": "http://bitbucket.org/m/bf1e763db20f/img/language-avatars/default_16.png"
            }
          },
          "name": "bitbucket2"
        }
      },
      "reason": "",
      "author": {
        "username": "evzijst",
        "display_name": "Erik van Zijst",
        "links": {
          "self": {
            "href": "https://api.bitbucket.org/2.0/users/evzijst"
          },
          "avatar": {
            "href": "https://bitbucket-staging-assetroot.s3.amazonaws.com/c/photos/2013/Oct/28/evzijst-avatar-3454044670-3_avatar.png"
          }
        }
      },
      "created_on": "2013-11-04T23:41:48.941334+00:00",
      "participants": [
        {
          "role": "REVIEWER",
          "user": {
            "username": "nvenegas",
            "display_name": "Nicolas Venegas",
            "links": {
              "self": {
                "href": "https://api.bitbucket.org/2.0/users/nvenegas"
              },
              "avatar": {
                "href": "http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e?d=&s=32"
              }
            }
          },
          "approved": false
        },
        {
          "role": "PARTICIPANT",
          "user": {
            "username": "evzijst",
            "display_name": "Erik van Zijst",
            "links": {
              "self": {
                "href": "https://api.bitbucket.org/2.0/users/evzijst"
              },
              "avatar": {
                "href": "https://bitbucket-staging-assetroot.s3.amazonaws.com/c/photos/2013/Oct/28/evzijst-avatar-3454044670-3_avatar.png"
              }
            }
          },
          "approved": true
        }
      ],
      "updated_on": "2013-11-08T18:55:37.272783+00:00",
      "merge_commit": null,
      "closed_by": null
    }
}

*/


    /*
    {
      "canon_url" : "https://bitbucket.org",
      "commits" : [ { "author" : "vladimir_dobrelya",
            "branch" : "master",
            "files" : [ { "file" : "src/classes/BitBucketWebhookListener.cls",
                  "type" : "modified"
                } ],
            "message" : "SLFF-42\n",
            "node" : "5c400acbe2d0",
            "parents" : [ "a3139e94771e" ],
            "raw_author" : "Vladimir Dobrelya <dobrelya@silverlinecrm.com>",
            "raw_node" : "5c400acbe2d0370d85044b5f80cb43f3eca5f9e9",
            "revision" : null,
            "size" : -1,
            "timestamp" : "2014-03-27 14:58:36",
            "utctimestamp" : "2014-03-27 13:58:36+00:00"
          } ],
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




}

// --- https://api.bitbucket.org/2.0/repositories/silverline/slff/commits?pagelen=1&page=1 --- //
/*
{ "next" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commits?pagelen=1&page=2",
  "page" : 1,
  "pagelen" : 1,
  "values" : [ { "author" : { "raw" : "Julia Kolesnik <julia@silverlinecrm.com>" },
        "date" : "2014-03-28T13:50:32+00:00",
        "hash" : "c3163da8af79be767f46cd81a72fa977f2f6f2b6",
        "links" : { "approve" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/c3163da8af79be767f46cd81a72fa977f2f6f2b6/approve" },
            "comments" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/c3163da8af79be767f46cd81a72fa977f2f6f2b6/comments" },
            "diff" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/diff/c3163da8af79be767f46cd81a72fa977f2f6f2b6" },
            "html" : { "href" : "https://bitbucket.org/silverline/slff/commits/c3163da8af79be767f46cd81a72fa977f2f6f2b6" },
            "patch" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/patch/c3163da8af79be767f46cd81a72fa977f2f6f2b6" },
            "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/c3163da8af79be767f46cd81a72fa977f2f6f2b6" }
          },
        "message" : "SLFF-33\n",
        "parents" : [ { "hash" : "788620ebb38825c4b7320f98b5f73271076aac74",
              "links" : { "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/788620ebb38825c4b7320f98b5f73271076aac74" } }
            } ],
        "repository" : { "full_name" : "silverline/slff",
            "links" : { "avatar" : { "href" : "https://d3oaxc4q5k2d6q.cloudfront.net/m/100dd4fdc110/img/language-avatars/default_16.png" },
                "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff" }
              },
            "name" : "SLFF"
          }
      } ]
}
*/



/*
[ {
    "author" : { "raw" : "Julia Kolesnik <julia@silverlinecrm.com>" },
    "date" : "2014-03-28T11:45:33+00:00",
    "hash" : "788620ebb38825c4b7320f98b5f73271076aac74",
    "links" : { "approve" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/788620ebb38825c4b7320f98b5f73271076aac74/approve" },
        "comments" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/788620ebb38825c4b7320f98b5f73271076aac74/comments" },
        "diff" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/diff/788620ebb38825c4b7320f98b5f73271076aac74" },
        "html" : { "href" : "https://bitbucket.org/silverline/slff/commits/788620ebb38825c4b7320f98b5f73271076aac74" },
        "patch" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/patch/788620ebb38825c4b7320f98b5f73271076aac74" },
        "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/788620ebb38825c4b7320f98b5f73271076aac74" }
      },
    "message" : "SLFF-24\n",
    "parents" : [ { "hash" : "dccea5d2dc30522ccf690fbbdb1006a2a6cabb42",
          "links" : { "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42" } }
        } ],
    "repository" : { "full_name" : "silverline/slff",
        "links" : { "avatar" : { "href" : "https://d3oaxc4q5k2d6q.cloudfront.net/m/100dd4fdc110/img/language-avatars/default_16.png" },
            "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff" }
          },
        "name" : "SLFF"
      }
  },
  {
    "author" : { "raw" : "Vladimir Dobrelya <dobrelya@silverlinecrm.com>",
        "user" : { "display_name" : "vladimir_dobrelya",
            "links" : { "avatar" : { "href" : "https://secure.gravatar.com/avatar/d5146a86abc774661eb729de8c3e51d1?d=https%3A%2F%2Fd3oaxc4q5k2d6q.cloudfront.net%2Fm%2F100dd4fdc110%2Fimg%2Fdefault_avatar%2F32%2Fuser_blue.png&s=32" },
                "self" : { "href" : "https://api.bitbucket.org/2.0/users/vladimir_dobrelya" }
              },
            "username" : "vladimir_dobrelya"
          }
      },
    "date" : "2014-03-27T15:45:29+00:00",
    "hash" : "dccea5d2dc30522ccf690fbbdb1006a2a6cabb42",
    "links" : { "approve" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42/approve" },
        "comments" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42/comments" },
        "diff" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/diff/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42" },
        "html" : { "href" : "https://bitbucket.org/silverline/slff/commits/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42" },
        "patch" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/patch/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42" },
        "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/dccea5d2dc30522ccf690fbbdb1006a2a6cabb42" }
      },
    "message" : "SLFF-42\n",
    "parents" : [ { "hash" : "ffd7b9943700667b3cdabf56f6b3a5c87e83cf6d",
          "links" : { "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff/commit/ffd7b9943700667b3cdabf56f6b3a5c87e83cf6d" } }
        } ],
    "repository" : { "full_name" : "silverline/slff",
        "links" : { "avatar" : { "href" : "https://d3oaxc4q5k2d6q.cloudfront.net/m/100dd4fdc110/img/language-avatars/default_16.png" },
            "self" : { "href" : "https://api.bitbucket.org/2.0/repositories/silverline/slff" }
          },
        "name" : "SLFF"
      }
  }
]
*/