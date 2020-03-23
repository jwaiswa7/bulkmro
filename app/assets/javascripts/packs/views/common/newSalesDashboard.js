import resetButton from "./resetButton";
import navigationMenu from "../../components/navigationMenu";
import clickOnCompose from "./clickOnCompose";
import notificationsPanel from "./notificationsPanel";
import getStatusRecords from './getStatusRecords';
import statusBox from './statusBox'
import getInquiryTasks from './getInquiryTasks';

const newdashboardload= function() {

notificationsPanel()
navigationMenu();
clickOnCompose();
statusBox();

    getStatusRecords();
    getInquiryTasks();

    $(".bmro-sales-back").click(function () {
        // $('.bmro-same-box').removeClass('bmro-same-box-active');
        $('.bmro-sales-main').addClass('bmro-sales-show-hide');
        $('.bmro-inquries-main').removeClass('bmro-inquiry-show-hide');
    })

    resetButton();

    $(".bmro-clickable").click(function () {
        $('.bmro-slide-on-inquries-2').addClass('bmro-slide-on-inquries-2-show');
        $('.bmro-slide-on-inquries').removeClass('bmro-inquries-po');
        $('.bmro-slide-order-no').removeClass('bmro-slide-order-show');
    });

    $('.bmro-show-purchse').click(function () {
        $('.bmro-purchase-order').addClass('bmro-show');
        $('.bmro-inquries-main').addClass('bmro-hide');
    });

    $('.bmro-show-sales').click(function () {
        $('.bmro-purchase-order').addClass('bmro-hide');
        $('.bmro-inquries-main').removeClass('bmro-hide');
    })

};

export default newdashboardload