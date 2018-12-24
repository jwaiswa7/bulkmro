
const newAction = () => {

    $('#freight_quote_freight_amount, #freight_quote_duty_on_freight_percentage').on('keyup', function () {
        calculateFreight();
    });

    $('#freight_quote_exchange_rate, #freight_quote_buying_price').on('keyup', function () {
        calculateBuyingPriceINR();
    });

};

let calculateFreight = () => {
    let freight_amount = $('#freight_quote_freight_amount').val();
    let freight_percentage = $('#freight_quote_duty_on_freight_percentage').val();

    if((freight_amount != '' && parseFloat(freight_amount) > 0) && ( freight_percentage != '' && parseFloat(freight_percentage) > 0)){
        $('#freight_quote_duty_on_freight').val((freight_amount * freight_percentage) / 100);
    }
}

let calculateBuyingPriceINR = () => {
    let exchange_rate = $('#freight_quote_exchange_rate').val();
    let buying_price = $('#freight_quote_buying_price').val();

    if( (exchange_rate != '' && parseFloat(exchange_rate) > 0) && (buying_price != '' && parseFloat(buying_price) > 0) ){
        $('#freight_quote_buying_price_inr').val((exchange_rate * buying_price));
        $('#freight_quote_invoice_value').val((exchange_rate * buying_price));
    }
}

export default newAction