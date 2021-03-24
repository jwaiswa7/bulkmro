const index = () => {
  $('a.bmro-button').on('click', function(){
    $(this).addClass('disabled');
  });
};

export default index