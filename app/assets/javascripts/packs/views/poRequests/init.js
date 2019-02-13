import poRequestsEdit from "./edit";
import poRequestsNew from "./new";
import pending from "./pendingAndRejected";
import index from "./index";
import amended from "./amended";

let poRequests= {
    new: poRequestsNew,
    edit: poRequestsEdit,
    pendingAndRejected: pending,
    amended: amended,
    index: index
}

export default poRequests