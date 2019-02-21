import openRatingModal from "../common/openRatingModal";

const edit = () => {
    openRatingModal()
    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
};

export default edit