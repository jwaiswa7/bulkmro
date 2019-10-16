import exportDaterange from '../common/exportDaterange'
import exportFilteredRecords from "../common/exportFilteredRecords";
import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from '../common/updateSummaryBox'

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    $('#add_to_inquiry_wrapper').hide();
    toggleCheckboxes();

    $('#add_to_inquiry').click((event) => {
        addToInquiry();
    });
    exportDaterange();

    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_activities_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
};

let toggleCheckboxes = () => {
    $('#all_activities').prop("checked", false);

    $('#all_activities').change((event) => {
        let $element = $(event.target);
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="activities[]"]', (event) => {
        showOrHideActions();
    })
};

let addToInquiry = () => {
    let activities = [];

    $('input[type=checkbox][name="activities[]"]:checked').each((index, element) => {
        activities.push($(element).val());
    });

    let inquiry = $('select[name*=inquiry]').val();
    if (inquiry == '') {
        alert("Please Choose an Inquiry to Assign");
        $('#inquiry_select').select2('open');
    }

    if (activities.length > 0 && inquiry != '') {

        let data = JSON.stringify({activities: activities, inquiry: inquiry});
        console.log(data)
        $.ajax({
            url: Routes.add_to_inquiry_overseers_activities_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                let dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_activities').removeAttr('checked');
                $('#all_activities').prop("checked", false);
            }
        });
    }
};


let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="activities[]"]:checked').length > 0) {
        $('#add_to_inquiry_wrapper').show();
    } else {
        $('#add_to_inquiry_wrapper').hide();
    }

};

export default index