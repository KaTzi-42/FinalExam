import {LightningElement, api} from 'lwc';
import {CloseActionScreenEvent} from "lightning/actions";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import searchProductsByName from '@salesforce/apex/ProductController.searchProductsByName'
import createPurchaseOrder from '@salesforce/apex/PurchaseOrderController.createPurchaseOrder'
import createPurchaseOrderLineItem from '@salesforce/apex/PurchaseOrderLineItemController.createPurchaseOrderLineItem'

export default class CreatePurchaseOrder extends LightningElement {
    @api recordId;

    product;
    orderName;
    quantity;
    unitPrice;
    productLookupErrors = [];

    async handleLookupSearch(event) {
        try {
            const lookup = event.target;
            const searchResult = await searchProductsByName({
                name: event.detail.searchCondition,
                pricebook: 'supplier'
            });

            lookup.setSearchResults(searchResult);
        } catch (e) {
            console.error('Lookup Product error', JSON.stringify(e));
            this.errors = [e];
        }
    }

    handleLookupSelectionChange(event) {
        this.product = event.target.getSelection();

        this.unitPrice = this._validateProductLookup()
            ? this.product.PricebookEntries[0].UnitPrice
            : '';
    }

    handleNameInput(event) {
        this.orderName = event.target.value;
    }

    handleQuantityInput(event) {
        this.quantity = event.target.value;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    validateInputs() {
        const validated = new Set();

        validated.add(this._validateProductLookup());
        validated.add(this.template.querySelector('lightning-input[data-field="name"]').reportValidity());
        validated.add(this.template.querySelector('lightning-input[data-field="quantity"]').reportValidity());

        return !validated.has(false);
    }

    async handleSubmit() {
        try {
            if (!this.validateInputs())
                return;

            const orderId = await createPurchaseOrder({
                name: this.orderName, vendorId: this.recordId
            });
            await createPurchaseOrderLineItem({
                productId: this.product.Id,
                purchaseOrderId: orderId,
                quantity: this.quantity,
                price: this.unitPrice
            })

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Purchase Order created',
                variant: 'success',
            }));
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error creating record',
                message: e.body.message,
                variant: 'error',
            }));
            console.error(e);
        } finally {
            this.handleCancel();
        }
    }

    _validateProductLookup() {
        this.productLookupErrors = [];
        const selection = !!(this.template.querySelector('c-custom-lookup').getSelection());

        if (!selection) {
            this.productLookupErrors.push({message: 'Please make a selection.'});
        }

        return selection;
    }
}