const updateTotalFreightCostAndUnitFreightCost = () => {
    $('form').on('change', "[name$='[freight_cost_subtotal]']", function (e) {
        updateValues(this, 'freight_cost_subtotal');
    }).on('keyup', "[name$='[freight_cost_subtotal]']", function (e) {
        updateValues(this, 'freight_cost_subtotal');
    }).on('change', "[name$='[unit_freight_cost_subtotal]']", function (e) {
        updateValues(this, 'unit_freight_cost');
    }).on('keyup', "[name$='[unit_freight_cost]']", function (e) {
        updateValues(this, 'unit_freight_cost');
    }).on('fields_removed.nested_form_fields', "", function (e) {
        updateValues(this, 'destroy');
    }).on('change', "[name$='[quantity]']", function (e) {
        updateValues(this, 'quantity');
    }).on('keyup', "[name$='[quantity]']", function (e) {
        updateValues(this, 'quantity');
    })
};

let updateValues = function (container, trigger) {
    let freight_cost_subtotal = $(container).closest('div.nested_fields').find("[name$='[freight_cost_subtotal]']").val();
    let unit_freight_cost = $(container).closest('div.nested_fields').find("[name$='[unit_freight_cost]']").val();
    let quantity = $(container).closest('div.nested_fields').find("[name$='[quantity]']").val();
    let freight_costs = $(container).closest('div.card-body').find("[name$='[calculated_freight_cost_total]']");
    let freight_cost_total = 0.0;

    if (trigger === 'freight_cost' || trigger === 'quantity') {
        if (freight_cost_subtotal >= 0) {
            unit_freight_cost = (freight_cost_subtotal / quantity);
            $(container).closest('div.nested_fields').find("[name$='[unit_freight_cost]']").val(parseFloat(unit_freight_cost).toFixed(2));
        }
    } else if ( trigger === 'unit_freight_cost' ) {
        let freight_cost_subtotal = ( unit_freight_cost * quantity );
        $(container).closest('div.nested_fields').find("[name$='[freight_cost_subtotal]']").val(parseFloat(freight_cost_subtotal).toFixed(2));
    } else {
        // TODO: UPDATE FREIGHT TOTAL ON DELETE
    }

    freight_costs.each(function() {
        freight_cost_total += parseFloat($(this).val());
    });

    $(container).closest('div.card-body').find("[name$='[calculated_freight_cost_total]']").val(parseFloat(freight_cost_total).toFixed(2));
};

export default updateTotalFreightCostAndUnitFreightCost