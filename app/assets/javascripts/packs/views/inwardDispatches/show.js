const show = () => {
    let url = location.href.replace(/\/$/, "");
    const splittedUrl = url.split("#");
    $('.nav-tabs a[href="#'+splittedUrl[1]+'"]').tab("show")

}

export default  show
