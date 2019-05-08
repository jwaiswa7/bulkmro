import onStatusChange from './bindStatusChange'
import cancelStatusConfirmation from './canceStatusConfirmation'

const newAction = () => {
    onStatusChange()
    cancelStatusConfirmation()
};


export default newAction