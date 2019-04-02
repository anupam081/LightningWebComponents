/* This class is used to send SMS to any mobile number using the
installed twilio un-managed package
*/
public class TwilioPageController {
    public String status { get; set; }
    public String message { get; set; }
    public String phoneNumber { get; set; }

    TwilioAccount account = TwilioAPI.getDefaultAccount();
    String myPhoneNumber = 
        account.getIncomingPhoneNumbers().getPageData()[0].getPhoneNumber();

    public PageReference sendSMS() {
        Map<String, String> params = new Map<String, String>{
            'From' => myPhoneNumber,
            'To' => phoneNumber,
            'Body' => message
        };

        try {
            TwilioSms sms = account.getSmsMessages().create(params);
            status = 'Sent SMS. SID: '+sms.getSid();
        } catch (Exception e) {
            status = 'Exception: '+e.getMessage();
        }

        phoneNumber = null;
        message = null;

        return null;
    }
    
    //call the contact from the salesforce
    public void sendConfInviteContact(){
    	
    	 // Get Conference Moderator (User) Info
        String moderatorId = '';
        String moderatorName = '';
        String moderatorPhone = '';
        String moderatorConfNumber = '';
        String moderatorUrl = '';
        String SFDC_SiteUrl = 'http://lifesupport-developer-edition.ap1.force.com/';
        
    	Id userid = UserInfo.getuserId();
    	
    	// Get the user's info
        for (User u : [SELECT id, name, MobilePhone, twilio_conf_number__c  FROM User WHERE id = :userid]) {
            moderatorId = u.id;
            moderatorName = EncodingUtil.URLENCODE(u.name, 'UTF-8');
            moderatorPhone = '+' + u.MobilePhone.replaceAll('\\D', '');
            moderatorConfNumber = '+' + u.twilio_conf_number__c.replaceAll('\\D', '');
        }
        
        moderatorUrl = SFDC_SiteUrl + '/TwilioVoiceCaseConfCallModerator?conferencename=' + moderatorId; 
        
        TwilioRestClient Client = TwilioAPI.getDefaultClient();
        
        // First, we dial the Moderator Phone and the URL will connect the moderator to the conference
        Map<String,String> voiceparams = new Map<String,String> {
            'To'   => moderatorPhone,
            'From' => moderatorConfNumber,
            'Url' => moderatorUrl
        };
        
        try{
		        // Conf call the moderator
		        TwilioCall callModerator = Client.getAccount().getCalls().create(voiceparams);
		        
		        String participantUrl = SFDC_SiteUrl + '/TwilioVoiceConfCaseCallParticipantGather?conferencename=' + moderatorId; 
		        String participantPersonalizedUrl = '';
		        
		       for (Contact cc: [SELECT name, MobilePhone FROM Contact WHERE id = '0039000001deOiw']) {
		       
				         // Send a voice call to join the conference if the member's role is Primary on the team
				        Map<String,String> voiceparams2 = new Map<String,String> {
				                           'To'   => cc.MobilePhone,
				                           'From' => moderatorConfNumber,
				                           'Url' => participantPersonalizedUrl
				                        };
				       
				       // Call the member
				        TwilioCall callParticipant = Client.getAccount().getCalls().create(voiceparams2);
		       }
        }Catch(Exception e){
        	ApexPages.addMessages(e); 
        }
    }
}