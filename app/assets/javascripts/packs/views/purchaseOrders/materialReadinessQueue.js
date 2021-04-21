import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import updateLogisticsOwner from "./updateLogisticsOwner"
import removeHrefExport from '../common/removeHrefExport';
import commanComment from "../common/commanComment";

const materialReadinessQueue = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    bindSummaryBox1();
    updateSummaryBox();
    // aggregateSummaryBox();
    updateLogisticsOwner();
    removeHrefExport();
    commanComment('purchase_order','purchase_orders');
};

let bindSummaryBox1 = (classname) => {
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
// ---
let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    let currencyName =  camelize($('body').data().currencyName)
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html(new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html(currencyName + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
};

export default materialReadinessQueue