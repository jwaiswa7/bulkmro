import poRequestsEdit from "./edit";
import poRequestsNew from "./new";
import pending from "./pendingAndRejected";
import index from "./index";

let poRequests= {
    new: poRequestsNew,
    edit: poRequestsEdit,
    pendingAndRejected: pending,
    index: index
}

export default poRequests