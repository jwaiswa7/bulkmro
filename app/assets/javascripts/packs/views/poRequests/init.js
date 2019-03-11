import poRequestsEdit from "./edit";
import poRequestsShow from "./show";
import poRequestsIndex from "./index";
// import pendingAndRejected from "./pendingAndRejected";
let poRequests= {
    edit: poRequestsEdit,
    show: poRequestsShow,
    index: poRequestsIndex,
    // pendingAndRejected: pendingAndRejected,
     pendingAndRejected: poRequestsIndex
}

export default poRequests