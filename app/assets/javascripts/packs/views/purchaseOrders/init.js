import purchaseOrdersIndex from "./index";
import materialDeliveredQueue from "./materialDeliveredQueue";
import editMaterialFollowup from "./editMaterialFollowup"

let purchaseOrders= {
    index: purchaseOrdersIndex,
    materialDeliveredQueue: materialDeliveredQueue,
    editMaterialFollowup: editMaterialFollowup
}

export default purchaseOrders