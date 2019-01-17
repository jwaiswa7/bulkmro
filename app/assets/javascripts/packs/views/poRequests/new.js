import bindAndUpdateStarRating from "../common/bindAndUpdateStarRating"
const newAction = () => {
    bindAndUpdateStarRating();
    $('.rating-modal a').click();
};

export default newAction