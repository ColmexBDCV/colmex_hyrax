// Custom behavior for based_near controlled vocabulary
// When there is only one visible field, the remove button clears the fields
// instead of hiding/removing the element. When there are multiple fields,
// the default behavior is preserved.

$(document).on('click', '.controlled_vocabulary .remove', function(e) {
  var $btn = $(this);
  var $field = $btn.closest('.field-wrapper');
  var $manager = $btn.closest('.controlled_vocabulary');
  if ($manager.length === 0) { return; }

  // Determine field name set via data-attribute (data-field-name)
  var fieldName = $manager.data('fieldName') || $manager.data('field-name');

  // Only change behavior for based_near
  if (fieldName !== 'based_near') { return; }

  var visibleCount = $manager.find('.field-wrapper:visible').length;

  if (visibleCount <= 1) {
    // Prevent the default/hyrax handler from running
    e.preventDefault();
    e.stopImmediatePropagation();

    // Clear visible inputs inside this field and reset destroy flag
    var $text = $field.find('input.multi-text-field');
    var $hiddenId = $field.find('input[type=hidden][data-id="remote"]');
    var $destroy = $field.find('input[data-destroy]');

    if ($text.length) {
      $text.val('');
      $text.prop('readonly', false);
      $text.trigger('change');
    }
    if ($hiddenId.length) { $hiddenId.val(''); }
    if ($destroy.length) { $destroy.val(''); }

    // Ensure field is visible (in case it was hidden previously)
    $field.show();

    // Re-attach autocomplete if necessary
    try {
      if (window.Hyrax && Hyrax.editor && Hyrax.editor.Autocomplete) {
        new Hyrax.editor.Autocomplete().setup($text, fieldName, $manager.data('autocompleteUrl'));
      } else if (window.Hyrax && Hyrax.autocomplete) {
        // fallback if older global exists
        Hyrax.autocomplete.setup($text, fieldName, $manager.data('autocompleteUrl'));
      }
    } catch (err) {
      // noop: if autocomplete re-init fails it's non-fatal
    }

    return false;
  }
  // else: allow default Hyrax removeFromList behavior to run
});

// On page load, ensure the remove button is visible for single-value based_near fields
$(document).on('turbolinks:load ready', function() {
  $('.controlled_vocabulary').each(function() {
    var $manager = $(this);
    var fieldName = $manager.data('fieldName') || $manager.data('field-name');
    if (fieldName === 'based_near') {
      var total = $manager.find('.field-wrapper').length;
      if (total <= 1) {
        $manager.find('.remove').show();
      }
    }
  });
});

// When the editor adds/manages fields later, ensure the remove button is visible
$(document).on('managed_field:add managed_field:init', function(event, element) {
  // element may be the new field or input; find closest manager
  var $elem = $(element);
  var $manager = $elem.closest('.controlled_vocabulary');
  if (!$manager.length) { return; }
  var fieldName = $manager.data('fieldName') || $manager.data('field-name');
  if (fieldName === 'based_near') {
    $manager.find('.remove').show();
  }
});
