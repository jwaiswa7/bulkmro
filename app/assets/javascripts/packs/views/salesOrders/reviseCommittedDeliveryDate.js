import disableBackdateOption from "../common/disableBackdateOption";

const reviseCommittedDeliveryDate = () => {
    disableBackdateOption($('.sales_order_revised_committed_delivery_date'));
};

export default reviseCommittedDeliveryDate