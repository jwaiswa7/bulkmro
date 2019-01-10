const lazyLoadImages = () => {
    $(".lazy-load").lazy({
        effect: "fadeIn",
        effectTime: 1000,
        threshold: 0
    });
};

export default lazyLoadImages