import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"

const edit = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();

};

export default edit