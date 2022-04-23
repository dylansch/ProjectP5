public class UnitService {
    public static Boolean registerUnitResponse(Id unitId, String jsonAnswer){
        
        // Setting a save point to make a rollback
        Database.SavePoint sp = Database.setSavePoint();

        try{
            // I query the student Id
            Student__c student = [SELECT Id FROM Student__c WHERE  User__c =: Userinfo.getUserId()];
            
            // I query the unit from the database and subquery the related questions
            Unit__c unit = [SELECT Module__c,(SELECT Id, Number_of_tries__c FROM UnitResponses__c WHERE ModuleResponse__r.Student__c =: student.Id ORDER BY Number_of_tries__c DESC LIMIT 1), (SELECT Id, Name FROM Questions__r) FROM Unit__c WHERE Id =: unitId];
            
            // I verify if the module response already exists
            Module_Response__c moduleResp = [SELECT Id FROM Module_Response__c WHERE Module__c =: unit.Module__c AND Student__c =: student.Id AND Status__c = 'In Progress'];

            // If it doesn't exist:
            if(moduleResp == null){
                // I create and insert the Module Response
                Module_Response__c moduleResp = new Module_Response__c(Student__c = student.Id, Module__c = unit.Module__c, Status__c = 'In Progress');
                insert moduleResp;
            }

            // I create and insert the Unit Response 
            Unit_Response__c unitResp = new Unit_Response__c(Unit__c = unitId, Student__c = student.Id, Module_Response__c = moduleResp.Id, Status__c = 'Draft');
            insert unitResp;
            
            // NTH
            unitResp.Number_of_tries__c = !unit.Unit_Responses__c.isEmpty() ? unit.Unit_Response__c[0].Number_of_tries__c + 1 : 1;
            insert unitResp;
            
            // I create and load the questions responses
            Map<Id,Id> answerMap = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer,Map<Id,Id>.class);
            List<QuestionResponse__c> questionRespList = new List<QuestionResponse__c>();
            //for(Id questionId : answerMap.keySet()){
            for(Question__c question : unit.Questions__r){
                // I check if the question was answered in the map
                if(answerMap.containsKey(questionId)){
                    QuestionResponse__c questionResp = new questionResponce__c(Question__c = question.Id, Unit_Response__c = unitResp.Id, Option__c = answerMap.get(question.Id));
                questionRespList.add(questionResp);
                }else{
                    throw new CustomException('The question ' + question.Name + ' was not answered and is required');
                }
            }
            insert questionRespList;

            // I update the unit response status to 'Answered' to trigger the evaluation process
            unitResp.Status__c = 'Answered';
            update unitResp;
        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }
    }
}
