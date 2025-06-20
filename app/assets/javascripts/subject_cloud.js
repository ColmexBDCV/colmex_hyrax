// Función para inicializar la nube de palabras
function initWordCloud() {
    // Obtener los valores min/max de los campos de año
    var minYear = parseInt($("#start_year").attr('min'));
    var maxYear = parseInt($("#end_year").attr('max'));
    var initialStartYear = parseInt($("#start_year").val());
    var initialEndYear = parseInt($("#end_year").val());

    // Configurar el slider de años
    var $slider = $("#year-slider").slider({
        range: true,
        min: minYear,
        max: maxYear,
        values: [initialStartYear, initialEndYear],
        slide: function(event, ui) {
            $("#start_year").val(ui.values[0]);
            $("#end_year").val(ui.values[1]);
        }
    });

    var currentCloudRequest = null;

    // Manejar el envío del formulario
    $("#subject-form").on("submit", function(e) {
        e.preventDefault();
        var $form = $(this);
        var formData = $form.serialize();
        var $submitBtn = $("#search-terms");
        var $clearBtn = $("#clear-cloud");
        // Deshabilitar el botón y agregar spinner (estructura personalizada)
        $submitBtn.prop('disabled', true);
        $clearBtn.prop('disabled', true);
        var originalBtnHtml = $submitBtn.html();
        $submitBtn.data('original-html', originalBtnHtml);
        var spinnerStyle = 'display:inline-block;vertical-align:middle;margin-right:8px;width:1.5em;height:1.5em;min-width:1.5em;min-height:1.5em;';
        var spinnerHtml = '';
        if ($('.spinner-border').length === 0) {
            spinnerHtml = '<span class="spinner-fallback" style="' + spinnerStyle + '"></span>';
        } else {
            spinnerHtml = '<span class="spinner-border text-light" role="status" style="' + spinnerStyle + 'opacity:0.7;"></span>';
        }
        $submitBtn.css({ 'min-width': $submitBtn.outerWidth() });
        $submitBtn.html(spinnerHtml + 'Buscando...');
        // Cancelar petición AJAX anterior si existe
        if (currentCloudRequest && currentCloudRequest.readyState !== 4) {
            currentCloudRequest.abort();
        }
        currentCloudRequest = $.get($form.attr("action"), formData, function(data) {
            // No limpiar el contenedor aún, dejar el spinner mientras aparecen las palabras
            if (data.length > 0) {
                $("#cloud-container").empty();
                // Normalizar los pesos en 10 grupos (1 a 10)
                let weights = data.map(t => t.weight);
                let minW = Math.min(...weights);
                let maxW = Math.max(...weights);
                let steps = 10;
                data = data.map((term) => {
                    // Normaliza el peso a un grupo entre 1 y 10
                    let group = 1;
                    if (maxW > minW) {
                        group = Math.round(1 + (steps - 1) * (term.weight - minW) / (maxW - minW));
                    }
                    let fieldParam = term.field ? term.field.replace('_tesim', '_sim') : 'subject_sim';
                    let url = `/catalog?f%5B${encodeURIComponent(fieldParam)}%5D%5B%5D=${encodeURIComponent(term.text)}`;
                    var currentUrlParams = window.location.search.substring(1);
                    if (currentUrlParams) {
                        url += `&${currentUrlParams}`;
                    }
                    url += '&locale=en&q=&search_field=all_fields';
                    let orientation = Math.random() < 0.25 ? 3 : 0;
                    // Guardar el texto base y el texto con peso
                    let baseText = term.text;
                    let hoverText = `&nbsp;${term.text}&nbsp;`;
                    let text = orientation === 3 ? `<a href='${url}' target='_blank' style='writing-mode: vertical-rl; transform: rotate(180deg); display:inline-block;' class='cloud-term' data-base='${baseText}' data-hover='${hoverText}'>${baseText}</a>` : `<a href='${url}' target='_blank' class='cloud-term' data-base='${baseText}' data-hover='${hoverText}'>${baseText}</a>`;
                    return {
                        text: text,
                        weight: group,
                        orientation: orientation
                    };
                });

                $("#cloud-container").jQCloud(data, {
                    width: $("#cloud-container").width(),
                    colors: ["#fed976", "#feb24c", "#fd8d3c", "#fc4e2a", "#e31a1c", "#bd0026", "#800026"],
                    fontSize: function(width, height, step) {
                        var minFont = 10;
                        var maxFont = 90;
                        var steps = 10;
                        var norm = step / (steps - 1);
                        return minFont + norm * (maxFont - minFont);
                    },
                    delay: 0,
                    autoResize: true,
                    afterCloudRender: function() {
                        $submitBtn.prop('disabled', false);
                        $submitBtn.html($submitBtn.data('original-html'));
                        $clearBtn.prop('disabled', false);
                    }
                });
                $(document).off('mouseenter mouseleave', '.cloud-term');
                $(document).on('mouseenter', '.cloud-term', function() {
                    $(this).text($(this).data('hover'));
                });
                $(document).on('mouseleave', '.cloud-term', function() {
                    $(this).text($(this).data('base'));
                });
            } else {
                $("#cloud-container").empty().html('<div class="alert alert-info">No se encontraron términos para los filtros seleccionados.</div>');
                //$("#spinner-cloud").fadeOut(300, function() { $(this).remove(); });
                $submitBtn.prop('disabled', false);
                $submitBtn.html($submitBtn.data('original-html'));
                $clearBtn.prop('disabled', false);
            }
            // Al terminar de cargar la nube, habilitar el botón y restaurar el texto
            // $submitBtn.prop('disabled', false);
            // $submitBtn.html($submitBtn.data('original-html'));
        }).fail(function() {
            // En caso de error, también reactivamos el botón
            $("#cloud-container").empty().html('<div class="alert alert-danger">Ocurrió un error al cargar los términos.</div>');
            $("#spinner-cloud").fadeOut(300, function() { $(this).remove(); });
            $submitBtn.prop('disabled', false);
            $submitBtn.html($submitBtn.data('original-html'));
            $clearBtn.prop('disabled', false);
        });
    });

    // Eliminar auto-submit al cambiar cualquier checkbox
    // $("#subject-form input[type='checkbox']").on("change", function() { ... });
    // Eliminar auto-submit al cambiar el slider de años
    // $("#slider-1, #slider-2").on("change mouseup touchend", function() { ... });
    // Nuevo: botón para limpiar la nube
    $("#clear-cloud").on("click", function() {
        $("#cloud-container").empty();
    });

    // Inicializar el estado del botón de envío
    $(document).ready(function() {
        var $submitButton = $("#subject-form input[type='submit']");
        var hasActiveCheckbox = $("#subject-form input[type='checkbox']:checked").length > 0;
        $submitButton.prop('disabled', !hasActiveCheckbox);
    });
}

// Inicializar cuando el documento esté listo
$(document).ready(function() {
    if ($("#subject-form").length) {
        initWordCloud();
    }
});
