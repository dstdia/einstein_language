public class Case_Trg {
    
    public static String INTENT_MODEL = 'XT67KO4U352TCIZMPYLJ6KSGBU';
    public static String MUSIC_MODEL = 'F7N2M54URI4XPXV654VH7FZHPI';
    public static String COMPLEXITY_MODEL = 'O63JO5WGZSA4VL5VIL5DWMLMJA';
    
    @future (callout=true)
    public static void predictSentiment(String s, Id caseId) {
        
        Case currentCase;
        
        Einstein_PredictionService service = new Einstein_PredictionService(
            Einstein_PredictionService.Types.SENTIMENT);
		Einstein_PredictionResult prediction = service.predictSentiment(
            'CommunitySentiment', s, 0, '');
        
        Einstein_PredictionService service2 = new Einstein_PredictionService(Einstein_PredictionService.Types.INTENT);
		Einstein_PredictionResult routing = service2.predictIntent(INTENT_MODEL, s, 0, '');
        Einstein_PredictionResult music = service2.predictIntent(MUSIC_MODEL, s, 0, '');
        Einstein_PredictionResult complexity = service2.predictIntent(COMPLEXITY_MODEL, s, 1, '');
        
        System.debug('Complexity:' + complexity);
        
        if (CaseId == NULL) return; 
        
        if (CaseId != NULL) {
            
            currentCase = [SELECT Id, OwnerId, Sentiment__c, Confidence__c, Intent__c, Music__c, hasComplexLanguage__c FROM Case WHERE Id =: caseId];
        	currentCase.Sentiment__c = prediction.probabilities[0].label;
            currentCase.Confidence__c = prediction.probabilities[0].probability;
            currentCase.Intent__c = routing.probabilities[0].label;
            currentCase.IntentConfidence__c = Double.valueOf(routing.probabilities[0].probability);
            currentCase.sendEmail__c = true;
            currentCase.Music__c = music.probabilities[0].label;
            
            if (complexity.probabilities[0].label == 'Complex') {
                currentcase.hasComplexLanguage__c = true;
            }
            
            update currentCase;
        }
        
        String comment = 'Einstein Results:\n'
            + 'Language complexity: '
            + getStringComment(complexity.probabilities[0])
            + 'Sentiment: '
            + getStringComment(prediction.probabilities[0])
            + 'Intent: '
            + getStringComment(routing.probabilities[0])
            + 'Music: '
            + getStringComment(music.probabilities[0]);
        
        insert new CaseComment(
            ParentId = caseId,
            CommentBody = comment,
            IsPublished = true
        );   
    }
    
    private static String getStringComment(Einstein_Probability probability) {
        
        return probability.label
            + ' '
            + probability.probability
            + '\n';
    }
}