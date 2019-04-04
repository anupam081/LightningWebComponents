trigger AttachmentTrigger on Attachment (after insert) {
    
    for(Attachment att: Trigger.new){
        
        if(att.parentid == '0039000001nr2Ka'){
            /*
            ContentVersion cv = new Contentversion();
            cv.title = 'test content';
            cv.FirstPublishLocationId = '05890000000YhjP';
            cv.versionData  = att.body;
            insert cv;
            */
        }
        
     }
    
}