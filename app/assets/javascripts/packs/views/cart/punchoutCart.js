
const punchoutCart = () => {

  window.onload = function(){
    let url = document.getElementById('url').value
    $.ajax({
      url: url,
      type: 'post',
      data: $('#cxml_form').serialize(),
      success: function(response){
          console.log(response)
          console.log("request sent")
      }
    });
  }
};

export default punchoutCart