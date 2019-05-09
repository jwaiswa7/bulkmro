import onStatusChange from './bindStatusChange'
import cancelStatusConfirmation from './canceStatusConfirmation'
import hideRemoveBtnInRows from "../common/hideRemoveBtnInRows"


const newAction = () => {
    onStatusChange()
    cancelStatusConfirmation()
    hideRemoveBtnInRows()
};


export default newAction