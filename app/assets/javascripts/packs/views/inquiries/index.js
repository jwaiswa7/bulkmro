import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from '../common/updateSummaryBox'
import exportFilteredRecords from '../common/exportFilteredRecords'
import commanComment from "../common/commanComment"
import removeHrefExport from '../common/removeHrefExport';

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    aggregateSummaryBox()
    bulkUpdate()
    let controller = camelize($('body').data().controller);
     exportFilteredRecords(Routes.export_filtered_records_overseers_inquiries_path(), 'Email sent with Filtered ' + controller.titleize() + '!')

    commanComment('inquiry','inquiries');
    removeHrefExport()
    $('.datatable').on('init.dt', function (event) {
        var date = window.hasher.getParam('Date')
        if (date != '' && $('.bmro-date-bag').val() == ''){
            $('.bmro-date-bag').val(date).trigger('change')
        }
    });
};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    let currencyName =  camelize($('body').data().currencyName)
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html(new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html(currencyName + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
}

let bulkUpdate = () => {
    $(".bulk-update-form").on('click', '.bulk-update', function (event) {
        var formSelector = $(".bulk-update-form"),
            datastring = $(formSelector).serialize();
        $.ajax({
            type: "GET",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $('.bulk-update-form').modal('hide');
                if (data.success == 0) {
                    alert(data.message);
                } else {
                    window.location.reload();
                }
            },
            error: function error(_error) {
                if (_error.responseJSON && _error.responseJSON.error)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error + "</div>");
            }
        });
        event.preventDefault();
    });
}

export default index