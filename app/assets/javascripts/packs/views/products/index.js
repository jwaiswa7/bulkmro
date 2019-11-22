import exportFilteredRecords from "../common/exportFilteredRecords";
import removeHrefExport from '../common/removeHrefExport';


const index = () => {

    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_products_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
    removeHrefExport();
};

export default index