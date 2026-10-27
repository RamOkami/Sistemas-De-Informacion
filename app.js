let gpsVecinoValido = true;
let archivoVecinoValido = true;
let archivoCuadrillaValido = true;

const API_URL = 'http://localhost:3000/incidencias';

window.addEventListener('DOMContentLoaded', async () => {
  await cargarIncidenciasDesdeBackend();
  buscarEstadoReclamo();
  renderizarTablaOIRS();
  actualizarSelectorCuadrilla();
});

async function cargarIncidenciasDesdeBackend() {
  try {
    const respuesta = await fetch(API_URL);
    if (respuesta.ok) {
      const datos = await respuesta.json();
      // Mapeamos el formato de la base de datos al formato que usa tu interfaz JS
      incidenciasDB = datos.map(i => ({
        id: i.id_incidencia,
        codigo: i.codigo_seguimiento,
        fecha: new Date(i.fecha_ingreso).toLocaleString('es-CL'),
        categoria: i.categoria,
        sector: i.sector,
        coords: `${i.latitud}, ${i.longitud}`,
        dentroCoquimbo: i.dentro_de_coquimbo,
        descripcion: i.descripcion,
        jurisdiccionValida: i.jurisdiccion_valida,
        gravedad: i.gravedad,
        estado: i.estado,
        cuadrilla: i.ordenes_trabajo?.id_cuadrilla ? `CUAD-${i.ordenes_trabajo.id_cuadrilla}` : null,
        fotoInicial: i.foto_inicial_url,
        fotoFinal: i.ordenes_trabajo?.foto_final_url || null,
        comentarioCierre: i.ordenes_trabajo?.comentario_cierre || null
      }));
    }
  } catch (error) {
    console.error('Error conectando con el backend NestJS:', error);
  }
}

// Selector de categoría táctil en el teléfono móvil
function seleccionarCategoriaMovil(cat, btnElement) {
  document.getElementById('vecino-categoria').value = cat;
  document.querySelectorAll('.btn-cat-movil').forEach(btn => {
    btn.className = 'btn-cat-movil p-2 rounded-xl border border-slate-200 bg-white font-medium text-slate-700 text-left flex items-center gap-1.5 transition';
  });
  btnElement.className = 'btn-cat-movil p-2 rounded-xl border-2 border-emerald-600 bg-emerald-50 font-bold text-emerald-900 text-left flex items-center gap-1.5 transition';
}

function mostrarSeccionVecinoMovil(seccion) {
  const esReporte = seccion === 'reporte';
  document.getElementById('contenido-reporte-movil').classList.toggle('hidden', !esReporte);
  document.getElementById('contenido-seguimiento-movil').classList.toggle('hidden', esReporte);
  document.getElementById('tab-reporte-movil').className = esReporte
    ? 'flex-1 py-2 rounded-lg bg-white text-muni-navy shadow-sm'
    : 'flex-1 py-2 rounded-lg text-slate-500';
  document.getElementById('tab-seguimiento-movil').className = esReporte
    ? 'flex-1 py-2 rounded-lg text-slate-500'
    : 'flex-1 py-2 rounded-lg bg-white text-muni-navy shadow-sm';
}

function seleccionarCategoriaVecinoMovil(categoria, boton) {
  document.getElementById('categoria-vecino-movil').value = categoria;
  document.querySelectorAll('.categoria-vecino-movil').forEach(elemento => {
    elemento.className = 'categoria-vecino-movil p-2.5 rounded-xl border border-slate-200 text-slate-700 text-left flex items-center gap-2';
    elemento.querySelector('span').className = 'text-[11px] font-semibold';
  });
  boton.className = 'categoria-vecino-movil p-2.5 rounded-xl border-2 border-emerald-600 bg-emerald-50 text-emerald-900 text-left flex items-center gap-2';
  boton.querySelector('span').className = 'text-[11px] font-bold';
}

function actualizarContadorVecinoMovil() {
  const longitud = document.getElementById('descripcion-vecino-movil').value.trim().length;
  const contador = document.getElementById('contador-vecino-movil');
  contador.textContent = `${longitud} / 20 mín.`;
  contador.className = longitud >= 20
    ? 'text-[10px] text-emerald-700 font-bold'
    : 'text-[10px] text-slate-500';
}

function actualizarFotoVecinoMovil(input) {
  const archivo = input.files[0];
  const nombre = document.getElementById('nombre-foto-vecino-movil');
  if (!archivo) {
    nombre.textContent = 'JPG o PNG · obligatoria';
    nombre.className = 'block text-[10px] text-slate-500 mt-0.5';
    return;
  }

  nombre.textContent = archivo.name;
  nombre.className = 'block text-[10px] text-emerald-700 font-semibold mt-0.5 truncate';
}

function mostrarAvisoVecinoMovil(tipo, mensaje) {
  const alerta = document.getElementById('alerta-vecino-movil');
  alerta.className = tipo === 'error'
    ? 'p-3 rounded-xl border bg-rose-50 border-rose-300 text-rose-800 text-xs leading-relaxed'
    : 'p-3 rounded-xl border bg-emerald-50 border-emerald-300 text-emerald-900 text-xs leading-relaxed';
  alerta.textContent = mensaje;
}

function enviarReporteVecinoMovil() {
  const descripcion = document.getElementById('descripcion-vecino-movil').value.trim();
  const archivo = document.getElementById('foto-vecino-movil').files[0];

  if (descripcion.length < 20) {
    mostrarAvisoVecinoMovil('error', 'Cuéntanos un poco más: la descripción debe tener al menos 20 caracteres.');
    return;
  }
  if (!archivo || !['image/jpeg', 'image/png'].includes(archivo.type)) {
    mostrarAvisoVecinoMovil('error', 'Adjunta una fotografía válida en formato JPG o PNG para enviar el reporte.');
    return;
  }

  const nuevoId = Math.max(100, ...incidenciasDB.map(item => item.id)) + 1;
  const codigo = `CQ-2026-0${nuevoId}`;
  const extension = archivo.type === 'image/png' ? 'png' : 'jpg';
  incidenciasDB.unshift({
    id: nuevoId,
    codigo,
    fecha: new Date().toLocaleString('es-CL'),
    categoria: document.getElementById('categoria-vecino-movil').value,
    sector: 'Av. Costanera 1250, Coquimbo',
    coords: '-29.9533, -71.3395',
    dentroCoquimbo: true,
    descripcion,
    jurisdiccionValida: true,
    gravedad: 'Rutina',
    estado: 'Ingresada',
    cuadrilla: null,
    fotoInicial: `foto_reporte_movil.${extension}`,
    fotoFinal: null,
    comentarioCierre: null
  });

  document.getElementById('codigo-seguimiento-movil').value = codigo;
  mostrarAvisoVecinoMovil('ok', `¡Reporte enviado! Guarda tu código ${codigo} para consultar el avance.`);
  document.getElementById('resultado-seguimiento-movil').textContent = `Reporte ${codigo} ingresado.`;
  mostrarSeccionVecinoMovil('seguimiento');
  consultarSeguimientoVecinoMovil();
}

function consultarSeguimientoVecinoMovil() {
  const codigo = document.getElementById('codigo-seguimiento-movil').value.trim().toUpperCase();
  const item = incidenciasDB.find(incidencia => incidencia.codigo === codigo);
  const resultado = document.getElementById('resultado-seguimiento-movil');

  if (!item) {
    resultado.textContent = `No encontramos un reporte con el código ${codigo || 'ingresado'}. Revisa que esté escrito correctamente.`;
    return;
  }

  const estado = item.estado.replace('_', ' ');
  resultado.innerHTML = `
    <div class="flex items-center justify-between gap-2 border-b border-slate-200 pb-2">
      <span id="estado-codigo-movil" class="font-mono font-extrabold text-muni-navy"></span>
      <span id="estado-badge-movil" class="px-2 py-1 rounded-full text-[10px] font-bold"></span>
    </div>
    <p class="mt-2 text-slate-600">Categoría: <strong id="estado-categoria-movil" class="text-slate-800"></strong></p>
    <p class="mt-1 text-slate-600">Ubicación: <strong id="estado-sector-movil" class="text-slate-800"></strong></p>
    <div class="mt-3 rounded-lg bg-white border border-slate-200 p-2.5">
      <p class="font-bold text-slate-800"><i class="ph ph-clock-countdown text-emerald-700"></i> Seguimiento del reporte</p>
      <p id="estado-detalle-movil" class="mt-1 text-slate-600"></p>
    </div>
  `;
  document.getElementById('estado-codigo-movil').textContent = item.codigo;
  document.getElementById('estado-categoria-movil').textContent = item.categoria;
  document.getElementById('estado-sector-movil').textContent = item.sector;
  document.getElementById('estado-badge-movil').textContent = estado;

  const badge = document.getElementById('estado-badge-movil');
  badge.className = 'px-2 py-1 rounded-full text-[10px] font-bold';
  if (item.estado === 'Resuelta') badge.classList.add('bg-emerald-100', 'text-emerald-800');
  else if (item.estado === 'Asignada') badge.classList.add('bg-blue-100', 'text-blue-800');
  else if (item.estado === 'En_Espera') badge.classList.add('bg-amber-100', 'text-amber-800');
  else if (item.estado.includes('Descartada')) badge.classList.add('bg-rose-100', 'text-rose-800');
  else badge.classList.add('bg-purple-100', 'text-purple-800');

  const detalle = item.estado === 'Resuelta'
    ? item.comentarioCierre || 'El reporte fue resuelto.'
    : item.estado === 'Asignada'
      ? `Trabajo asignado a ${item.cuadrilla || 'una cuadrilla municipal'}.`
      : item.estado === 'En_Espera'
        ? 'El reporte está en lista de espera para su atención.'
        : item.estado.includes('Descartada')
          ? item.comentarioCierre || 'El reporte fue descartado.'
          : 'Reporte recibido. El equipo municipal revisará los antecedentes.';
  document.getElementById('estado-detalle-movil').textContent = detalle;
}

function enfocarBuscadorCodigo() {
  const input = document.getElementById('input-buscador-codigo');
  input.focus();
  input.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

// Cambiar entre las 4 vistas superiores
function cambiarVista(vista) {
  document.querySelectorAll('.role-view').forEach(el => el.classList.add('hidden'));
  document.querySelectorAll('.nav-tab').forEach(btn => {
    btn.classList.remove('bg-muni-emerald', 'text-white', 'shadow');
    btn.classList.add('text-slate-200');
  });

  document.getElementById('vista-' + vista).classList.remove('hidden');
  const activeBtn = document.getElementById('btn-vista-' + vista);
  activeBtn.classList.add('bg-muni-emerald', 'text-white', 'shadow');
  activeBtn.classList.remove('text-slate-200');

  if (vista === 'oirs') renderizarTablaOIRS();
  if (vista === 'cuadrilla') actualizarSelectorCuadrilla();
}

// ==================== FUNCIONES DE VALIDACIÓN VISTA VECINO ====================
function setCoordenadasVecino(coords, sector, esValido) {
  document.getElementById('vecino-coords').value = coords;
  document.getElementById('vecino-sector').value = sector;
  // Fallbacks de elementos originales
  const miniCoords = document.getElementById('coords-display-mini');
  if(miniCoords) miniCoords.textContent = coords;
  const miniSector = document.getElementById('sector-display-mini');
  if(miniSector) miniSector.textContent = '📍 ' + sector;
  
  gpsVecinoValido = esValido;

  const badge = document.getElementById('badge-gps-vecino');
  const alerta = document.getElementById('alerta-validacion-vecino');
  const pinLabel = document.getElementById('label-pin-mapa');

  if (esValido) {
    badge.className = 'text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800';
    badge.textContent = 'Coquimbo OK';
    if(pinLabel) pinLabel.textContent = 'Punto de la denuncia';
    alerta.classList.add('hidden');
  } else {
    badge.className = 'text-[10px] font-bold px-2 py-0.5 rounded-full bg-rose-100 text-rose-800';
    badge.textContent = 'Fuera de Rango';
    if(pinLabel) pinLabel.textContent = 'Fuera de Coquimbo';
    mostrarAlertaFormulario(
      'error',
      '<strong>Error Validación 1 (Geofencing GPS):</strong> Coordenadas (<code>-29.9027, -71.2519</code>) pertenecen a La Serena. Reporte descartado para el indicador <strong>TDT</strong>.'
    );
  }
}

function cambiarArchivoSimuladoVecino(esValido) {
  archivoVecinoValido = esValido;
  const inputArchivo = document.getElementById('vecino-archivo');
  const estadoArchivo = document.getElementById('estado-archivo-vecino');

  if (esValido) {
    inputArchivo.value = 'foto_evidencia_microbasural.jpg';
    estadoArchivo.textContent = '✓ JPG listo';
    estadoArchivo.className = 'text-xs font-semibold text-emerald-700';
    document.getElementById('alerta-validacion-vecino').classList.add('hidden');
  } else {
    inputArchivo.value = 'documento_reclamo.pdf';
    estadoArchivo.textContent = '✕ Formato PDF inválido';
    estadoArchivo.className = 'text-xs font-bold text-rose-600';
    mostrarAlertaFormulario(
      'warning',
      '<strong>Error Validación 2 (Foto Obligatoria):</strong> Formato <code>.pdf</code> no admitido. Se exige captura de imagen <code>.jpg</code> o <code>.png</code>.'
    );
  }
}

function actualizarContadorTexto() {
  const txt = document.getElementById('vecino-descripcion').value.trim();
  const contador = document.getElementById('contador-caracteres');
  contador.textContent = `${txt.length} / mín. 20 caracteres`;

  if (txt.length < 20) {
    contador.className = 'text-xs font-mono font-bold text-rose-600';
  } else {
    contador.className = 'text-xs font-mono font-semibold text-emerald-700';
  }
}

function mostrarAlertaFormulario(tipo, htmlMsg) {
  const alerta = document.getElementById('alerta-validacion-vecino');
  alerta.classList.remove('hidden');
  if (tipo === 'error') {
    alerta.className = 'p-4 rounded-xl border bg-rose-50 border-rose-300 text-rose-800 text-xs leading-relaxed';
  } else if (tipo === 'warning') {
    alerta.className = 'p-4 rounded-xl border bg-amber-50 border-amber-300 text-amber-900 text-xs leading-relaxed';
  } else {
    alerta.className = 'p-4 rounded-xl border bg-emerald-50 border-emerald-300 text-emerald-900 text-xs leading-relaxed';
  }
  alerta.innerHTML = htmlMsg;
}

async function procesarEnvioVecino(e) {
  if (e) e.preventDefault();
  
  const desc = document.getElementById('vecino-descripcion').value.trim();
  const categoria = document.getElementById('vecino-categoria').value;
  const coords = document.getElementById('vecino-coords').value.split(',');
  const sector = document.getElementById('vecino-sector').value;

  if (desc.length < 20) {
    mostrarAlertaFormulario('error', 'La descripción debe tener al menos 20 caracteres.');
    return;
  }

  const latitud = parseFloat(coords[0]);
  const longitud = parseFloat(coords[1]);
  const nuevoCodigo = `CQ-2026-0${Math.floor(Math.random() * 900) + 100}`;

  const payload = {
    codigo_seguimiento: nuevoCodigo,
    categoria: categoria,
    sector: sector,
    latitud: latitud,
    longitud: longitud,
    dentro_de_coquimbo: gpsVecinoValido,
    descripcion: desc,
    jurisdiccion_valida: gpsVecinoValido,
    gravedad: 'Rutina',
    estado: gpsVecinoValido ? 'Ingresada' : 'Descartada_GPS',
    foto_inicial_url: document.getElementById('vecino-archivo').value,
    id_departamento: 1
  };

  try {
    const respuesta = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    if (respuesta.ok) {
      await cargarIncidenciasDesdeBackend(); // Recargar datos desde PostgreSQL
      mostrarAlertaFormulario('ok', `¡Denuncia registrada con éxito en PostgreSQL! Código: <code>${nuevoCodigo}</code>`);
      renderizarTablaOIRS();
      notificarToast(`Denuncia ${nuevoCodigo} guardada en PostgreSQL`);
    }
  } catch (error) {
    notificarToast('Error al conectar con la API en NestJS', true);
  }
}

// Botones de simulación rápida en la barra superior
function activarPruebaValidacion(num) {
  cambiarVista('vecino');
  if (num === 1) {
    setCoordenadasVecino('-29.9027, -71.2519', 'Av. Francisco de Aguirre, La Serena', false);
  } else if (num === 2) {
    cambiarArchivoSimuladoVecino(false);
  } else if (num === 3) {
    document.getElementById('vecino-descripcion').value = 'Basura en calle';
    actualizarContadorTexto();
    mostrarAlertaFormulario(
      'error',
      '<strong>Error en Validación 3 (Campos y Categoría):</strong> La descripción tiene menos de 20 caracteres ("Basura en calle" = 15 caracteres). El formulario impide el envío a la base de datos.'
    );
  }
}

function limpiarSimulaciones() {
  cambiarVista('vecino');
  setCoordenadasVecino('-29.9533, -71.3395', 'Av. Costanera 1250, Coquimbo Centro', true);
  cambiarArchivoSimuladoVecino(true);
  document.getElementById('vecino-descripcion').value = 'Acumulación de basura domiciliaria y escombros bloqueando el paso peatonal.';
  actualizarContadorTexto();
  document.getElementById('alerta-validacion-vecino').classList.add('hidden');
  notificarToast('Formulario restaurado sin errores');
}

// ==================== BUSCADOR PÚBLICO DE ESTADO ====================
function cargarCodigoRapido(cod) {
  document.getElementById('input-buscador-codigo').value = cod;
  buscarEstadoReclamo();
}

function buscarEstadoReclamo() {
  const cod = document.getElementById('input-buscador-codigo').value.trim().toUpperCase();
  const box = document.getElementById('resultado-buscador-box');
  const item = incidenciasDB.find(i => i.codigo === cod);

  if (!item) {
    box.innerHTML = `<p class="text-rose-600 font-semibold">No se encontró ningún reporte con el código "${cod}".</p>`;
    return;
  }

  let colorBadge = 'bg-slate-200 text-slate-800';
  if (item.estado === 'Resuelta') colorBadge = 'bg-emerald-100 text-emerald-800';
  if (item.estado === 'Asignada') colorBadge = 'bg-blue-100 text-blue-800';
  if (item.estado === 'En_Espera') colorBadge = 'bg-amber-100 text-amber-800';
  if (item.estado.includes('Descartada')) colorBadge = 'bg-rose-100 text-rose-800';

  box.innerHTML = `
    <div class="flex items-center justify-between border-b border-slate-200 pb-2">
      <div>
        <span class="font-mono font-extrabold text-sm text-muni-navy">${item.codigo}</span>
        <span class="text-slate-400 ml-1">· ${item.fecha}</span>
      </div>
      <span class="px-2.5 py-0.5 rounded-full font-bold text-[11px] ${colorBadge}">${item.estado.replace('_', ' ')}</span>
    </div>
    <div class="space-y-1 text-slate-700">
      <p><strong>Categoría:</strong> ${item.categoria} (${item.gravedad})</p>
      <p><strong>Ubicación:</strong> ${item.sector} <span class="font-mono text-[11px] text-slate-500">(${item.coords})</span></p>
      <p><strong>Cuadrilla asignada:</strong> ${item.cuadrilla ? `<span class="font-mono font-bold text-blue-700">${item.cuadrilla}</span>` : 'Pendiente de despacho'}</p>
    </div>
    ${item.comentarioCierre ? `
      <div class="p-2.5 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-900">
        <p class="font-bold text-[11px] uppercase">✓ Detalle de Resolución / Cierre:</p>
        <p class="mt-0.5">${item.comentarioCierre}</p>
        ${item.fotoFinal ? `<p class="mt-1 font-mono text-[10px] text-emerald-700">📷 Evidencia adjunta: ${item.fotoFinal}</p>` : ''}
      </div>
    ` : ''}
  `;
}

// ==================== BANDEJA OIRS / COORDINADOR ====================
function renderizarTablaOIRS() {
  const tbody = document.getElementById('tbody-oirs');
  const filtro = document.getElementById('filtro-bandeja-oirs').value;
  tbody.innerHTML = '';

  // Actualizar contadores superiores
  document.getElementById('count-ingresadas').textContent = incidenciasDB.filter(i => i.estado === 'Ingresada').length;
  document.getElementById('count-espera').textContent = incidenciasDB.filter(i => i.estado === 'En_Espera').length;
  document.getElementById('count-asignadas').textContent = incidenciasDB.filter(i => i.estado === 'Asignada').length;
  document.getElementById('count-resueltas').textContent = incidenciasDB.filter(i => i.estado === 'Resuelta').length;
  document.getElementById('count-descartadas').textContent = incidenciasDB.filter(i => i.estado.includes('Descartada')).length;

  const lista = incidenciasDB.filter(item => {
    if (filtro === 'TODAS') return true;
    if (filtro === 'Descartada') return item.estado.includes('Descartada');
    return item.estado === filtro;
  });

  lista.forEach(item => {
    let badgeEstado = 'bg-slate-100 text-slate-700';
    if (item.estado === 'Ingresada') badgeEstado = 'bg-purple-100 text-purple-800';
    if (item.estado === 'En_Espera') badgeEstado = 'bg-amber-100 text-amber-800';
    if (item.estado === 'Asignada') badgeEstado = 'bg-blue-100 text-blue-800';
    if (item.estado === 'Resuelta') badgeEstado = 'bg-emerald-100 text-emerald-800';
    if (item.estado.includes('Descartada')) badgeEstado = 'bg-rose-100 text-rose-800';

    const tr = document.createElement('tr');
    tr.className = 'hover:bg-slate-50 transition';
    tr.innerHTML = `
      <td class="p-3.5 align-top">
        <span class="font-mono font-bold text-muni-navy block">${item.codigo}</span>
        <span class="text-[11px] text-slate-400">${item.fecha}</span>
      </td>
      <td class="p-3.5 align-top max-w-xs">
        <span class="font-bold text-slate-800 block">${item.categoria}</span>
        <span class="text-[11px] text-slate-600 block">${item.sector}</span>
        <span class="font-mono text-[10px] text-slate-400">GPS: ${item.coords} · 📷 ${item.fotoInicial}</span>
      </td>
      <td class="p-3.5 align-top">
        ${item.estado === 'Descartada_GPS' ? `
          <span class="text-[11px] font-bold text-rose-600">Bloqueado por GPS</span>
        ` : `
          <select onchange="cambiarJurisdiccionOIRS(${item.id}, this.value)" class="border border-slate-300 rounded-lg px-2 py-1 text-xs bg-white font-medium">
            <option value="SI" ${item.jurisdiccionValida ? 'selected' : ''}>✓ Competencia Municipal</option>
            <option value="NO" ${!item.jurisdiccionValida ? 'selected' : ''}>✕ Descartar (Otra Entidad)</option>
          </select>
        `}
      </td>
      <td class="p-3.5 align-top">
        <select onchange="cambiarGravedadOIRS(${item.id}, this.value)" ${item.estado.includes('Descartada') ? 'disabled' : ''} class="border border-slate-300 rounded-lg px-2 py-1 text-xs font-bold ${item.gravedad === 'Crítica' ? 'bg-rose-50 text-rose-700 border-rose-300' : 'bg-slate-50 text-slate-700'}">
          <option value="Rutina" ${item.gravedad === 'Rutina' ? 'selected' : ''}>Rutina (Cola 24h)</option>
          <option value="Crítica" ${item.gravedad === 'Crítica' ? 'selected' : ''}>🔥 Crítica (Urgente)</option>
        </select>
      </td>
      <td class="p-3.5 align-top">
        <span class="px-2.5 py-1 rounded-full text-[11px] font-bold inline-block ${badgeEstado}">
          ${item.estado.replace('_', ' ')}
        </span>
      </td>
      <td class="p-3.5 align-top">
        ${item.estado === 'Resuelta' ? `
          <span class="text-emerald-700 font-bold text-[11px] flex items-center gap-1">
            <i class="ph ph-check-circle"></i> Cerrada por ${item.cuadrilla}
          </span>
        ` : item.estado.includes('Descartada') ? `
          <span class="text-slate-400 italic text-[11px]">Sin asignación</span>
        ` : `
          <div class="flex items-center gap-1.5">
            <select id="select-cuad-${item.id}" class="border border-slate-300 rounded-lg px-2 py-1 text-xs bg-white">
              <option value="ASEO-01" ${item.cuadrilla === 'ASEO-01' ? 'selected' : ''}>ASEO-01 (Disp.)</option>
              <option value="PARQ-01" ${item.cuadrilla === 'PARQ-01' ? 'selected' : ''}>PARQ-01 (Disp.)</option>
              <option value="ALUM-01" ${item.cuadrilla === 'ALUM-01' ? 'selected' : ''}>ALUM-01 (Disp.)</option>
              <option value="OPER-02" ${item.cuadrilla === 'OPER-02' ? 'selected' : ''}>OPER-02 (Disp.)</option>
              <option value="ESPERA">-- Enviar a Lista Espera (24h) --</option>
            </select>
            <button onclick="despacharCuadrilla(${item.id})" class="bg-muni-navy hover:bg-muni-navyLight text-white font-bold px-2.5 py-1 rounded-lg text-xs transition">
              Asignar
            </button>
          </div>
        `}
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function cambiarJurisdiccionOIRS(id, valor) {
  const item = incidenciasDB.find(i => i.id === id);
  if (!item) return;
  if (valor === 'NO') {
    item.jurisdiccionValida = false;
    item.estado = 'Descartada_OIRS';
    item.comentarioCierre = 'Descartada por Operador OIRS: El problema corresponde a una empresa externa (ej. Aguas del Valle / CGE). Se notificó al vecino.';
    notificarToast(`Caso ${item.codigo} descartado por jurisdicción OIRS`, true);
  } else {
    item.jurisdiccionValida = true;
    item.estado = 'En_Espera';
    item.comentarioCierre = null;
    notificarToast(`Caso ${item.codigo} validado y pasado a Lista de Espera`);
  }
  renderizarTablaOIRS();
}

function cambiarGravedadOIRS(id, nuevaGravedad) {
  const item = incidenciasDB.find(i => i.id === id);
  if (!item) return;
  item.gravedad = nuevaGravedad;
  notificarToast(`Gravedad de ${item.codigo} actualizada a ${nuevaGravedad}`);
  renderizarTablaOIRS();
}

function despacharCuadrilla(id) {
  const item = incidenciasDB.find(i => i.id === id);
  const select = document.getElementById(`select-cuad-${id}`);
  if (!item || !select) return;

  if (select.value === 'ESPERA') {
    item.estado = 'En_Espera';
    item.cuadrilla = null;
    notificarToast(`${item.codigo} enviado a Lista de Espera (Temporizador 24h activo)`);
  } else {
    item.estado = 'Asignada';
    item.cuadrilla = select.value;
    notificarToast(`Orden ${item.codigo} asignada a cuadrilla ${select.value}`);
  }
  renderizarTablaOIRS();
  actualizarSelectorCuadrilla();
}

// ==================== VISTA MÓVIL CUADRILLA EN TERRENO ====================
function actualizarSelectorCuadrilla() {
  const select = document.getElementById('select-orden-cuadrilla');
  if (!select) return;
  select.innerHTML = '';

  const ordenes = incidenciasDB.filter(i => i.estado === 'Asignada' || i.estado === 'Resuelta');
  ordenes.forEach(o => {
    const opt = document.createElement('option');
    opt.value = o.id;
    opt.textContent = `${o.codigo} · ${o.categoria} (${o.estado})`;
    select.appendChild(opt);
  });

  cargarFichaCuadrilla();
}

function cargarFichaCuadrilla() {
  const select = document.getElementById('select-orden-cuadrilla');
  const container = document.getElementById('ficha-cuadrilla-body');
  if (!select || !container) return;

  const id = parseInt(select.value);
  const item = incidenciasDB.find(i => i.id === id) || incidenciasDB[1];

  container.innerHTML = `
    <div class="p-3.5 rounded-2xl bg-slate-50 border border-slate-200 space-y-2">
      <div class="flex justify-between items-center">
        <span class="font-mono font-extrabold text-sm text-muni-navy">${item.codigo}</span>
        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold ${item.gravedad === 'Crítica' ? 'bg-rose-100 text-rose-800' : 'bg-slate-200 text-slate-700'}">
          Prioridad ${item.gravedad}
        </span>
      </div>
      <p class="font-bold text-slate-800">${item.sector}</p>
      <p class="font-mono text-[11px] text-slate-500">Coordenadas GPS: ${item.coords}</p>
      <p class="text-slate-600 bg-white p-2.5 rounded-xl border border-slate-200 italic">"${item.descripcion}"</p>
    </div>

    <!-- Selector de Estado en Terreno -->
    <div>
      <label class="font-bold text-slate-700 block mb-1 uppercase text-[11px]">1. Actualizar Estado en Terreno</label>
      <select id="cuadrilla-estado-select" class="w-full border border-slate-300 rounded-xl px-3 py-2.5 bg-white font-bold text-muni-navy">
        <option value="En_Reparacion">🛠️ En Reparación / Cuadrilla en Terreno</option>
        <option value="Finalizado" selected>✅ Trabajo Finalizado (Listo para cerrar orden)</option>
      </select>
    </div>

    <!-- Carga Obligatoria de Foto del Después (Validación 2 en Cierre) -->
    <div class="p-3.5 rounded-2xl bg-emerald-50/60 border border-emerald-200 space-y-2">
      <div class="flex justify-between items-center">
        <label class="font-bold text-emerald-950 uppercase text-[11px]">2. Foto Obligatoria del "Después" *</label>
        <span id="badge-foto-cuadrilla" class="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-200 text-emerald-900">✓ .JPG Cargado</span>
      </div>
      <input type="text" id="input-foto-cierre" readonly value="evidencia_cierre_${item.codigo.toLowerCase()}.jpg" class="w-full bg-white border border-emerald-300 rounded-lg px-2.5 py-1.5 font-mono text-[11px]">
      <div class="flex gap-2 pt-1">
        <button type="button" onclick="simularFotoCuadrilla(true)" class="flex-1 py-1.5 bg-white border border-slate-300 rounded-lg font-semibold text-[11px]">📷 Foto .JPG OK</button>
        <button type="button" onclick="simularFotoCuadrilla(false)" class="flex-1 py-1.5 bg-rose-50 border border-rose-300 text-rose-700 rounded-lg font-bold text-[11px]">🚫 Probar Sin Foto</button>
      </div>
    </div>

    <div id="alerta-cierre-cuadrilla" class="hidden p-3 rounded-xl bg-rose-50 border border-rose-300 text-rose-800 text-[11px]">
      <strong>Bloqueo de Cierre (Validación 2):</strong> El sistema impide pasar la orden a "Resuelta" si la cuadrilla no adjunta la fotografía verificada del trabajo terminado.
    </div>

    <div>
      <label class="font-bold text-slate-700 block mb-1 uppercase text-[11px]">3. Comentario Técnico de la Cuadrilla</label>
      <textarea id="comentario-cuadrilla-input" rows="2" class="w-full border border-slate-300 rounded-xl p-2.5 text-xs">${item.comentarioCierre || 'Se realizó limpieza completa y retiro de escombros en el punto georreferenciado.'}</textarea>
    </div>

    <button onclick="cerrarOrdenTrabajo(${item.id})" class="w-full bg-muni-emerald hover:bg-muni-emeraldDark text-white font-bold py-3 rounded-xl shadow-md transition flex items-center justify-center gap-2 text-xs">
      <i class="ph ph-check-square-offset text-base"></i>
      <span>Cerrar Orden y Notificar por Correo al Vecino</span>
    </button>
  `;
  archivoCuadrillaValido = true;
}

function simularFotoCuadrilla(valido) {
  archivoCuadrillaValido = valido;
  const input = document.getElementById('input-foto-cierre');
  const badge = document.getElementById('badge-foto-cuadrilla');
  const alerta = document.getElementById('alerta-cierre-cuadrilla');

  if (valido) {
    input.value = 'evidencia_terreno_resuelto.jpg';
    badge.textContent = '✓ .JPG Cargado';
    badge.className = 'text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-200 text-emerald-900';
    alerta.classList.add('hidden');
  } else {
    input.value = '-- Sin archivo adjunto --';
    badge.textContent = '✕ Falta Fotografía';
    badge.className = 'text-[10px] font-bold px-2 py-0.5 rounded bg-rose-200 text-rose-900';
    alerta.classList.remove('hidden');
  }
}

function cerrarOrdenTrabajo(id) {
  if (!archivoCuadrillaValido) {
    document.getElementById('alerta-cierre-cuadrilla').classList.remove('hidden');
    notificarToast('No se puede cerrar la orden sin fotografía final', true);
    return;
  }

  const item = incidenciasDB.find(i => i.id === id);
  if (!item) return;

  item.estado = 'Resuelta';
  item.fotoFinal = document.getElementById('input-foto-cierre').value;
  item.comentarioCierre = document.getElementById('comentario-cuadrilla-input').value;

  notificarToast(`Orden ${item.codigo} cerrada con foto. Vecino notificado.`);
  actualizarSelectorCuadrilla();
  buscarEstadoReclamo();
}

function notificarToast(texto, esError = false) {
  const toast = document.getElementById('toast-msg');
  const icon = document.getElementById('toast-icon');
  document.getElementById('toast-text').textContent = texto;
  icon.className = esError ? 'ph ph-warning-circle text-rose-400 text-lg' : 'ph ph-check-circle text-emerald-400 text-lg';
  toast.classList.remove('hidden');
  setTimeout(() => toast.classList.add('hidden'), 3500);
}