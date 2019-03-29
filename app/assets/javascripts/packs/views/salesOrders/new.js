import select2s from "../../components/select2s";

const newAction = () => {

    //assignEventsAndGetAttributes()

    let vj = initVueJS();
    $('body').on("fields_added.nested_form_fields", function (e, params) {
        vj.$destroy();

        vj = initVueJS();
    }).on("fields_removing.nested_form_fields", function (e, params) {
        vj.$destroy();

        vj = initVueJS();
    });

    $('body').on('change.select2', function (e, params) {

    });
};

let destroySelect = () => {
    if ($('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2()) {
        $('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2('destroy')
    }


    $('select.select2-ajax').each(function (k, v) {
        if ($(this).select2()) {
            $(this).select2('destroy');
        }

    });
};

let initVueJS = () => {
    let vj = new Vue({
        el: 'form',
        data: assignEventsAndGetAttributes(),
        mounted() {
            this.updateSelectElements();
            this.rowsUpdated();
        },
        watch: {
            rows: {
                handler(oldVal, newVal) {
                    this.rowsUpdated();
                },
                deep: true
            },
            conversion_rate() {
                this.calculateConvertedSellingPrices()
            },
            check: {
                handler(oldVal, newVal) {
                    //console.log(this.getCheckedRows());
                    this.rowsUpdated();
                },
                deep: true
            }
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

            getCheckedRows() {
                let checkedSupplierIds = [];
                let checkedRows = [];
                let checked = this.getAttribute("check");
                for (var property in checked) {
                    if (checked.hasOwnProperty(property)) {
                        checkedSupplierIds.push(checked[property]);
                    }
                }

                this.rows.forEach(function (row, currentRowIndex) {
                    if (checkedSupplierIds.includes(row.inquiry_product_supplier_id)) {
                        row.index = currentRowIndex;
                        checkedRows[currentRowIndex] = row;
                    }
                });

                return checkedRows;
            },

            rowUpdated(index) {
                this.updateConvertedSellingPriceFor(index);
                //this.triggerSellingPriceChangeFor(index, 'margin_percentage');
                this.recalculateRowTotals(index);
            },
            recalculateRowTotals(index) {
                console.log();
                let row = this.getRow(index);
                row.total_selling_price = toDecimal(row.unit_selling_price * row.quantity);
                let tax = parseFloat(row.total_selling_price * row.tax_percentage / 100);
                row.total_selling_price_with_tax = toDecimal(parseFloat(row.total_selling_price) + parseFloat(tax));
                this.setRow(index, row);
            },
            rowsUpdated() {
                let _this = this;
                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.rowUpdated(currentRowIndex);
                });
                this.afterRowsUpdated();
            },

            afterRowsUpdated() {
                let calculated_freight_cost_total = 0,
                    total_selling_price = 0,
                    total_cost_price = 0,
                    total_selling_price_with_tax = 0,
                    margin_percentage = 0;

                this.rows.forEach(function (row, index) {

                    total_selling_price += parseFloat(row.total_selling_price);
                    total_selling_price_with_tax += parseFloat(row.total_selling_price_with_tax);
                    total_cost_price += parseFloat(row.unit_cost_price_with_unit_freight_cost * row.quantity);
                    margin_percentage += parseFloat(row.margin_percentage);
                });
                this.calculated_total_margin = toDecimal(total_selling_price - total_cost_price);
                this.average_margin_percentage = toDecimal(this.calculated_total_margin) / this.rows.length;
                this.calculated_total_tax = toDecimal(total_selling_price_with_tax - total_selling_price);
                this.calculated_total = toDecimal(total_selling_price);
                this.calculated_total_with_tax = toDecimal(total_selling_price_with_tax);

            },

            dropdownChanged(e) {
                let container = e.target;
                let optionSelected = $("option:selected", container);
                let _this = this;

                $.each(optionSelected.data(), function (k, v) {
                    _this[underscore(k)] = v;
                });
                this.rowsUpdated();
            },

            quantityChangedFor(index) {
                //this.triggerFreightChangeFor(index, 'quantity');
                //   //this.triggerSellingPriceChangeFor(index);
            },

            selectSupplierChangedFor(index) {

            },

            freightCostSubtotalChangedFor(index) {
                this.triggerFreightChangeFor(index, 'freight_cost_subtotal');
            },

            unitFreightCostChangedFor(index) {
                this.triggerFreightChangeFor(index, 'unit_freight_cost');
            },

            unitCostPriceChangedFor(index) {
                //this.triggerSellingPriceChangeFor(index);
            },

            unitCostPriceWithUnitFreightCostChangedFor(index) {
                //this.triggerSellingPriceChangeFor(index);
            },

            marginPercentageChangedFor(index) {
                //this.triggerSellingPriceChangeFor(index, 'margin_percentage');
            },

            unitSellingPriceChangedFor(index) {
                //this.triggerSellingPriceChangeFor(index);
            },
            totalSellingPriceChangedFor(index) {
                //this.triggerSellingPriceChangeFor(index);
            },
            totalSellingPriceWithTaxChangedFor(index) {
                //this.triggerSellingPriceChangeFor(index);
            },
            taxCodeIdChangedFor(index) {
                //console.log("triggered Changed")
            },
            taxPercentageChangedFor(index) {

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
                // //this.triggerSellingPriceChangeFor(index);
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

                row.unit_cost_price_with_unit_freight_cost = parseFloat(row.unit_freight_cost) + parseFloat(row.unit_cost_price);

                this.setRow(index, row);
            },

            triggerSellingPriceChangeFor(index, trigger) {
                let row = this.getRow(index);

                /*
                                //console.dir(row);
                                let margin_percentage = row.margin_percentage;
                                let unit_selling_price = row.unit_selling_price;
                                let unit_cost_price_with_unit_freight_cost = row.unit_cost_price_with_unit_freight_cost;

                                if (trigger === 'margin_percentage' && margin_percentage >= 0 && margin_percentage < 100) {
                                    unit_selling_price = unit_cost_price_with_unit_freight_cost / (1 - (margin_percentage / 100));
                                    row.unit_selling_price = toDecimal(unit_selling_price);
                                } else {
                                    margin_percentage = 1 - (unit_cost_price_with_unit_freight_cost / unit_selling_price);
                                    row.margin_percentage = toDecimal(margin_percentage * 100);
                                }*/
                this.setRow(index, row);

            },
            /*genericFunction() {

            },
            initRowAndExecute(index, callback) {
                let row = this.getRow(index);
                if (row !== undefined) {
                    callback(index);
                }
            },
            initRowAndExecuteWithTrigger(index, trigger, callback) {
                let row = this.getRow(index);
                if (row !== undefined) {
                    callback(index, trigger);
                }
            },*/
            updateConvertedSellingPriceFor(index) {
                let row = this.getRow(index);
                if (row !== undefined) {
                    row.converted_unit_selling_price = toDecimal(parseFloat(row.unit_selling_price) / parseFloat(this.getAttribute('conversion_rate')));
                }
                this.setRow(index, row);
            },
            formatCurrency(value) {
                let val = (value / 1).toFixed(2);
                return this.currencySign + val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
            },
            calculateConvertedSellingPrices() {
                let _this = this;

                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.updateConvertedSellingPriceFor(currentRowIndex);
                })
            },
            updateSelectElements() {
                setTimeout(function () {
                    destroySelect();
                    $('form [name*=tax_code_id]').addClass('select2-ajax');
                    select2s();
                    $('select.select2-ajax').each(function (k, v) {
                        $(this).select2({
                            theme: "bootstrap",
                            containerCssClass: ':all:',
                            ajax: {
                                url: $(this).attr('data-source'),
                                dataType: 'json',
                                delay: 100
                            },
                            processResults: function (data, page) {
                                return {results: data};
                            },

                        }).on('change', function () {
                            //$(this).trigger('input');
                            let attributeName = this.name.match(/\[([a-z_]*)\]$/)[1];
                            let currentRowIndex = $(this).closest('div.simple-row').data('index');
                            //console.log(currentRowIndex,attributeName,this.value, vj.$data.rows[currentRowIndex][attributeName]);
                            vj.$data.rows[currentRowIndex][attributeName] = this.value;
                            //vj.$emit('input', this.value) // emitting Vue change event

                            let optionSelected = $("option:selected", this);
                            //console.log(optionSelected[0].text.match(/\w[\d]*\.[\d]*/gm)[0])
                            vj.$data.rows[currentRowIndex]["tax_percentage"] = parseFloat(optionSelected[0].text.match(/\w[\d]*\.[\d]*/gm)[0])
                        });
                    });
                }, 1000);

            }
        },
    });

    return vj;
};

let assignEventsAndGetAttributes = () => {
    let rows = [];
    let data = {
        currencySign: "",
        "check": {},
        calculated_total_margin: 0,
        average_margin_percentage: 0,
        calculated_total_tax: 0,
        calculated_total: 0,
        calculated_total_with_tax: 0,
        calculated_freight_cost_total: 0,
    };

    // Handle repeatable rows
    $('[data-index]').each(function (index, row) {
        let currentRowIndex = $(row).data('index');

        if ($(row).is(':visible')) {
            let currentRowTemplate = {};

            // Bind attributes
            $(row).find('[data-bind]').each(function (index, el) {
                let attributeName = "";
                let modelName = "";
                if ($(el).data("bind") != "") {

                    modelName = $(el).data("bind");
                    if ($(el).is(":checked")) {
                        data["check"][modelName] = $(el).val();
                    }
                    $(el).attr("v-model", 'check.' + modelName + '');
                }
                else {
                    attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
                    modelName = ["rows[", currentRowIndex, "].", attributeName].join('');
                    let attributeVal = $(el).val();

                    // To recreate VueJS v-model when nested form rows are added or removed
                    $(el).attr("v-model", modelName);
                    //$(el).attr("data-v-index", currentRowIndex);
                    currentRowTemplate[attributeName] = attributeVal;
                }


                assignDataEventsAsEvents(el, currentRowIndex);
            });
            // Show Model information in non-input element
            $(row).find('[data-bind-html]').each(function (index, el) {
                let modelName = "";
                if ($(el).data("bind-html") != "") {
                    let attributeName = $(el).data("bind-html");
                    modelName = ["rows[", currentRowIndex, "].", attributeName].join('');

                    // To recreate VueJS v-model when nested form rows are added or removed
                    $(el).attr("v-html", modelName);


                    //$(el).attr("data-v-index", currentRowIndex);
                    if (currentRowTemplate[attributeName] == undefined) {

                        let value = $(el).text().trim();
                        let numberValue = value;

                        //Check if first char is not a number
                        if (value.match("[^0-9]").index == 0) {
                            if (data.currencySign == "") {
                                data.currencySign = value.match("[^0-9]")[0]
                            }
                            $(el).attr("v-html", "formatCurrency(" + modelName + ")");
                            numberValue = value.replace(/[^0-9.]/g, "")
                        }

                        currentRowTemplate[attributeName] = parseFloat(numberValue);
                    }

                }
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
    $('[data-v-html]').each(function (index, el) {

        let value = $(el).text().trim();
        let attributeValue = value;
        let attributeName = $(el).attr('data-v-html');
        let modelName = attributeName;
        //Check if first char is not a number
        if (value.match("[^0-9]").index == 0) {
            if (data.currencySign == "") {
                data.currencySign = value.match("[^0-9]")[0];
            }
            attributeName = "formatCurrency(" + modelName + ")";
            attributeValue = value.replace(/[^0-9.]/g, "")
        }

        $(el).attr("v-html", attributeName);
        data[modelName] = attributeValue
    });
    data.rows = rows;
    return data;
};

let assignDataEventsAsEvents = (el, currentRowIndex = '') => {
    let eventNames = ['v-on:change', 'v-on:input', 'v-on:click'];
    let attributeName = undefined;

    if (el.name !== undefined && el.name.trim() !== '') {

        let methodName = "";

        if ($(el).data("bind") != "") {
            attributeName = $(el).data("bind");
            methodName = [camelizeAndSkipLastWord(attributeName), 'Changed', 'For'].join('');

        }
        else {
            attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
            methodName = camelize([attributeName, 'Changed', 'For'].join('_'));
        }


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



export default newAction