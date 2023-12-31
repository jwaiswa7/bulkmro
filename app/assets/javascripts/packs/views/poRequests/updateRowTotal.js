const updateRowTotal = () => {
    $('form').on('keyup', 'input[name*=quantity],input[name*=unit_price]', function (e) {
        updateTotal(e.target);
    }).find('input[name*=quantity],input[name*=unit_price]').each(function (e, element) {
        updateTotal(element);
    });

    $('form').on('keyup', 'input[name*=quantity],input[name*=selected_currency_up]', function (e) {
        updateTotalss(e.target);
    }).find('input[name*=quantity],input[name*=selected_currency_up]').each(function (e, element) {
        updateTotalss(element);
    });

    $('form').on('change', 'select[name*=tax_rate_id]', function (e) {
        updateTotal(e.target);
    }).find('select[name*=tax_rate_id]').each(function (e, element) {
        updateTotal(element);
    });
};

let updateTotal = (element) => {

    let container = $(element).closest('.po-request-row');
    let totalPriceElement = $(container).find('input[name$="converted_total_selling_price]"]');
    let taxPercentageOption = $('option:selected', $(container).find('select[name*=tax_rate_id]'));
    let totalTaxElement = $(container).find('input[name*=converted_total_tax]');

    let quantity = toDecimal(container.find('input[name*=quantity]').val());
    let unitPrice = toDecimal($(container).find('input[name*=unit_price]').val());
    let taxPercentage = 0;
    if (taxPercentageOption != null) {
        taxPercentage = toDecimal(taxPercentageOption [0].text.match(/\w[\d]*\.[\d]*/gm)[0])
    }
    let totalPriceWithTaxElement = $(container).find('input[name*=converted_total_selling_price_with_tax]');
    let total_price = quantity * unitPrice;
    let total_tax = ((total_price * taxPercentage) / 100);

    $(totalPriceElement).val(toDecimal(total_price));
    $(totalTaxElement).val(toDecimal(total_tax));
    $(totalPriceWithTaxElement).val(toDecimal(total_price + total_tax));
}

let updateTotalss = (element) => {

    let container = $(element).closest('.po-request-row');
    let totalPriceElement = $(container).find('input[name$="total_price_with_selected_currency]"]');

    let quantity = toDecimal($(container).find('input[name*=quantity]').val());
    let unitPrice = toDecimal($(container).find('input[name*=selected_currency_up]').val());

    let total_price = quantity * unitPrice;

    $(totalPriceElement).val(toDecimal(total_price));
}


let toDecimal = (value, precision = 2) => {
    if (isNaN(parseFloat(value))) {
        value = 0
    }

    return parseFloat(value).toFixed(precision);
};
export default updateRowTotal
