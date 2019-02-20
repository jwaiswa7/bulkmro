import purchaseOrdersIndex from "./index";
import materialDeliveredQueue from "./materialDeliveredQueue";
import materialReadinessQueue from "./materialReadinessQueue";
import updateLogisticsOwner from "./materialPickupQueue";
import editMaterialFollowup from "./editMaterialFollowup";

let purchaseOrders= {
    index: purchaseOrdersIndex,
    materialDeliveredQueue: materialDeliveredQueue,
    materialReadinessQueue: materialReadinessQueue,
    materialPickupQueue: updateLogisticsOwner,
    editMaterialFollowup: editMaterialFollowup
}

export default purchaseOrders