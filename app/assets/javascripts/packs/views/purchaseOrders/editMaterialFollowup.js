import disableBackdateOption from "../common/disableBackdateOption";

const editMaterialFollowup = () => {
    $('.supplier-dispatch-date').on("focus", function () {
        disableBackdateOption( $('.supplier-dispatch-date'));
    });

    $('.revised-supplier-delivery-date').on("focus", function () {
        disableBackdateOption( $('.revised-supplier-delivery-date'));
    });

    $('.followup-date').on("focus", function () {
        disableBackdateOption( $('.followup-date'));
    });
}

export default editMaterialFollowup