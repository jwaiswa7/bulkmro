import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"

const show = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();

    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
};

export default show