const newAction = () => {

    let vm = initVueJS();


    $('body').on("fields_added.nested_form_fields", function (e, param) {
        vm.$destroy();
        vm = initVueJS();
    }).on("fields_removing.nested_form_fields", function (e, param) {
        vm.$destroy();
        vm = initVueJS();
    });
};

let setModelAndMethodAttributes = () => {
    let rows = [];
    let data = {}
    let events = ['v-on:change', 'v-on:keyup', 'v-on:input', 'v-on:click'];
    $('[data-index]').each(function (index, element) {


        let rowIndex = $(element).data('index');
        if ($('[name*="[' + rowIndex + ' ][_destroy]"]').length == 0) {
            let rowTemplate = {};
            console.log('[name*="[' + rowIndex + '][_destroy]"]', $('[name*="[' + rowIndex + ' ][_destroy]"]').length == 0);
            $(' [data-index="' + rowIndex + '"] [data-bind]').each(function (index, element) {

                if ($(element).data('bind')) {
                    let model = "rows[" + rowIndex + "]." + $(element).data('bind');
                    $(element).attr("v-model", model);
                }

                setEvents(element, events, rowIndex);

                if ($(element).data('bind') !== undefined) {
                    rowTemplate[$(element).data('bind')] = $(element).val();
                }

            });
            $(' [data-index="' + rowIndex + '"] [data-v]').each(function (index, element) {

                setEvents(element, events, rowIndex);

            });
            rows[rowIndex] = rowTemplate;
        }


    });


    $('[data-v-model]').each(function (index, element) {
        $(element).attr("v-model", $(element).data('v-model'));
        data[$(element).data('v-model')] = $(element).val();
        setEvents($(element), events, '');
    });

    $('[data-v-computed]').each(function (index, element) {
        $(element).attr("v-model", $(element).data('v-computed'));
    });

    data.rows = rows;
    return data;
}

let setEvents = (element, events, rowIndex) => {
    if (rowIndex === undefined) {
        rowIndex = '';
    }
    events.forEach(function (event) {
        if ($(element).data(event)) {
            let methodWithParams = $(element).data(event).replace('_index_', rowIndex);
            console.log(event, methodWithParams);
            $(element).attr(event, methodWithParams);
        }
    });


}

let decimal = (value, precision) => {
    if (precision === undefined) {
        precision = 2
    }
    return parseFloat(value).toFixed(precision);

}

let initVueJS = () => {

    return new Vue({
        el: '#layout',
        data: setModelAndMethodAttributes(),
        created() {
            // this.rows =  setModelAndMethodAttributes();
        },
        methods: {
            getRow(index) {
                return this.rows[index];
            },
            setRow(index, row) {
                if (row !== undefined) {
                    this.rows[index] = row;
                }

            },
            updateRow(index) {
                let row = this.getRow(index);

                //Calculate Totals here


                this.setRow(index, row)
            },
            updateRows() {
                let _this = this;
                this.rows.forEach(function (t, index) {
                    _this.updateRow(index);
                })
            },
            changeSupplier(event) {
                let container = event.target
                let optionSelected = $("option:selected", container);
                let select = $(container).closest('select');
                let _this = this;
                let row = select.data('row')
                if (_this.rows[row] !== undefined) {
                    $.each(optionSelected.data(), function (k, v) {
                        _this.rows[row][underscore(k)] = v;
                    });
                    this.updateFreightCostAndUnitFreightCostFor(row, 'quantity');

                }


            },
            updateFreightCostAndUnitFreightCostFor(index, trigger) {
                let row = this.getRow(index);

                let freight_cost_subtotal = row.freight_cost_subtotal;
                let unit_freight_cost = row.unit_freight_cost;
                let quantity = row.quantity;

                let freight_cost_total = 0.0;

                if (trigger === 'freight_cost' ) {
                    if (freight_cost_subtotal >= 0) {
                        row.unit_freight_cost = decimal(freight_cost_subtotal / quantity);
                    }
                } else if (trigger === 'unit_freight_cost' || trigger === 'quantity') {
                    row.freight_cost_subtotal = decimal(unit_freight_cost * quantity);
                } else {
                    // TODO: UPDATE FREIGHT TOTAL ON DELETE
                }

                row.unit_cost_price_with_unit_freight_cost = decimal(parseFloat(row.unit_freight_cost) + parseFloat(row.unit_cost_price));

                this.setRow(index, row);
                console.log('margin_percentage');
                this.updateMarginAndSellingPriceFor(index, 'margin_percentage');
            },
            changeQuantityFor(index) {
                this.updateFreightCostAndUnitFreightCostFor(index, 'quantity');
            },
            changeSellingPriceFor(index) {
                this.updateMarginAndSellingPriceFor(index);

            },
            updateMarginAndSellingPriceFor(index, trigger) {
                let row = this.getRow(index);

                let margin_percentage = row.margin_percentage;
                let unit_selling_price = row.unit_selling_price;
                let unit_cost_price_with_unit_freight_cost = row.unit_cost_price_with_unit_freight_cost;

                if (trigger === 'margin_percentage') {
                    if (margin_percentage >= 0 && margin_percentage < 100) {
                        unit_selling_price = unit_cost_price_with_unit_freight_cost / (1 - (margin_percentage / 100));
                        row.unit_selling_price = decimal(unit_selling_price);
                    }
                } else {
                    margin_percentage = 1 - (unit_cost_price_with_unit_freight_cost / unit_selling_price);
                    row.margin_percentage = decimal(margin_percentage * 100);
                }
                this.setRow(index, row);
                this.updateConvertedSellingPriceFor(index);
            },
            updateConvertedSellingPriceFor(index) {
                let row = this.getRow(index);

                row.converted_unit_selling_price = decimal(parseFloat(row.unit_selling_price) / parseFloat(this.conversion_rate))


                this.setRow(index, row);
            },
            updateConvertedSellingPrices() {
                let _this = this;
                this.rows.forEach(function (t, index) {
                    _this.updateConvertedSellingPriceFor(index);
                })
            },
            changeCurrency(event) {
                let container = event.target
                let optionSelected = $("option:selected", container);
                let _this = this;

                $.each(optionSelected.data(), function (k, v) {
                    _this[underscore(k)] = v;
                });
                this.updateConvertedSellingPrices();
            },
            drop(index) {
                let row = this.getRow(index)
                for (var property in row) {
                    if (row.hasOwnProperty(property)) {
                        row[property] = 0;
                    }
                }

                this.setRow(index, row);
            }
        },

        watch: {
            rows: {
                handler(oldVal, newVal) {
                    this.updateRows();
                },
                deep: true
            }
        },
        computed: {
            // a computed getter
            totalFrieghtCost: function () {
                // `this` points to the vm instance
                var total = 0;
                this.rows.forEach(function (row, index) {
                    total += parseFloat(row.freight_cost_subtotal);
                })

                return total
            }
        }
    })
}


export default newAction