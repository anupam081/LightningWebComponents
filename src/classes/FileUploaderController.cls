/*
  Description : Controller class for file uploaded ligthning component FileUploader.cmp
  Date Created : 15th Sep 2017
  Date Modified : 12th Sep 2017
*/

public class FileUploaderController {
    //class variables
    Public static final String OBJ_ATTACHMENT = 'Attachment';
    Public static final String OBJ_Files = 'files';
    
    
    /*
	 	Description : Method to insert attachments to a object record
		Param 1 : Id
		Param 2 : String
		Param 3 : String
		Param 4 : String
		Return : None
	*/
    
    @AuraEnabled 
    public static void insertFile(Id recId, String fileName, String base64, String objecttype) {
        try{ 	
        	Blob fileBlob = EncodingUtil.base64Decode(base64);
            
            //integer a = 1 / 0; // Division by zero causes exception
            
            if (fileBlob != null && objecttype == OBJ_ATTACHMENT) {               
                //delete existing attachment
                Attachment[] attsOld = [SELECT Id FROM Attachment WHERE ParentId=:recId];
                delete attsOld;
                
                //insert new
                Attachment att = new Attachment();
                att.Body = fileBlob;
                att.ParentId = recId;
                att.Name = fileName;
                insert att;
            }
        
            if (fileBlob != null && objecttype == OBJ_Files) { 
                    //delete existing Chatter files
                    ContentVersion [] attsOld = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =:recId];
                    //delete attsOld;
                    
                    //insert new
					saveToFiles(recId, fileName, fileBlob);
                   
                }
        }catch(Exception e){
            System.debug('Exception occured in method insertFile() is := '+e.getMessage());
            throw new AuraHandledException('Darn it! Something went wrong: '+ e.getMessage());    

        }
    }
    
  
     /*
	 	Description : Method to fetch image url from attachments for object record
		Param 1 : Id
		Return : None
	*/
    @AuraEnabled
    public static String getImageUrlFromAttachment(Id recId) {
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId=:recId];
        if (atts.size()>0) {
            return atts.get(0).Id;
        }
        return '';
    }
   
    
     /*
	 	Description : Method to insert document to chatter files for parent object record
		Param 1 : Id
		Param 2 : String
		Param 1 : Blob
		Return : Id
	*/
    private static Id saveToFiles(Id parentId, String fileName, Blob base64Data)  { 
        system.debug('Saving chatter files '+fileName);
        
        //insert contentversion
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title =fileName; 
        testContentInsert.ContentLocation = 'S'; 
        //testContentInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        testContentInsert.VersionData= base64Data;
        testContentInsert.PathOnClient='/' + fileName ;
        insert testContentInsert;     
        system.debug('testContentInsert.id '+ testContentInsert.id);
        
        //insert ContentDocumentLink to link it to the parent object
        testContentInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: testContentInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = testContentInsert.ContentDocumentId;
        cl.LinkedEntityId = parentId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
    
        system.debug('testContentInsert.id');
        return testContentInsert.id;

    }      


}