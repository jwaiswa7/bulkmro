import bindAndUpdateStarRating from "../common/bindAndUpdateStarRating"
const bindRatingModalTabClick = () => {
    $('#multipleRatingForm').on('click','.custom-tab',function () {
        var id = $(this).data('id')
        $.ajax({
            data: {},
            url: "/overseers/company_reviews/"+id+"/render_form",
            success: function (data) {
                var form_div = '#form-render-div-'+id
                $(form_div).empty()
                $(form_div).append(data)
                 let reviewQuestionsLength = $(form_div+" .star").length
                     for (let i = 0; i < reviewQuestionsLength; i++) {
                         let starRating = ".star-"+i
                         $(starRating).raty({scoreName: "review-score-"+i,
                             click:function (score) {
                                 $(form_div+ " .rating-"+i).val(score)
                             },score: function () {
                                 return $(form_div+" .rating-"+i).data('rating');
                             }});
                     }

            },
            complete: function complete() {
            }
        })
    })
}
export default bindRatingModalTabClick