import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"
import updateOnContactSelect from "../poRequests/updateOnContactSelect";


const newPurchaseOrdersRequests = () => {
    validatePoRequestAddresses();
    validatePoRequestContacts();
    updateRowTotal();

    updateOnContactSelect();
};



export default newPurchaseOrdersRequests