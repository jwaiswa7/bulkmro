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
        return $.ajax({
            url: "/overseers/notifications/mark_as_read",
            dataType: "JSON",
            method: "POST",
            success: function () {
                return $("[data-behavior='unread-count']").text(0);
            }
        });
    }

    handleSuccess(data) {
        var items, unread_count;
        items = $.map(data, function (notification) {
            return notification.template;
        });
        unread_count = 0;
        $.each(data, function (i, notification) {
            if (notification.unread) {
                return unread_count += 1;
            }
        });
        $("[data-behavior='unread-count']").text(unread_count);
        return $("[data-behavior='notification-items']").html(items);
    }

};

jQuery(function () {
    return new Notifications;
});
