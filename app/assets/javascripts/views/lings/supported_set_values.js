(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Lings = this.Terraling.Lings || {};

  var lings = this.Terraling.Lings;

  lings.supported_set_values = {
    init: setupComplexPage
  };

  function setupComplexPage(){

    var tplPath = 'waiting';

    var img = HoganTemplates[tplPath].render({big: true, color: '#E53900'});

    $('#prop-descrip p a').attr('target', '_blank');

    var exampleOverlay = $('#example-modal .save-overlay');

    var newURL = function(id) {
        var url = location.href;
        if (/prop_id=/.test(location.href)) {
            url = url.replace(/id=[0-9]+/, "id=" + id);
            url = url.replace(/commit=[^\&]+/, "commit=" + "Select");
            return url;
        } else {
          var divider = /\?.+/.test(location.href) ? '&' : /\?$/.test(location.href) ? '' : '?';
          return location.href + divider + "prop_id=" + id + "&commit=Select";
        }
    };

    var reload = function(url) {
        $("#property-container, #values-container").html(img);

        $("#property-tab").addClass("hidden");
        var data = $.get(url, function(resp) {

            if(Modernizr.history){
              window.history.pushState(null, document.title, url);
            }

            $("#property-container").html($("#property-container", resp).html());
            $("#values-container").html($("#values-container", resp).html());
            $("#prop-select").find(':selected').prop("selected", false);
            var currentPropId = getData().prop_id;
            var newOption = $("#prop-select option[value=" + currentPropId + "]");
            newOption.prop("selected", true);

            onValueChange();
        });

    };

    $(document)
    // Category
      .on("change", "#prop-select", function(e) {
        e.preventDefault();
        if ($("#prop-select :selected").length > 0) {
          reload(newURL(e.target.value));
        }
      })
    // Properties
      .on("click", "#property-selector .btn", function(e) {
        e.preventDefault();
        var val = $.trim(e.target.text);
        var url;
        if (/commit/.test(location.href)) {
            url = location.href.replace(/commit=[^&]+/, "commit=" + val);
        } else {
            var prop_id = $('#prop-select').val()[0];
            if (/\?.+/.test(location.href)) {
                url = location.href + "&prop_id=" + prop_id + "&commit=" + val;
            } else if (/\?$/.test(location.href)) {
                url = location.href + "prop_id=" + prop_id + "&commit=" + val;
            } else {
                url = location.href + "?prop_id=" + prop_id + "&commit=" + val;
            }
        }
        reload(url);
      })
      .on('change', "#values input[name='value']", onValueChange)
      // Example selection
      .on("click", "#example-select-btn", function(e) {
        e.preventDefault();
        var form = $("#prop-example-selector form");

        $("#prop-active-example").html(img);

        $.get(form.attr("action"), form.serialize())
          .done(function(data){
            $("#prop-active-example").html($("#prop-active-example", data).html());
            $("#example-change").toggleClass("disabled enabled");
          })
          .fail(function() {
            $("#prop-active-example").text("No examples available");
        });
      })
      // Save
      .on("click", "[id^=sureness_]:not(:disabled)", function (e) {
        e.preventDefault();
        var form = $("#value-form");

        $.post(form.attr("action"), form.serialize(), onSavedValue, 'json');

        function saveFeedback(success){
          $('#value-saved-'+ (success ? 'success' : 'error')).parent().removeClass('hide');
        }

        function onSavedValue(data) {

          saveFeedback(data.success);

          if (data.success) {
            $("#prop-name").data("lp_id", data.id);

            var colSelector = $("#prop-" + getData().prop_id);

            if (colSelector.length > 0) {
              var needsReview = $("#sureness_revisit, #sureness_need_help").hasClass("active");
              
              colSelector.css("color", needsReview ? "orange" : "green");
              
            }

            toggleExampleWarning(false);

          } else {

          }

        }

      })
      // Example Modals
      .on("click", "#example-create.enabled, #example-change.enabled", function(e) {
        e.preventDefault();
        var isChange = /change/.test(e.target.id);
        openExampleModal(isChange);
      })

      // Properties
      .on("click", "#property-modal", function(e) {
        e.preventDefault();

        openPropertyModal();
      })
      
      .on("click", "#minimize-property, #minimize-example", function(e) {
        var prefix = /example/.test(e.target.id) ? 'example' : 'property';
        minimize(prefix);
      })

      .on("click", "#property-tab, #example-tab", function(e) {
        var prefix = /example/.test(e.target.id) ? 'example' : 'property';
        toggleTab('#'+prefix+'-modal');
      })

      .on("click", "#example-create.disabled #example-change.disabled", disableAction);

    $("#example-modal")
    // on modal closed
      .on('hidden.bs.modal', closeOverlay(exampleOverlay))
    // on modal open
      .on("click", ".btn", function(e) {
        e.preventDefault();
        var form = $("#example-modal form");

        displayOverlay(exampleOverlay);

        $.post(form.attr("action"), form.serialize(), onSavedExample, 'json');

        function onSavedExample(data) {
          exampleOverlay.css("background-color", "");
          if (data.success) {
              exampleOverlay.addClass("alert-success").text("Save Successful");
              $("#prop-example").html(img);
              // TODO rewrite this to avoid to reload the whole page for a fragment...
              $("#prop-example").load(location.href + " #prop-example");
          } else {
              exampleOverlay.addClass("alert-danger").text("Save Unsuccessful");
          }
          // remember to destroy the Examples JS stuff
          T.Examples.edit.destroy();
          $("#example-modal").modal("hide");
        }
      });

    function getData() {
      var data = $("#prop-name");
      return {
          ling_id: data.data("ling-id"),
          prop_id: data.data("prop-id"),
          lp_id: data.data("lp-id")
      };
    }

    function onValueChange(){
      toggleSureness();
      toggleExampleWarning();
    }

    function disableAction(e){
      e.preventDefault();
    }

    function toggleTab(id){
      $(this).addClass("hidden");
      $(id).modal("toggle");
      $("body").css("overflow", "hidden");
    }

    function minimize(prefix){
      $("#"+prefix+"-tab").removeClass("hidden");
      $("#"+prefix+"-modal").modal("toggle");
    }

    function openExampleModal(isChange){
      // common stuff
      var data = $.param(getData());

      $("#example-tab").addClass("hidden");
      $("#example-modal .modal-body").html(img);

      // variable stuff
      // Start with create default
      var ex_id,
          url = "/groups/" + T.currentGroup + "/examples/new",
          titlePrefix = 'Create';

      if( isChange ){
        titlePrefix = 'Change';
        ex_id = $('#example-select').find(":selected").val();
        url = "/groups/" + T.currentGroup + "/examples/" + ex_id + "/edit";
      }

      $('#example-modal-title').html("<h3> "+titlePrefix+" Example</h3>");
      $("#example-modal").modal('toggle');
      $('#example-modal .modal-body').load(url+" form", data, T.Examples.edit.init);
    }

    function openPropertyModal(){
      $("#property-tab").addClass("hidden");
      $("#property-modal .modal-body").html($('#prop-descrip').html());
      $("#property-modal-title").html("<h3> Property Description</h3>");
      $("#property-modal").modal("toggle");
    }

    function closeOverlay(overlay){
      overlay = overlay || this;
      return function(){
        overlay.removeAttr("style");
        overlay.removeClass("alert-success alert-danger");
        overlay.text("");
      };
    }

    function displayOverlay(overlay){
      overlay.css("display", "block").css("background-color", "white").html(img);
    }

    function isValueSet(){
      var newRadio = $("#value_value_new:checked").length;
      var newInput = newRadio && $("input[name='new_value']").val().length;
      var radioValues = $("#values input[name='value']:checked").length - newRadio;
      return !!(newInput || radioValues);
    }

    function toggleSureness(){
      // check the state of the value
      var isChecked = isValueSet();
      // toggle the disabled state of sureness
      $('[id^=sureness_]').toggleClass("disabled", !isChecked);
      $('#value-sureness-box')
        .toggleClass('ready alert-success', isChecked)
        .toggleClass('alert-info', !isChecked);
    }

    function toggleExampleWarning(){
      var isChecked = isValueSet();
      $("#example-warning").toggleClass("hidden", isChecked);
      $("#example-create").toggleClass("disabled", !isChecked);
      $("#example-create").toggleClass("enabled", isChecked);
    }

  }

})();
