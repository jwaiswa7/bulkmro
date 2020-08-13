
const punchoutCart = () => {

  window.onload = function(){
    let url = document.getElementById('url').value
    $.ajax({
      url: 'https://webhook.site/d31d22e4-69a1-4d48-b7d9-2bf585b52e62',
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