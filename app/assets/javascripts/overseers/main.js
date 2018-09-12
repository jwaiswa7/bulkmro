main = {
    a: undefined,
    load: function () {
        var dataAttributes = $('body').data();
        var controller = main.camelize(dataAttributes.controller);
        var controllerAction = main.camelize(dataAttributes.controllerAction);

        if (controller in main && controllerAction in main[controller]) {
            main[controller][controllerAction]();
            console.log("main[" + controller + "][" + controllerAction + "]")
        }
    },
    camelize: function camelize(text) {
        var separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
        var words = text.split(separator);
        var camelized = [words[0]].concat(words.slice(1).map(function (word) {
            return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
        }));
        return camelized.join('');
    },

    imports: {
        manageFailedSkus: function () {
            var onRadioChange = function (radio) {
                var newProductForm = $(radio).closest('div.option-wrapper').find('div.nested');
            
                if (isNaN(radio.value)) {
                    newProductForm.find(':input:visible:not(:radio)').prop('disabled', false).prop('required', true);
                } else {
                    newProductForm.find(':input:visible:not(:radio)').prop('disabled', true).prop('required', false);
                }
            };

            $(':input:visible:radio:checked').each(function (e) {
                onRadioChange(this);
            });

            $('input[name*=approved_alternative_id]:radio').on('change', function (e) {
                onRadioChange(this);
            });
        },

        createFailedSkus: function () {
            main.imports.manageFailedSkus()
        },

    },
    inquiries: {
        editSuppliers: function () {
            var onSupplierChange = function (container) {
                var optionSelected = $("option:selected", container);
                var select = $(container).closest('select');

                if (optionSelected.exists() && optionSelected.val() !== '') {
                    $.getJSON({
                        url: Routes.best_prices_overseers_product_path(select.data('product-id')),
                        data: {
                            supplier_id: optionSelected.val(),
                            inquiry_product_supplier_id: select.data('inquiry-product-supplier-id')
                        },
                        success: function (response) {
                            select.closest('div.row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                            select.closest('div.row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
                        }
                    });
                }
            };

            $('form[action$=update_suppliers]').on('change', 'select[name*=supplier_id]', function (e) {
                onSupplierChange(this);
            }).on('click', '.update-with-best-price', function (e) {
                var parent = $(this).parent();
                var input = parent.find('input');
                parent.closest('div.row').find('[name*=unit_cost_price]').val(input.val());
            }).find('select[name*=supplier_id]').each(function (e) {
                onSupplierChange(this);
            });
        },

        updateSuppliers: function () {
            main.inquiries.editSuppliers();
        },
    },
    salesQuotes: {
        new: function () {
            main.salesQuotes.updateMarginAndSellingPrice();
            main.salesQuotes.updateUnitCostPriceOnSelect();
        },

        newRevision: function () {
            main.salesQuotes.new();
        },

        edit: function () {
            main.salesQuotes.new();
        },

        updateMarginAndSellingPrice: function () {
            var updateValues = function (container, trigger) {
                var margin_percentage = $(container).closest('div.nested_fields').find("[name$='[margin_percentage]']").val();
                var unit_selling_price = $(container).closest('div.nested_fields').find("[name$='[unit_selling_price]']").val();
                var unit_cost_price = $(container).closest('div.nested_fields').find("[name$='[unit_cost_price]']").val();

                if (trigger === 'margin_percentage') {
                    if (margin_percentage >= 0 && margin_percentage < 100) {
                        unit_selling_price = unit_cost_price / (1 - (margin_percentage / 100));
                        $(container).closest('div.nested_fields').find("[name$='[unit_selling_price]']").val(parseFloat(unit_selling_price).toFixed(2));
                    }
                } else {
                    margin_percentage = 1 - (unit_cost_price / unit_selling_price);
                    $(container).closest('div.nested_fields').find("[name$='[margin_percentage]']").val(parseFloat(margin_percentage * 100).toFixed(2));
                }
            };

            $('form').on('change', "[name$='[margin_percentage]']", function (e) {
                updateValues(this, 'margin_percentage');
            }).on('keyup', "[name$='[margin_percentage]']", function (e) {
                updateValues(this, 'margin_percentage');
            }).on('change', "[name$='[unit_selling_price]']", function (e) {
                updateValues(this, 'unit_selling_price');
            }).on('keyup', "[name$='[unit_selling_price]']", function (e) {
                updateValues(this, 'unit_selling_price');
            });
        },

        updateUnitCostPriceOnSelect: function () {
            var onSupplierChange = function (container) {
                var optionSelected = $("option:selected", container);
                var select = $(container).closest('select');
                select.closest('div.row').find('[name*=unit_cost_price]').val(optionSelected.data("unit-cost-price"));
                select.closest('div.row').find('[name*=margin_percentage]').val(15).change();
            };
            $('form').on('change', 'select[name*=inquiry_product_supplier_id]', function (e) {
                onSupplierChange(this);
            })
        }
    },
};

$.fn.exists = function () {
    return jQuery(this).length > 0;
};
