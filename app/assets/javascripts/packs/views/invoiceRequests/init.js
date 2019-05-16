import invoiceRequestsIndex from "./index";
import invoiceRequestsEdit from "./edit";
import invoiceRequestsShow from "./show";

let invoiceRequests= {
    index: invoiceRequestsIndex,
    pending: invoiceRequestsIndex,
    edit: invoiceRequestsEdit,
    new: invoiceRequestsEdit,
    show: invoiceRequestsShow,
    completed: invoiceRequestsIndex,
    cancelled: invoiceRequestsIndex
}

export default invoiceRequests