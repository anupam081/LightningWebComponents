public class testContent {
    	
    public blob file { get; set; }
    
    public PageReference go() {
        ContentVersion v = new ContentVersion();
        v.versionData = file;
        v.title = 'from VF';
        v.pathOnClient ='/foo.txt';
        system.debug('Content data == '+v);
        insert v;
        return new PageReference('/' + v.id);
    }


}