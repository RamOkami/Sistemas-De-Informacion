-- ============================================================
-- ESTRUCTURA DE LA BASE DE DATOS (5 TABLAS RELACIONALES)
-- ============================================================

DROP TABLE IF EXISTS ordenes_trabajo CASCADE;
DROP TABLE IF EXISTS incidencias CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS cuadrillas CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;

-- 1. Tabla DEPARTAMENTOS
CREATE TABLE departamentos (
    id_departamento SERIAL PRIMARY KEY,
    nombre_depto VARCHAR(80) NOT NULL,
    encargado VARCHAR(100) NOT NULL
);

-- 2. Tabla CUADRILLAS
CREATE TABLE cuadrillas (
    id_cuadrilla SERIAL PRIMARY KEY,
    id_departamento INT REFERENCES departamentos(id_departamento) ON DELETE SET NULL,
    codigo_cuadrilla VARCHAR(30) UNIQUE NOT NULL,
    responsable VARCHAR(100) NOT NULL,
    disponible BOOLEAN DEFAULT TRUE
);

-- 3. Tabla USUARIOS (Autenticación y Roles RBAC)
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(30) NOT NULL CHECK (rol IN ('Ciudadano', 'Operador_OIRS', 'Coordinador', 'Cuadrilla', 'Administrador')),
    activo BOOLEAN DEFAULT TRUE
);

-- 4. Tabla INCIDENCIAS (Tabla principal)
CREATE TABLE incidencias (
    id_incidencia SERIAL PRIMARY KEY,
    codigo_seguimiento VARCHAR(30) UNIQUE NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    categoria VARCHAR(50) NOT NULL,
    sector VARCHAR(255) NOT NULL,
    latitud DECIMAL(10, 8) NOT NULL,
    longitud DECIMAL(11, 8) NOT NULL,
    dentro_de_coquimbo BOOLEAN DEFAULT TRUE,
    descripcion TEXT NOT NULL,
    jurisdiccion_valida BOOLEAN DEFAULT TRUE,
    gravedad VARCHAR(20) DEFAULT 'Rutina' CHECK (gravedad IN ('Rutina', 'Crítica')),
    estado VARCHAR(30) DEFAULT 'Ingresada' CHECK (estado IN ('Ingresada', 'En_Espera', 'Asignada', 'Resuelta', 'Descartada_GPS', 'Descartada_OIRS')),
    foto_inicial_url VARCHAR(255) NOT NULL,
    id_departamento INT REFERENCES departamentos(id_departamento) ON DELETE SET NULL
);

-- 5. Tabla ORDENES_TRABAJO
CREATE TABLE ordenes_trabajo (
    id_orden SERIAL PRIMARY KEY,
    id_incidencia INT UNIQUE REFERENCES incidencias(id_incidencia) ON DELETE CASCADE,
    id_cuadrilla INT REFERENCES cuadrillas(id_cuadrilla) ON DELETE SET NULL,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre TIMESTAMP,
    foto_final_url VARCHAR(255),
    comentario_cierre TEXT
);

-- ============================================================
-- POBLADO INICIAL DE DATOS
-- ============================================================

INSERT INTO departamentos (id_departamento, nombre_depto, encargado) VALUES
(1, 'Aseo y Ornato', 'Carlos Mendoza'),
(2, 'Alumbrado Público', 'Roberto Silva'),
(3, 'Parques y Jardines', 'Elena Torres'),
(4, 'Operaciones y Calzadas', 'Hugo Ramos');

INSERT INTO cuadrillas (id_cuadrilla, id_departamento, codigo_cuadrilla, responsable, disponible) VALUES
(1, 1, 'ASEO-01', 'Juan Pérez', TRUE),
(2, 2, 'ALUM-01', 'Marcos Araya', TRUE),
(3, 3, 'PARQ-01', 'Lucía Gómez', TRUE),
(4, 4, 'OPER-02', 'Esteban Morales', TRUE);

INSERT INTO usuarios (nombre, correo, password, rol, activo) VALUES
('Vecino Coquimbo', 'vecino.coquimbo@gmail.com', 'pass123', 'Ciudadano', TRUE),
('Operador OIRS', 'oirs@coquimbo.cl', 'pass123', 'Operador_OIRS', TRUE),
('Coordinador General', 'coordinador@coquimbo.cl', 'pass123', 'Coordinador', TRUE),
('Juan Pérez (Aseo)', 'aseo01@coquimbo.cl', 'pass123', 'Cuadrilla', TRUE);

-- POBLADO DE 100 INCIDENCIAS
INSERT INTO incidencias 
(id_incidencia, codigo_seguimiento, fecha_ingreso, categoria, sector, latitud, longitud, dentro_de_coquimbo, descripcion, jurisdiccion_valida, gravedad, estado, foto_inicial_url, id_departamento)
VALUES
(101, 'CQ-2026-0101', '2026-10-24 09:15:00', 'Aseo', 'Calle Aldunate 840, Centro Coquimbo', -29.9533, -71.3395, TRUE, 'Microbasural acumulado en esquina peatonal con restos de muebles y bolsas rotas.', TRUE, 'Rutina', 'Resuelta', 'microbasural_aldunate.jpg', 1),
(102, 'CQ-2026-0102', '2026-10-25 11:30:00', 'Alumbrado Público', 'Av. Las Torres esq. Talca, Tierras Blancas', -29.9681, -71.2829, TRUE, 'Poste de alumbrado público apagado y con cables sueltos frente a área verde vecinal.', TRUE, 'Crítica', 'Asignada', 'poste_apagado_tierras_blancas.jpg', 2),
(103, 'CQ-2026-0103', '2026-10-25 16:45:00', 'Parques y Jardines', 'Plaza de Armas de Coquimbo', -29.9541, -71.3389, TRUE, 'Rama de árbol quebrada sobre banca metálica requiere poda preventiva.', TRUE, 'Rutina', 'En_Espera', 'rama_plaza_armas.png', 3),
(104, 'CQ-2026-0104', '2026-10-26 08:20:00', 'Operaciones', 'Av. Costanera 1420, Sector Playa Changa', -29.9610, -71.3315, TRUE, 'Bache profundo en calzada principal que pone en riesgo a ciclistas y vehículos.', TRUE, 'Crítica', 'Ingresada', 'bache_costanera.jpg', 4),
(105, 'CQ-2026-0105', '2026-10-23 18:10:00', 'Aseo', 'Av. Francisco de Aguirre, La Serena', -29.9027, -71.2519, FALSE, 'Escombros dejados en vereda norte fuera de jurisdicción comunal.', FALSE, 'Rutina', 'Descartada_GPS', 'escombros_limite.jpg', 1),
(106, 'CQ-2026-0106', '2026-10-20 10:00:00', 'Aseo', 'Av. Videla 320, Parte Alta', -29.9588, -71.3412, TRUE, 'Acumulación de escombros de remodelación bloqueando vereda.', TRUE, 'Rutina', 'Resuelta', 'foto_106.jpg', 1),
(107, 'CQ-2026-0107', '2026-10-20 11:15:00', 'Alumbrado Público', 'Calle Bilbao 512, Centro', -29.9552, -71.3370, TRUE, 'Foco parpadeante genera inseguridad nocturna en calle comercial.', TRUE, 'Rutina', 'En_Espera', 'foto_107.jpg', 2),
(108, 'CQ-2026-0108', '2026-10-20 12:30:00', 'Parques y Jardines', 'Parque O’Higgins, Costanera', -29.9590, -71.3350, TRUE, 'Fuga de agua en sistema de riego automatizado del parque.', TRUE, 'Crítica', 'Asignada', 'foto_108.jpg', 3),
(109, 'CQ-2026-0109', '2026-10-20 14:00:00', 'Operaciones', 'Calle Regimiento Coquimbo 110, San Juan', -29.9710, -71.3210, TRUE, 'Tapa de alcantarillado desprendida tras paso de camión pesado.', TRUE, 'Crítica', 'Resuelta', 'foto_109.jpg', 4),
(110, 'CQ-2026-0110', '2026-10-20 15:45:00', 'Aseo', 'Ruta 5 Norte km 465, Peñuelas', -29.9320, -71.2980, TRUE, 'Restos de neumáticos quemados en berma de autopista.', TRUE, 'Rutina', 'Ingresada', 'foto_110.jpg', 1),
(111, 'CQ-2026-0111', '2026-10-21 08:30:00', 'Aseo', 'Calle Balmaceda, La Serena', -29.9150, -71.2400, FALSE, 'Basura domiciliaria fuera de sector asignado a Coquimbo.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_111.jpg', 1),
(112, 'CQ-2026-0112', '2026-10-21 09:10:00', 'Alumbrado Público', 'Av. El Rosario 400, Sindempart', -29.9820, -71.3450, TRUE, 'Luminaria solar dañada por impacto vehicular.', TRUE, 'Crítica', 'Asignada', 'foto_112.jpg', 2),
(113, 'CQ-2026-0113', '2026-10-21 10:20:00', 'Parques y Jardines', 'Plaza Sindempart Norte', -29.9800, -71.3410, TRUE, 'Pastos secos y acumulación de maleza arbolada.', TRUE, 'Rutina', 'En_Espera', 'foto_113.jpg', 3),
(114, 'CQ-2026-0114', '2026-10-21 11:50:00', 'Operaciones', 'Av. La Cantera esq. El Sauce', -29.9750, -71.3100, TRUE, 'Hoyo peligroso en señalización de disco pare desplomado.', TRUE, 'Crítica', 'Resuelta', 'foto_114.jpg', 4),
(115, 'CQ-2026-0115', '2026-10-21 13:10:00', 'Aseo', 'Población Baquedano, Calle Baquedano', -29.9500, -71.3320, TRUE, 'Restos de voluminosos tras marejada y viento fuerte.', TRUE, 'Rutina', 'Ingresada', 'foto_115.jpg', 1),
(116, 'CQ-2026-0116', '2026-10-21 14:25:00', 'Alumbrado Público', 'Calle Cuprita, El Llano', -29.9620, -71.3380, TRUE, 'Circuito completo apagado en 3 cuadras consecutivas.', TRUE, 'Crítica', 'Asignada', 'foto_116.jpg', 2),
(117, 'CQ-2026-0117', '2026-10-21 15:40:00', 'Parques y Jardines', 'Av. Jose Joaquín Pérez, Guayacán', -29.9700, -71.3500, TRUE, 'Arbol con peligro de caída sobre tendido eléctrico.', TRUE, 'Crítica', 'En_Espera', 'foto_117.jpg', 3),
(118, 'CQ-2026-0118', '2026-10-21 16:55:00', 'Operaciones', 'Calle Portugal, Las Torres', -29.9650, -71.2890, TRUE, 'Lomo de toro desgastado sin pintura reflectante.', TRUE, 'Rutina', 'Ingresada', 'foto_118.jpg', 4),
(119, 'CQ-2026-0119', '2026-10-21 17:30:00', 'Aseo', 'Sector Cuatro Esquinas, La Serena', -29.9250, -71.2600, FALSE, 'Desechos biológicos dejados en la playa en sector La Serena.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_119.jpg', 1),
(120, 'CQ-2026-0120', '2026-10-22 08:00:00', 'Aseo', 'Av. El Cucharcillo, Punta Mira Sur', -29.9910, -71.3300, TRUE, 'Basural clandestino en terreno eriazo comunal.', TRUE, 'Rutina', 'Resuelta', 'foto_120.jpg', 1),
(121, 'CQ-2026-0121', '2026-10-22 09:15:00', 'Alumbrado Público', 'Calle Urmeneta, Barrio Inglés', -29.9530, -71.3375, TRUE, 'Farola patrimonial quebrada en paseo peatonal.', TRUE, 'Rutina', 'En_Espera', 'foto_121.jpg', 2),
(122, 'CQ-2026-0122', '2026-10-22 10:30:00', 'Parques y Jardines', 'Paseo Muelle Prat', -29.9510, -71.3390, TRUE, 'Jardineras destruidas por vandalismo.', TRUE, 'Rutina', 'Ingresada', 'foto_122.jpg', 3),
(123, 'CQ-2026-0123', '2026-10-22 11:45:00', 'Operaciones', 'Av. Darío Salas, Tierras Blancas', -29.9690, -71.2810, TRUE, 'Rejilla de sumidero de aguas lluvias rota.', TRUE, 'Crítica', 'Asignada', 'foto_123.jpg', 4),
(124, 'CQ-2026-0124', '2026-10-22 12:50:00', 'Aseo', 'Playa Changa Norte', -29.9570, -71.3300, TRUE, 'Restos de mallas pesqueras varadas en la orilla.', TRUE, 'Rutina', 'Resuelta', 'foto_124.jpg', 1),
(125, 'CQ-2026-0125', '2026-10-22 14:10:00', 'Alumbrado Público', 'Av. Pampa Central, Las Torres', -29.9670, -71.2850, TRUE, 'Foco sulfatado no enciende de noche.', TRUE, 'Rutina', 'En_Espera', 'foto_125.jpg', 2),
(126, 'CQ-2026-0126', '2026-10-22 15:20:00', 'Aseo', 'Aguas del Valle Private Property', -29.9540, -71.3310, TRUE, 'Reclamo sobre medidor de agua potable roto.', FALSE, 'Rutina', 'Descartada_OIRS', 'foto_126.jpg', 1),
(127, 'CQ-2026-0127', '2026-10-22 16:30:00', 'Parques y Jardines', 'Av. La Cantera, Rotonda', -29.9720, -71.3050, TRUE, 'Césped sobrecrecido dificulta visibilidad de conductores.', TRUE, 'Crítica', 'Asignada', 'foto_127.jpg', 3),
(128, 'CQ-2026-0128', '2026-10-22 17:40:00', 'Operaciones', 'Calle Pinto esq. Las Heras', -29.9560, -71.3360, TRUE, 'Señal de Ceda el Paso doblada tras choque.', TRUE, 'Rutina', 'Resuelta', 'foto_128.jpg', 4),
(129, 'CQ-2026-0129', '2026-10-22 18:50:00', 'Aseo', 'Camino a Huachalalume', -29.9850, -71.2700, TRUE, 'Bolsas de basura esparcidas en la vía pública.', TRUE, 'Rutina', 'Ingresada', 'foto_129.jpg', 1),
(130, 'CQ-2026-0130', '2026-10-23 08:10:00', 'Alumbrado Público', 'Calle Pedro de Valdivia, Guayacán', -29.9720, -71.3480, TRUE, 'Cable energizado colgando a baja altura.', TRUE, 'Crítica', 'Asignada', 'foto_130.jpg', 2),
(131, 'CQ-2026-0131', '2026-10-23 09:20:00', 'Parques y Jardines', 'Plaza Guanaqueros, Guanaqueros', -30.1980, -71.4210, TRUE, 'Juegos infantiles con pernos sueltos.', TRUE, 'Crítica', 'Resuelta', 'foto_131.jpg', 3),
(132, 'CQ-2026-0132', '2026-10-23 10:30:00', 'Operaciones', 'Av. Tongoy, Tongoy Centro', -30.2540, -71.4920, TRUE, 'Eventón en calzada de acceso a la caleta.', TRUE, 'Crítica', 'En_Espera', 'foto_132.jpg', 4),
(133, 'CQ-2026-0133', '2026-10-23 11:40:00', 'Aseo', 'Sector Las Compañías, La Serena', -29.8850, -71.2420, FALSE, 'Carcasa de electrodoméstico tirada en la calle.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_133.jpg', 1),
(134, 'CQ-2026-0134', '2026-10-23 12:50:00', 'Aseo', 'Avenida del Mar 2000, La Serena', -29.9120, -71.2700, FALSE, 'Botellas de vidrio en la playa cerca del Faro.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_134.jpg', 1),
(135, 'CQ-2026-0135', '2026-10-23 14:00:00', 'Alumbrado Público', 'Calle Regimiento 2, San Juan', -29.9730, -71.3250, TRUE, 'Poste de madera podrido en la base.', TRUE, 'Crítica', 'Ingresada', 'foto_135.jpg', 2),
(136, 'CQ-2026-0136', '2026-10-23 15:10:00', 'Parques y Jardines', 'Mirador de los Navegantes, Parte Alta', -29.9570, -71.3480, TRUE, 'Sillas y bancas de madera astilladas.', TRUE, 'Rutina', 'Resuelta', 'foto_136.jpg', 3),
(137, 'CQ-2026-0137', '2026-10-23 16:20:00', 'Operaciones', 'Av. El Bosque, San Juan', -29.9780, -71.3280, TRUE, 'Demarcación de paso peatonal totalmente borrada.', TRUE, 'Rutina', 'En_Espera', 'foto_137.jpg', 4),
(138, 'CQ-2026-0138', '2026-10-23 17:30:00', 'Aseo', 'Playa La Herradura, Sector Club de Yates', -29.9810, -71.3520, TRUE, 'Cajas de cartón abandonadas tras evento privado.', TRUE, 'Rutina', 'Ingresada', 'foto_138.jpg', 1),
(139, 'CQ-2026-0139', '2026-10-24 08:00:00', 'Alumbrado Público', 'Calle Sc车型, Sindempart', -29.9840, -71.3420, TRUE, 'Proyector led de multicancha dañado.', TRUE, 'Rutina', 'Asignada', 'foto_139.jpg', 2),
(140, 'CQ-2026-0140', '2026-10-24 09:10:00', 'Parques y Jardines', 'Av. Gerónimo Méndez, Zona Industrial', -29.9620, -71.3180, TRUE, 'Palmera seca con riesgo de desprendimiento de ramas.', TRUE, 'Crítica', 'Resuelta', 'foto_140.jpg', 3),
(141, 'CQ-2026-0141', '2026-10-24 10:20:00', 'Operaciones', 'Calle Santiago, Tierras Blancas', -29.9660, -71.2820, TRUE, 'Pavimento levantado por raíces de árbol antiguo.', TRUE, 'Crítica', 'Ingresada', 'foto_141.jpg', 4),
(142, 'CQ-2026-0142', '2026-10-24 11:30:00', 'Aseo', 'Sector Panul, Ruta 5 Sur km 455', -30.0210, -71.3720, TRUE, 'Vertimiento ilegal de escombros de construcción.', TRUE, 'Crítica', 'En_Espera', 'foto_142.jpg', 1),
(143, 'CQ-2026-0143', '2026-10-24 12:40:00', 'Alumbrado Público', 'Av. Pampa, La Serena', -29.9190, -71.2480, FALSE, 'Luminaria apagada cerca de Mall Plaza La Serena.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_143.jpg', 2),
(144, 'CQ-2026-0144', '2026-10-24 13:50:00', 'Parques y Jardines', 'Plaza Las Rocas, La Herradura', -29.9860, -71.3560, TRUE, 'Cactus destruidos en franja costera protegida.', TRUE, 'Rutina', 'Ingresada', 'foto_144.jpg', 3),
(145, 'CQ-2026-0145', '2026-10-24 15:00:00', 'Operaciones', 'Av. Changas, Peñuelas', -29.9410, -71.3020, TRUE, 'Tapa de cámara telefónica sin seguro en la acera.', TRUE, 'Crítica', 'Asignada', 'foto_145.jpg', 4),
(146, 'CQ-2026-0146', '2026-10-24 16:10:00', 'Aseo', 'Calle Portales, Centro Coquimbo', -29.9545, -71.3365, TRUE, 'Contenedor metálico de basura chocado e inutilizable.', TRUE, 'Rutina', 'Resuelta', 'foto_146.jpg', 1),
(147, 'CQ-2026-0147', '2026-10-24 17:20:00', 'Alumbrado Público', 'Calle Riquelme, El Llano', -29.9610, -71.3390, TRUE, 'Foco encendido 24 horas continuas (falla fotocelda).', TRUE, 'Rutina', 'En_Espera', 'foto_147.jpg', 2),
(148, 'CQ-2026-0148', '2026-10-25 08:30:00', 'Parques y Jardines', 'Paseo Costero Tongoy', -30.2580, -71.4900, TRUE, 'Arbolitos reciéntemente plantados secándose por falta de riego.', TRUE, 'Rutina', 'Ingresada', 'foto_148.jpg', 3),
(149, 'CQ-2026-0149', '2026-10-25 09:40:00', 'Operaciones', 'Camino a Tambillos km 10', -30.0810, -71.2100, TRUE, 'Derrumbe menor de rocas en borde de cerro.', TRUE, 'Crítica', 'Resuelta', 'foto_149.jpg', 4),
(150, 'CQ-2026-0150', '2026-10-25 10:50:00', 'Aseo', 'Sector Gabriel González Videla, La Serena', -29.9080, -71.2410, FALSE, 'Llantas abandonadas en canaleta de regadío.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_150.jpg', 1),
(151, 'CQ-2026-0151', '2026-10-25 12:00:00', 'Alumbrado Público', 'Calle Aníbal Pinto, Centro', -29.9555, -71.3382, TRUE, 'Cortocircuito de cables en caja de registro sobre poste.', TRUE, 'Crítica', 'Asignada', 'foto_151.jpg', 2),
(152, 'CQ-2026-0152', '2026-10-25 13:10:00', 'Parques y Jardines', 'Plaza de las Américas, Tierras Blancas', -29.9675, -71.2840, TRUE, 'Graffitis en monumentos y bancos de la plaza.', TRUE, 'Rutina', 'En_Espera', 'foto_152.jpg', 3),
(153, 'CQ-2026-0153', '2026-10-25 14:20:00', 'Operaciones', 'Av. Suecia, San Juan', -29.9725, -71.3230, TRUE, 'Reductores de velocidad de goma desprendidos parcialmente.', TRUE, 'Rutina', 'Ingresada', 'foto_153.jpg', 4),
(154, 'CQ-2026-0154', '2026-10-25 15:30:00', 'Aseo', 'Pasaje Los Changos, Parte Alta', -29.9595, -71.3425, TRUE, 'Perros vagabundos rompieron sacos de basura en la vía.', TRUE, 'Rutina', 'Resuelta', 'foto_154.jpg', 1),
(155, 'CQ-2026-0155', '2026-10-25 16:40:00', 'Alumbrado Público', 'Calle Los Clarines, Sindempart', -29.9835, -71.3445, TRUE, 'Luminaria peatonal tapada por follaje espeso.', TRUE, 'Rutina', 'En_Espera', 'foto_155.jpg', 2),
(156, 'CQ-2026-0156', '2026-10-25 17:50:00', 'Parques y Jardines', 'Av. El Teniente, Zona Industrial', -29.9635, -71.3155, TRUE, 'Tronco caído tras fuertes vientos del sudoeste.', TRUE, 'Crítica', 'Asignada', 'foto_156.jpg', 3),
(157, 'CQ-2026-0157', '2026-10-26 08:15:00', 'Operaciones', 'Calle Argomedo, Centro', -29.9525, -71.3368, TRUE, 'Hoyo en vereda provoca caída de adultos mayores.', TRUE, 'Crítica', 'Resuelta', 'foto_157.jpg', 4),
(158, 'CQ-2026-0158', '2026-10-26 09:25:00', 'Aseo', 'Sector Chañaral Alto, Vicuña Road', -30.0120, -70.9800, FALSE, 'Contenedor lleno fuera de los límites de Coquimbo.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_158.jpg', 1),
(159, 'CQ-2026-0159', '2026-10-26 10:35:00', 'Aseo', 'CGE Subestación Eléctrica', -29.9620, -71.3200, TRUE, 'Transformador con fuga de aceite en propiedad CGE.', FALSE, 'Crítica', 'Descartada_OIRS', 'foto_159.jpg', 1),
(160, 'CQ-2026-0160', '2026-10-26 11:45:00', 'Alumbrado Público', 'Calle Borgoño, Parte Alta', -29.9565, -71.3440, TRUE, 'Foco destruido por pedrada vandalica.', TRUE, 'Rutina', 'Ingresada', 'foto_160.jpg', 2),
(161, 'CQ-2026-0161', '2026-10-26 12:55:00', 'Parques y Jardines', 'Plaza Guacolda, El Llano', -29.9630, -71.3360, TRUE, 'Juegos de madera podridos y con astillas expuestas.', TRUE, 'Crítica', 'Asignada', 'foto_161.jpg', 3),
(162, 'CQ-2026-0162', '2026-10-26 14:05:00', 'Operaciones', 'Calle Alessandri, Bosque San Carlos', -29.9880, -71.2950, TRUE, 'Señalización vial girada de sentido opuesto.', TRUE, 'Rutina', 'En_Espera', 'foto_162.jpg', 4),
(163, 'CQ-2026-0163', '2026-10-26 15:15:00', 'Aseo', 'Av. Las Olas, Peñuelas', -29.9380, -71.2920, TRUE, 'Restos de carpas abandonadas en la playa.', TRUE, 'Rutina', 'Resuelta', 'foto_163.jpg', 1),
(164, 'CQ-2026-0164', '2026-10-26 16:25:00', 'Alumbrado Público', 'Calle Cienfuegos, La Serena', -29.9010, -71.2500, FALSE, 'Poste de luz roto cerca de la Recova.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_164.jpg', 2),
(165, 'CQ-2026-0165', '2026-10-26 17:35:00', 'Parques y Jardines', 'Paseo los Héroes, Guayacán', -29.9715, -71.3490, TRUE, 'Matorrales demasiado altos tapan señalética.', TRUE, 'Rutina', 'Ingresada', 'foto_165.jpg', 3),
(166, 'CQ-2026-0166', '2026-10-27 08:05:00', 'Operaciones', 'Calle Los Naranjos, Sindempart', -29.9815, -71.3430, TRUE, 'Grieta amplia en pavimento asfáltico.', TRUE, 'Rutina', 'En_Espera', 'foto_166.jpg', 4),
(167, 'CQ-2026-0167', '2026-10-27 09:15:00', 'Aseo', 'Sector La Herradura Alta', -29.9890, -71.3480, TRUE, 'Restos de poda tirados en esquina de avenida.', TRUE, 'Rutina', 'Resuelta', 'foto_167.jpg', 1),
(168, 'CQ-2026-0168', '2026-10-27 10:25:00', 'Alumbrado Público', 'Av. Los Changos, Parte Alta', -29.9580, -71.3460, TRUE, 'Tendido eléctrico con chispas periódicas.', TRUE, 'Crítica', 'Asignada', 'foto_168.jpg', 2),
(169, 'CQ-2026-0169', '2026-10-27 11:35:00', 'Parques y Jardines', 'Plaza Las Metalias, Tierras Blancas', -29.9655, -71.2860, TRUE, 'Banca metálica destruida por choque de moto.', TRUE, 'Rutina', 'Ingresada', 'foto_169.jpg', 3),
(170, 'CQ-2026-0170', '2026-10-27 12:45:00', 'Operaciones', 'Ruta 43 esq. Acharán Arce', -29.9820, -71.2890, TRUE, 'Barrera de contención dañada tras accidente.', TRUE, 'Crítica', 'Resuelta', 'foto_170.jpg', 4),
(171, 'CQ-2026-0171', '2026-10-27 13:55:00', 'Aseo', 'Sector La Serena Zoo Area', -29.9300, -71.2100, FALSE, 'Microbasural en ladera de cerro fuera de comuna.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_171.jpg', 1),
(172, 'CQ-2026-0172', '2026-10-27 15:05:00', 'Alumbrado Público', 'Calle Freire, Centro Coquimbo', -29.9540, -71.3378, TRUE, 'Luminaria colgante a punto de caer.', TRUE, 'Crítica', 'Asignada', 'foto_172.jpg', 2),
(173, 'CQ-2026-0173', '2026-10-27 16:15:00', 'Parques y Jardines', 'Plaza Viviendas Dignas, San Juan', -29.9740, -71.3260, TRUE, 'Arboles secos requieren retiro urgente.', TRUE, 'Rutina', 'En_Espera', 'foto_173.jpg', 3),
(174, 'CQ-2026-0174', '2026-10-27 17:25:00', 'Operaciones', 'Pasaje Los Pinos, Bosque San Carlos', -29.9870, -71.2980, TRUE, 'Calle sin pavimentar con surcos profundos por lluvia.', TRUE, 'Crítica', 'Ingresada', 'foto_174.jpg', 4),
(175, 'CQ-2026-0175', '2026-10-27 18:35:00', 'Aseo', 'Av. El Sauce esq. Los Álamos', -29.9810, -71.3350, TRUE, 'Escombros obstruyen paso de personas con discapacidad.', TRUE, 'Crítica', 'Resuelta', 'foto_175.jpg', 1),
(176, 'CQ-2026-0176', '2026-10-28 08:10:00', 'Alumbrado Público', 'Av. Costanera Peñuelas', -29.9350, -71.2960, TRUE, 'Tres farolas apagadas en sector de restoranes.', TRUE, 'Rutina', 'En_Espera', 'foto_176.jpg', 2),
(177, 'CQ-2026-0177', '2026-10-28 09:20:00', 'Parques y Jardines', 'Mirador La Herradura', -29.9840, -71.3590, TRUE, 'Vegetación seca con riesgo de incendio forestal.', TRUE, 'Crítica', 'Asignada', 'foto_177.jpg', 3),
(178, 'CQ-2026-0178', '2026-10-28 10:30:00', 'Operaciones', 'Calle Aldunate esq. Las Heras', -29.9538, -71.3390, TRUE, 'Tapa de alcantarilla hace ruidos fuertes al pasar autos.', TRUE, 'Rutina', 'Ingresada', 'foto_178.jpg', 4),
(179, 'CQ-2026-0179', '2026-10-28 11:40:00', 'Aseo', 'Sector Ovalle Central Highway', -30.5900, -71.2000, FALSE, 'Basura acumulada en paradero de buses en Ovalle.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_179.jpg', 1),
(180, 'CQ-2026-0180', '2026-10-28 12:50:00', 'Alumbrado Público', 'Calle René Schneider, Baquedano', -29.9515, -71.3330, TRUE, 'Foco caído sobre techo de casa de vecino.', TRUE, 'Crítica', 'Resuelta', 'foto_180.jpg', 2),
(181, 'CQ-2026-0181', '2026-10-28 14:00:00', 'Parques y Jardines', 'Plaza Las Palmeras, La Herradura', -29.9825, -71.3530, TRUE, 'Riego botan agua hacia la calle en vez del césped.', TRUE, 'Rutina', 'En_Espera', 'foto_181.jpg', 3),
(182, 'CQ-2026-0182', '2026-10-28 15:10:00', 'Operaciones', 'Av. Pedro Montt, Las Torres', -29.9685, -71.2870, TRUE, 'Bache en viraje de micros de locomoción colectiva.', TRUE, 'Crítica', 'Asignada', 'foto_182.jpg', 4),
(183, 'CQ-2026-0183', '2026-10-28 16:20:00', 'Aseo', 'Playa Changa Sur', -29.9630, -71.3340, TRUE, 'Peces muertos y bolsas de plástico acumuladas.', TRUE, 'Rutina', 'Ingresada', 'foto_183.jpg', 1),
(184, 'CQ-2026-0184', '2026-10-28 17:30:00', 'Alumbrado Público', 'Av. El Rosario esq. Las Tepas', -29.9830, -71.3460, TRUE, 'Foco intermitente molesta ventana residencial.', TRUE, 'Rutina', 'Resuelta', 'foto_184.jpg', 2),
(185, 'CQ-2026-0185', '2026-10-28 18:40:00', 'Parques y Jardines', 'Plaza las Palmeras, San Juan', -29.9755, -71.3245, TRUE, 'Rama pesada a punto de desgajarse.', TRUE, 'Crítica', 'Asignada', 'foto_185.jpg', 3),
(186, 'CQ-2026-0186', '2026-10-28 19:50:00', 'Operaciones', 'Calle La Marina, Guayacán', -29.9705, -71.3495, TRUE, 'Falta solera en esquina con riesgo de derrumbe de vereda.', TRUE, 'Rutina', 'Ingresada', 'foto_186.jpg', 4),
(187, 'CQ-2026-0187', '2026-10-28 20:10:00', 'Aseo', 'Sector El Milagro, La Serena', -29.9350, -71.2380, FALSE, 'Bolsas colgadas en reja fuera de comuna.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_187.jpg', 1),
(188, 'CQ-2026-0188', '2026-10-28 20:30:00', 'Alumbrado Público', 'Calle Bilbao esq. Varela', -29.9548, -71.3362, TRUE, 'Caja eléctrica abierta en la base del poste.', TRUE, 'Crítica', 'En_Espera', 'foto_188.jpg', 2),
(189, 'CQ-2026-0189', '2026-10-28 20:50:00', 'Parques y Jardines', 'Paseo de las Camelias, Sindempart', -29.9855, -71.3415, TRUE, 'Césped seco por falta de mantención.', TRUE, 'Rutina', 'Resuelta', 'foto_189.jpg', 3),
(190, 'CQ-2026-0190', '2026-10-28 21:10:00', 'Operaciones', 'Av. Manuel Peñafiel, San Juan', -29.9770, -71.3215, TRUE, 'Hoyo grande frente a paradero de buses.', TRUE, 'Crítica', 'Asignada', 'foto_190.jpg', 4),
(191, 'CQ-2026-0191', '2026-10-28 21:30:00', 'Aseo', 'Calle Aníbal Pinto 450, Centro', -29.9542, -71.3385, TRUE, 'Desechos orgánicos de restaurante en la vereda.', TRUE, 'Rutina', 'Ingresada', 'foto_191.jpg', 1),
(192, 'CQ-2026-0192', '2026-10-28 21:50:00', 'Alumbrado Público', 'Av. Eje Cisternas, La Serena', -29.9200, -71.2450, FALSE, 'Poste sin luz en ciclovía de La Serena.', FALSE, 'Rutina', 'Descartada_GPS', 'foto_192.jpg', 2),
(193, 'CQ-2026-0193', '2026-10-28 22:10:00', 'Parques y Jardines', 'Plaza de Guanaqueros', -30.1975, -71.4220, TRUE, 'Palmera con hojas secas cayendo sobre juegos.', TRUE, 'Rutina', 'Resuelta', 'foto_193.jpg', 3),
(194, 'CQ-2026-0194', '2026-10-28 22:30:00', 'Operaciones', 'Calle Balmaceda, Tongoy', -30.2550, -71.4930, TRUE, 'Tapa de alcantarilla hundida.', TRUE, 'Crítica', 'En_Espera', 'foto_194.jpg', 4),
(195, 'CQ-2026-0195', '2026-10-28 22:50:00', 'Aseo', 'Población San Juan, Pasaje 4', -29.9712, -71.3228, TRUE, 'Muebles viejos tirados en la esquina.', TRUE, 'Rutina', 'Ingresada', 'foto_195.jpg', 1),
(196, 'CQ-2026-0196', '2026-10-28 23:10:00', 'Alumbrado Público', 'Calle Sierra, Parte Alta', -29.9575, -71.3435, TRUE, 'Chispas constante en transformador.', TRUE, 'Crítica', 'Asignada', 'foto_196.jpg', 2),
(197, 'CQ-2026-0197', '2026-10-28 23:25:00', 'Parques y Jardines', 'Plaza las Américas, Tierras Blancas', -29.9670, -71.2835, TRUE, 'Flores pisoteadas y manguera destruida.', TRUE, 'Rutina', 'Resuelta', 'foto_197.jpg', 3),
(198, 'CQ-2026-0198', '2026-10-28 23:40:00', 'Operaciones', 'Calle Regimiento, Peñuelas', -29.9390, -71.2990, TRUE, 'Lomo de toro de plástico roto con clavos expuestos.', TRUE, 'Crítica', 'En_Espera', 'foto_198.jpg', 4),
(199, 'CQ-2026-0199', '2026-10-28 23:50:00', 'Aseo', 'Sector Pan de Azúcar, Ruta 43', -29.9980, -71.2650, TRUE, 'Sacos de cemento quemados en la berma.', TRUE, 'Rutina', 'Ingresada', 'foto_199.jpg', 1),
(200, 'CQ-2026-0200', '2026-10-28 23:59:00', 'Alumbrado Público', 'Calle Videla esq. Melgarejo', -29.9560, -71.3380, TRUE, 'Luminaria apagada en cruce peatonal concurridos.', TRUE, 'Crítica', 'Asignada', 'foto_200.jpg', 2);

-- Ajustar la secuencia SERIAL al id máximo
SELECT setval('incidencias_id_incidencia_seq', (SELECT MAX(id_incidencia) FROM incidencias));

-- ORDENES DE TRABAJO INICIALES ASOCIADAS A INCIDENCIAS RESUELTAS Y ASIGNADAS
INSERT INTO ordenes_trabajo (id_incidencia, id_cuadrilla, fecha_asignacion, fecha_cierre, foto_final_url, comentario_cierre) VALUES
(101, 1, '2026-10-24 10:00:00', '2026-10-24 14:30:00', 'limpieza_completada_aldunate.jpg', 'Se retiraron 1.8 toneladas de residuos con camión recolector y se despejó la vía.'),
(102, 2, '2026-10-25 12:00:00', NULL, NULL, NULL),
(106, 1, '2026-10-20 10:30:00', '2026-10-20 12:00:00', 'foto_cierre_106.jpg', 'Retiro de escombros completado exitosamente.'),
(108, 3, '2026-10-20 13:00:00', NULL, NULL, NULL),
(109, 4, '2026-10-20 14:30:00', '2026-10-20 16:00:00', 'foto_cierre_109.jpg', 'Tapa reubicada y sellada con hormigón rápido.'),
(112, 2, '2026-10-21 10:00:00', NULL, NULL, NULL),
(114, 4, '2026-10-21 12:00:00', '2026-10-21 13:00:00', 'foto_cierre_114.jpg', 'Bache tapado con asfalto en frío.'),
(116, 2, '2026-10-21 15:00:00', NULL, NULL, NULL),
(120, 1, '2026-10-22 08:30:00', '2026-10-22 10:30:00', 'foto_cierre_120.jpg', 'Limpieza de terreno con maquinaria pesada.'),
(123, 4, '2026-10-22 12:00:00', NULL, NULL, NULL),
(124, 1, '2026-10-22 13:00:00', '2026-10-22 14:00:00', 'foto_cierre_124.jpg', 'Retiro de redes pesqueras en borde costero.'),
(127, 3, '2026-10-22 17:00:00', NULL, NULL, NULL),
(128, 4, '2026-10-22 18:00:00', '2026-10-22 18:30:00', 'foto_cierre_128.jpg', 'Señal reemplazada por una nueva.'),
(130, 2, '2026-10-23 08:30:00', NULL, NULL, NULL),
(131, 3, '2026-10-23 09:30:00', '2026-10-23 10:30:00', 'foto_cierre_131.jpg', 'Reemplazo de pernos y fijación de juegos.'),
(136, 3, '2026-10-23 15:30:00', '2026-10-23 16:00:00', 'foto_cierre_136.jpg', 'Reparación de madera y lijado preventivo.'),
(139, 2, '2026-10-24 08:30:00', NULL, NULL, NULL),
(140, 3, '2026-10-24 09:30:00', '2026-10-24 11:00:00', 'foto_cierre_140.jpg', 'Poda de palmera y despeje de vía pública.'),
(145, 4, '2026-10-24 15:30:00', NULL, NULL, NULL),
(146, 1, '2026-10-24 16:30:00', '2026-10-24 17:30:00', 'foto_cierre_146.jpg', 'Contenedor reemplazado por uno nuevo de 1100L.'),
(149, 4, '2026-10-25 10:00:00', '2026-10-25 11:30:00', 'foto_cierre_149.jpg', 'Limpieza de calzada y retiro de rocas.'),
(151, 2, '2026-10-25 12:30:00', NULL, NULL, NULL),
(154, 1, '2026-10-25 16:00:00', '2026-10-25 16:30:00', 'foto_cierre_154.jpg', 'Barrido y desinfección de vereda.'),
(156, 3, '2026-10-25 18:00:00', NULL, NULL, NULL),
(157, 4, '2026-10-26 08:30:00', '2026-10-26 09:30:00', 'foto_cierre_157.jpg', 'Reparación de baldosa con mezcla cemento-arena.'),
(161, 3, '2026-10-26 13:00:00', NULL, NULL, NULL),
(163, 1, '2026-10-26 15:30:00', '2026-10-26 16:00:00', 'foto_cierre_163.jpg', 'Limpieza de zona de playa.'),
(168, 2, '2026-10-27 10:30:00', NULL, NULL, NULL),
(170, 4, '2026-10-27 13:00:00', '2026-10-27 14:00:00', 'foto_cierre_170.jpg', 'Barrera enderezada y ajustada.'),
(172, 2, '2026-10-27 15:30:00', NULL, NULL, NULL),
(175, 1, '2026-10-27 19:00:00', '2026-10-27 19:40:00', 'foto_cierre_175.jpg', 'Despeje total de vereda.'),
(177, 3, '2026-10-28 09:30:00', NULL, NULL, NULL),
(180, 2, '2026-10-28 13:00:00', '2026-10-28 14:00:00', 'foto_cierre_180.jpg', 'Foco retirado y asegurado en poste.'),
(182, 4, '2026-10-28 15:30:00', NULL, NULL, NULL),
(184, 2, '2026-10-28 17:40:00', '2026-10-28 18:00:00', 'foto_cierre_184.jpg', 'Fotocelda reemplazada.'),
(185, 3, '2026-10-28 19:00:00', NULL, NULL, NULL),
(189, 3, '2026-10-28 21:00:00', '2026-10-28 21:30:00', 'foto_cierre_189.jpg', 'Reactivación de sistema de riego por goteo.'),
(190, 4, '2026-10-28 21:20:00', NULL, NULL, NULL),
(193, 3, '2026-10-28 22:20:00', '2026-10-28 22:40:00', 'foto_cierre_193.jpg', 'Poda y retiro de palmas secas.'),
(196, 2, '2026-10-28 23:15:00', NULL, NULL, NULL),
(197, 3, '2026-10-28 23:30:00', '2026-10-28 23:45:00', 'foto_cierre_197.jpg', 'Reparación de manguera de riego.'),
(200, 2, '2026-10-29 00:00:00', NULL, NULL, NULL);

SELECT setval('ordenes_trabajo_id_orden_seq', (SELECT MAX(id_orden) FROM ordenes_trabajo));