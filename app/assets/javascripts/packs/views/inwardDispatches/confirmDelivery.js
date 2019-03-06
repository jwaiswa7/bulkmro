import disableBackdateOption from "../common/disableBackdateOption";

const confirmDelivery = () => {
    disableBackdateOption( $('.expected-dispatch-date'));
    disableBackdateOption( $('.expected-delivery-date'));
    disableBackdateOption( $('.actual-delivery-date'));
}

export default confirmDelivery