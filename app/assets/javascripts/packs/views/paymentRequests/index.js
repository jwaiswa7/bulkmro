import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import updateStatus from "./updateStatus";

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    updateStatus()
    aggregateSummaryBox()
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