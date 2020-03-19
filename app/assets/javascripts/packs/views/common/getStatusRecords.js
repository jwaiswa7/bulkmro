

const getStatusRecords = function () {
        $(".bmro-status-label").click(function (e) {
            let inquiry_number = $(this).data('id');
            e.preventDefault();
            $.ajax({
                url: Routes.get_status_records_overseers_dashboard_path({format: "html"}),
                type: "GET",
                data: {
                    inquiry_number: inquiry_number
                },
                success: function (data) {
                    $('#status-record-div').empty();
                    $('#status-record-div').append(data);
                },
            });
            $('.bmro-slide-order-no').removeClass('bmro-slide-order-show');
            $('.bmro-slide-on-inquries').addClass('bmro-inquries-po');
        })


            $(".bmro-close-order-slide").click(function () {
                $('.bmro-slide-on-inquries').removeClass('bmro-inquries-po');
                $('.bmro-slide-order-no').removeClass('bmro-slide-order-show');
                $('.bmro-slide-on-inquries-2').removeClass('bmro-slide-on-inquries-2-show');
                $('.bmro-slide-on-inquries').removeClass('bmro-inquries-po');

            });

    };



export default getStatusRecords;