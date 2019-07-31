import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import updateLogisticsOwner from "./updateLogisticsOwner"

const materialReadinessQueue = () => {
    bindSummaryBox(".summary_box", '.status-filter');
    updateSummaryBox();
    aggregateSummaryBox();
    updateLogisticsOwner();
};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html(new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
};

export default materialReadinessQueue