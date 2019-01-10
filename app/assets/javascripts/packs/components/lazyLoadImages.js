const lazyLoadImages = () => {
    $(".lazy-load").lazy({
        effect: "fadeIn",
        effectTime: 1000,
        threshold: 500
    });
};

export default lazyLoadImages