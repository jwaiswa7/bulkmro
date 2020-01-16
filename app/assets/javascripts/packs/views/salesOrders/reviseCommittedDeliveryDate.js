import disableBackdateOption from "../common/disableBackdateOption";

const reviseCommittedDeliveryDate = () => {
    disableBackdateOption($('input[name*=revised_committed_delivery_date]'));
};

export default reviseCommittedDeliveryDate