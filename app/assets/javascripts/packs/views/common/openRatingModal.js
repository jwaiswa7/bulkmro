import bindRatingModalTabClick from "./bindRatingModalTabClick";
import updateRatingForm from "./updateRatingForm";
import createAndSetCookie from "./createAndSetCookie";

const openRatingModal = () => {
    bindRatingModalTabClick();
    var isRated = $('.rating-modal a').attr('data-rating')
    // Below code is for 'Review Later' button, which is not required from now.
    // if ((document.cookie.match(/\d+/g) < new Date().getTime()) && (isRated === 'false')){
    if (isRated === 'false'){
        $('.rating-modal a').click();
    }
    updateRatingForm();

    $('#multipleRatingForm').on('click','.review-later',function(e) {
        var path = document.location.pathname
        createAndSetCookie(path)
    })
}

export default openRatingModal
