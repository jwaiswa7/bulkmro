import disableBackdateOption from "../common/disableBackdateOption";

const editMaterialFollowup = () => {
    disableBackdateOption( $('.supplier-dispatch-date'));
    disableBackdateOption( $('.revised-supplier-delivery-date'));
    disableBackdateOption( $('.followup-date'));
}

export default editMaterialFollowup