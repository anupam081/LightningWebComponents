public class emailattachment {
 
public string Conid;
public string attid;
public Map<String,String> urlMap=new Map<String,String>();
public List<Attachment> attach;
public Attachment att{get;set;}
public String pdfcontent{get;set;}

public emailattachment (){
    attach=[Select id,name,Body From Attachment Where Parentid=:Conid];
    if(attach.size() > 0){
        att = attach[0];
        pdfcontent= EncodingUtil.Base64Encode(att.body);
    }

}

public string getConid() {
    return null;
}

public void setConid(String s) {
    Conid=s;
}

public Map<String,String> getattach() {
    attach=[Select id,name From Attachment Where Parentid=:Conid];

for(Attachment att1:attach) {
    String urls=URL.getSalesforceBaseURL().toExternalForm()+'/servlet/servlet.FileDownload?file='+att1.id ;
    urlMap.put(urls,att1.Name);
}
    return urlMap;
}

public void setattach(List<Attachment> ata) {
attach=ata;
}

}