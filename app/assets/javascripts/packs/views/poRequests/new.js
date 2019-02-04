import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import updateRowTotal from "./updateRowTotal"


const newAction = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();

    var customTabSelector = $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    updateRatingForm();

    updateRowTotal();

};

export default newAction