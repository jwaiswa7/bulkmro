import openRatingModal from "../common/openRatingModal";

const show = () => {

    openRatingModal()

    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
};

export default show