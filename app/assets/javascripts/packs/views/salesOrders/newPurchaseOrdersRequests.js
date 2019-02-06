import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"

import select2s from "../../components/select2s";

const newPurchaseOrdersRequests = () => {

/*    bindRatingModalTabClick();
    $('.rating-modal a').click();
    var customTabSelector = $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    updateRatingForm();*/


    validatePoRequestAddresses();
    updateRowTotal();

};


export default newPurchaseOrdersRequests