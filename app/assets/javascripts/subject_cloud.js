function initWordCloud() {
    var minYear = parseInt($("#start_year").attr('min'));
    var maxYear = parseInt($("#end_year").attr('max'));
    var initialStartYear = parseInt($("#start_year").val());
    var initialEndYear = parseInt($("#end_year").val());

    $("#year-slider").slider({
        range: true,
        min: minYear,
        max: maxYear,
        values: [initialStartYear, initialEndYear],
        slide: function(event, ui) {
            $("#start_year").val(ui.values[0]);
            $("#end_year").val(ui.values[1]);
        }
    });

    let currentCloudRequest = null;
    let cloudVersion = 0;

    // 🔄 Forzar destrucción de nubes anteriores
    function clearCloud() {
        if ($("#cloud-container").data('jqcloud')) {
            $("#cloud-container").jQCloud('destroy');
        }
        $("#cloud-container").replaceWith('<div id="cloud-container"></div>');
    }

    $("#subject-form").on("submit", function(e) {
        e.preventDefault();
        const $form = $(this);
        const formData = $form.serialize();

        // Si no hay ningún checkbox activo, limpiar la nube y salir
        if ($("#subject-form input[type='checkbox']:checked").length === 0) {
            clearCloud();
            return;
        }

        if (currentCloudRequest && typeof currentCloudRequest.abort === 'function') {
            currentCloudRequest.abort();
        }

        cloudVersion++;
        const thisVersion = cloudVersion;

        clearCloud(); // ✅ limpiar DOM y destruir jQCloud anterior

        $("#cloud-container").html('<div id="spinner-cloud" style="display:flex;justify-content:center;align-items:center;height:200px;"><div class="spinner-fallback"></div></div>');

        currentCloudRequest = $.ajax({
            url: $form.attr("action"),
            data: formData,
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                if (thisVersion !== cloudVersion) return; // ❌ respuesta vieja

                if (data.length === 0) {
                    clearCloud();
                    $("#cloud-container").html('<div class="alert alert-info">No se encontraron términos para los filtros seleccionados.</div>');
                    return;
                }

                // Normalizar pesos
                let weights = data.map(t => t.weight);
                let minW = Math.min(...weights);
                let maxW = Math.max(...weights);
                let steps = 10;

                data = data.map(term => {
                    let group = 1;
                    if (maxW > minW) {
                        group = Math.round(1 + (steps - 1) * (term.weight - minW) / (maxW - minW));
                    }

                    let fieldParam = term.field ? term.field.replace('_tesim', '_sim') : 'subject_sim';
                    let url = `/catalog?f%5B${encodeURIComponent(fieldParam)}%5D%5B%5D=${encodeURIComponent(term.text)}`;
                    let currentUrlParams = window.location.search.substring(1);
                    if (currentUrlParams) url += `&${currentUrlParams}`;
                    url += '&locale=en&q=&search_field=all_fields';

                    let orientation = Math.random() < 0.25 ? 3 : 0;
                    let baseText = term.text;
                    let hoverText = `&nbsp;${term.text}&nbsp;`;
                    let text = orientation === 3
                        ? `<a href='${url}' target='_blank' style='writing-mode: vertical-rl; transform: rotate(180deg); display:inline-block;' class='cloud-term' data-base='${baseText}' data-hover='${hoverText}'>${baseText}</a>`
                        : `<a href='${url}' target='_blank' class='cloud-term' data-base='${baseText}' data-hover='${hoverText}'>${baseText}</a>`;

                    return { text, weight: group, orientation };
                });

                clearCloud(); // ✅ garantizar que solo haya una nube activa

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
                        // eventos hover
                        $(document).off('mouseenter mouseleave', '.cloud-term');
                        $(document).on('mouseenter', '.cloud-term', function() {
                            $(this).text($(this).data('hover'));
                        });
                        $(document).on('mouseleave', '.cloud-term', function() {
                            $(this).text($(this).data('base'));
                        });
                    }
                });
            },
            error: function() {
                if (thisVersion !== cloudVersion) return;
                clearCloud();
                $("#cloud-container").html('<div class="alert alert-danger">Ocurrió un error al cargar los términos.</div>');
            }
        });
    });

    // Auto-submit al cambiar cualquier checkbox
    $("#subject-form input[type='checkbox']").on("change", function() {
        if ($("#subject-form input[type='checkbox']:checked").length > 0) {
            $("#cloud-container").replaceWith('<div id="cloud-container"></div>');
            $("#subject-form").submit();
        }
    });

    // Auto-submit al mover sliders
    $("#slider-1, #slider-2").on("change mouseup touchend", function() {
        if ($("#subject-form input[type='checkbox']:checked").length > 0) {
            $("#cloud-container").replaceWith('<div id="cloud-container"></div>');
            $("#subject-form").submit();
        }
    });

    $("#clear-cloud").on("click", function() {
        clearCloud();
    });

    $(document).ready(function() {
        let $submitButton = $("#subject-form input[type='submit']");
        let hasActiveCheckbox = $("#subject-form input[type='checkbox']:checked").length > 0;
        $submitButton.prop('disabled', !hasActiveCheckbox);
    });
}

$(document).ready(function() {
    if ($("#subject-form").length) {
        initWordCloud();
    }
});
