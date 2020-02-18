// Imports
import disableBackdateOption from "../common/disableBackdateOption";

const editSupplierRfqs = () => {

    $('#select_all_isps').change(function () {
        $('input[name="inquiry_product_supplier_ids[]"]').each(function () {
            $(this).prop('checked', $('#select_all_isps').prop("checked")).trigger('change');
        });
    });

    $('input[name*=lead_time]').on("focus", function () {
        let $this = $(this);
        let newDate = Date.parse(new Date());
        console.log(newDate);
        disableBackdateOption($this,true,moment(newDate).format('DD-MMM-YYYY'));
    });

    $(".rfq_edit :input").on('change', function () {
        let dataId= $(this).data('id');
        let activeElementNumber = typeof dataId === 'undefined' ? '' : dataId.split('_').pop();
        let basicUnitPrice = $('input[data-id="unit_cost_price_' + activeElementNumber + '"]').val() || 0;
        let gst = $('select[data-id="gst_' + activeElementNumber + '"]').val();
        let unitFreight = $('input[data-id="unit_freight_' + activeElementNumber + '"]').val() || 0;

        calculate_final_unit_price(gst, basicUnitPrice, unitFreight, activeElementNumber);

        if (!(basicUnitPrice) || basicUnitPrice == "0") {
            $('input[data-id="final_unit_price_' + activeElementNumber + '"]').val('');
            $('input[data-id="gst_' + activeElementNumber + '"]').val('');
            $('input[data-id="unit_freight_' + activeElementNumber + '"]').val('');
            $('input[data-id="total_price_' + activeElementNumber + '"]').val('');
        }
    });

    rfqReview();
    updateAllInquiryProductSuppliers();

};

let rfqReview = () => {
    $('.rfq-review').click(function () {
        let inquiryProductSupplierIds = [];
        let inquiryId = $('input[name="supplier_rfq[inquiry_id]"]').val();
        $.each($("input[name='inquiry_product_supplier_ids[]']:checked"), function () {
            let $this = $(this);
            inquiryProductSupplierIds.push($this.attr('id').split('inquiry_product_supplier_id_')[1]);
        });

        let data = {inquiry_id: inquiryId, inquiry_product_supplier_ids: inquiryProductSupplierIds};
        window.open(Routes.rfq_review_overseers_inquiry_sales_quotes_path(data), '_self');
    });
};

let updateAllInquiryProductSuppliers = () => {
    $(".update-all, .update-and-send-link-all").click(function () {
        let $this = $(this);
        let formType = $this.val();
        let delay = 300;
        $("form").each(function() {
            let $this = $(this);
            let input = $("<input>").attr("type", "hidden").attr("name", "button").val(formType);
            $this.append(input);
            setTimeout( function () {
                $this.submit();
            }, delay);
            delay = delay + 700;
        });
        location.reload();
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

export default editSupplierRfqs