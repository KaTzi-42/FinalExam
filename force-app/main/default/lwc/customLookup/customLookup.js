import {api, LightningElement} from 'lwc';

const SEARCH_DELAY = 500;
const KEY_ARROW_UP = 38;
const KEY_ARROW_DOWN = 40;
const KEY_ENTER = 13;

const VARIANT_LABEL_STACKED = 'label-stacked';
const VARIANT_LABEL_INLINE = 'label-inline';
const VARIANT_LABEL_HIDDEN = 'label-hidden';


export default class Lookup extends LightningElement {
    @api variant = VARIANT_LABEL_STACKED;
    @api label = '';
    @api required = false;
    @api disabled = false;
    @api placeholder = '';
    @api minSearchTermLength = 2;
    @api icon = 'standard:default';

    searchResultsLocalState = [];
    loading = false;

    _errors = [];
    _hasFocus = false;
    _isDirty = false;
    _searchTerm = '';
    _cleanSearchTerm;
    _cancelBlur = false;
    _searchThrottlingTimeout;
    _searchResults = [];
    _defaultSearchResults = [];
    _curSelection;
    _focusedResultIndex = null;

    @api
    set selection(initialSelection) {
        this._curSelection = Array.isArray(initialSelection) ? initialSelection : [initialSelection];
        this.processSelectionUpdate(false);
    }

    @api
    setFocus() {
        this.template.querySelector('input').focus();
    }

    get selection() {
        return this._curSelection;
    }

    @api
    set errors(value) {
        this._errors = value;
        // Blur component if errors are passed
        if (this._errors?.length > 0) {
            this.blur();
        }
    }

    get errors() {
        return this._errors;
    }

    @api
    setSearchResults(results) {
        // Reset the spinner
        this.loading = false;
        // Clone results before modifying them to avoid Locker restriction
        let resultsLocal = JSON.parse(JSON.stringify(results));

        this._searchResults = resultsLocal.map((result) => {
            result.title = result.Name;
            result.subtitle = result.Id;
            result.icon = this.icon;

            return result;
        });

        // Add local state and dynamic class to search results
        this._focusedResultIndex = null;
        const self = this;
        this.searchResultsLocalState = this._searchResults.map((result, i) => {
            return {
                result,
                get classes() {
                    let cls = 'slds-media slds-media_center slds-listbox__option slds-listbox__option_entity';
                    if (result.subtitle) {
                        cls += ' slds-listbox__option_has-meta';
                    }
                    if (self._focusedResultIndex === i) {
                        cls += ' slds-has-focus';
                    }
                    return cls;
                }
            };
        });
    }

    @api
    getSelection() {
        return this._curSelection;
    }

    @api
    setDefaultResults(results) {
        this._defaultSearchResults = [...results];
        if (this._searchResults.length === 0) {
            this.setSearchResults(this._defaultSearchResults);
        }
    }

    @api
    blur() {
        this.template.querySelector('input')?.blur();
    }

    updateSearchTerm(newSearchTerm) {
        this._searchTerm = newSearchTerm;

        const cleanSearchCondition = newSearchTerm.trim().toLowerCase();

        if (cleanSearchCondition.length < this.minSearchTermLength) {
            this.setSearchResults(this._defaultSearchResults);
            return;
        }

        // Save clean search term
        this._cleanSearchTerm = cleanSearchCondition;

        // Apply search throttling (prevents search if user is still typing)
        if (this._searchThrottlingTimeout) {
            clearTimeout(this._searchThrottlingTimeout);
        }

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._searchThrottlingTimeout = setTimeout(() => {
            if (this._cleanSearchTerm.length >= this.minSearchTermLength) {
                // Display spinner until results are returned
                this.loading = true;

                this.dispatchEvent(new CustomEvent('search', {
                    detail: {
                        searchCondition: this._cleanSearchTerm
                    }
                }));
            }
            this._searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    isSelectionAllowed() {
        return !this.hasSelection();
    }

    hasSelection() {
        return !!this._curSelection;
    }

    processSelectionUpdate(isUserInteraction) {
        // Reset search
        this._cleanSearchTerm = '';
        this._searchTerm = '';
        this.setSearchResults([...this._defaultSearchResults]);
        // Indicate that component was interacted with
        this._isDirty = isUserInteraction;
        // Blur input after single select lookup selection
        if (this.hasSelection()) {
            this._hasFocus = false;
        }
        // If selection was changed by user, notify parent components
        if (isUserInteraction) {
            this.dispatchEvent(new CustomEvent('selectionchange', {
                detail: {id: this._curSelection?.Id}
            }));
        }
    }

    // EVENT HANDLING

    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleKeyDown(event) {
        if (this._focusedResultIndex === null) {
            this._focusedResultIndex = -1;
        }
        if (event.keyCode === KEY_ARROW_DOWN) {
            // If we hit 'down', select the next item, or cycle over.
            this._focusedResultIndex++;
            if (this._focusedResultIndex >= this._searchResults.length) {
                this._focusedResultIndex = 0;
            }
            event.preventDefault();
        } else if (event.keyCode === KEY_ARROW_UP) {
            // If we hit 'up', select the previous item, or cycle over.
            this._focusedResultIndex--;
            if (this._focusedResultIndex < 0) {
                this._focusedResultIndex = this._searchResults.length - 1;
            }
            event.preventDefault();
        } else if (event.keyCode === KEY_ENTER && this._hasFocus && this._focusedResultIndex >= 0) {
            // If the user presses enter, and the box is open, and we have used arrows,
            // treat this just like a click on the listbox item
            const selectedId = this._searchResults[this._focusedResultIndex].Id;
            this.template.querySelector(`[data-recordid="${selectedId}"]`).click();
            event.preventDefault();
        }
    }

    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;

        const selectedItem = this._searchResults.find((result) => result.Id === recordId);
        if (!selectedItem) {
            return;
        }

        this._curSelection = selectedItem;
        this.processSelectionUpdate(true);
    }

    handleComboboxMouseDown(event) {
        const mainButton = 0;
        if (event.button === mainButton) {
            this._cancelBlur = true;
        }
    }

    handleComboboxMouseUp() {
        this._cancelBlur = false;
        // Re-focus to text input for the next blur event
        this.template.querySelector('input').focus();
    }

    handleFocus() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }

        this._hasFocus = true;
        this._focusedResultIndex = null;
    }

    handleBlur() {
        // Prevent action if selection is either not allowed or cancelled
        if (!this.isSelectionAllowed() || this._cancelBlur) {
            return;
        }

        this._hasFocus = false;
    }

    handleClearSelection() {
        this._curSelection = null;
        this._hasFocus = false;
        // Process selection update
        this.processSelectionUpdate(true);

        this.template.querySelector('input').focus();
    }

    // STYLE EXPRESSIONS

    get hasResults() {
        return this._searchResults.length > 0;
    }

    get getFormElementClass() {
        return this.variant === VARIANT_LABEL_INLINE
            ? 'slds-form-element slds-form-element_horizontal'
            : 'slds-form-element';
    }

    get getLabelClass() {
        return this.variant === VARIANT_LABEL_HIDDEN
            ? 'slds-form-element__label slds-assistive-text'
            : 'slds-form-element__label';
    }

    get getContainerClass() {
        let css = 'slds-combobox_container ';
        if (this._errors.length > 0) {
            css += 'has-custom-error';
        }
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        const isSearchTermValid = this._cleanSearchTerm;
        if (
            this._hasFocus &&
            this.isSelectionAllowed() &&
            (isSearchTermValid || this.hasResults)
        ) {
            css += 'slds-is-open';
        }
        return css;
    }

    get getInputClass() {
        let css = 'slds-input slds-combobox__input has-custom-height ';
        if (this._hasFocus && this.hasResults) {
            css += 'slds-has-focus ';
        }
        if (this._errors.length > 0 || (this._isDirty && this.required && !this.hasSelection())) {
            css += 'has-custom-error ';
        }
        css += 'slds-combobox__input-value ' + (this.hasSelection() ? 'has-custom-border' : '');

        return css;
    }

    get getComboboxClass() {
        return 'slds-combobox__form-element slds-input-has-icon ' +
            (this.hasSelection()
                ? 'slds-input-has-icon_left-right'
                : 'slds-input-has-icon_right');
    }

    get getSearchIconClass() {
        return 'slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? 'slds-hide' : '');
    }

    get getClearSelectionButtonClass() {
        return (
            'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    get getSelectIconName() {
        return this.hasSelection() ? this._curSelection.icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon ' + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        return this.hasSelection() ? this._curSelection.title : this._searchTerm;
    }

    get isInputReadonly() {
        return this.hasSelection();
    }
}