import onLoadPage from '../common/onLoadPage'
const index = () => {
    onLoadPage();

    $('.datatable').on('click','.rating',function () {
        var id = $(this).data('company-id')
        var $this = $(this)
        $(this).addClass('disabled')
        $.ajax({
            data: {},
            url: "/overseers/companies/"+id+"/render_rating_form",
            success: function (data) {
                $('.modal-render').empty()
                $('.modal-render').append(data)
                $('#modalRatingForm').modal('show')
                let reviewQuestionsLength = $(".rating-form .star").length
                console.log(reviewQuestionsLength)

                for (let i = 0; i < reviewQuestionsLength; i++) {
                    let starRating = ".star-"+i
                    $(starRating).raty({scoreName: "review-score-"+i ,score: function () {
                            return $(this).data('rating');
                        },
                        click:function (score) {
                            $(".rating-"+i).val(score)
                        }});
                }
                $('#modalRatingForm').on('hidden.bs.modal', function () {
                    $this.removeClass('disabled')
                })
            },
            complete: function complete() {
            }
        })
    })

}
export default index