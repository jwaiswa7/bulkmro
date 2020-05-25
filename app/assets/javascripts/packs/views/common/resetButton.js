import getInquiryTasks from "./getInquiryTasks";

const resetButton=function() {
    $(".bmro-reset-button").click(function () {
        $('.bmro-order-action').addClass('bmro-order-hide');
        $('.bmro-all-task-action').removeClass('bmro-order-hide');
        $('.bmro-inquries-main').removeClass('bmro-bg-color');
        $('.bmro-Inquries-task').removeClass('bmro-active-white');
        $('.bmro-Inquries-task').parent().removeClass('bmro-bg-color')
        $('.bmro-show-star').removeClass('bmro-inquiry-show-hide');
        $('.bmro-reset-button').addClass('bmro-inquiry-show-hide');

      $('.collapse').each((e,obj)=>{
          //console.log(obj.id);
        //let collapseId = $('.collapse').attr('id');
       $(`#${obj.id}`).removeClass('show');
    })
        $('.bmro-same-box').removeClass('bmro-same-box-active');

        $('.bmro-drop-icon-head-acknow').removeClass('bmro-drop-icon-head-rotated-up');
        $('.bmro-drop-icon-head-acknow').addClass('bmro-drop-icon-head');
        $('#collapseOne').addClass('show');

    });

}
export default resetButton;