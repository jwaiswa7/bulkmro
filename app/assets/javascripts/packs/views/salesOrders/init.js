import salesOrdersCreate from "./create";
import salesOrdersEdit from "./edit";
import salesOrdersNew from "./new";
import salesOrdersNewRevision from "./newRevision";
import salesOrdersUpdate from "./update";
import salesOrdersUpdateOnSelect from "./updateOnSelect";
import salesOrdersIndex from "./index";
import salesOrdersPending from "./pending";
import notInvoiced from "./notInvoiced";
import newPurchaseOrdersRequests from "./newPurchaseOrdersRequests";
import salesOrdersNewAccountsConfirmation from "./newAccountsConfirmation";
import salesOrdersReviseCommittedDeliveryDate from "./reviseCommittedDeliveryDate";

let salesOrders = {
    create: salesOrdersCreate,
    edit: salesOrdersEdit,
    new: salesOrdersNew,
    newRevision: salesOrdersNewRevision,
    update: salesOrdersUpdate,
    updateOnSelect: salesOrdersUpdateOnSelect,
    index: salesOrdersIndex,
    pending: salesOrdersPending,
    notInvoiced: notInvoiced,
    newPurchaseOrdersRequests: newPurchaseOrdersRequests,
    newAccountsConfirmation: salesOrdersNewAccountsConfirmation,
    reviseCommittedDeliveryDate: salesOrdersReviseCommittedDeliveryDate
};

export default salesOrders