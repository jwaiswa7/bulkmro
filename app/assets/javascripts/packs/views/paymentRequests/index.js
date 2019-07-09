import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import updateStatus from "./updateStatus";
import callAjaxFunction from "../common/callAjaxFunction";

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    updateStatus()
    aggregateSummaryBox()

    $('.datatable').on('click', '.comment-payment-request', function (e) {
        var id = $(this).data('payment-request-id')
        var title = $(this).attr('title')
        var json = {
            url: "/overseers/payment_requests/" + id + "/render_modal_form?title=" + title,
            modalId: '#addComment',
            className: '.open-modal-form',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: title
        }
        callAjaxFunction(json)


    })

};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html( new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
}

export default index