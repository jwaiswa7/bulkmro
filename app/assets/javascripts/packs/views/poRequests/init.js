import poRequestsEdit from "./edit";
import poRequestsShow from "./show";
import pending from "./pendingAndRejected";
import index from "./index";
import amended from "./amended";

let poRequests= {
    edit: poRequestsEdit,
    show: poRequestsShow,
    pendingAndRejected: pending,
    amended: amended,
    index: index
}

export default poRequests