// Imports
import newAction from "./new";
import massSupplierDeliveryDateUpdate from "./massSupplierDeliveryDateUpdate"

const edit = () => {
    newAction();
    massSupplierDeliveryDateUpdate();
};

export default edit