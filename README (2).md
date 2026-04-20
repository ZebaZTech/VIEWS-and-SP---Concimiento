#  PharmaSys — Sistema de Gestión para Industria Farmacéutica

##  Descripción General

**PharmaSys** es un sistema de base de datos diseñado para administrar las operaciones de un laboratorio farmacéutico. Permite gestionar principios activos, medicamentos, materias primas, lotes de producción y control de calidad, garantizando trazabilidad y cumplimiento normativo en cada etapa del proceso.

Este módulo implementa **Vistas (Views)** y **Procedimientos Almacenados (Stored Procedures)** sobre la base de datos `farmacia`, optimizando la consulta y manipulación de información crítica del laboratorio.

---

##  Estructura del Repositorio

```
VIEWS-and-SP---Concimiento/
├── CONOCIMIENTOS.sql     -- Vistas y Procedimientos Almacenados implementados
└── README.md             -- Documentación del proyecto
```

> **Nota:** La base de datos `farmacia` fue diseñada en el módulo previo. Este repositorio contiene únicamente los objetos de base de datos correspondientes a este módulo.

---

##  Instrucciones de Uso

### Requisitos previos

- MySQL o MariaDB instalado
- HeidiSQL u otro cliente SQL (DBeaver, MySQL Workbench, etc.)
- Base de datos `farmacia` creada y poblada previamente

### Pasos para ejecutar

1. Abrir HeidiSQL y conectarse al servidor local
2. Asegurarse de tener la base de datos `farmacia` activa:
   ```sql
   USE farmacia;
   ```
3. Cargar y ejecutar el archivo `CONOCIMIENTOS.sql`
4. Verificar las vistas creadas:
   ```sql
   SHOW FULL TABLES IN farmacia WHERE TABLE_TYPE = 'VIEW';
   ```
5. Verificar los procedimientos almacenados:
   ```sql
   SHOW PROCEDURE STATUS WHERE Db = 'farmacia';
   ```

---

##  Módulos Implementados

###  Vistas (Views)

| Vista | Descripción |
|-------|-------------|
| `V_LotesEnProduccion` | Muestra todos los lotes con estado `En proceso` |
| `V_Inventario_Materias_Primas` | Inventario de materias primas ordenado por fecha de caducidad |
| `V_ResultadosControlCalidad` | Resultados de control de calidad por lote y tipo de prueba |
| `V_TrazabilidadMedicamento` | Trazabilidad completa de un medicamento desde producción |
| `V_EstudioEstabilidadActivos` | Estado de estudios de estabilidad por medicamento |

---

###  Procedimientos Almacenados (Stored Procedures)

| Procedimiento | Descripción | Parámetros |
|---------------|-------------|------------|
| `CrearLoteProduccion` | Verifica stock de materia prima y activa el lote | `numero_lote`, `ID_materia`, `cantidad` |
| `RegistrarControlCalidad` | Registra pruebas de calidad asociadas a un lote | `numero_lote`, `ID_tipo_prueba`, `resultados`, `ID_analista`, `conformidad` |
| `GestionarEstabilidad` | Crea un estudio de estabilidad para un medicamento | `ID_medicamento`, `temperatura`, `humedad`, `fecha_inicio`, `fecha_fin` |
| `AprobarLiberacionLote` | Libera un lote si pasó el control de calidad | `numero_lote` |
| `ProgramarMantenimientoEquipos` | Programa mantenimiento para un equipo del laboratorio | `numero_serie`, `fecha_programada`, `descripcion`, `tecnico` |

---

##  Detalle de Cada Objeto

### Vistas

#### 1. V_LotesEnProduccion
Filtra los lotes cuyo `estado_lote = 'En proceso'`, permitiendo monitorear la producción activa.

```sql
SELECT * FROM V_LotesEnProduccion;
```

#### 2. V_Inventario_Materias_Primas
Muestra el inventario completo de materias primas incluyendo los días restantes para su vencimiento.

```sql
SELECT * FROM V_Inventario_Materias_Primas;
```

#### 3. V_ResultadosControlCalidad
Combina las tablas `control_calidad`, `tipo_prueba` y `empleado` para mostrar qué analista realizó cada prueba y su resultado.

```sql
SELECT * FROM V_ResultadosControlCalidad;
```

#### 4. V_TrazabilidadMedicamento
Muestra el historial completo de operaciones de cada lote: fabricación, análisis, liberación y almacenamiento.

```sql
SELECT * FROM V_TrazabilidadMedicamento;
```

#### 5. V_EstudioEstabilidadActivos
Presenta los estudios de estabilidad activos con los días restantes de cada estudio.

```sql
SELECT * FROM V_EstudioEstabilidadActivos;
```

---

### Procedimientos Almacenados

#### 1. CrearLoteProduccion
Verifica que haya stock suficiente de la materia prima antes de activar el lote. Si hay stock, descuenta la cantidad usada.

```sql
-- Crear lote usando 22.5 kg de materia prima ID 1
CALL CrearLoteProduccion('LOTE-2024-002', 1, 22.500);
```

#### 2. RegistrarControlCalidad
Inserta un registro de análisis de calidad para el lote indicado con fecha actual automática.

```sql
-- Registrar prueba física (ID 1) con resultado conforme (1) por analista ID 2
CALL RegistrarControlCalidad('LOTE-2024-001', 1, 'todo bien', 2, 1);
```

#### 3. GestionarEstabilidad
Crea un nuevo estudio de estabilidad con temperatura, humedad y fechas de vigencia del estudio.

```sql
-- Estudio para medicamento 1 a 25°C y 60% humedad
CALL GestionarEstabilidad(1, 25.00, 60.00, '2024-01-01', '2025-01-01');
```

#### 4. AprobarLiberacionLote
Verifica el resultado de conformidad del control de calidad. Si es conforme (`1`), cambia el estado del lote a `Liberado`.

```sql
-- Intentar liberar el lote LOTE-2024-001
CALL AprobarLiberacionLote('LOTE-2024-001');
```

#### 5. ProgramarMantenimientoEquipos
Programa una tarea de mantenimiento para un equipo registrado en el sistema, asignando un técnico responsable.

```sql
-- Programar revisión del equipo EQ-001
CALL ProgramarMantenimientoEquipos('EQ-001', '2024-05-01', 'revision general', 'Diego Vargas');
```

---

##  Autor

| Campo | Detalle |
|-------|---------|
| **Estudiante** | ZebaZTech |
| **Curso** | Base de Datos Avanzado |
| **Sistema** | Sistema 12 — PharmaSys |
| **Fecha** | Abril 2026 |
