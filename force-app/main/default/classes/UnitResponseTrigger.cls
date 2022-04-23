public class UnitResponseTrigger {

    public static void onBeforeUpdate(List<Unit_Response__c> unitRespList, Map<Id,Unit_Response__c> oldUnitRespMap){
        for(Unit_Response__c unitResp : unitRespList){
            List<Unit_Response__c> answeredUnitRespList = new List<Unit_Response__c>();
            if(unitResp.Status__c == 'Answered' && oldUnitRespMap.get(unitResp.Id).Status__c == 'Draft'){
                answeredUnitRespList.add(unitResp);
            }
        }
        validateAnswers(answeredUnitRespList);
    }

    private static void validateAnswers(List<Unit_Response__c> unitRespList){

        Map<Id,Unit_Response__c> unitRespFromDbMap = new Map<Id,Unit_Response__c>([SELECT Id, (SELECT Id, Option__r.isCorrect__c FROM Question_Responses__c) FROM Unit_Response__c WHERE Id in : unitRespList]);

        // 200 
        for(Unit_Response__c unitResp : unitRespList){

        unitResp.IsCorrect__c = true;
            // 10
            for(QuestionResponse__c questResp : unitRespFromDbMap.get(unitResp.Id).Question_Responses__r){
                // 10 * 200 = 2000
                if(!questResp.Option__r.IsCorrect__c){
                    unitResp.IsCorrect__c = false;
                    break;
                }
            }
        }
        
    }

}
