var Notifications;

Notifications = class Notifications {
    constructor() {
        this.handleClick = this.handleClick.bind(this);
        this.handleSuccess = this.handleSuccess.bind(this);
        this.notifications = $("[data-behavior='notifications']");
        if (this.notifications.length > 0) {
            this.handleSuccess(this.notifications.data("notifications"));
            $("[data-behavior='notifications-link']").on("click", this.handleClick);
        }
        this.getNewNotifications();
    }

    getNewNotifications() {
        return $.ajax({
            url: "/overseers/notifications/queue.json",
            dataType: "JSON",
            method: "GET",
            success: this.handleSuccess
        });
    }

    handleClick(e) {
        var page_title = $(document).attr('title');
        return $.ajax({
            url: "/overseers/notifications/mark_as_read",
            dataType: "JSON",
            method: "POST",
            success: function () {
                $(document).attr('title', this.remove_count(page_title));
                return $("[data-behavior='unread-count']").text(0).removeClass('badge-danger');
            }
        });
    }

    handleSuccess(data) {
        var items, unread_count, page_title;
        items = $.map(data, function (notification) {
            return notification.template;
        });
        unread_count = 0;
        page_title = this.remove_count($(document).attr('title'));
        $.each(data, function (i, notification) {
            if (notification.unread) {
                return unread_count += 1;
            }
        });
        if (unread_count > 0) {
            $(document).attr('title', '('+unread_count+') ' + page_title);
            $("[data-behavior='unread-count']").text(unread_count).addClass('badge-danger');
        }
        if (items == 0) {
            items = '<div class="dropdown-item text-center text-secondary">No records found</div>'
        }
        return $("[data-behavior='notification-items']").html(items);
    }

    remove_count(title){
        return title.replace(/^\([\s\d]*?\) /g, '');
    }

};

jQuery(function () {
    return new Notifications;
});
