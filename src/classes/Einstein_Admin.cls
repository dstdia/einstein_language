public class Einstein_Admin {

    @AuraEnabled
    public static void createDatasetFromUrl(String zipUrl, Einstein_PredictionService.Types einsteinType) {
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        service.createDatasetFromUrlAsync(zipUrl);
    }
    
    @AuraEnabled
    public static List<Einstein_Dataset> getDatasets(Einstein_PredictionService.Types einsteinType) {
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        Einstein_Dataset[] datasets = service.getDatasets();
        return datasets;
    }
    
    @AuraEnabled
    public static String trainDataset(Decimal datasetId, Einstein_PredictionService.Types einsteinType) {
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        Einstein_Model model = service.trainDataset(Long.valueOf(String.valueOf(datasetId)), 'Training', 0, 0, '');
        return model.modelId;
    }
    
    @AuraEnabled
    public static void deleteDataset(Long datasetId, Einstein_PredictionService.Types einsteinType) {
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        service.deleteDataset(datasetId);
    }
    
    @AuraEnabled
    public static List<Einstein_Model> getModels(Long datasetId, Einstein_PredictionService.Types einsteinType) {
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        Einstein_Model[] models = service.getModels(datasetId);
        return models;
    }
    
    @AuraEnabled
    public static void getCatPrediction(Id catId, String fileName, String base64, Einstein_PredictionService.Types einsteinType) {
        Blob fileBlob = EncodingUtil.base64Decode(base64);
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        Einstein_Dataset[] datasets = service.getDatasets();
        for (Einstein_Dataset dataset : datasets) {
            if (dataset.Name.equals('Cats')) {
                Einstein_Model[] models = service.getModels(dataset.id);
                Einstein_Model model = models.get(0);
                Einstein_PredictionResult result = service.predictImageBlob(model.modelId, fileBlob, 0, '');
                Einstein_Probability probability = result.probabilities.get(0);
                
                /** Trailhead cats part
                 * Cat__c cat = [SELECT Id FROM Cat__C WHERE Id=:catId];
                cat.Cat_Breed__c = probability.label;
                update cat;
                Attachment[] attsOld = [SELECT Id FROM Attachment WHERE ParentId=:catId];
                delete attsOld;
                Attachment att = new Attachment();
                att.Body = fileBlob;
                att.ParentId = cat.Id;
                att.Name = fileName;
                insert att;*/
            }
        }
    }
    
    @AuraEnabled
    public static List<Einstein_Label> getCatLabels(Einstein_PredictionService.Types einsteinType) {
        Einstein_PredictionService service = new Einstein_PredictionService(einsteinType);
        Einstein_Dataset[] datasets = service.getDatasets();
        for (Einstein_Dataset dataset : datasets) {
            if (dataset.Name.equals('Cats')) {
                return dataset.labelSummary.labels;
            }
        }
        return null;
    }

    @AuraEnabled
    public static String getImageUrlFromAttachment(Id catId) {
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId=:catId];
        if (atts.size()>0) {
            return atts.get(0).Id;
        }
        return '';
    }
    
}