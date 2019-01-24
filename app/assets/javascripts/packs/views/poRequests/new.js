import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
const newAction = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();

    var customTabSelector =  $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    updateRatingForm();

};

export default newAction