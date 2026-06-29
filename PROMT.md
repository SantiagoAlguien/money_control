# PROYECTO: GESTOR FINANCIERO PERSONAL OFFLINE

Actúa como un Arquitecto Senior especializado en Flutter, Android Nativo, SQLite y Clean Architecture.

## OBJETIVO

Construir una aplicación Android Flutter completamente OFFLINE para registrar automáticamente movimientos financieros personales a partir de notificaciones bancarias.

La aplicación será únicamente para uso personal.

NO utilizar:

- Firebase
- APIs externas
- Backend
- Servicios en la nube
- Sincronización remota

Toda la información debe permanecer en el dispositivo.

---

# MVP V1

La primera versión debe validar que una transferencia proveniente de Caja Social pueda ser detectada, procesada, clasificada y almacenada correctamente.

---

# TECNOLOGÍAS

Flutter Stable
Dart
SQLite
Riverpod
Material Design 3
Go Router

Android Nativo:

NotificationListenerService
MethodChannel o EventChannel

---

# ARQUITECTURA

Aplicar Clean Architecture:

lib/

core/
features/

features/
 transactions/

data/
domain/
presentation/

repository/
datasource/
models/
entities/
usecases/

---

# CAPTURA DE NOTIFICACIONES

Implementar NotificationListenerService Android.

La aplicación debe solicitar al usuario habilitar acceso a notificaciones.

Capturar:

- packageName
- title
- text
- timestamp

Guardar temporalmente para análisis.

---

# PRIMER CASO DE USO

Prueba inicial:

Simular la recepción de una notificación de Caja Social.

Texto de ejemplo:

TX EXITOSA en *8128.
El 2026.05.30 a las 08:00
TRANSFERENCIA por $100.000
Banco Caja Social.

El sistema debe convertirla automáticamente en:

{
  "bank": "Caja Social",
  "amount": 100000,
  "type": "EGRESO",
  "category": "TRANSFERENCIA",
  "date": "2026-05-30"
}

Y almacenarla en SQLite.

---

# MODELO DE DATOS

Transaction

- id
- bank
- amount
- type
- category
- transactionDate
- originalText
- source
- createdAt

Enums:

MovementType

- income
- expense

Category

- payroll
- transfer
- purchase
- withdrawal
- performance
- other

---

# REGLAS DE CLASIFICACIÓN

Si contiene:

TRANSFERENCIA

=> Categoria: transfer
=> Tipo: expense

NOMINA

=> Categoria: payroll
=> Tipo: income

RENDIMIENTO

=> Categoria: performance
=> Tipo: income

COMPRA

=> Categoria: purchase
=> Tipo: expense

RETIRO

=> Categoria: withdrawal
=> Tipo: expense

---

# BASE DE DATOS

SQLite

Tabla:

transactions

Campos:

id
bank
amount
type
category
transactionDate
originalText
source
createdAt

Crear migraciones iniciales.

---

# INTERFAZ MVP

Pantalla Dashboard.

Mostrar:

Saldo Actual

Ingresos del Mes

Gastos del Mes

Cantidad de movimientos

Últimos movimientos

Diseño:

Material Design 3
Dark Mode por defecto

---

# FLUJO DE PRUEBA

Agregar botón:

"Simular Transferencia Caja Social"

Al presionarlo:

1. Generar notificación simulada.
2. Ejecutar parser.
3. Crear Transaction.
4. Guardar en SQLite.
5. Mostrar en historial.

Esto permitirá validar toda la arquitectura antes de depender de notificaciones reales.

---

# HISTORIAL

Pantalla Movimientos.

Mostrar:

Fecha
Banco
Categoría
Monto
Tipo

Orden descendente.

---

# TESTS OBLIGATORIOS

Generar pruebas unitarias.

Caso 1:

Entrada:

TX EXITOSA en *8128.
El 2026.05.30 a las 08:00
TRANSFERENCIA por $100.000
Banco Caja Social.

Resultado esperado:

bank == Caja Social
amount == 100000
type == expense
category == transfer

Caso 2:

ABONO NOMINA por $1.500.000

Resultado:

type == income
category == payroll

Caso 3:

Recibiste rendimientos por $4.532

Resultado:

type == income
category == performance

Ejecutar:

flutter test

Todos los tests deben pasar.

---

# ENTREGABLE

Generar proyecto Flutter completo.

Generar:

- SQLite
- Repositories
- UseCases
- Models
- NotificationListenerService
- Riverpod
- Navegación
- Dashboard
- Historial
- Parser
- Tests

El proyecto debe abrir correctamente en VS Code y ejecutar:

flutter pub get
flutter run

sin errores.