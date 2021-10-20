trigger testBeforeInsert on Opportunity (before insert) {

System.debug('OLDCONTEXT IS:'+ trigger.old);

}