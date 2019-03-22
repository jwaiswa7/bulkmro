
const newAction = () => {

    $('#freight_quote_freight_amount, #freight_quote_duty_on_freight_percentage').on('keyup', function () {
        calculateFreight();
    });

    $('#freight_quote_exchange_rate, #freight_quote_buying_price').on('keyup', function () {
        calculateBuyingPriceINR();
    });

    $('#freight_quote_other_charges').on('keyup', function () {
        $('#other').val($('#freight_quote_other_charges').val());
        calculateBasicCustomDuty();
        calculateNetTotalBuyingPrice();
    });

    $('#freight_quote_basic_custom_duty_percentage').on('keyup', function () {
        calculateBasicCustomDuty();
    });

    $('#freight_quote_gst_percentage').on('change', function () {
        calculateGst();
    });

    $('#freight_quote_bank_charges, #freight_quote_clearance, #freight_quote_outward_freight').on('keyup', function () {
        calculateNetTotalBuyingPrice();
    });

    $('#freight_quote_selling_price_inr').on('keyup', function() {
        calculateMargin();
    });

    $('#freight_quote_buying_price_inr').on('keyup', function() {
        $('#freight_quote_invoice_value').val($('#freight_quote_buying_price_inr').val());
        calculateInsurance();
        calculateGst();
    });

    $('#freight_quote_currency').on('change', function () {
        $('#freight_quote_exchange_rate').val(this.options[this.selectedIndex].dataset.conversionRate);
        calculateBuyingPriceINR();
    })
};

let calculateFreight = () => {
    let freight_amount = $('#freight_quote_freight_amount').val();
    let freight_percentage = $('#freight_quote_duty_on_freight_percentage').val();

    $('#freight').val(freight_amount);
    calculateInsurance();
    calculateNetTotalBuyingPrice();

    if((freight_amount != '' && parseFloat(freight_amount) > 0) && ( freight_percentage != '' && parseFloat(freight_percentage) > 0)) {
        $('#freight_quote_duty_on_freight').val(((parseFloat(freight_amount) * parseFloat(freight_percentage)) / 100).toFixed(2));
    }else{
        $('#freight_quote_duty_on_freight').val(0);
    }
};

let calculateBuyingPriceINR = () => {
    let exchange_rate = $('#freight_quote_exchange_rate').val();
    let buying_price = $('#freight_quote_buying_price').val();

    if( (exchange_rate != '' && parseFloat(exchange_rate) > 0) && (buying_price != '' && parseFloat(buying_price) > 0) ){
        $('#freight_quote_buying_price_inr').val((parseFloat(exchange_rate) * parseFloat(buying_price)).toFixed(2));
        $('#freight_quote_invoice_value').val((parseFloat(exchange_rate) * parseFloat(buying_price)).toFixed(2));
        calculateInsurance();
        calculateGst();
    }
};

let calculateInsurance = () => {
    let invoice_value = $('#freight_quote_invoice_value').val();
    let freight_amount = $('#freight_quote_freight_amount').val();
    let insurance_percentage = $('#freight_quote_insurance_percentage').val();

    if( (invoice_value != '' && parseFloat(invoice_value) > 0) && (freight_amount != '' && parseFloat(freight_amount) > 0) ){
        $('#freight_quote_insurance').val((((parseFloat(invoice_value) + parseFloat(freight_amount)) * parseFloat(insurance_percentage)) / 100).toFixed(2));
        calculateBasicCustomDuty();
    }
};

let calculateBasicCustomDuty = () => {
    let invoice_value = $('#freight_quote_invoice_value').val();
    let other_charges = $('#freight_quote_other_charges').val();
    let duty_percentage = $('#freight_quote_basic_custom_duty_percentage').val();

    $('#freight_quote_basic_custom_duty').val((((parseFloat(invoice_value) + parseFloat(other_charges)) * parseFloat(duty_percentage)) / 100).toFixed(2));
    calculateSocialWelfareCess();

};

let calculateSocialWelfareCess = () => {
    let basic_custom_duty = $('#freight_quote_basic_custom_duty').val();
    let cess_percentage = $('#freight_quote_social_welfare_cess_percentage').val();

    if((basic_custom_duty != '' && parseFloat(basic_custom_duty) > 0) && (cess_percentage != '' && parseFloat(cess_percentage) > 0)){
        $('#freight_quote_social_welfare_cess').val(((parseFloat(basic_custom_duty) * parseFloat(cess_percentage)) / 100).toFixed(2));
    }else{
        $('#freight_quote_social_welfare_cess').val(0);
    }
    calculateTotalDuty();
};

let calculateTotalDuty = () => {
    let basic_custom_duty = $('#freight_quote_basic_custom_duty').val();
    let social_welfare_cess = $('#freight_quote_social_welfare_cess').val();

    $('#freight_quote_custom_duty').val((parseFloat(basic_custom_duty) + parseFloat(social_welfare_cess)).toFixed(2));
    $('#net_custom_duty').val($('#freight_quote_custom_duty').val());

    calculateGst();
    calculateGrandTotal();
    calculateNetTotalBuyingPrice();

};

let calculateGst = () => {
    let invoice_value = $('#freight_quote_invoice_value').val();
    let social_welfare_cess = $('#freight_quote_social_welfare_cess').val();
    let gst_percentage = $('#freight_quote_gst_percentage').val();

    $('#freight_quote_gst').val((((parseFloat(invoice_value) + parseFloat(social_welfare_cess)) * parseFloat(gst_percentage)) / 100).toFixed(2));
    $('#gst_on_custom_duty').val($('#freight_quote_gst').val());

    calculateGrandTotal();
};

let calculateGrandTotal = () => {
    let total_duty = $('#freight_quote_custom_duty').val();
    let gst = $('#freight_quote_gst').val();

    $('#freight_quote_grand_total').val((parseFloat(gst) + parseFloat(total_duty)).toFixed(2));
};

let calculateNetTotalBuyingPrice = () => {
    let buying_price = $('#freight_quote_buying_price_inr').val();
    let freight = $('#freight').val();
    let other_charges = $('#other').val();
    let net_custom_duty = $('#net_custom_duty').val();
    let bank_charges = $('#freight_quote_bank_charges').val();
    let clearance = $('#freight_quote_clearance').val();
    let outward_freight = $('#freight_quote_outward_freight').val();

    $('#freight_quote_total_buying_price').val((parseFloat(buying_price) + parseFloat(freight) + parseFloat(other_charges) + parseFloat(net_custom_duty) + parseFloat(bank_charges) +
        parseFloat(clearance) + parseFloat(outward_freight)).toFixed(2));
    calculateMargin();
};

let calculateMargin = () => {
  let total_buying_price = $('#freight_quote_total_buying_price').val();
  let total_selling_price = $('#freight_quote_selling_price_inr').val();

  if((total_buying_price != '' && parseFloat(total_buying_price) > 0) && (total_selling_price != '' && parseFloat(total_selling_price) > 0)){
    $('#freight_quote_margin').val(((100 * (parseFloat(total_selling_price) - parseFloat(total_buying_price))) / parseFloat(total_selling_price)).toFixed(2));
    $('#freight_quote_margin_value').val(((total_selling_price * $('#freight_quote_margin').val()) / 100).toFixed(2));
  }else{
      $('#freight_quote_margin').val(0);
      $('#freight_quote_margin_value').val(0);
  }
};


export default newAction