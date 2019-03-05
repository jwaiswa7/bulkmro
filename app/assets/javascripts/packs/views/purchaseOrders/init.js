import purchaseOrdersIndex from "./index";
import inwardDispatchDeliveredQueue from "./inwardDispatchDeliveredQueue";
import materialReadinessQueue from "./materialReadinessQueue";
import updateLogisticsOwner from "./inwardDispatchPickupQueue";
import editMaterialFollowup from "./editMaterialFollowup";

let purchaseOrders= {
    index: purchaseOrdersIndex,
    inwardDispatchDeliveredQueue: inwardDispatchDeliveredQueue,
    materialReadinessQueue: materialReadinessQueue,
    inwardDispatchPickupQueue: updateLogisticsOwner,
    editMaterialFollowup: editMaterialFollowup
}

export default purchaseOrders