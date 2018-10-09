import salesOrdersCreate from "./create";
import salesOrdersEdit from "./edit";
import salesOrdersNew from "./new";
import salesOrdersNewRevision from "./newRevision";
import salesOrdersUpdate from "./update";
import salesOrdersUpdateOnSelect from "./updateOnSelect";

let salesOrders = {
    create: salesOrdersCreate,
    edit: salesOrdersEdit,
    new: salesOrdersNew,
    newRevision: salesOrdersNewRevision,
    update: salesOrdersUpdate,
    updateOnSelect: salesOrdersUpdateOnSelect
}

export default salesOrders