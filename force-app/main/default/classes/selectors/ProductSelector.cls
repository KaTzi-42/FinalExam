public with sharing class ProductSelector {

    public static List<Product2> getProductByNameAndPricebook(String name, String pricebook) {
        String searchName = '%' + name + '%';

        return [
                SELECT
                        Id, Name,
                        (SELECT UnitPrice FROM PricebookEntries)
                FROM Product2
                WHERE Name LIKE :searchName
                AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2.Name = :pricebook)
        ];
    }
}