# Sistema de Reporte de Incidencias Municipalidad de Coquimbo (RIMC)

Este proyecto es un mockup funcional para la gestión y reporte de incidencias municipales. Incluye un módulo frontend interactivo, un backend desarrollado en **NestJS** con **Prisma ORM** y una base de datos **PostgreSQL** alojada en un contenedor Docker.

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener instaladas las siguientes herramientas en tu sistema:

1. **Docker Desktop**: [Descargar Docker](https://www.docker.com/products/docker-desktop/) *(debe estar abierto y corriendo)*
2. **Node.js (LTS)**: [Descargar Node.js](https://nodejs.org/)
3. **pnpm**: Instálalo globalmente abriendo la consola y ejecutando:
```bash
npm install -g pnpm
```


## Pasos Para Inicializar el Proyecto

### Paso 1 - Levantar Base de Datos
Con Docker abierto en la carpeta DB ejecutar.
```bash
docker compose up -d
```

### Paso 2 - Instalacion de dependencias Backend
En la carpeta Backend ejecutar laos siguientes codigoas para instalar dependencias.
```bash
pnpm install
```
En caso de que se ignoren scripts de construccion ejecutar lo siguiente y volver a intentar.
```bash
pnpm approve-builds
pnpm install
```
Crear archivo .env
```bash
Set-Content -Path .env -Value 'DATABASE_URL="postgresql://muni_user:muni_password123@localhost:5433/coquimbo_incidencias?schema=public"'
```

### Paso 3 - Generacion de Prisma
Generar el cliente de Prisma
```bash
pnpm exec prisma generate
```

### Paso 4 - Iniciar Backend
```bash
pnpm run start:dev
```


## ESTRUCTURA DEL PROYECTO3
```
Sistemas-De-Informacion/
├── DB/                      # Configuración de Docker y script SQL inicial
├── backend/                 # API REST desarrollada en NestJS + Prisma ORM
│   ├── src/                 # Controladores, servicios y módulos
│   ├── prisma/              # Esquema de base de datos
│   └── .env                 # Variables de entorno
├── index.html               # Frontend - Interfaz pública
├── app.js                   # Lógica del cliente y consumo de la API REST
└── README.md                # Guía de instalación
```


## CREDENCIALES
```
Host: localhost
Port: 5433
User: muni_user
Password: muni_password123
Database: coquimbo_incidencias
```