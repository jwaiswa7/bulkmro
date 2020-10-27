
const punchoutCart = () => {

  // window.onload = function(){
  //   let url = document.getElementById('url').value
  //   $.ajax({
  //     url: url,
  //     type: 'post',
  //     data: $('#cxml_form').serialize(),
  //     success: function(response){
  //         console.log(response)
  //         console.log("request sent")
  //     }
  //   });
  // }

  $('form.cxml').submit(function() {
    createPunchoutOrder();
  });
};

let createPunchoutOrder = () => {
  $.ajax({
    url: Routes.generate_punchout_order_customers_customer_orders_path(),
    type: 'get',
    success: function (data) {
      console.log("Order Created Successfully")
    }
  });
}

export default punchoutCart
