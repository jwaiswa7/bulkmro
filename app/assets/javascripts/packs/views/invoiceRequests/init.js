import invoiceRequestsIndex from "./index";
import invoiceRequestsEdit from "./edit";
import invoiceRequestsShow from "./show";

let invoiceRequests= {
    index: invoiceRequestsIndex,
    pending: invoiceRequestsIndex,
    edit: invoiceRequestsEdit,
    show: invoiceRequestsShow
}

export default invoiceRequests