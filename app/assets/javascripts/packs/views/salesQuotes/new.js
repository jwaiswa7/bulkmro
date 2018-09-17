// Imports
import updateMarginAndSellingPrice from "./updateMarginAndSellingPrice";
import updateOnSelect from "./updateOnSelect";
import updateFreightCostAndUnitFreightCost from "./updateFreightCostAndUnitFreightCost"
import select2s from "../../components/select2s";

const newAction = () => {
    updateMarginAndSellingPrice();
    updateOnSelect();
    updateFreightCostAndUnitFreightCost();

    var vm;

    initVueJS();
    $('body')
        .on("fields_added.nested_form_fields", function (e, param) {
            initVueJS();
        });
};

let getSalesQuoteRows = () => {
    let rows = [];
    $('[data-index]').each(function (index, element) {
        let rowTemplate = {};
        let rowIndex = $(element).data('index')
        $(' [data-index="' + $(element).data('index') + '"] [data-bind]').each(function (index, element) {

            if ($(element).data('bind')) {
                let model = "row["+rowIndex+"]."+$(element).data('bind');
                $(element).attr("bind", model);
            }
            if ($(element).data('v-on:change')) {
                let methodWithParams = $(element).data('v-on:change').replace('_index_', rowIndex);
                console.log(methodWithParams);
                $(element).attr("v-on:change", methodWithParams);
            }
            if ($(element).data('bind') !== undefined) {
                rowTemplate[$(element).data('bind')] = $(element).val();
            }

        })
        rows[$(element).data('index')] = rowTemplate;
    });
    return rows;
}

let initVueJS = () => {


    return new Vue({
        el: '#layout',
        data: {
            rows: getSalesQuoteRows(),
            totals:{}
        },
        methods: {
            getRow(index){
              return this.rows[index];
            },
            setRow(index,row){
                this.rows[index] = row;
            },
            updateRow(index) {
                let row = this.rows[index];
                console.log(row.quantity);



                this.rows[index] = row;
            },
            updateRows() {
                let _this = this;
                this.rows.forEach(function (t, index) {
                    _this.updateRow(index);
                })
            },
            changeSupplier(event) {
                //console.log(event);
                let container = event.target
                let optionSelected = $("option:selected", container);
                let select = $(container).closest('select');
                let _this = this;
                let row = select.data('row')
                $.each(optionSelected.data(), function (k, v) {
                    _this.rows[row][underscore(k)] = v;
                });

            },
            updateFreightCostAndUnitFreightCost(index,trigger) {
                let row = this.getRow(index);


                let freight_cost_subtotal = row.freight_cost_subtotal;
                let unit_freight_cost = row.unit_freight_cost;
                let quantity = row.quantity;

                let freight_cost_total = 0.0;

                if (trigger === 'freight_cost' || trigger === 'quantity') {
                    if (freight_cost_subtotal >= 0) {
                        row.unit_freight_cost = (freight_cost_subtotal / quantity);
                    }
                } else if ( trigger === 'unit_freight_cost' ) {
                    row.freight_cost_subtotal = ( unit_freight_cost * quantity )
                } else {
                    // TODO: UPDATE FREIGHT TOTAL ON DELETE
                }

                /*this.rows.each(function(index,row) {
                    freight_cost_total += parseFloat(row.freight_cost_subtotal);
                });*/

                this.totals.freight_cost_total = parseFloat(freight_cost_total).toFixed(2);


                this.setRow(index,row);
            },


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
            reversedMessage: function () {
                // `this` points to the vm instance
                return this.message.split('').reverse().join('')
            }
        }
    })
}


export default newAction