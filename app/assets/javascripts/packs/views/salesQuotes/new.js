const newAction = () => {
    let vj = initVueJS();

    $('body').on("fields_added.nested_form_fields", function (e, params) {
        vj.$destroy();
        vj = initVueJS();
    }).on("fields_removing.nested_form_fields", function (e, params) {
        vj.$destroy();
        vj = initVueJS();
    });
};

let initVueJS = () => {
    return new Vue({
        el: 'form',
        data: assignEventsAndGetAttributes(),
        watch: {
            rows: {
                handler(oldVal, newVal) {
                    this.rowsUpdated();
                },
                deep: true
            },
            conversion_rate() {
                this.updateConvertedSellingPrices()
            },
        },
        computed: {
            totalFreightCost: function () {
                // let total = 0;
                //
                // this.rows.forEach(function (row, index) {
                //     total += parseFloat(row.freight_cost_subtotal);
                // });
                //
                // return total;
            }
        },
        methods: {
            getAttribute(name) {
                return this[name]
            },

            getRow(index) {
                return this.rows[index];
            },

            setRow(index, row) {
                if (row !== undefined) {
                    this.rows[index] = row;
                }
            },

            dropRow(index) {
                let row = this.getRow(index);
                for (var property in row) {
                    if (row.hasOwnProperty(property)) {
                        row[property] = 0;
                    }
                }
                this.setRow(index, row);
            },

            rowUpdated(index) {
                let row = this.getRow(index);
                // perform calculations
                this.updateConvertedSellingPriceFor(index);

                this.setRow(index, row)
            },

            rowsUpdated() {
                let _this = this;

                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.rowUpdated(currentRowIndex);
                });

                this.afterRowsUpdated();
            },

            afterRowsUpdated() {
                let total = 0;
                this.rows.forEach(function (row, index) {
                    total += parseFloat(row.freight_cost_subtotal);
                });
                this.calculated_freight_cost_total = total;
            },

            dropdownChanged(e) {
                let container = e.target;
                let optionSelected = $("option:selected", container);
                let _this = this;

                $.each(optionSelected.data(), function (k, v) {
                    _this[underscore(k)] = v;
                });
            },

            quantityChangedFor(index) {
                this.triggerFreightChangeFor(index, 'quantity');
            },

            freightCostSubtotalChangedFor(index) {
                this.triggerFreightChangeFor(index, 'freight_cost_subtotal');
            },

            unitFreightCostChangedFor(index) {
                this.triggerFreightChangeFor(index, 'unit_freight_cost');
            },

            unitCostPriceChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },

            unitCostPriceWithUnitFreightCostChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },

            marginPercentageChangedFor(index) {
                this.triggerSellingPriceChangeFor(index, 'margin_percentage');
            },

            unitSellingPriceChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },

            convertedUnitSellingPriceChangedFor(index) {

            },

            changeSupplier(event) {
                /*let container = event.target;
                let optionSelected = $("option:selected", container);
                let select = $(container).closest('select');
                let _this = this;
                let row = select.data('row');
                if (_this.rows[row] !== undefined) {
                    $.each(optionSelected.data(), function (k, v) {
                        _this.rows[row][underscore(k)] = v;
                    });
                    this.triggerFreightChangeFor(row, 'quantity');
                }*/
            },
            sellingPriceChangedFor(index) {
                // this.triggerSellingPriceChangeFor(index);
            },

            triggerFreightChangeFor(index, trigger) {
                let row = this.getRow(index);

                let freight_cost_subtotal = row.freight_cost_subtotal;
                let unit_freight_cost = row.unit_freight_cost;
                let quantity = row.quantity;

                if (trigger === 'freight_cost_subtotal' && freight_cost_subtotal >= 0) {
                    row.unit_freight_cost = toDecimal(freight_cost_subtotal / quantity);
                } else if (trigger === 'unit_freight_cost' || trigger === 'quantity') {
                    row.freight_cost_subtotal = toDecimal(unit_freight_cost * quantity);
                }

                row.unit_cost_price_with_unit_freight_cost = toDecimal(row.unit_freight_cost) + toDecimal(row.unit_cost_price);

                this.setRow(index, row);
            },

            triggerSellingPriceChangeFor(index, trigger) {
                let row = this.getRow(index);


                console.dir(row);
                let margin_percentage = row.margin_percentage;
                let unit_selling_price = row.unit_selling_price;
                let unit_cost_price_with_unit_freight_cost = row.unit_cost_price_with_unit_freight_cost;

                if (trigger === 'margin_percentage' && margin_percentage >= 0 && margin_percentage < 100) {
                    unit_selling_price = unit_cost_price_with_unit_freight_cost / (1 - (margin_percentage / 100));
                    row.unit_selling_price = toDecimal(unit_selling_price);
                } else {
                    margin_percentage = 1 - (unit_cost_price_with_unit_freight_cost / unit_selling_price);
                    row.margin_percentage = toDecimal(margin_percentage * 100);
                }
                this.setRow(index, row);
            },

            updateConvertedSellingPriceFor(index) {
                let row = this.getRow(index);
                row.converted_unit_selling_price = toDecimal(row.unit_selling_price) / toDecimal(this.getAttribute('conversion_rate'));
                this.setRow(index, row);
            },

            updateConvertedSellingPrices() {
                let _this = this;

                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.updateConvertedSellingPriceFor(currentRowIndex);
                })
            }
        },
    })
};

let assignEventsAndGetAttributes = () => {
    let rows = [];
    let data = {};

    // Handle repeatable rows
    $('[data-index]').each(function (index, row) {
        let currentRowIndex = $(row).data('index');

        if ($(row).is(':visible')) {
            let currentRowTemplate = {};

            // Bind attributes
            $(row).find('[data-bind]').each(function (index, el) {
                let attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
                let attributeVal = $(el).val();

                // To recreate VueJS v-model when nested form rows are added or removed
                $(el).attr("v-model", ["rows[", currentRowIndex, "].", attributeName].join(''));
                currentRowTemplate[attributeName] = attributeVal;

                assignDataEventsAsEvents(el, currentRowIndex);
            });

            // Bind non-input events like buttons
            $(row).find('[data-v]').each(function (index, element) {
                assignDataEventsAsEvents(element, currentRowIndex);
            });

            rows[currentRowIndex] = currentRowTemplate;
        }
    });

    // Independent of rows, like a total row
    $('[data-v-model]').each(function (index, el) {
        let attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
        let attributeValue = $(el).val();

        $(el).attr("v-model", attributeName);
        data[attributeName] = attributeValue;

        assignDataEventsAsEvents($(el), undefined);
    });

    // V-models that cannot be edited, auto calculated
    $('[data-v-computed]').each(function (index, el) {
        $(el).attr("v-model", $(el).attr('data-v-computed'));
    });

    data.rows = rows;
    return data;
};

let assignDataEventsAsEvents = (el, currentRowIndex = '') => {
    let eventNames = ['v-on:change', 'v-on:input', 'v-on:click'];
    let attributeName = undefined;

    if (el.name !== undefined && el.name.trim() !== '') {
        attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];

        let methodName = camelize([attributeName, 'Changed', 'For'].join('_'));

        if (currentRowIndex !== '') {
            methodName += '(' + currentRowIndex + ')'
        }

        eventNames.forEach(function (eventName) {
            $(el).attr('v-on:input', methodName);
        });
    } else {
        eventNames.forEach(function (eventName) {
            if ($(el).data(eventName)) {
                $(el).attr(eventName, $(el).data(eventName).replace('_index_', currentRowIndex));
            }
        });
    }
};

let toDecimal = (value, precision = 2) => {
    return parseFloat(value).toFixed(precision);
};

export default newAction