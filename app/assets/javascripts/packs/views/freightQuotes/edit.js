import newAction from "../freightQuotes/new";

const edit = () => {
    newAction();

    $('#net_custom_duty').val($('#freight_quote_custom_duty').val());
    $('#gst_on_custom_duty').val($('#freight_quote_gst').val());
    $('#other').val($('#freight_quote_other_charges').val());
    $('#freight').val($('#freight_quote_freight_amount').val());
};

export default edit