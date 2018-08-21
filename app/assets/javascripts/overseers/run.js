$(function () {
    main.load();
});

document.addEventListener("turbolinks:load", function() {
    main.load();
});

document.addEventListener("turbolinks:before-cache", function() {
    main.beforeCache();
});