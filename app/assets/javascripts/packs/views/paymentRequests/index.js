import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import updateStatus from "./updateStatus";
import callAjaxFunction from "../common/callAjaxFunction";
import commanComment from "../common/commanComment";

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    updateStatus()
    aggregateSummaryBox()
    commanComment('payment-request','payment_requests');

};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    let currencyName =  camelize($('body').data().currencyName)
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html( new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html(currencyName + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
}

export default index