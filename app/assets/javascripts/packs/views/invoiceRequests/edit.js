import updateRatingForm from "../common/updateRatingForm";
import bindRatingModalTabClick from "../common/bindRatingModalTabClick";

const edit = () => {
    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();
};

export default edit