const updateFreightCostAndUnitFreightCost = () => {
    $('form').on('change', "[name$='[freight_cost]']", function (e) {
        updateValues(this, 'freight_cost');
    }).on('keyup', "[name$='[freight_cost]']", function (e) {
        updateValues(this, 'freight_cost');
    }).on('change', "[name$='[unit_freight_cost]']", function (e) {
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
    let freight_cost = $(container).closest('div.nested_fields').find("[name$='[freight_cost]']").val();
    let unit_freight_cost = $(container).closest('div.nested_fields').find("[name$='[unit_freight_cost]']").val();
    let quantity = $(container).closest('div.nested_fields').find("[name$='[quantity]']").val();
    let all_freight_cost = $(container).closest('div.card-body').find("[name$='[freight_cost]']");
    let total_freight_cost = '0.0';

    if (trigger === 'freight_cost' || trigger === 'quantity') {
        if (freight_cost >= 0) {
            unit_freight_cost = (freight_cost / quantity);
            $(container).closest('div.nested_fields').find("[name$='[unit_freight_cost]']").val(parseFloat(unit_freight_cost).toFixed(2));
        }
    } else if ( trigger === 'unit_freight_cost' ) {
        freight_cost = ( unit_freight_cost * quantity );
        $(container).closest('div.nested_fields').find("[name$='[freight_cost]']").val(parseFloat(freight_cost).toFixed(2));
    } else {
        // TODO: UPDATE FREIGHT TOTAL ON DELETE
    }

    all_freight_cost.each(function() {
        total_freight_cost = parseFloat(total_freight_cost) + parseFloat($(this).val());
    });
    $(container).closest('div.card-body').find("[name$='[total_freight_cost]']").val(parseFloat(total_freight_cost).toFixed(2));
};

export default updateFreightCostAndUnitFreightCost