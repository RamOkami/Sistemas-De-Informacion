-- ============================================================
-- ESTRUCTURA DE LA BASE DE DATOS (5 TABLAS RELACIONALES)
-- ============================================================

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
-- POBLADO INICIAL DE DATOS (MOCKUP COQUIMBO)
-- ============================================================

INSERT INTO departamentos (nombre_depto, encargado) VALUES
('Aseo y Ornato', 'Carlos Mendoza'),
('Alumbrado Público', 'Roberto Silva'),
('Parques y Jardines', 'Elena Torres'),
('Operaciones y Calzadas', 'Hugo Ramos');

INSERT INTO cuadrillas (id_departamento, codigo_cuadrilla, responsable, disponible) VALUES
(1, 'ASEO-01', 'Juan Pérez', TRUE),
(2, 'ALUM-01', 'Marcos Araya', TRUE),
(3, 'PARQ-01', 'Lucía Gómez', TRUE),
(4, 'OPER-02', 'Esteban Morales', TRUE);

INSERT INTO usuarios (nombre, correo, password, rol, activo) VALUES
('Vecino Coquimbo', 'vecino.coquimbo@gmail.com', 'pass123', 'Ciudadano', TRUE),
('Operador OIRS', 'oirs@coquimbo.cl', 'pass123', 'Operador_OIRS', TRUE),
('Coordinador General', 'coordinador@coquimbo.cl', 'pass123', 'Coordinador', TRUE),
('Juan Pérez (Aseo)', 'aseo01@coquimbo.cl', 'pass123', 'Cuadrilla', TRUE);

INSERT INTO incidencias 
(id_incidencia, codigo_seguimiento, fecha_ingreso, categoria, sector, latitud, longitud, dentro_de_coquimbo, descripcion, jurisdiccion_valida, gravedad, estado, foto_inicial_url, id_departamento)
VALUES
(101, 'CQ-2026-0101', '2026-10-24 09:15:00', 'Aseo', 'Calle Aldunate 840, Centro Coquimbo', -29.9533, -71.3395, TRUE, 'Microbasural acumulado en esquina peatonal con restos de muebles y bolsas rotas.', TRUE, 'Rutina', 'Resuelta', 'microbasural_aldunate.jpg', 1),
(102, 'CQ-2026-0102', '2026-10-25 11:30:00', 'Alumbrado Público', 'Av. Las Torres esq. Talca, Tierras Blancas', -29.9681, -71.2829, TRUE, 'Poste de alumbrado público apagado y con cables sueltos frente a área verde vecinal.', TRUE, 'Crítica', 'Asignada', 'poste_apagado_tierras_blancas.jpg', 2),
(103, 'CQ-2026-0103', '2026-10-25 16:45:00', 'Parques y Jardines', 'Plaza de Armas de Coquimbo', -29.9541, -71.3389, TRUE, 'Rama de árbol quebrada sobre banca metálica requiere poda preventiva.', TRUE, 'Rutina', 'En_Espera', 'rama_plaza_armas.png', 3),
(104, 'CQ-2026-0104', '2026-10-26 08:20:00', 'Operaciones', 'Av. Costanera 1420, Sector Playa Changa', -29.9610, -71.3315, TRUE, 'Bache profundo en calzada principal que pone en riesgo a ciclistas y vehículos.', TRUE, 'Crítica', 'Ingresada', 'bache_costanera.jpg', 4),
(105, 'CQ-2026-0105', '2026-10-23 18:10:00', 'Aseo', 'Av. Francisco de Aguirre, La Serena', -29.9027, -71.2519, FALSE, 'Escombros dejados en vereda norte fuera de jurisdicción comunal.', FALSE, 'Rutina', 'Descartada_GPS', 'escombros_limite.jpg', 1);

-- Ajustar la secuencia SERIAL tras insertar IDs fijos
SELECT setval('incidencias_id_incidencia_seq', (SELECT MAX(id_incidencia) FROM incidencias));

INSERT INTO ordenes_trabajo (id_incidencia, id_cuadrilla, fecha_asignacion, fecha_cierre, foto_final_url, comentario_cierre) VALUES
(101, 1, '2026-10-24 10:00:00', '2026-10-24 14:30:00', 'limpieza_completada_aldunate.jpg', 'Se retiraron 1.8 toneladas de residuos con camión recolector y se despejó la vía.'),
(102, 2, '2026-10-25 12:00:00', NULL, NULL, NULL);