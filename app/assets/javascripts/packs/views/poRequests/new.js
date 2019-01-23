import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
const newAction = () => {
    $('#multipleRatingForm').on('show.bs.modal', function (e) {
        console.log('modal loaded')
        $('#multipleRatingForm .custom-tab')[0].click()
        })
    bindRatingModalTabClick();
    $('.rating-modal a').click();
};

export default newAction