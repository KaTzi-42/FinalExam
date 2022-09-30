@IsTest
private class OpportunitySelectorTest {

    @IsTest
    static void getOppItemWithProductTest() {
        OpportunityLineItem item = TestDataFactory.createOppLineItemsByDefault(1, true)[0];

        Test.startTest();
        List<OpportunityLineItem> items = OpportunitySelector.getOppItemWithProduct(
                new Set<Id>{item.OpportunityId});
        Test.stopTest();

        System.assertEquals(1, items.size());
    }
}