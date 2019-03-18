import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"
import validatePoRequestContacts from "../poRequests/validatePoRequestContacts"
import updateOnContactSelect from "../poRequests/updateOnContactSelect";
import validateLeadDate from "../poRequests/validateLeadDate";


const newPurchaseOrdersRequests = () => {
    validatePoRequestAddresses();
    validatePoRequestContacts();
    updateRowTotal();

    updateOnContactSelect();
    validateLeadDate();
};



export default newPurchaseOrdersRequests