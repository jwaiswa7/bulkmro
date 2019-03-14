import disableBackdateOption from "../common/disableBackdateOption";
import newAction from "./new";

const confirmDelivery = () => {
    newAction();
    disableBackdateOption( $('.expected-dispatch-date'));
    disableBackdateOption( $('.expected-delivery-date'));
    disableBackdateOption( $('.actual-delivery-date'));
}

export default confirmDelivery