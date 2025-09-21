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

        if (currentCloudRequest && typeof currentCloudRequest.abort === 'function') {
            currentCloudRequest.abort();
        }

        cloudVersion++;
        const thisVersion = cloudVersion;

        clearCloud(); // ✅ limpiar DOM y destruir jQCloud anterior

        $("#cloud-container").html('<div id="spinner-cloud" style="display:flex;justify-content:center;align-items:center;height:200px;"><div class="spinner-fallback"></div></div>');

        // Adjuntar exclusión a los datos del formulario
    let exclusionList = (window.subjectCloudExclusionList || []).map(t => t.trim());
    let exclusionParam = exclusionList.map(encodeURIComponent).join("|||");
    let formDataWithExclusion = formData + (exclusionParam ? `&exclusion_terms=${exclusionParam}` : "");

        currentCloudRequest = $.ajax({
            url: $form.attr("action"),
            data: formDataWithExclusion,
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

                // Lista de exclusión local
                let exclusionList = window.subjectCloudExclusionList || [];
                // Renderizar la lista de exclusión
                if (typeof renderExclusionList === 'function') renderExclusionList();

                data = data.map(term => {
                    let group = 1;
                    if (maxW > minW) {
                        group = Math.round(1 + (steps - 1) * (term.weight - minW) / (maxW - minW));
                    }

                    let fieldParam = term.field ? term.field.replace('_tesim', '_sim') : 'subject_sim';
                    let url = `/catalog?f%5B${encodeURIComponent(fieldParam)}%5D%5B%5D=${encodeURIComponent(term.text)}`;
                    let currentUrlParams = window.location.search.substring(1);
                    if (currentUrlParams) url += `&${currentUrlParams}`;
                    //url += '&f[human_readable_type_sim][]=Thesis';
                    url += '&locale=en&q=&search_field=all_fields';

                    let orientation = 0; // Solo horizontal
                    let baseText = term.text;
                    let hoverText = `&nbsp;${term.text}&nbsp;`;


                    // Botón de tache (✖) más pequeño y siempre visible
                    let closeBtn = `<span style='pointer-events:none;'><span class='cloud-exclude-btn' data-term='${encodeURIComponent(baseText)}' title='Excluir término' style='pointer-events:auto;color:#b00;font-size:0.6em;cursor:pointer;margin-left:4px;line-height:1;'>✖</span></span>`;

                    let linkHtml = orientation === 3
                        ? `<span class='cloud-term-container' style='display:inline-block;position:relative;'><a href='${url}' target='_blank' style='writing-mode: vertical-rl; transform: rotate(180deg); display:inline-block;position:relative;' class='cloud-term' data-base='${baseText}' data-hover='${hoverText}'>${baseText}</a><span class='cloud-exclude-btn' data-term='${encodeURIComponent(baseText)}' title='Excluir término' style='color:#b00;font-size:0.6em;cursor:pointer;margin-left:4px;line-height:1;'>✖</span></span>`
                        : `<span class='cloud-term-container' style='display:inline-block;position:relative;'><a href='${url}' target='_blank' style='position:relative;' class='cloud-term' data-base='${baseText}' data-hover='${hoverText}'>${baseText}</a><span class='cloud-exclude-btn' data-term='${encodeURIComponent(baseText)}' title='Excluir término' style='color:#b00;font-size:0.6em;cursor:pointer;margin-left:4px;line-height:1;'>✖</span></span>`;

                    return { text: linkHtml, weight: group, orientation };
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
                        // Hover solo en el contenedor: nunca se pierde mientras el mouse esté sobre el contenedor o cualquier hijo
                        // Hover solo en el contenedor, nunca en el anchor
                        $(document).off('mouseenter mouseleave', '.cloud-term-container, .cloud-term');
                        $(document).on('mouseenter', '.cloud-term-container', function() {
                            let $container = $(this);
                            let $anchor = $container.find('.cloud-term');
                            let hoverText = $anchor.data('hover');
                            $anchor.contents().filter(function(){ return this.nodeType === 3; }).first().replaceWith(hoverText);
                            $anchor.addClass('cloud-term-hover');
                        });
                        $(document).on('mouseleave', '.cloud-term-container', function() {
                            let $container = $(this);
                            let $anchor = $container.find('.cloud-term');
                            let baseText = $anchor.data('base');
                            $anchor.contents().filter(function(){ return this.nodeType === 3; }).first().replaceWith(baseText);
                            $anchor.removeClass('cloud-term-hover');
                        });

                        // Evento para el botón de tache
                        $(document).off('click', '.cloud-exclude-btn');
                        $(document).on('click', '.cloud-exclude-btn', function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            let term = decodeURIComponent($(this).data('term')).trim();
                            window.subjectCloudExclusionList = (window.subjectCloudExclusionList || []).map(t => t.trim());
                            if (!window.subjectCloudExclusionList.includes(term)) {
                                window.subjectCloudExclusionList.push(term);
                            }
                            if (typeof renderExclusionList === 'function') renderExclusionList();
                            $("#subject-form").submit();
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
        }else{
            clearCloud();
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
