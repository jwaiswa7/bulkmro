import updateRatingForm from "../common/updateRatingForm";
import bindRatingModalTabClick from "../common/bindRatingModalTabClick";

const show = () => {
    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();

    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
};

export default show