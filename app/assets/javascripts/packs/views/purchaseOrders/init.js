import purchaseOrdersIndex from "./index";
import inwardDispatchDeliveredQueue from "./inwardDispatchDeliveredQueue";
import inwardCompletedQueue from "./inwardCompletedQueue";
import materialReadinessQueue from "./materialReadinessQueue";
import updateLogisticsOwner from "./inwardDispatchPickupQueue";
import editMaterialFollowup from "./editMaterialFollowup";

let purchaseOrders= {
    index: purchaseOrdersIndex,
    inwardDispatchDeliveredQueue: inwardDispatchDeliveredQueue,
    inwardCompletedQueue: inwardCompletedQueue,
    materialReadinessQueue: materialReadinessQueue,
    inwardDispatchPickupQueue: updateLogisticsOwner,
    editMaterialFollowup: editMaterialFollowup
}

export default purchaseOrders