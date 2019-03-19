
import exportFilteredRecords from "../common/exportFilteredRecords";

const index = () => {

    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_products_path(), 'Email sent with Filtered ' + controller.titleize() + '!')

};

export default index