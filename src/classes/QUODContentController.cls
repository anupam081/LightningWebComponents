public without sharing class QUODContentController {
    public ID[] contentIDs{get;set;}
    public ID[] attachmentIDs{get;set;}
    public String contentTitle{get;set;}
     public String anchorTag{get;set;}
    public PageReference getContent(){
      String anchorTag=ApexPages.currentPage().getParameters().get('anchor');

         contentTitle=ApexPages.currentPage().getParameters().get('name');

        List<ContentVersion> contents  = [select id from ContentVersion  where ID= :'06890000001zOELAA2' and isLatest = true]; 
        contentIDs=new List<String>();
        System.debug('Content Values are:'+contentIDs);
        if(contents.size()>1){
            for(ContentVersion content : contents){
                contentIDs.add(content.ID);
            }
        }else if(contents.size()==1&& anchorTag!=null){
          return new PageReference('/sfc/servlet.shepherd/version/download/'+contents[0].ID).setAnchor(anchorTag);
        }
         else if(contents.size()==1&& anchorTag==null){
           return new PageReference('/sfc/servlet.shepherd/version/download/'+contents[0].ID);
           }
        return null;
    }
}