@IsTest
private class ProductTest {

    @IsTest
    static void searchProductsByNameTest() {
        Product2 prod = TestDataFactory.createProducts(1, true)[0];
        //fix for Standard Price Book in Test
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;

        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(1, prod.Id, true)[0];

        Test.startTest();
        List<Product2> result = ProductController.searchProductsByName(prod.Name, 'Standard Price Book');
        Test.stopTest();

        System.assertEquals(1, result.size());
    }
}