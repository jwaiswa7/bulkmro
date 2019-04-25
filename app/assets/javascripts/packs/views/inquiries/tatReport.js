const tatReport = () => {
    $('.datatable').on('filters:change', function (event) {
        let value = window.hasher.getHashString();
        if (value != "" || $(this).val() != '') {

            if (value.indexOf('Sales') != -1) {
                $('.avg_summary_box').show();
                let inside_sales_owner_id = parseInt(value.split('%7C')[1]);
                $.ajax({
                    type: "GET",
                    data: {inside_sales_owner_id: inside_sales_owner_id},
                    url: Routes.sales_owner_status_avg_overseers_inquiries_path(),
                    success: function success(data) {
                        $(".avg_summary_box").empty();
                        $(".avg_summary_box").append(data);
                    },
                    error: function error(_error) {

                    }
                });
                event.preventDefault();
            } else {
                $('.avg_summary_box').hide();
            }
        } else {
            $('.avg_summary_box').hide();
        }

    });
}

export default tatReport