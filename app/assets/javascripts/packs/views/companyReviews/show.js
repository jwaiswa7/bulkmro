import bindAndUpdateStarRating from "../common/bindAndUpdateStarRating"

const  showAction = () => {
    $(document).ready(function () {
        // $('.star').each(function () {
        //     $(this).raty({'readOnly': false, 'score': $(this).data('rating'), 'precision': true})
        // })

        $('.change-company-review').on('click',function () {
            console.log('kkkk')
            $('#modalRatingForm').modal('show')
        })
        // $( "#modalRatingForm" ).on('shown.bs.modal', function(){
            bindAndUpdateStarRating()
        // })
    })

}

export default showAction