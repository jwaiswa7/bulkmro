import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import select2s from "../../components/select2s";

const newPurchaseOrdersRequests = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();

    var customTabSelector = $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    updateRatingForm();

    $('.supplier-committed-date').daterangepicker({
        singleDatePicker: true,
        minDate: moment(),
        locale: {
            format: 'DD-MMM-YYYY'
        }
    });
    //
    // $('select[name*=bill_to_id]').each(function(i, select) {
    //
    //
    //
    // });
    $('form').on('change', 'select[name*=bill_to_id]', function (e) {
        validateAddress(element)
    }).find('select[name*=bill_to_id]').each(function (e, element) {
        validateAddress(element)
    });
};

let validateAddress = (element) => {
    console.log("OPTION",$('option:selected', $(element)))
}

export default newPurchaseOrdersRequests