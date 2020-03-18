import resetButton from "./resetButton";
import navigationMenu from "../../components/navigationMenu";
import clickOnCompose from "./clickOnCompose";
import notificationsPanel from "./notificationsPanel";
const newdashboardload= function() {

notificationsPanel()
    // $(".bmro-menu-click").click(function () {
    //     $('.bmro-dash-main-menu').toggleClass('bmro-dash-main-menu-show');
    //     $(this).toggleClass('bmro-menu-roted');
    // });
    // $('.bmro-main-drop-col p').hover(function () {
    //     $(this).children('.bmro-dash-hover').css("display", "block");
    // }, function () {
    //     $(this).children('.bmro-dash-hover').css("display", "none");
    // });
    // $(".bmro-dashbord-click").click(function () {
    //     $('.bmro-dash-main-menu').removeClass('bmro-dash-main-menu-show');
    //     $('.bmro-menu-click').removeClass('bmro-menu-roted');
    // });
navigationMenu();

    $('#myModal').on('hidden.bs.modal', function () {
        tinymce.remove('.html-editor');
    });

    $(".bmro-right-side-open").click(function () {
        $('.bmro-slide-order-no').addClass('bmro-slide-order-show');
        $('.bmro-slide-on-inquries').removeClass('bmro-inquries-po');
    });
    $(".bmro-close-order-slide").click(function () {
        $('.bmro-slide-on-inquries').removeClass('bmro-inquries-po');
        $('.bmro-slide-order-no').removeClass('bmro-slide-order-show');
        $('.bmro-slide-on-inquries-2').removeClass('bmro-slide-on-inquries-2-show');
        $('.bmro-slide-on-inquries').removeClass('bmro-inquries-po');

    });
// $(".bmro-same-box").click(function () {
//     $('.bmro-same-box').removeClass('bmro-same-box-active');
//     $(this).addClass('bmro-same-box-active',1000);
//     $('.bmro-sales-main').removeClass('bmro-sales-show-hide');
//     $('.bmro-inquries-main').addClass('bmro-inquiry-show-hide');
// });


    // const clickOnCompose = function () {
    //     $(".compose-email").click(function (e) {
    //         let inquiry_number = $(this).data('id');
    //         e.preventDefault();
    //         $.ajax({
    //             url: Routes.show_email_message_modal_overseers_dashboard_path({format: "html"}),
    //             type: "GET",
    //             data: {
    //                 inquiry_number: inquiry_number
    //             },
    //             success: function (data) {
    //                 $('#email_message').empty();
    //                 $('#email_message').append(data);
    //                 tinymce.init({
    //                     selector: '.html-editor',
    //                     plugins: "fullpage code autoresize",
    //                     skin: 'lightgray',
    //                     toolbar: 'undo redo | bold italic | link | code',
    //                     menubar: false,
    //                     fullpage_default_doctype: '<!DOCTYPE html>',
    //                     fullpage_default_encoding: "UTF-8",
    //                     visual: false
    //                 });
    //             },
    //         });
    //     });
    // }

    clickOnCompose();
    const getInquiryTasks = function () {
        $(".inquiry").click(function (e) {
            let inquiry_number = $(this).data('inquiry');
            e.preventDefault();
            $('.bmro-inquries-main').addClass('bmro-bg-color');
            $('.bmro-Inquries-task').removeClass('bmro-active-white');
            $(this).parent().parent().addClass('bmro-active-white', 1000);
            $('.bmro-show-star').addClass('bmro-inquiry-show-hide');
            $('.bmro-reset-button').removeClass('bmro-inquiry-show-hide');
            $.ajax({
                url: Routes.get_inquiry_tasks_overseers_dashboard_path({format: "html"}),
                type: "GET",
                data: {
                    inquiry_number: inquiry_number
                },
                success: function (data) {
                    $('.inquiry-tasks').empty();
                    $('.inquiry-tasks').append(data);
                    $('.bmro-order-action').removeClass('bmro-order-hide');
                    $('.bmro-all-task-action').addClass('bmro-order-hide');
                    clickOnCompose()
                    // $('.bmro-Inquries-task').removeClass('bmro-active-white');
                    // $this.addClass('bmro-active-white');
                    // $('.bmro-reset-button').addClass('bmro-inquiry-show-hide');
                },
            });
        });
    };

    const getStatusRecords = function () {
        $(".bmro-status-label").click(function (e) {
            let inquiry_number = $(this).data('id');
            e.preventDefault();
            $.ajax({
                url: Routes.get_status_records_overseers_dashboard_path({format: "html"}),
                type: "GET",
                data: {
                    inquiry_number: inquiry_number
                },
                success: function (data) {
                    $('#status-record-div').empty();
                    $('#status-record-div').append(data);
                },
            });
            $('.bmro-slide-order-no').removeClass('bmro-slide-order-show');
            $('.bmro-slide-on-inquries').addClass('bmro-inquries-po');
        })
    };

    getStatusRecords();
    getInquiryTasks();

    $(".status-box").click(function (e) {
        let inquiry_status = $(this).data('status');
        $('.bmro-same-box').removeClass('bmro-same-box-active');
        $(this).addClass('bmro-same-box-active', 1000);
        e.preventDefault();
        $.ajax({
            url: Routes.get_filtered_inquiries_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                status: inquiry_status
            },
            success: function (data) {
                $('.inquiries-card').empty();
                $('.inquiries-card').append(data);
                getInquiryTasks();
                getStatusRecords();
            },
        });
    });

    $(".bmro-sales-back").click(function () {
        // $('.bmro-same-box').removeClass('bmro-same-box-active');
        $('.bmro-sales-main').addClass('bmro-sales-show-hide');
        $('.bmro-inquries-main').removeClass('bmro-inquiry-show-hide');
    })
// $(".bmro-order-show").click(function () {
//     $('.bmro-order-action').removeClass('bmro-order-hide');
//     $('.bmro-all-task-action').addClass('bmro-order-hide');
//     $('.bmro-inquries-main').addClass('bmro-bg-color');
//     // $('.bmro-Inquries-task').removeClass('bmro-active-white');
//     $(this).parent().parent().addClass('bmro-active-white',1000);
//     $('.bmro-show-star').addClass('bmro-inquiry-show-hide');
//     $('.bmro-reset-button').removeClass('bmro-inquiry-show-hide');
// });
resetButton();
    $(".bmro-dash-main-menu").mouseleave(function () {
        $(".bmro-dash-main-menu").removeClass('bmro-dash-main-menu-show');
    });
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

    $('.dropdown-toggle').click(function () {
        $('.dropdown-toggle').parent().removeClass('dropdown-show');
        $(this).parent().addClass('dropdown-show', 2000);
    })

    function toggleFirstLevelHeading(classname, containerName) {

        $("#" + classname).click(() => {
            let toggle = $('.bmro-main-drop-col-level-one-container .bmro-select-level-one-to-see-second-and-third').hasClass('active')
            let toggleClass = $('.bmro-second-and-third-level-headings .bmro-second-and-third-level-headings-container').hasClass('show')
            // console.log(toggle)
            if (toggle || toggleClass) {
                $('.bmro-main-drop-col-level-one-container .bmro-select-level-one-to-see-second-and-third').toggleClass('active', false)
                $('.bmro-second-and-third-level-headings .bmro-second-and-third-level-headings-container').toggleClass('show', false)
            }
            // console.log(this)
            $("#" + classname).toggleClass('active', true)
            $("#" + containerName).toggleClass('show', true)
        })

    }

    $(".bmro-menu-click").click(function () {
        $('.bmro-dash-main-menu').toggleClass('bmro-dash-main-menu-show');
        $(this).toggleClass('bmro-menu-roted');
    })

    toggleFirstLevelHeading('nav-catalog-heading', 'catalog_heading_container')

    toggleFirstLevelHeading('nav-sales-heading', 'sales_heading_container')

    toggleFirstLevelHeading('nav-logistics-heading', 'logistics_heading_container')

    toggleFirstLevelHeading('nav-inventory-heading', 'inventory_heading_container')

    toggleFirstLevelHeading('nav-reports-heading', 'reports_heading_container')

    toggleFirstLevelHeading('nav-admin-heading', 'admin_heading_container')

    toggleFirstLevelHeading('nav-docs-heading', 'docs_heading_container')

    toggleFirstLevelHeading('nav-favourites-heading', 'favourites_heading_container')


};

export default newdashboardload