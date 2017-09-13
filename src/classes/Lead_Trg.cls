public class Lead_Trg {
    
    public static String INTENT_MODEL = 'XT67KO4U352TCIZMPYLJ6KSGBU';
    public static String MUSIC_MODEL = 'F7N2M54URI4XPXV654VH7FZHPI';
    public static String COMPLEXITY_MODEL = 'O63JO5WGZSA4VL5VIL5DWMLMJA';
    
    @future (callout=true)
    public static void predict(String s, Id leadId) {
        
        Lead currentLead;
        
        Einstein_PredictionService service = new Einstein_PredictionService(Einstein_PredictionService.Types.INTENT);
		Einstein_PredictionResult routing = service.predictIntent(INTENT_MODEL, s, 0, '');
        Einstein_PredictionResult music = service.predictIntent(MUSIC_MODEL, s, 0, '');
        
        if (leadId == NULL) return; 
        
        if (leadId != NULL) {
            
            currentLead = [SELECT Id, Intent__c, Music__c, Status FROM LEad WHERE Id =: leadId];
        	currentLead.Intent__c = routing.probabilities[0].label;
            currentLead.sendMail__c = true;
            currentLead.Music__c = music.probabilities[0].label;
            currentLead.Status = 'Predicted';
            
            update currentLead;
        }
        
        String comment = 'Einstein Results:\n'
            + 'Intent: '
            + getStringComment(routing.probabilities[0])
            + 'Music: '
            + getStringComment(music.probabilities[0]);
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(
            Network.getNetworkId(), 
            LeadId, 
            ConnectApi.FeedElementType.FeedItem, 
            comment);
        
           
    }
    
    private static String getStringComment(Einstein_Probability probability) {
        
        return probability.label
            + ' '
            + probability.probability
            + '\n';
    }
}