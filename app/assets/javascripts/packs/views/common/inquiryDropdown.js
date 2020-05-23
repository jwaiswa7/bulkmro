const dropdownInquiryArrow= function() {
    $('.bmro-drop-icon-head-acknow').click((e) => {
        //let current =e.currentTarget.parentElement.parentElement;
        //console.log('hdcal');
        if (e.currentTarget.classList.contains('bmro-drop-icon-head-rotated-up')) {
            e.currentTarget.classList.remove('bmro-drop-icon-head-rotated-up');
            e.currentTarget.classList.add('bmro-drop-icon-head');
        } else {
            e.currentTarget.classList.add('bmro-drop-icon-head-rotated-up');
            e.currentTarget.classList.remove('bmro-drop-icon-head');
        }
    })
}
export default dropdownInquiryArrow;