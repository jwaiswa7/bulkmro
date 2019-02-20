import purchaseOrdersIndex from "./index";
import materialDeliveredQueue from "./materialDeliveredQueue";
import materialReadinessQueue from "./materialReadinessQueue";
import updateLogisticsOwner from "./materialPickupQueue";

let purchaseOrders= {
    index: purchaseOrdersIndex,
    materialDeliveredQueue: materialDeliveredQueue,
    materialReadinessQueue: materialReadinessQueue,
    materialPickupQueue: updateLogisticsOwner
}

export default purchaseOrders