import updateRatingForm from "../common/updateRatingForm";
import bindRatingModalTabClick from "../common/bindRatingModalTabClick";

const show = () => {
    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();

};

export default show