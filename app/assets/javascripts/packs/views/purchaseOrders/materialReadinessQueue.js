import updateSummaryBox from "../common/updateSummaryBox";
import updateLogisticsOwner from "./updateLogisticsOwner"
import removeHrefExport from '../common/removeHrefExport';

const materialReadinessQueue = () => {
    bindSummaryBox(".summary_box");
    updateSummaryBox();
    // aggregateSummaryBox();
    updateLogisticsOwner();
    removeHrefExport();
};

let bindSummaryBox = (classname) => {
    $(classname).on('click', function (e) {
        // let value = $(this).data('value'); .toLowerCase()
        var keyup_event = $.Event("keyup");
        let value = $(this).find('p')[0].innerText;
        let inputField = $('.filter-list-input');

        inputField.val(value).trigger(keyup_event);
        e.preventDefault();
        return false;
    });
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