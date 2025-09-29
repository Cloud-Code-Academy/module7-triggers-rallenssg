trigger OpportunityTrigger on Opportunity (before update, before delete, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount <= 5000) opp.addError(
                'Opportunity amount must be greater than 5000'
                );
        }
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won') {
                oppIds.add(opp.Id);
            }
        }
        
        if (!oppIds.isEmpty()) {
            for(Opportunity opp : [SELECT Id, Account.Industry FROM Opportunity WHERE Id IN :oppIds]) {
                if (opp.Account.Industry == 'Banking') { Trigger.oldMap.get(opp.Id).addError('Cannot delete closed opportunity for a banking account that is won'); }
            }
        }
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> acctIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                acctIds.add(opp.AccountId);
            }
        }
        
        if (acctIds.isEmpty()) { return; }
        
        Map<Id, Contact> accountIdToCeoMap = new Map<Id, Contact>();
        for (Contact ceoContact : [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE AccountId IN :acctIds AND Title = 'CEO'
        ]) {
            accountIdToCeoMap.put(ceoContact.AccountId, ceoContact);
        }
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : Trigger.new) {
            if (accountIdToCeoMap.containsKey(opp.AccountId)) {
                Contact ceo = accountIdToCeoMap.get(opp.AccountId);
                
                if (opp.Primary_Contact__c != ceo.Id) {
                    Opportunity oppForUpdate = new Opportunity(Id = opp.Id);
                    oppForUpdate.Primary_Contact__c = ceo.Id;
                    oppsToUpdate.add(oppForUpdate);
                }
            }
        }
        
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}