import exportFilteredRecords from "../common/exportFilteredRecords";

const index = () => {

    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_companies_path(), 'Email sent with Filtered ' + controller.titleize() + '!')

    $(".select2-selection__clear").on("click", function () {
        alert("hello");
    })

    // $('.datatable').on('click','.rating',function () {
    //     var id = $(this).data('company-id')
    //     var $this = $(this)
    //     $(this).addClass('disabled')
    //     $.ajax({
    //         data: {},
    //         url: "/overseers/companies/"+id+"/render_rating_form",
    //         success: function (data) {
    //             $('.modal-render').empty()
    //             $('.modal-render').append(data)
    //             $('#modalRatingForm').modal('show')
    //             let reviewQuestionsLength = $(".rating-form .star").length
    //
    //             for (let i = 0; i < reviewQuestionsLength; i++) {
    //                 let starRating = ".star-"+i
    //                 $(starRating).raty({scoreName: "review-score-"+i ,score: function () {
    //                         return $(this).data('rating');
    //                     },
    //                     click:function (score) {
    //                         $(".rating-"+i).val(score)
    //                     }});
    //             }
    //             $('#modalRatingForm').on('hidden.bs.modal', function () {
    //                 $this.removeClass('disabled')
    //             })
    //         },
    //         complete: function complete() {
    //         }
    //     })
    // })

};
export default index