import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
const newPurchaseOrdersRequests = () => {

    bindRatingModalTabClick();
    // $('.rating-modal a').click();

    var customTabSelector =  $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    updateRatingForm();

    $('#daterange').daterangepicker({
        singleDatePicker: true,
        minDate: moment(),
        locale: {
            format: 'DD-MMM-YYYY'
        }
    });
};

export default newPurchaseOrdersRequests