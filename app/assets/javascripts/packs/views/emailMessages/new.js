import openRatingModal from "../common/openRatingModal";

const newAction = () => {
    openRatingModal()

    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
};


export default newAction