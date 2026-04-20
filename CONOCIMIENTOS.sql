USE farmacia 

Este sistema administra un laboratorio farmacéutico, principios activos, medicamentos, materias primas, lotes de producción y control de calidad.


-- Vistas:

-- 1. V_LotesEnProduccion: Muestra todos los lotes actualmente en producción.

CREATE VIEW V_LotesEnProduccion AS
SELECT 
    numero_lote,
    ID_medicamento,
    fecha_fabricacion,
    cantidad_producida,
    fecha_caducidad,
    estado_lote
FROM lote_produccion
WHERE estado_lote = 'En proceso';

SELECT * FROM V_LotesEnProduccion;

UPDATE lote_produccion
SET estado_lote = 'En proceso'
WHERE numero_lote = 'LOTE-2024-001';

-- 2. V_InventarioMateriasPrimas: 
-- Detalla el inventario de materias primas con caducidad.

CREATE VIEW V_Inventario_Materias_Primas AS
SELECT
    nombre,
    stock_actual,
    unidad_medida,
    fecha_caducidad,
    estado,
    DATEDIFF(fecha_caducidad, CURDATE()) AS dias_para_vencer
FROM materia_prima
ORDER BY fecha_caducidad ASC;

SELECT * FROM V_Inventario_Materias_Primas;

-- 3. V_ResultadosControlCalidad:
-- Resultados de control de calidad por lote y prueba.

CREATE VIEW V_ResultadosControlCalidad AS
SELECT
    cc.numero_lote,
    tp.nombre_prueba,
    cc.fecha_analisis,
    cc.resultados,
    cc.conformidad,
    e.nombre AS analista
FROM control_calidad cc
JOIN tipo_prueba tp ON cc.ID_tipo_prueba = tp.ID
JOIN empleado e ON cc.ID_analista = e.ID;

SELECT * FROM V_ResultadosControlCalidad;

-- 4. V_TrazabilidadMedicamento: 
-- Trazabilidad completa de un medicamento desde materias primas.

CREATE VIEW V_TrazabilidadMedicamento AS
SELECT
	lp.numero_lote,
	m.nombre_comercial,
	lp.fecha_fabricacion,
	lp.estado_lote,
	t.fecha_operacion,
	t.ubicacion,
	e.nombre AS responsable
FROM trazabilidad t
JOIN lote_produccion lp ON t.numero_lote = lp.numero_lote
JOIN medicamento m ON lp.ID_medicamento = m.ID
JOIN empleado e ON t.ID_responsable = e.ID;

SELECT * FROM V_TrazabilidadMedicamento

-- 5. V_EstudioEstabilidadActivos: 
-- Estado de estudios de estabilidad por medicamento.

CREATE VIEW V_EstudioEstabilidadActivos AS
SELECT
	m.nombre_comercial,
	ee.temperatura,
	ee.humedad,
	ee.fecha_inicio,
	ee.fecha_fin,
	ee.monitoreo,
	DATEDIFF(ee.fecha_fin, CURDATE()) AS dias_restantes
FROM estudio_estabilidad ee
JOIN medicamento m ON ee.ID_medicamento = m.ID;

SELECT * FROM V_EstudioEstabilidadActivos

-- Procedimientos Almacenados:

-- 1. CrearLoteProduccion:
 -- Crea un nuevo lote de producción verificando disponibilidad de materias primas.


CREATE PROCEDURE CrearLoteProduccion(
IN p_numero_lote VARCHAR(40),
IN p_ID_materia INT,
IN p_cantidad DECIMAL(12,3)
)
BEGIN
IF (SELECT stock_actual FROM materia_prima WHERE ID = p_ID_materia) >= p_cantidad THEN
UPDATE lote_produccion
SET estado_lote = 'En proceso'
WHERE numero_lote = p_numero_lote;
UPDATE materia_prima
SET stock_actual = stock_actual - p_cantidad
WHERE ID = p_ID_materia;
SELECT 'lote creado' AS mensaje;
ELSE
SELECT 'no hay stock suficiente' AS mensaje;
END IF;
END //

CALL CrearLoteProduccion('LOTE-2024-002', 1, 22.500);

-- 2. RegistrarControlCalidad: 
-- Registra pruebas de control de calidad para un lote.

CREATE PROCEDURE RegistrarControlCalidad(
IN p_numero_lote VARCHAR(40),
IN p_ID_tipo_prueba INT,
IN p_resultados TEXT,
IN p_ID_analista INT,
IN p_conformidad TINYINT(1)
)
BEGIN
INSERT INTO control_calidad(numero_lote, fecha_analisis, ID_tipo_prueba, resultados, ID_analista, conformidad)
VALUES(p_numero_lote, CURDATE(), p_ID_tipo_prueba, p_resultados, p_ID_analista, p_conformidad);
SELECT 'control de calidad registrado' AS mensaje;
END //

CALL RegistrarControlCalidad('LOTE-2024-001', 1, 'todo bien', 2, 1);

-- 3. GestionarEstabilidad: 
-- Gestiona estudios de estabilidad para medicamentos.

CREATE PROCEDURE GestionarEstabilidad(
IN p_ID_medicamento INT,
IN p_temperatura DECIMAL(5,2),
IN p_humedad DECIMAL(5,2),
IN p_fecha_inicio DATE,
IN p_fecha_fin DATE
)
BEGIN
INSERT INTO estudio_estabilidad(ID_medicamento, temperatura, humedad, fecha_inicio, fecha_fin)
VALUES(p_ID_medicamento, p_temperatura, p_humedad, p_fecha_inicio, p_fecha_fin);
SELECT 'estudio de estabilidad creado' AS mensaje;
END //

CALL GestionarEstabilidad(1, 25.00, 60.00, '2024-01-01', '2025-01-01');

-- 4. AprobarLiberacionLote: 
-- Aprueba la liberación de un lote tras verificar todos los controles.

CREATE PROCEDURE AprobarLiberacionLote(
IN p_numero_lote VARCHAR(40)
)
BEGIN
IF (SELECT conformidad FROM control_calidad WHERE numero_lote = p_numero_lote LIMIT 1) = 1 THEN
UPDATE lote_produccion
SET estado_lote = 'Liberado'
WHERE numero_lote = p_numero_lote;
SELECT 'lote aprobado y liberado' AS mensaje;
ELSE
SELECT 'lote no cumple calidad, no se puede liberar' AS mensaje;
END IF;
END //

CALL AprobarLiberacionLote('LOTE-2024-001');

-- 5. ProgramarMantenimientoEquipos:
-- Programa mantenimiento para equipos de laboratorio y producción.

CREATE PROCEDURE ProgramarMantenimientoEquipos(
IN p_numero_serie VARCHAR(60),
IN p_fecha_programada DATE,
IN p_descripcion TEXT,
IN p_tecnico VARCHAR(100)
)
BEGIN
INSERT INTO mantenimiento_equipo(numero_serie, fecha_programada, descripcion, tecnico, resultado)
VALUES(p_numero_serie, p_fecha_programada, p_descripcion, p_tecnico, 'Pendiente');
SELECT 'mantenimiento programado' AS mensaje;
END //

CALL ProgramarMantenimientoEquipos('EQ-001', '2024-05-01', 'revision general', 'Diego Vargas');

