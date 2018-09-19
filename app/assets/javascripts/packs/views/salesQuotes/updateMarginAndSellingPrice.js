const updateMarginAndSellingPrice = () => {
    $('form').on('change', "[name$='[margin_percentage]']", function (e) {
        updateValues(this, 'margin_percentage');
    }).on('keyup', "[name$='[margin_percentage]']", function (e) {
        updateValues(this, 'margin_percentage');
    }).on('change', "[name$='[unit_selling_price]']", function (e) {
        updateValues(this, 'unit_selling_price');
    }).on('keyup', "[name$='[unit_selling_price]']", function (e) {
        updateValues(this, 'unit_selling_price');
    });
};

let updateValues = function (container, trigger) {
    let margin_percentage = $(container).closest('div.nested_fields').find("[name$='[margin_percentage]']").val();
    let unit_selling_price = $(container).closest('div.nested_fields').find("[name$='[unit_selling_price]']").val();
    let unit_cost_price = $(container).closest('div.nested_fields').find("[name$='[unit_cost_price]']").val();
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

export default updateMarginAndSellingPrice