import supplierRfqsCreate from "./create";
import supplierRfqsEdit from "./edit";
import supplierRfqsNew from "./new";
import supplierRfqsUpdate from "./update";
import supplierRfqsIndex from "./index"
import supplierRfqReview from "./editSupplierRfqs"

let supplierRfqs = {
    create: supplierRfqsCreate,
    edit: supplierRfqsEdit,
    new: supplierRfqsNew,
    update: supplierRfqsUpdate,
    index: supplierRfqsIndex,
    editSupplierRfqs: supplierRfqReview
}

export default supplierRfqs