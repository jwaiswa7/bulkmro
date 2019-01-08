const lazyLoadImages = () => {
    $(".lazy").lazy({
        effect: "fadeIn",
        effectTime: 2000,
        threshold: 0
    });
}

export default lazyLoadImages