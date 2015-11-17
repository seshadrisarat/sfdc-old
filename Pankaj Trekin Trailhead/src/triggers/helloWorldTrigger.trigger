trigger helloWorldTrigger on Account (before insert) {
    if(Trigger.isBefore && Trigger.isInsert)
          System.debug('Hello World!');
}