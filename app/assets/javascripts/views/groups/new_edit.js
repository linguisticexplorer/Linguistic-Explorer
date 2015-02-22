(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};
  this.Terraling.Groups = this.Terraling.Groups || {};

  var groups = this.Terraling.Groups;

  groups.edit = groups['new'] = {
    init: initPage
  };

  function initPage(){

    function makeElement (text) {
      return HoganTemplates[T.controller.toLowerCase() + '/input'].render({text: text});
    }

    function getInputValues(){
      return $(this).val();
    }
    
    var examples = $('#group_example_fields').val();
    var orderEl = $('#order');
    
    if (examples) {
      examples = examples.split(", ");
      $.each(examples, function(i, val) {
        orderEl.append(makeElement(val));
      });
    } else {
      orderEl.append(makeElement('text'));
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

        var me = this;

        bootbox.confirm('Are you sure you want delete the element?', function (willDelete){
          if(willDelete){
            $(me).parent().parent().remove();
          }
        });

      })
      .on('click', '#append-button', function (e) {
        var text = $('#append').val();
        if(text) {
          $('#order').append(makeElement(text));
          $('#append').val('');
        }
      })
      .on('keydown', '#append', function (e){
        if(e.keyCode == 13) {
          e.preventDefault();
          $('#append-button').trigger('click');
      }
      })
      .on('click', '[id^="depth_"]', function(){
        // Previous state here
        var hasDepth = !$('#depth_1.active').length;

        $('#group_ling1_name').prop('disabled', !hasDepth).toggleClass('disabled', !hasDepth);
      });

  }

})();