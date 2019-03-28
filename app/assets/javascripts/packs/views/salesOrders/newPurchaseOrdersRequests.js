import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"
import validatePoRequestContacts from "../poRequests/validatePoRequestContacts"
import updateOnContactSelect from "../poRequests/updateOnContactSelect";


const newPurchaseOrdersRequests = () => {
    validatePoRequestAddresses();
    validatePoRequestContacts();
    updateRowTotal();

    updateOnContactSelect();
};



export default newPurchaseOrdersRequests