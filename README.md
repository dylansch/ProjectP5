# ProjectP5
Inconsistencias:
1) No deberia poder elegir cualquier unidad para un modulo, cada modulo tiene sus propias unidades. Estoy viendo que le puedo agregar cualquier unidad y me la contabiliza.
2) Creo que tengo un problema con el tema del Status del module, no me pasa a Finished una vez que completo todas las unidades del modulo.

public class UnitService {

    public static Boolean registerUnitResponse(Id unitId, String jsonAnswer){

        // I query the student Id
        Student__c student = [SELECT Id FROM Student__c WHERE  User__c =: Userinfo.getUserId()];
        
        // I query the unit from the database
        Unit__c unit = [SELECT Module__c FROM Unit__c WHERE Id =: unitId];

        // I create and insert the Module Response
        moduleResponse__c moduleResp = new moduleResponse__c(Student__c = student.Id, Module__c = unit.Module__c, Status__c = 'In Progress');
        insert moduleResp;

        // I create and insert the Unit Response 
        UnitResponse__c unitResp = new UnitResponse__c(Unit__c = unitId, Student__c = student.Id, ModuleResponse__c = moduleResp.Id);
        insert unitResp;

        // I create the questions responses
        Map<Id,Id> answerMap = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer,Map<Id,Id>.class);
        List<QuestionResponse__c> questionRespList = new List<QuestionResponse__c>();
        for(Id questionId : answerMap.keySet()){
            QuestionResponse__c questionResp = new questionResponce__c(Question__c = questionId, UnitResponse__c = unitResp.Id, Option__c = answerMap.get(questionId));
            questionRespList.add(questionResp);
        }
        insert questionRespList;
    }
}
 
