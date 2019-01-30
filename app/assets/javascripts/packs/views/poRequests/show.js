import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"

const show = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();

};

export default show