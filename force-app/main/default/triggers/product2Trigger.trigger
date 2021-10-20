trigger product2Trigger on Product2 (after update) {
    product2Helper.AfterUpdate((List<Product2>) Trigger.old, (List<Product2>) Trigger.new);
}