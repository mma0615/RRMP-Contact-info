public  without sharing class MaterialsController { 
    
    @AuraEnabled (cacheable = true)
    public static String getMaterials(String eventId){
        //if (String.isBlank(eventId)) return null;
        String result = MaterialsControllerHelper.getMaterialsHelper(eventId);
        return result;
    }
}