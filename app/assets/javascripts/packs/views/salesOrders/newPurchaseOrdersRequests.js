import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"
import validatePoRequestContacts from "../poRequests/validatePoRequestContacts"
import updateOnContactSelect from "../poRequests/updateOnContactSelect";
import validateLeadDate from "../poRequests/validateLeadDate";
import massLeadDateUpdate from "../poRequests/massLeadDateUpdate";

const newPurchaseOrdersRequests = () => {
    validatePoRequestAddresses();
    validatePoRequestContacts();
    updateRowTotal();

    updateOnContactSelect();
    validateLeadDate();
    massLeadDateUpdate();
};

export default newPurchaseOrdersRequests