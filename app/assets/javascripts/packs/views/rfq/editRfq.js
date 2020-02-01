const editRfq = () => {
    $(".rfq_edit :input").on('change', function(){
        let dataId= $(this).data('id');
        let activeElementNumber = typeof dataId === 'undefined' ? '' : dataId.split('_').pop();
        let basicUnitPrice = parseFloat($('input[data-id="unit_cost_price_' + activeElementNumber + '"]').val()).toFixed(2) || 0;
        let gst = $('select[data-id="gst_' + activeElementNumber + '"]').val();
        let unitFreight = parseFloat($('input[data-id="unit_freight_' + activeElementNumber + '"]').val()).toFixed(2) || 0;

        calculate_final_unit_price(gst, basicUnitPrice, unitFreight, activeElementNumber);

        if (!(basicUnitPrice) || basicUnitPrice == "0") {
            $('input[data-id="final_unit_price_' + activeElementNumber + '"]').val('');
            $('input[data-id="gst_' + activeElementNumber + '"]').val('');
            $('input[data-id="unit_freight_' + activeElementNumber + '"]').val('');
            $('input[data-id="total_price_' + activeElementNumber + '"]').val('');
        }
    });
};

let calculate_final_unit_price = (gst, basicUnitPrice, unitFreight, activeElementNumber) => {
    let finalUnitPriceInput = $("form").find("[data-id='final_unit_price_" + activeElementNumber + "']");
    let quantity = $('input[data-id="quantity_' + activeElementNumber + '"]').val();
    let finalUnitPrice;
    if ((gst && gst != 0) && basicUnitPrice) {
        let unitPriceWithGst = (parseFloat(basicUnitPrice) * parseFloat(gst) / 100) || 0;
        let unitPriceWithFreight = parseFloat(unitFreight)  || 0;
        finalUnitPrice = parseFloat(basicUnitPrice) + unitPriceWithGst + unitPriceWithFreight;
        finalUnitPriceInput.val(parseFloat(finalUnitPrice).toFixed(2));
    } else if (basicUnitPrice) {
        let unitPriceWithGst = 0;
        let unitPriceWithFreight = parseFloat(unitFreight)  || 0;
        finalUnitPrice = parseFloat(basicUnitPrice) + unitPriceWithGst + unitPriceWithFreight;
        finalUnitPriceInput.val(parseFloat(finalUnitPrice).toFixed(2));
    }
    calculate_total_price(finalUnitPrice, quantity, activeElementNumber)
};

let calculate_total_price = (finalUnitPrice, quantity, activeElementNumber) => {
    let totalUnitPriceInput = $('input[data-id="total_price_' + activeElementNumber + '"]');
    if (finalUnitPrice != null && quantity != null) {
        let total = parseFloat(finalUnitPrice) * parseFloat(quantity);
        totalUnitPriceInput.val(total.toFixed(2));
    } else {
        totalUnitPriceInput.val('');
    }
};

export default editRfq