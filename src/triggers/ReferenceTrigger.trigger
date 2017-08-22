/**
 * Created by dell on 7/22/2017.
 */

trigger ReferenceTrigger on Reference__c (after insert, after update, after delete ,after undelete) {
    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUndelete){
            AccountHandler.addAccountShareToContact(Trigger.new);
        }

        if (Trigger.isUpdate) {
            AccountHandler.updateAccountShareToContact(Trigger.new, Trigger.old);
        }

        if (Trigger.isDelete) {
            AccountHandler.delAccountShareToContact(Trigger.old);
        }
    }
}