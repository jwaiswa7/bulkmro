import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";

const notInvoiced = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.not-invoiced-status').text(json.recordsStatusesCount);
        $('.not-invoiced-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsValue));
    });
};

export default notInvoiced