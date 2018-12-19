import statusChange from './../../components/statusChange'

const pending = () => {
    console.log("pending index")
    statusChange(".status_class",'#dropdown_status_column')
};

export default pending