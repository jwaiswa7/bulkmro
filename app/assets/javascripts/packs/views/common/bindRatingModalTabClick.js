
const bindRatingModalTabClick = () => {
    $('#multipleRatingForm').on('click', '.custom-tab', function () {
        let id = $(this).data('id');
        
        $.ajax({
            data: {},
            url: "/overseers/company_reviews/" + id + "/render_form",
            success: function (data) {
                let form_div = '#form-render-div-' + id;
                $(form_div).empty();
                $(form_div).append(data);
                $('.star').raty({score: function () {
                        return $(this).attr('data-rating')
                    },
                    click: function (score, evt) {
                        var _this = this;
                        if (score == null) {
                            score = 0;
                        }
                        $.post('/rate',
                            {
                                score: score,
                                dimension: $(this).attr('data-dimension'),
                                id: $(this).attr('data-id'),
                                klass: $(this).attr('data-classname')
                            },
                            function (data) {
                                if (data) {
                                    if ($(_this).attr('data-disable-after-rate') == 'true') {
                                        $(_this).raty('set', {readOnly: true, score: score});
                                    }
                                }
                            });
                        gtag('event','submit-rating', { event_category: 'supplier-rating',  event_label: 'Supplier Rating ', value: score})
                    }})
            },
            complete: function complete() {
            }
        })
    })
}
export default bindRatingModalTabClick