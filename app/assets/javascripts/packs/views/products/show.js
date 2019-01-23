const show = () => {
    if(window.location.href.indexOf('#inventory') != -1) {
        $('#inventoryModal').modal('show');
    }
};

export default show