import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from '../common/exportFilteredRecords'
import removeHrefExport from '../common/removeHrefExport';


const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_sales_invoices_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
    removeHrefExport();
};

export default index