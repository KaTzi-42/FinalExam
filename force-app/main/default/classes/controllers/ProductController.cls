public with sharing class ProductController {

    @AuraEnabled(Cacheable=true)
    public static List<Product2> searchProductsByName(String name, String pricebook) {
        return ProductSelector.getProductByNameAndPricebook(name, pricebook);
    }
}