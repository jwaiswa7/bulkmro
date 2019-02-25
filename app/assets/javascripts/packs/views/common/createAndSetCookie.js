
const createAndSetCookie = (path) => {
    var id = path.split('/')[3]
    var expires = new Date();
    expires.setDate(expires.getDate() + 7);
    var cookie = 'invoice'+id+expires.getTime()
    var cookiePath = path.split('/edit')[0]
    document.cookie = 'cookie='+cookie+'; expires='+expires+'; path='+cookiePath+';'

}

export default createAndSetCookie