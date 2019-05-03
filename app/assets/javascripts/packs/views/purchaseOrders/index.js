import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from '../common/exportFilteredRecords';

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()

    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_purchase_orders_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
};

export default index