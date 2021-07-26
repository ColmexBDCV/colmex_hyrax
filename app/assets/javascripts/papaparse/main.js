function TableView() {

    $('#csvFileInput').on('click', function() {

        $(".contenedor-tabla").remove();    

        const csvFileInput = document.querySelector("#csvFileInput");
        const select_work = document.querySelector('#validations_type_work');
        const targetDiv = document.querySelector('.contenido');
        const targetDivContenedor = document.querySelector('.header.contenedor');
        const path = document.querySelector('.path_file').value;
        //camposHyrax: Atributos o propiedades que estan declarados en el proyecto Hyrax para crear los trabajos
        /*const camposHyrax = ['title', 'alternate_title', 'other_title', 'date_created', 'description', 'creator', 
            'contributor', 'subject', 'subject_person', 'subject_family', 'subject_work', 'subject_corporate',
            'publisher', 'language', 'reviewer', 'identifier', 'resource_type', 'keyword', 'based_near',
            'license', 'geographic_coverage', 'temporary_coverage',
            'gender_or_form', 'notes', 'classification', 'supplementary_content_or_bibliography', 'bibliographic_citation',
            'responsibility_statement', 'other_related_persons', 'system_requirements', 'item_access_restrictions',
            'table_of_contents', 'doi', 'isbn', 'edition', 'dimensions', 'extension', 'item_use_restrictions', 'encoding_format_details',
            'type_of_content, editor', 'compiler', 'commentator', 'translator', 'digital_resource_generation_information',
            'interviewer', 'interviewee', 'organizer_collective_agent', 'photographer', 'collective_title', 'part_of_place', 
            'provenance', 'curator_collective_agent_of', 'project', 'owner_agent_of', 'custodian_agent_of', 'file_type_details',
            'type_of_illustrations', 'center', 'mode_of_issuance', 'source', 'rights_statement', 
            'related_url', 'representative_id', 'thumbnail_id', 'rendering_ids', 'files',
            'visibility_during_embargo', 'embargo_release_date', 'visibility_after_embargo',
            'visibility_during_lease', 'lease_expiration_date', 'visibility_after_lease',
            'visibility', 'ordered_member_ids', 'in_works_ids',
            'member_of_collection_ids', 'admin_set_id'];*/
        //campostoValidate: contiene campos que tienen sus propias validaciones en el código
        const campostoValidate = ['title','date_created','identifier','file_name'];
        const  camposObligatorios =['title','identifier'];
        let type_work = '';
        let campostoValidateNotExist = [];
        let camposHeaderNull = [];
        //let camposHyraxNotFound = [];  Guarda el nombre de los campos del header que no están declarados en el proyecto Colmex_Hyax
        let resgistrosTitleNull = [];
        let registrosIdentifierNull = [];
        let registrosDateCreatedNoInteger = [];
        let registrosDateCreatedNull = [];
        let registrosDateCreatedString = [];
        let registrosFileNameErroneos = [];
        let ValorTextArea = [];
        let camposExist = [];
        let camposNotExist = [];
        
        /*const TableCsv = {
            root: HTMLTableElement,
            constructor: root => this.root = root,
            setHeader: headerColumns => this.root.insertAdjacentHTML("afterbegin",`
                <thead>
                    ${ headerColumns.map(text => `<th> ${text}</th>`).join("") }
                </thead>
            `),
            setBody: (data,headerColumns) => {
                const rowsHtml = data.map(row => {
                    return `
                    <tr class="correct">
                        ${ row.map((text,index) => `<td class="${headerColumns[index%headerColumns.length]}" > ${text} </td>`).join("") }
                    </tr>
                    `
                });
                this.root.insertAdjacentHTML("beforeend",`
                    <tbody>
                        ${rowsHtml.join("")}
                    </tbody>
                `);
            }
        }*/

        function creadTH(text) {
            const th = document.createElement('th');
            th.textContent = text
            return th;
        }
        function creaTR() {
            const tr = document.createElement('tr');
            tr.classList.add('correct');
            return tr;
        }
        function creaTD(headerColumns,index,text) {
            const td = document.createElement('td')
            td.classList.add(headerColumns[index%headerColumns.length] === '' ? 'vacio' : headerColumns[index%headerColumns.length]);
            td.textContent = text
            return td;
        }

        const TableCsv = {
            root: HTMLTableElement,
            constructor: (root) => this.root = root,
            setheader: (headerColumns) => {setHeader(headerColumns,this.root)},
            setbody: (data,headerColumns) => {setBody(headerColumns,data,this.root)}
        }

        function setHeader(headerColumns,root) {
            const header = document.createElement('thead');
            headerColumns.forEach( head => {
                header.appendChild(creadTH(head))
            })
            root.appendChild(header);
        }

        function setBody(headerColumns,data,root) {
            const body = document.createElement('tbody');
            data.forEach( row => {
                const tr = creaTR();
                row.forEach((text,index) => {
                    tr.appendChild(creaTD(headerColumns,index,text));
                })
                body.appendChild(tr);
            })
            root.appendChild(body);
        }

        cargaListeners();

        function cargaListeners() {
            

            targetDivContenedor.addEventListener('click', e => {
                if (e.target.classList.contains('form-control-file')) {
                    e.stopImmediatePropagation();
                    iniciaApp();
                }
                if (e.target.classList.contains('validador')) {
                    e.stopImmediatePropagation();
                    deshabilitaBtnValidador(e.target);
                    validadorBtn();
                }

            });
            csvFileInput.addEventListener('change', e => {
                e.stopImmediatePropagation();
                if (csvFileInput.files[0] !== undefined) {
                    creaTablaDelCsv();
                    quitarSpinnerVisualizarTabla();
                }
            })
            select_work.addEventListener('change', e => {
                const f = new Date();
                const dia = f.getDate();
                const mes = (f.getMonth() + 1);
                const anio = f.getFullYear();
                const hora = f.getHours();
                const min = f.getMinutes();
                const seg = f.getSeconds();
                type_work = e.target.value;
                rellenarTextField(document.querySelector('.new_name'), `Importacion_${dia}${mes}${anio}_${hora}${min}${seg}_` + type_work +'.csv');
                document.querySelector('.path_file').value = path + `/Importacion_${dia}${mes}${anio}_${hora}${min}${seg}_` + type_work +'.csv';
                mostrarContenedorOculto('importar');
            })
        }
        let validar = '';
        if (Locale === 'es') {
            validar = 'Validar archivo';
        }else{
            validar = 'Validate'
        }
        function quitarSpinnerVisualizarTabla() {
            //setTimeout se ejecuta después de 3 segundos cada 1000 es un segundo.
            setTimeout(() =>{
                document.querySelector('.spinner').remove();
                document.querySelector('.table-sm').classList.remove('visibility-hide');
                targetDivContenedor.appendChild(creaBoton('validador',validar));
            },2000);
        }
        /**
         * @param {HTMLElement} target 
         * 
         * Agrega al elemento HTMLElement la clase de cursor-not-allowed y opacity-50, para que el usuario no pueda darle click
         */
        function deshabilitaBtnValidador(target) {
            agregaClasesElmentosHTML(['cursor-not-allowed','opacity-50'],target);
        }

        function iniciaApp() {
            limpiaValoresArreglos(ValorTextArea);
            limpiaValoresArreglos(campostoValidateNotExist);
            limpiaValoresArreglos(camposHeaderNull);
            //limpiaValoresArreglos(camposHyraxNotFound); Agregar si se añade la funcionalidad de comparar campos hyrax
            limpiaValoresArreglos(resgistrosTitleNull);
            limpiaValoresArreglos(registrosIdentifierNull);
            limpiaValoresArreglos(registrosDateCreatedNoInteger);
            limpiaValoresArreglos(registrosDateCreatedNull);
            limpiaValoresArreglos(registrosDateCreatedString);
            limpiaValoresArreglos(registrosFileNameErroneos);
            if(document.querySelector('#csvRoot') !== null){
                document.querySelector('#csvRoot').remove();
            }
            if(document.querySelector('.contenedor-tabla') !== null){
                document.querySelector('.contenedor-tabla').remove();
            }
            if (document.querySelector('.contenedor-report') !== null) {
                document.querySelector('.contenedor-report').remove();
            }
            if(!document.querySelector('.importar').classList.contains('contenedor-oculto')){
                agregaClasesElmentosHTML(['contenedor-oculto'],document.querySelector('.importar'));
            }
            if(document.querySelector('.validador') !== null){
                document.querySelector('.validador').remove();
            }
            if (!document.querySelector('.select-work').classList.contains('contenedor-oculto')) {
                agregaClasesElmentosHTML(['contenedor-oculto'],document.querySelector('.select-work'));
            }
            if(document.querySelector('.original_name').value !== null){
                document.querySelector('.original_name').value = '';
                document.querySelector('.new_name').value = '';
            }
        }
        /**
         * Renderiza la tabla en la página y crea los elementos HTML de acuerdo al archivo CSV
         */
        function creaTablaDelCsv() {
            targetDiv.appendChild(creaDiv(['contenedor-tabla','table-responsive','table-csv']));
            targetDiv.children[1].appendChild(creaTabla(['table-sm','visibility-hide']));
            const tableRoot = document.querySelector("#csvRoot");
            TableCsv.constructor(tableRoot);
            Papa.parse(csvFileInput.files[0], {
                delimiter: ",",
                skipEmptyLines: true,
                complete: results => {
                    agregaCampoRegistro(results.data[0]);
                    agregaNumeroRegistro(results.data.slice(1));
                    update(results.data.slice(1), results.data[0]);
                }
            });
            creandoSpinnerAnimado(targetDiv.children[1]);
        }

        function creandoSpinnerAnimado(tardetDiv) {
            tardetDiv.appendChild(creaDiv(['spinner']));
            tardetDiv.children[1].appendChild(creaDiv(['sk-chase']));
            tardetDiv.children[1].children[0].appendChild(creaDiv(['sk-chase-dot']));
            tardetDiv.children[1].children[0].appendChild(creaDiv(['sk-chase-dot']));
            tardetDiv.children[1].children[0].appendChild(creaDiv(['sk-chase-dot']));
            tardetDiv.children[1].children[0].appendChild(creaDiv(['sk-chase-dot']));
            tardetDiv.children[1].children[0].appendChild(creaDiv(['sk-chase-dot']));
            tardetDiv.children[1].children[0].appendChild(creaDiv(['sk-chase-dot']));
        }
        /**
         * @param {String []} headers 
         * agrega al header el campo registro
         */
        function agregaCampoRegistro(headers) {
            return headers.unshift('Fila_CSV');
        }
        /**
         * 
         * @param {Array[][]} ArreglosRegistros Contiene los registros de cada  fila con los campos del archivo CSV
         * Añade a la fila el número correspondiente de registro
         */
        function agregaNumeroRegistro(ArreglosRegistros) {
            ArreglosRegistros.forEach( (ArregloRegistro,index) => {
                ArregloRegistro.unshift(`${index + 2}`);
            })
            return ArreglosRegistros
        }
        /**
         * Función que ejecuta al darle click al botón validar
         */
        function validadorBtn() {
            targetDiv.appendChild(creaDiv(['contenedor-report']));
            validadorCsvCampos();
            ValorTextArea.forEach( msgError => {
                targetDiv.children[2].appendChild(creaSpan('reporte',msgError));
            });
        }
        /**
         * 
         * @param {string []} nameClassElementoHtml Nombre de la clase del objeto que contiene la clase contenedor-oculto
         * 
         * Elimina del elemento HTML la clase contenedor oculto
         */
        function mostrarContenedorOculto(nameClassElementoHtml) {
            document.querySelector(`.${nameClassElementoHtml}`).classList.remove('contenedor-oculto');
        }

        /**
         * Renderiza un HTMLTableElement de acuerdo a los datos del archivo CSV
         * 
         * @param {string[][]} data Son los datos de nuestro archivo CSV
         * @param {string[]} headerColumns Son los encabezados del archivo CSV
         */
        function update(data,headerColumns = []){
            TableCsv.setheader(headerColumns);
            TableCsv.setbody(data,headerColumns);
        }
        /**
         * 
         * @param {string[][]} clase 
         * @param {string[]} msg 
         * Agregar la función si se requiere crear inputs
         */
        /*
        function creaInput(clase,tipoInput, value) {
            const creaInput = document.createElement('input');
            creaInput.type = tipoInput;
            agregaClasesElmentosHTML(clase,creaInput);
            creaInput.value = value;
            return creaInput;
        }*/
        function creaBoton(clase,msg) {
            const creaButtton = document.createElement('button');
            creaButtton.type = 'button';
            creaButtton.classList.add(clase);
            creaButtton.textContent = msg;
            return creaButtton;
        }
        function creaTabla(clases) {
            const creaTable = document.createElement('table');
            creaTable.id = 'csvRoot';
            agregaClasesElmentosHTML(clases,creaTable);
            return creaTable;
        }
        function creaDiv(clases) {
            const creaDiv = document.createElement('div');
            agregaClasesElmentosHTML(clases,creaDiv)
            return creaDiv;
        }
        function creaSpan(clase,msg) {
            const creaP = document.createElement('p');
            creaP.classList.add(clase);
            creaP.textContent = msg;
            return creaP;
        }
        /**
         * @param {String [][]} clases Arreglo de strings que contiene las clases que tendrá el elemento HTML
         * @param {HTMLElement} HtmlElement Elemento HTML al cual se le agregarán las clases
         * 
         * Añade al elemento HTML las clases que tenga declaradas en el arreglo
         */
        function agregaClasesElmentosHTML(clases,HtmlElement){
            clases.forEach(clase => {
                HtmlElement.classList.add(clase);
            })
        }
        /**
         * @param {Array} arreglo 
         * Elimina el contenido del arreglo
         */
        function limpiaValoresArreglos(arreglo) {
            arreglo.splice(0,arreglo.length);
        }
        /**
         * La función hara las validaciones de acuerdo a nuestras necesidades, en caso de
         * no tener algún error se podra descargar el archivo, sino se le notificara al usuario en que campos esta mal
         * false esta correcto todo
         * true esta incorrecto un campo
         */
        function validadorCsvCampos() {
            const registros = document.querySelectorAll('.table-csv tbody tr');
            validarCamposNullNotExistDeleteToValidate();
            conjuntoValidadoresACampos(registros);
                        
            agregandoMensajesATextArea();

            //DEPENDIENDO SI EXISTEN ERRORES O CAMPOS NO IDENTIFICADOS EN HYRAX ES EL MENSAJE QUE MUESTRA EN EL TEXT AREA SI NO HAY REGISTROS ERRONEOS NO ELIMINA LAS FILAS CORRECTAS

            if (!document.querySelector('.wrong') && !ValorTextArea.length) {
                ValorTextArea.unshift('No existen registros erroneos en el archivo');
                eliminaColumnaRegistro();
                rellenarTextField(document.querySelector('.original_name'), csvFileInput.files[0].name);
                mostrarContenedorOculto('select-work');
                // no se eliminan los registros correctos y se muestra el boton de importar en la raíz
            }else{
                /*
                Si se agrega la modalida que compare los campos hyrax del proyecto en el header, se añade estas condiciones y se elimina la llamada
                de la funcion eliminaRegistrosCorrectos(); que está debajo de estos comentarios
                if (!document.querySelector('.wrong') && ValorTextArea.length) {
                    ValorTextArea.unshift('No existen registros erroneos pero existen nombres de campos que no estan registrados en el proyecto');
                    creaBtnImportacion();
                    // No se eliminan los registros correctos y se muestra el boton de importar en la raíz pero con un aviso de que los campos serán ignorados
                } else {
                    eliminaRegistrosCorrectos();
                }*/
                eliminaRegistrosCorrectos();
            }
        }

        function rellenarTextField(elementHTML, textcontent) {
            elementHTML.value = textcontent;    
        }

        function eliminaColumnaRegistro() {
            document.querySelectorAll('.Fila_CSV').forEach( registro => {
                registro.remove();
            });

            document.querySelector('.table-csv thead th').remove();
        }
        /**
         * @param {HTMLElement} registros Conjuto de tr en el tbody de la tabla
         * 
         * Itera los tr o filas de la tabla para verificar en cada campo del arreglo campotoValidate y llama a cada validador dependiendo del campo
         */
        function conjuntoValidadoresACampos(registros) {
            registros.forEach( (registro, index) => {
                campostoValidate.forEach( campotoValidate => {
                    validaCamposExistentes(campotoValidate,registro,index);
                })
            })
        }
        /**
         * 
         * @param {string[][]} campotoValidate Campos confirmados que existen en el archivo para validar
         * @param {HTMLTableRowElement} registro 
         * @param {integer} index 
         */
        function validaCamposExistentes(campotoValidate,registro,index) {
            if (campotoValidate === 'file_name') {
                        
            } else {
                validaCamposNull(registro,index,campotoValidate);
                if (campotoValidate === 'date_created') {
                    registroDateCreated = registro.querySelector(`.${campotoValidate}`);
                    validaDateCreatedStringOrFormatoCuatro(registroDateCreated,index,registro);
                }
            }
        }
        /**
         * Valida si los nombres de los campos del archivo CSV correspondan a los del Proyecto Hyrax, también verifica si algún header está vació
         * y verifica que los campos a validar de acuerdo a los requisitos de la biblioteca existen en el archivo si no existen los elimina para
         * no validar ese campo que no existe en el archivo
         */
        function validarCamposNullNotExistDeleteToValidate() {
            const camposHeaderTable = document.querySelectorAll('.table-csv thead th');
            let valorCamposHeaderTextContent = [];
            camposHeaderTable.forEach( (campo,index) => {
                if (camposObligatorios.includes(campo.textContent.trim()) && !camposExist.includes(campo.textContent.trim())) {
                    camposExist.push(campo.textContent.trim())
                }
            });
                       
            camposHeaderTable.forEach( (campo,index) => {

                if (campo.textContent.trim() === '') {
                    camposHeaderNull = [...camposHeaderNull, index + 1];
                } else {
                    valorCamposHeaderTextContent = [...valorCamposHeaderTextContent, campo.textContent.trim() ];
                    //validadorCamposHyrax(campo);
                }
            });
            eliminaCampostoValidate(valorCamposHeaderTextContent);
            
            
            camposObligatorios.forEach((campo, index)=> {
                if(!camposExist.includes(campo)){
                    camposNotExist.push(campo)
                }

            });
                
            
        }
        /**
         * 
         * @param {string []} campo Valor del campo del header de la tabla
         * 
         * La función validará que todos los campos que esten en el header pertenezcan a los que estan declarados en el proyecto de ColMex_Hyrax
         * Si no estan los agrega a un arreglo para mencionarlo en el reporte para avisar que estos campos no estan declarados en el proyecto y serán ignorados
         */
        /*function validadorCamposHyrax(campo){
            if (!camposHyrax.includes(campo.textContent.trim()) && campo.textContent.trim() !== ''){
                if (!camposHyraxNotFound.includes(campo.textContent.trim()) ) {
                    camposHyraxNotFound = [...camposHyraxNotFound, campo.textContent.trim()];
                }
            }
        }*/
        /**
         * @param {string[][]} valorCamposHeaderTextContent Array de los valores de cada header de la tabla
         * 
         * Función que elimina los campos no existentes del arreglo donde se validan los campos en la biblioteca
         */

        function eliminaCampostoValidate(valorCamposHeaderTextContent) {
            campostoValidate.forEach ( (campo,index) => {
                if (!valorCamposHeaderTextContent.includes(campo)) {
                    campostoValidateNotExist = [...campostoValidateNotExist, campo];
                    campostoValidate.splice(index,1);
                }
            })
        }
        /**
         * @param {HTMLElement} registro tr
         * 
         * Marca al elemento con la clase error y a la vez elimina la clase correct en la fila
         */
        function MarcaRegistrosErroneos(registro) {
            if( !registro.classList.contains('wrong')){
                registro.classList.remove('correct');
                registro.classList.add('wrong');
            }
        }
        /**
         * 
         * @param {HTMLElement} registro 
         * @param {integer} index 
         * @param {string[]} campotoValidate 
         * 
         * Verifíca si en el campo del registro contiene un null, espacio, vació o doble espacio en caso de que si contenga eso, marca el registro con wrong
         */
        function validaCamposNull(registro,index,campotoValidate) {
            if (registro.querySelector(`.${campotoValidate}`).textContent === null || registro.querySelector(`.${campotoValidate}`).textContent === '' || registro.querySelector(`.${campotoValidate}`).textContent === '  '){
                switch (campotoValidate ) {
                    case 'identifier':
                        registrosIdentifierNull = [...registrosIdentifierNull, index + 2];
                        MarcaRegistrosErroneos(registro.querySelector(`.${campotoValidate}`));
                        break;
                    case 'title':
                        resgistrosTitleNull = [...resgistrosTitleNull, index + 2];
                        MarcaRegistrosErroneos(registro.querySelector(`.${campotoValidate}`));
                        break;
                    // case 'date_created':
                    //     registrosDateCreatedNull = [...registrosDateCreatedNull, index + 2];
                    //     MarcaRegistrosErroneos(registro.querySelector(`.${campotoValidate}`));
                    //     break;
                    default:
                        break;
                }
                if(campotoValidate !== "date_created") {
                    MarcaRegistrosErroneos(registro);
                }
            }   
        }
        /**
         * @param {HTMLElement} registroDateCreated Elemento HTML que apunta a la fila de la tabla
         * @param {integer} index  número de registro
         * 
         * Valida si el contenido del campo del registro date_created si primero es un string y después si cumple con ser 4 dígitos
         */
        function validaDateCreatedStringOrFormatoCuatro(registroDateCreated,index,registro) {
            if (!Number.isInteger(parseInt(registroDateCreated.textContent.trim(),10)) && registroDateCreated.textContent !== '  ') {
                if(registroDateCreated.textContent !== '')
                {
                    registrosDateCreatedString = [...registrosDateCreatedString,index + 2];
                    MarcaRegistrosErroneos(registroDateCreated);
                    MarcaRegistrosErroneos(registro);
                }
            }
            else{
                if(registroDateCreated.textContent.trim().length !== 4 && registroDateCreated.textContent !== '  '){
                    registrosDateCreatedNoInteger = [...registrosDateCreatedNoInteger, index + 2];
                    MarcaRegistrosErroneos(registroDateCreated);
                    MarcaRegistrosErroneos(registro);
                }
            }
        }
        /**
         * Funcion que agrega los mensajes de error al text area
         */
        function agregandoMensajesATextArea() {
            // valorTextArea(campostoValidateNotExist, campostoValidateNotExist.length != 1 ? 'Los campos que son validados en el programa no existen en el archivo son los siguientes: ' : 'El campo que se valida en el programa no existe en el archivo, es el siguiente: ')
            valorTextArea(camposHeaderNull, camposHeaderNull.length != 1 ? 'Esta vació el encabezado en las columnas: ' : 'Esta vació el encabezado en la columna: ');
            //valorTextArea(camposHyraxNotFound, camposHyraxNotFound.length != 1 ? 'Los campos no existentes en el proyecto son: ' : 'El campo no existe en el proyecto es: '); Agregar si se validan los campos hyrax
            valorTextArea(resgistrosTitleNull, resgistrosTitleNull.length != 1 ? 'En el campo title estan vacios los registros: ' : 'En el campo title está vació en el registro: ');
            valorTextArea(registrosIdentifierNull, registrosIdentifierNull.length != 1 ? 'En el campo identifier estan vacios los registros: ' : 'En el campo identifier está vació en el registro: ');
            valorTextArea(registrosDateCreatedNull, registrosDateCreatedNull.length != 1 ? 'En el campo date_created estan vacios los registros: ' : 'En el campo date_created está vació en el registro: ');
            valorTextArea(registrosDateCreatedString, registrosDateCreatedString.length != 1 ? 'Registros date_created que son letras: ': 'Registro date_created que son letras: ');
            valorTextArea(registrosDateCreatedNoInteger, registrosDateCreatedNoInteger.length != 1 ? 'Registros date_created que no cumplen con el formato de año con 4 dígitos son: ' : 'Registro date_created que no cumple con el formato de año con 4 dígitos es: ');
            valorTextArea(camposNotExist, camposNotExist.length != 1 ? 'No existe el campo el campo obligatorio: ' : 'No existe el campo obligatorio: '  )
        }
        /**
         * @param {integer[]} tipoError Conjunto de registros erroneos del campo
         * @param {String[]} msg    Mensaje de reporte de error de acuerdo al tipo de campo 
         * 
         * Se va agregando cada registro de error para el reporte
         */
        function valorTextArea(tipoError, msg) {
            if (tipoError.length !== 0) {
                ValorTextArea = [...ValorTextArea, msg + tipoError];
            }
        }
        /**
         * Elimina los registros correctos después de validar el archivo
         */
        function eliminaRegistrosCorrectos() {
            const registrosCorrectos = document.querySelectorAll('.correct');
            registrosCorrectos.forEach( registro => {
                registro.remove();
            })
        }

    });

}