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

    // Manejar el envío del formulario
    $("#subject-form").on("submit", function(e) {
        e.preventDefault();
        var $form = $(this);

        var formData = $form.serialize();

        // Mostrar spinner compatible (Bootstrap o fallback CSS)
        var spinnerHtml = '';
        if ($('.spinner-border').length === 0) {
            spinnerHtml = '<div id="spinner-cloud" style="display:flex;justify-content:center;align-items:center;height:200px;"><div class="spinner-fallback"></div></div>';
        } else {
            spinnerHtml = '<div id="spinner-cloud" style="display:flex;justify-content:center;align-items:center;height:200px;"><div class="spinner-border text-primary" role="status" style="width: 4rem; height: 4rem;"><span class="sr-only">Cargando...</span></div></div>';
        }
        $("#cloud-container").html(spinnerHtml);
        setTimeout(function() {
            $.get($form.attr("action"), formData, function(data) {
                $("#cloud-container").empty();
                if (data.length > 0) {
                    // Obtener los parámetros actuales de la URL (sin el hash)
                    var currentUrlParams = window.location.search.substring(1);
                    data = data.map(term => {
                        let fieldParam = term.field ? term.field.replace('_tesim', '_sim') : 'subject_sim';
                        let url = `/catalog?f%5B${encodeURIComponent(fieldParam)}%5D%5B%5D=${encodeURIComponent(term.text)}`;
                        if (currentUrlParams) {
                            url += `&${currentUrlParams}`;
                        }
                        url += '&locale=en&q=&search_field=all_fields';
                        // 25% de los casos: palabra de abajo hacia arriba (vertical, legible)
                        let orientation = Math.random() < 0.25 ? 3 : 0;
                        if (orientation === 3) {
                            return {
                                text: `<a href='${url}' target='_blank' style='writing-mode: vertical-rl; transform: rotate(180deg); display:inline-block;'>${term.text}</a>`,
                                weight: term.weight,
                                orientation: orientation
                            };
                        } else {
                            return {
                                text: `<a href='${url}' target='_blank'>${term.text}</a>`,
                                weight: term.weight,
                                orientation: orientation
                            };
                        }
                    });

                    $("#cloud-container").jQCloud(data, {
                        width: $("#cloud-container").width(),
                        height: 500,
                        colors: ["#fed976", "#feb24c", "#fd8d3c", "#fc4e2a", "#e31a1c", "#bd0026", "#800026"],
                        fontSize: function(binSize) {
                            return binSize * 4 + 6;  // Ajustamos el tamaño de la fuente según el peso
                        },
                        delay: 50,
                        // Permitir orientación vertical de abajo hacia arriba
                        autoResize: true
                    });
                } else {
                    $("#cloud-container").html('<div class="alert alert-info">No se encontraron términos para los filtros seleccionados.</div>');
                }
            }).fail(function() {
                // En caso de error, también reactivamos el botón
                $("#cloud-container").html('<div class="alert alert-danger">Ocurrió un error al cargar los términos.</div>');
            });
        }, 1000);
    });

    // Auto-submit al cambiar cualquier checkbox
    $("#subject-form input[type='checkbox']").on("change", function() {
        // Solo enviar si hay al menos un checkbox activo
        if ($("#subject-form input[type='checkbox']:checked").length > 0) {
            $("#subject-form").submit();
        }
    });

    // Auto-submit al cambiar el slider de años
    $("#slider-1, #slider-2").on("change mouseup touchend", function() {
        // Solo enviar si hay al menos un checkbox activo
        if ($("#subject-form input[type='checkbox']:checked").length > 0) {
            $("#subject-form").submit();
        }
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
