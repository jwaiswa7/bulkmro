import poRequestsEdit from "./edit";
import poRequestsShow from "./show";
import poRequestsIndex from "./index";
// import pendingAndRejected from "./pendingAndRejected";
import poRequestsNew from "./new";
import poRequestNewPurchaseOrder from './newPurchaseOrder';
import poRequestRejectPurchaseOrderModal from './rejectPurchaseOrderModal';

let poRequests= {
    edit: poRequestsEdit,
    show: poRequestsShow,
    index: poRequestsIndex,
    // pendingAndRejected: pendingAndRejected,
    pendingAndRejected: poRequestsIndex,
    newPurchaseOrder: poRequestNewPurchaseOrder,
    new: poRequestsNew,
    rejectPurchaseOrderModal: poRequestRejectPurchaseOrderModal
}

export default poRequests