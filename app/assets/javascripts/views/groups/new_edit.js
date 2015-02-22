(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};
  this.Terraling.Groups = this.Terraling.Groups || {};

  var groups = this.Terraling.Groups;

  groups.edit = groups['new'] = {
    init: initPage
  };

  function initPage(){
    var examples = $('#group_example_fields').val().split(", ");

    function makeElement (text) {
      return HoganTemplates[T.controller.toLowerCase() + '/input'].render({text: text});
    }

    var orderEl = $('#order');
    
    if (examples) {
      $.each(examples, function(i, val) {
        orderEl.append(makeElement(val));
      });
    }
    else {
      orderEl.append(makeElement('text'));
    }

    function getInputValues(){
      return $(this).val();
    }

    orderEl
      .sortable({handle:'.handle', cancel: ''})
      .disableSelection()
      .on('DOMSubtreeModified change', function (event,ui){
        var values = $('#order div input').map(getInputValues).get().join(', ');
        $('#group_example_fields').val( values || 'text');
    });
    
    $('body')
      .on('click', '.delete-button',function (e) {
        e.preventDefault();

        if(confirm('Are you sure you want delete the element?')) {
          $(this).parent().parent().remove();
        }

      })
      .on('click', '#append-button', function (e) {
        var text = $('#append').val();
        if(text) {
          $('#order').append(makeElement(text));
          $('#append').val('');
        }
      });

    $("#append").keydown(function(event){
        if(event.keyCode == 13) {
          event.preventDefault();
          $('#append-button').trigger('click');
      }
    });

  }

})();